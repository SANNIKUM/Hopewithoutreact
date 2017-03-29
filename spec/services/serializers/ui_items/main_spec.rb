require 'rails_helper'

describe Serializers::UiItems::Main do

  def subject(*args)
    Serializers::UiItems::Main.run(*args)#.map(&:deep_symbolize_keys!)
  end

  def fc(*args)
    FactoryGirl.create(*args)
  end

  let!(:ui_item_1) { fc(:ui_item, name: 'ui_item_1')}

  # leave thorough testing to the other specs in this folder
  it 'works' do
    result = subject([ui_item_1.id], [])
    expect(result[0]).to eq({
      id: ui_item_1.id,
      name: 'ui_item_1',
      form_field_id: nil,
      is_form: false,
      is_form_field: false,
      ui_item_type_id: nil,
      expected_form_field_ids: [],
      assignments: {}
    })
  end

end
