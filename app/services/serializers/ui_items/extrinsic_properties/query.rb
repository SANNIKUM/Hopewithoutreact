module Serializers::UiItems::ExtrinsicProperties::Query

  def self.run(args)
    query_string = self.query_string(args)
    ActiveRecord::Base.connection.execute(query_string)
  end

  private

  def self.query_string(args)
    ui_item_ids = args[:ui_items].map{|x| x[:id]}
    ui_item_ids_string = "(#{ui_item_ids.join(",")})"
    <<-SQL
      WITH RECURSIVE recursive_ui_item_properties AS (

        SELECT
          uiprs.id as ui_item_property_relation_id,
          uiprs.ui_item_property_id as ui_item_property_id,
          uiprs.parent_id as parent_id,
          uiprs.parent_type as parent_type
        FROM
          ui_item_property_relations uiprs
        WHERE
            uiprs.parent_id IN #{ui_item_ids_string}
        AND uiprs.parent_type = 'ui_item'

        UNION

        SELECT
          uiprs2.id as ui_item_property_relation_id,
          uiprs2.ui_item_property_id as ui_item_property_id,
          uiprs2.parent_id as parent_id,
          uiprs2.parent_type as parent_type

        FROM
          recursive_ui_item_properties
        JOIN ui_item_property_relations uiprs2
          ON recursive_ui_item_properties.ui_item_property_relation_id = uiprs2.parent_id
        WHERE uiprs2.parent_type = 'ui_item_property_relation'
      )

      SELECT
        recursive_ui_item_properties.parent_id as ui_item_property_parent_id,
        recursive_ui_item_properties.parent_type as ui_item_property_parent_type,
        recursive_ui_item_properties.ui_item_property_id as ui_item_property_child_id,
        recursive_ui_item_properties.ui_item_property_relation_id as ui_item_property_relation_id,
        ui_item_property_types.is_singleton as is_singleton,
        ui_item_property_types.name as ui_item_property_type_name,
        ui_item_properties.value as ui_item_property_value,
        ui_item_properties.form_field_id as ui_item_property_form_field_id

      FROM recursive_ui_item_properties
      JOIN ui_item_properties
        ON recursive_ui_item_properties.ui_item_property_id = ui_item_properties.id
      JOIN ui_item_property_types
        ON ui_item_properties.ui_item_property_type_id = ui_item_property_types.id
    SQL
  end
end
