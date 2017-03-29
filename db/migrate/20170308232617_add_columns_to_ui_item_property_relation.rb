class AddColumnsToUiItemPropertyRelation < ActiveRecord::Migration[5.0]
  def change
    add_column :ui_item_property_relations, :parent_id, :integer, index: true
    add_column :ui_item_property_relations, :parent_type, :string, index: true
  end
end
