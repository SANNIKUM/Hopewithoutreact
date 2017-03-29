namespace :update_ui_item_property_relations do

  task :run => :environment do
    ::UiItemPropertyRelation.all.each do |uipr|
      uipt.update_attributes(parent_id: uipr.ui_item_id, parent_type: 'ui_item')
    end

    ::UiItemPropertyPropertyRelation.all.each do |uippr|
      # parent_id. child_id
      ::UiItemPropertyRelation.create(
        parent_id: uippr.parent_id,
        parent_type: 'ui_item_property_relation',
        ui_item_property_id: uippr.ui_item_property_id
      )
    end
  end

end
