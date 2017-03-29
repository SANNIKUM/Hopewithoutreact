module Serializers::UiItems::FormFieldProperties::Query

  def self.run(ui_item_ids, asg_ids)
    ui_item_ids_string = "(#{ui_item_ids.join(",")})"
    asg_ids_arr = asg_ids.empty? ? [0] : asg_ids
    asg_ids_string = "(#{asg_ids_arr.join(",")})"
    query_string = <<-SQL

      WITH ui_items2 AS (
        SELECT
          id,
          form_field_id
        FROM ui_items
        WHERE id IN #{ui_item_ids_string}
      ),

      #{self.helper('input_type')},

      #{self.helper('if_none_assigned_then_base_off')},

      #{self.helper('include_all_if_none_assigned')}


      SELECT
        ui_items2.id as ui_item_id,
        form_fields.id as form_field_id,
        form_fields.name as form_field_name,
        form_fields.label as form_field_label,
        form_fields.field_type as form_field_field_type,
        form_fields.assignment_type_id as form_field_assignment_type_id,
        form_value_options.id as form_value_option_id,
        form_value_options.value as form_value_option_value,
        form_value_options.label as form_value_option_label,
        form_fields_value_options.order as form_field_value_option_order,
        assignments.id as assignment_id,
        assignments.name as assignment_name,
        assignments.label as assignment_label,
        assignment_types.id as assignment_type_id,
        assignment_types.name as assignment_type_name,
        assignment_types.label as assignment_type_label,
        apts.name as assignment_property_type_name,
        aps.value as assignment_property_value

        ,
        if_none_assigned_then_base_off_property_relations.value as zzzz_value,
        semitrivial_assignments.id as semitrivial_assignments_id


      FROM ui_items2
      JOIN form_fields
        ON ui_items2.form_field_id = form_fields.id

      LEFT JOIN form_fields_value_options
        ON form_fields.field_type = 'option'
        AND form_fields.id = form_fields_value_options.form_field_id
      LEFT JOIN form_value_options
        ON form_fields_value_options.form_value_option_id = form_value_options.id

      LEFT JOIN input_type_property_relations
        ON ui_items2.id = input_type_property_relations.parent_id

      LEFT JOIN include_all_if_none_assigned_property_relations
        ON ui_items2.id = include_all_if_none_assigned_property_relations.parent_id

      LEFT JOIN if_none_assigned_then_base_off_property_relations
        ON ui_items2.id = if_none_assigned_then_base_off_property_relations.parent_id

      LEFT JOIN assignments nontrivial_assignments
        ON form_fields.field_type = 'assignment'
        AND (
          input_type_property_relations.value IS NULL
          OR
          input_type_property_relations.value != 'string'
        )

        AND form_fields.assignment_type_id = nontrivial_assignments.assignment_type_id
        AND nontrivial_assignments.id IN #{asg_ids_string}

      LEFT JOIN assignments semitrivial_assignments
        ON form_fields.field_type = 'assignment'
        AND (
          input_type_property_relations.value IS NULL
          OR
          input_type_property_relations.value != 'string'
        )
        AND nontrivial_assignments.id IS NULL
        AND semitrivial_assignments.id IN (
          WITH base_asgs AS (
            SELECT staas.id as id
            FROM assignments staas
            JOIN assignment_types staas_ats
              ON staas.assignment_type_id = staas_ats.id
            WHERE staas.id IN #{asg_ids_string}
            AND staas_ats.name = if_none_assigned_then_base_off_property_relations.value
          ),
          other_asgs AS (
            SELECT id
            FROM assignments
            WHERE assignments.assignment_type_id = form_fields.assignment_type_id
          )
          SELECT other_asgs.id as id
          FROM other_asgs
          JOIN assignment_relations ars
            ON ( other_asgs.id = ars.assignment_1_id
                OR other_asgs.id = ars.assignment_2_id )
          JOIN base_asgs
            ON ( base_asgs.id = ars.assignment_1_id
                OR base_asgs.id = ars.assignment_2_id)
        )

      LEFT JOIN assignments trivial_assignments
        ON form_fields.field_type = 'assignment'
        AND (
          input_type_property_relations.value IS NULL
          OR
          input_type_property_relations.value != 'string'
        )
        AND nontrivial_assignments.id IS NULL
        AND semitrivial_assignments.id IS NULL
        AND (
              include_all_if_none_assigned_property_relations.value IS NULL
              OR
              include_all_if_none_assigned_property_relations.value = 'true'
        )
        AND form_fields.assignment_type_id = trivial_assignments.assignment_type_id

      LEFT JOIN assignments
        ON nontrivial_assignments.id = assignments.id
        OR semitrivial_assignments.id = assignments.id
        OR trivial_assignments.id = assignments.id

      LEFT JOIN assignment_types
        ON form_fields.assignment_type_id = assignment_types.id

      LEFT JOIN assignment_properties aps
        ON assignments.id = aps.assignment_id

      LEFT JOIN assignment_property_types apts
        ON aps.assignment_property_type_id = apts.id

    SQL
    result = ActiveRecord::Base.connection.execute(query_string).map(&:deep_symbolize_keys)
    result
  end

  def self.helper(ui_item_property_type_name)
    <<-SQL
      #{ui_item_property_type_name}_properties AS (
        SELECT
          ui_item_properties.id as id,
          ui_item_properties.value as value
        FROM ui_item_properties
        JOIN ui_item_property_types
          ON ui_item_properties.ui_item_property_type_id = ui_item_property_types.id
        WHERE ui_item_property_types.name = \'#{ui_item_property_type_name.camelize(:lower)}\'
      ),

      #{ui_item_property_type_name}_property_relations AS (
        SELECT
          ui_item_property_relations.parent_id as parent_id,
          #{ui_item_property_type_name}_properties.value as value
        FROM #{ui_item_property_type_name}_properties
        JOIN ui_item_property_relations
          ON #{ui_item_property_type_name}_properties.id = ui_item_property_relations.ui_item_property_id
        WHERE ui_item_property_relations.parent_type = 'ui_item'
      )
    SQL
  end

end
