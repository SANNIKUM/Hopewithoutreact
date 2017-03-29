require 'rails_helper'

describe Serializers::UiItems::ExpectedFormFields::Main do

  def subject(args)
    Serializers::UiItems::ExpectedFormFields::Main.run(args)[:ui_items]
  end

  def fc(*args)
    FactoryGirl.create(*args)
  end

  let!(:asg_1) { fc(:assignment) }
  let!(:asg_2) { fc(:assignment) }
  let!(:ff_1) { fc(:form_field) }
  let!(:ff_2) { fc(:form_field) }
  let!(:ef_1) { fc(:expected_field, assignment_id: asg_1.id, form_field_id: ff_1.id)}
  let!(:ef_2) { fc(:expected_field, assignment_id: asg_2.id, form_field_id: ff_2.id)}

  let!(:ui_item_1) { {id: 1, assignments: [asg_1.id, asg_2.id]} }
  let!(:ui_item_2) { {id: 2, assignments: [asg_1.id]} }
  let!(:ui_item_3) { {id: 3, assignments: []} }

  it 'fetches all expected_fields and append to ui_items' do
    result = subject({ui_items: [ui_item_1, ui_item_2, ui_item_3]})
    expect(result).to contain_exactly(
      ui_item_1.merge({expected_form_field_ids: [ff_1.id, ff_2.id]}),
      ui_item_2.merge({expected_form_field_ids: [ff_1.id]}),
      ui_item_3.merge({expected_form_field_ids: []})
    )
  end
end
