require 'rails_helper'

describe Serializers::UiItems::Assignments::Main do

  def subject(args)
    Serializers::UiItems::Assignments::Main.run(args)[:ui_items]
  end

  def fc(*args)
    FactoryGirl.create(*args)
  end

  let!(:at_1) { fc(:assignment_type) }
  let!(:at_2) { fc(:assignment_type) }

  let!(:asg_1) { fc(:assignment, assignment_type: at_1) }
  let!(:asg_2) { fc(:assignment, assignment_type: at_2) }
  let!(:ff_1) { fc(:form_field, assignment_type: at_1) }
  let!(:ff_2) { fc(:form_field, assignment_type: at_2) }

  let!(:ui_item_1) { {id: 1, assignments: [asg_1.id, asg_2.id]} }
  let!(:ui_item_2) { {id: 2, assignments: [asg_1.id]} }

  it 'works' do
    result = subject({ui_items: [ui_item_1, ui_item_2]})
    expect(result).to contain_exactly(
      ui_item_1.merge({assignments: Hash[ff_1.id, asg_1.id, ff_2.id, asg_2.id] }),
      ui_item_2.merge({assignments: Hash[ff_1.id, asg_1.id]}),
    )
  end
end
