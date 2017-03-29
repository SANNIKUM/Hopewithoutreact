require 'rails_helper'

describe Serializers::UiItems::FormFieldProperties::Main do

  def subject(args)
    Serializers::UiItems::FormFieldProperties::Main.run(args)[:ui_items]
  end

  def fc(*args)
    FactoryGirl.create(*args)
  end

  let!(:ff_1) { fc(:form_field, name: 'ff_1', label: 'ff_1_label', field_type: 'option') }
  let!(:form_value_option_1) { fc(:form_value_option, value: 'value1', label: 'label1') }
  let!(:form_field_value_option) { fc(:form_field_value_option, form_field: ff_1, form_value_option: form_value_option_1) }

  let!(:ui_item_1) { fc(:ui_item, form_field_id: ff_1.id).attributes.deep_symbolize_keys }

  it 'works for form_value_options' do
    result = subject({ui_items: [ui_item_1], asg_ids: []})
    expect(result[0]).to eq(
      ui_item_1.merge({
        is_form_field: true,
        form_field: {
          id: ff_1.id,
          name: 'ff_1',
          label: 'ff_1_label',
          field_type: 'option',
          assignment_type_id: nil,
          form_value_options: [
            {
              id: form_value_option_1.id,
              label: 'label1',
              value: 'value1',
              order: 0
            }
          ]
        }
      })
    )
  end


  let!(:at_1) { fc(:assignment_type) }
  let!(:asg_1) { fc(:assignment, assignment_type: at_1) }
  let!(:apt1) { fc(:assignment_property_type, name: 'apt1') }
  let!(:ap1) { fc(:assignment_property, assignment_property_type: apt1, value: 'ap1_value', assignment: asg_1)}
  let!(:asg_2) { fc(:assignment, assignment_type: at_1) }

  let!(:ff_2) { fc(:form_field,
                    name: 'ff_2',
                    label: 'ff_2_label',
                    field_type: 'assignment',
                    assignment_type_id: at_1.id)
  }
  let!(:form_value_option_2) { fc(:form_value_option, label: 'fvo_2', value: nil, assignment_id: asg_1.id) }
  let!(:form_value_option_3) { fc(:form_value_option, label: 'fvo_3', value: nil, assignment_id: asg_2.id) }

  let!(:ui_item_2) { fc(:ui_item, form_field_id: ff_2.id).attributes.deep_symbolize_keys }

  context 'field_type = assignment' do

    it 'handles case where an assignment of relevant type is included in asg_ids' do
      result = subject({ui_items: [ui_item_2], asg_ids: [asg_1.id]})
      expect(result[0]).to eq(
        ui_item_2.merge({
          is_form_field: true,
          form_field: {
            id: ff_2.id,
            name: 'ff_2',
            label: 'ff_2_label',
            field_type: 'assignment',
            assignment_type_id: at_1.id,
            form_value_options: [
              {
                id: form_value_option_2.id,
                label: 'fvo_2',
                value: asg_1.id,
                assignment: {
                  id: asg_1.id,
                  name: asg_1.name,
                  label: asg_1.label,
                  assignment_type_id: at_1.id,
                  assignment_type: {
                    id: at_1.id,
                    name: at_1.name,
                    label: at_1.label
                  },
                  apt1: 'ap1_value',
                }
              }
            ]
          }
        })
      )
    end

    it 'handles cases where an assignment of relevant type is NOT included in asg_ids' do
      result = subject({ui_items: [ui_item_2], asg_ids: []})
      expect(result[0]).to eq(
        ui_item_2.merge({
          is_form_field: true,
          form_field: {
            id: ff_2.id,
            name: 'ff_2',
            label: 'ff_2_label',
            field_type: 'assignment',
            assignment_type_id: at_1.id,
            form_value_options: [
              {
                id: form_value_option_2.id,
                label: 'fvo_2',
                value: asg_1.id,
                assignment: {
                  id: asg_1.id,
                  name: asg_1.name,
                  label: asg_1.label,
                  assignment_type_id: at_1.id,
                  assignment_type: {
                    id: at_1.id,
                    name: at_1.name,
                    label: at_1.label
                  },
                  apt1: 'ap1_value',
                }
              },
              {
                id: form_value_option_3.id,
                label: 'fvo_3',
                value: asg_2.id,
                assignment: {
                  id: asg_2.id,
                  name: asg_2.name,
                  label: asg_2.label,
                  assignment_type_id: at_1.id,
                  assignment_type: {
                    id: at_1.id,
                    name: at_1.name,
                    label: at_1.label
                  },
                },
              },
            ]
          }
        })
      )
    end

    it 'handles cases where input_type = string' do
      uipt = fc(:ui_item_property_type, name: 'inputType')
      uip = fc(:ui_item_property, ui_item_property_type: uipt, value: 'string')
      uipr = fc(:ui_item_property_relation, parent_type: 'ui_item', parent_id: ui_item_2[:id], ui_item_property_id: uip.id)

      result = subject({ui_items: [ui_item_2], asg_ids: []})
      expect(result[0]).to eq(
        ui_item_2.merge({
          is_form_field: true,
          form_field: {
            id: ff_2.id,
            name: 'ff_2',
            label: 'ff_2_label',
            field_type: 'assignment',
            assignment_type_id: at_1.id,
            form_value_options: [],
          }
        })
      )
    end

    it 'handles case where include_all_if_none_assigned=false' do
      uipt = fc(:ui_item_property_type, name: 'includeAllIfNoneAssigned')
      uip = fc(:ui_item_property, ui_item_property_type: uipt, value: 'false')
      uipr = fc(:ui_item_property_relation, parent_type: 'ui_item', parent_id: ui_item_2[:id], ui_item_property_id: uip.id)

      result = subject({ui_items: [ui_item_2], asg_ids: []})
      expect(result[0]).to eq(
        ui_item_2.merge({
          is_form_field: true,
          form_field: {
            id: ff_2.id,
            name: 'ff_2',
            label: 'ff_2_label',
            field_type: 'assignment',
            assignment_type_id: at_1.id,
            form_value_options: [],
          }
        })
      )
    end


    it 'handles case where if_none_assigned_then_base_off is specified' do
      uipt = fc(:ui_item_property_type, name: 'ifNoneAssignedThenBaseOff')
      uip = fc(:ui_item_property, ui_item_property_type: uipt, value: 'countInstance')
      uipr = fc(:ui_item_property_relation, parent_type: 'ui_item', parent_id: ui_item_2[:id], ui_item_property_id: uip.id)

      cit = fc(:assignment_type, name: 'countInstance')
      ci = fc(:assignment, name: 'countInstance1', assignment_type_id: cit.id)

      ar = fc(:assignment_relation, assignment_1_id: asg_1.id, assignment_2_id: ci.id)

      result = subject({ui_items: [ui_item_2], asg_ids: [ci.id]})
      expect(result[0]).to eq(
        ui_item_2.merge({
          is_form_field: true,
          form_field: {
            id: ff_2.id,
            name: 'ff_2',
            label: 'ff_2_label',
            field_type: 'assignment',
            assignment_type_id: at_1.id,
            form_value_options: [
              {
                id: form_value_option_2.id,
                label: 'fvo_2',
                value: asg_1.id,
                assignment: {
                  id: asg_1.id,
                  name: asg_1.name,
                  label: asg_1.label,
                  assignment_type_id: at_1.id,
                  assignment_type: {
                    id: at_1.id,
                    name: at_1.name,
                    label: at_1.label
                  },
                  apt1: 'ap1_value',
                }
              },
            ],
          }
        })
      )
    end
  end
end
