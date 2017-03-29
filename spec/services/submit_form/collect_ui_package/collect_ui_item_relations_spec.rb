require 'rails_helper'

describe SubmitForm::CollectUiPackage::CollectUiItemRelations do

  let!(:ui_item_1) { FactoryGirl.create(:ui_item)}
  let!(:ui_item_2) { FactoryGirl.create(:ui_item)}
  let!(:ui_item_3) { FactoryGirl.create(:ui_item)}
  let!(:ui_item_4) { FactoryGirl.create(:ui_item)}
  let!(:ui_item_5) { FactoryGirl.create(:ui_item)}
  let!(:ui_item_relation_1) { FactoryGirl.create(:ui_item_relation, parent_ui_item_id: ui_item_1.id, child_ui_item_id: ui_item_2.id) }
  let!(:ui_item_relation_2) { FactoryGirl.create(:ui_item_relation, parent_ui_item_id: ui_item_2.id, child_ui_item_id: ui_item_3.id) }
  let!(:ui_item_relation_3) { FactoryGirl.create(:ui_item_relation, parent_ui_item_id: ui_item_3.id, child_ui_item_id: ui_item_5.id) }

  let!(:assignment_1) { FactoryGirl.create(:assignment) }
  let!(:assignment_2) { FactoryGirl.create(:assignment) }


  def subject
    SubmitForm::CollectUiPackage::CollectUiItemRelations.run([ui_item_1.id, ui_item_4.id], [assignment_2.id])
      .map{|x| x.deep_symbolize_keys!}.map{|x| x[:id]}
  end


  it 'collects all first level of ui_item_relations' do
    result = subject
    expect(result).to include(
      ui_item_relation_1.id,
    )
  end

  it 'collects second level of ui_item_relations' do
    result = subject
    expect(result).to include(
      ui_item_relation_2.id,
      ui_item_relation_3.id
    )
  end

end
