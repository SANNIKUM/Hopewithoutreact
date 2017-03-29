require 'rails_helper'

describe Serializers::UiItems::ComputedProperties::Main do

  def subject(args)
    Serializers::UiItems::ComputedProperties::Main.run(args)[:ui_items]
  end

  def fc(*args)
    FactoryGirl.create(*args)
  end

  let!(:ui_item_1) { {id: 1, uiItemType: 'someType'} }
  let!(:ui_item_2) { {id: 2, uiItemType: 'sequenceForm'} }

  it 'works' do
    result = subject({ui_items: [ui_item_1, ui_item_2]})
    expect(result).to contain_exactly(
      ui_item_1.merge({
        is_form: false,
      }),
      ui_item_2.merge({
        is_form: true
      })
    )
  end
end
