require 'rails_helper'

describe Serializers::UiItems::ExtrinsicProperties::Main do

  def subject(hash)
    Serializers::UiItems::ExtrinsicProperties::Main.run(hash)[:ui_items]
  end

  def fc(*args)
    FactoryGirl.create(*args)
  end

  let!(:form_field1) { fc(:form_field, name: 'form_field1', field_type: 'option') }

  let!(:ui_item_property_type1) { fc(:ui_item_property_type, name: 'uiItemPropertyType1', is_singleton: true) }
  let!(:ui_item_property1) { fc(:ui_item_property, ui_item_property_type: ui_item_property_type1, value: 'value1') }

  let!(:ui_item_property_type2) { fc(:ui_item_property_type, name: 'uiItemPropertyType2', is_singleton: false) }
  let!(:ui_item_property2) { fc(:ui_item_property, ui_item_property_type: ui_item_property_type2, value: 'value2') }
  let!(:ui_item_property2_2) { fc(:ui_item_property, ui_item_property_type: ui_item_property_type2, value: 'value2_2') }

  let!(:ui_item1) { fc(:ui_item, name: 'ui_item1', form_field: form_field1) }

  let!(:ui_item_property_relation1) do
    fc(
        :ui_item_property_relation,
        parent_id: ui_item1.id,
        ui_item_property: ui_item_property1,
        parent_type: 'ui_item'
    )
  end

  let!(:ui_item_property_relation2) do
    fc(
        :ui_item_property_relation,
        parent_id: ui_item1.id,
        ui_item_property: ui_item_property2,
        parent_type: 'ui_item'
    )
  end


    let!(:ui_item_property_relation2_2) do
      fc(
          :ui_item_property_relation,
          parent_id: ui_item1.id,
          ui_item_property: ui_item_property2_2,
          parent_type: 'ui_item'
      )
    end


  let!(:dependency_type) { fc(:ui_item_property_type, name: 'formFieldDependencies', is_singleton: false) }
  let!(:dependency_or) { fc(:ui_item_property, ui_item_property_type: dependency_type, value: '_OR') }
  let!(:dependency_or_value) { fc(:ui_item_property, ui_item_property_type: dependency_type, value: "2823")}

  let!(:ui_item_property_relation3) do
    fc(
        :ui_item_property_relation,
        parent_id: ui_item1.id,
        ui_item_property: dependency_or,
        parent_type: 'ui_item'
    )
  end

  let!(:ui_item_property_relation4) do
    fc(
      :ui_item_property_relation,
      parent_id: ui_item_property_relation3.id,
      ui_item_property: dependency_or_value,
      parent_type: 'ui_item_property_relation'
    )
  end

  let!(:form_field2) { fc(:form_field, name: 'form_field2', field_type: 'option') }
  let!(:ui_item2) { fc(:ui_item, name: 'ui_item2', form_field: form_field2) }

  let!(:ui_item_property_type3) { fc(:ui_item_property_type, name: 'uiItemPropertyType3', is_singleton: true) }
  let!(:ui_item_property3) { fc(:ui_item_property, ui_item_property_type: ui_item_property_type3, value: 'value3') }

  let!(:ui_item_property_type4) { fc(:ui_item_property_type, name: 'uiItemPropertyType4', is_singleton: false) }
  let!(:ui_item_property4) { fc(:ui_item_property, ui_item_property_type: ui_item_property_type4, value: 'value4') }

  let!(:ui_item_property_relation5) do
    fc(
        :ui_item_property_relation,
        parent_id: ui_item2.id,
        ui_item_property: ui_item_property3,
        parent_type: 'ui_item'
    )
  end

  let!(:ui_item_property_relation6) do
    fc(
        :ui_item_property_relation,
        parent_id: ui_item2.id,
        ui_item_property: ui_item_property4,
        parent_type: 'ui_item'
    )
  end

  it 'works for first and higher order properties' do
    result = subject({
      ui_items: [
        {id: ui_item1.id},
        {id: ui_item2.id}
      ]
    })
    expect(result).to eq(
      [
        {
          id: ui_item1.id,
          uiItemPropertyType1: 'value1',
          uiItemPropertyType2: ['value2', 'value2_2'],
          formFieldDependencies: [
            id: dependency_or.id,
            value: "_OR",
            formFieldDependencies: [
              {
                id: dependency_or_value.id,
                value: "2823"
              }
            ]
          ]
        },
        {
          id: ui_item2.id,
          uiItemPropertyType3: 'value3',
          uiItemPropertyType4: ['value4'],
        }
      ]
    )
  end
end
