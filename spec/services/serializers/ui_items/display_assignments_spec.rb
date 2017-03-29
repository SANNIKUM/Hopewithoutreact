require 'rails_helper'

describe Serializers::UiItems::DisplayAssignments::Main do

  def subject(args)
    Serializers::UiItems::DisplayAssignments::Main.run(args)[:ui_items]
  end

  def fc(*args)
    FactoryGirl.create(*args)
  end

  let!(:at1) { fc(:assignment_type, name: 'at1', label: 'at1-label') }
  let!(:asg1) { fc(:assignment, assignment_type: at1, name: 'asg1', label: 'asg1-label') }

  let!(:ui_item_1) { {id: 1, uiItemType: 'assignmentDisplay', assignmentType: 'at1'} }

  it 'works' do
    result = subject({ui_items: [ui_item_1], asg_ids: [asg1.id]})
    expect(result).to contain_exactly(
      ui_item_1.merge({
        assignment: {
          id: asg1.id,
          name: 'asg1',
          label: 'asg1-label',
          assignment_type_id: at1.id,
          assignment_type: {
            id: at1.id,
            name: 'at1',
            label: 'at1-label'
          }
        }
      })
    )
  end
end
