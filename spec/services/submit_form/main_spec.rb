require 'rails_helper'

describe SubmitForm::Main do

  def subject(*args) SubmitForm::Main.run(*args).deep_symbolize_keys! end
  def fc(*args) FactoryGirl.create(*args) end

  let!(:at)  { fc(:assignment_type, name: 'at1') }
  let!(:ff)  { fc(:form_field, field_type: 'assignment', assignment_type_id: at.id) }
  let!(:asg) { fc(:assignment, name: 'asg1', assignment_type: at) }
  let!(:ui)  { fc(:ui_item) }
  let!(:as) { fc(:access_set, ui_item_id: ui.id) }
  let!(:asr)  { fc(:access_set_relation, access_set_id: as.id, assignment_id: asg.id) }

  let!(:data) do
    {
      request_id: 1,
      form_fields: [
        {
          form_field_id: ff.id,
          input_type: 'id',
          field_type: 'assignment',
          value: asg.id,
        }
      ]
    }
  end

  it 'works' do
    result = subject(data)
    expect(result).to eq({
      ui_items:  [{:id=>1, :name=>nil, :ui_item_type_id=>nil, :form_field_id=>nil, :expected_form_field_ids=>[], :assignments=>{}, :is_form_field=>false, :is_form=>false}],
      ui_item_relations: []
    })
  end
end
