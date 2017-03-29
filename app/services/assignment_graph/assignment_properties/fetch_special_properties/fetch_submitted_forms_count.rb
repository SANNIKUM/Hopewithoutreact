module AssignmentGraph::AssignmentProperties::FetchSpecialProperties::FetchSubmittedFormsCount

  def self.run(ats, asgs, config_hash)
    caids = config_hash[:context_assignment_ids]
    cans = Assignment.where(id: caids).map(&:name)
    asg_names = cans.concat(['survey'])
    sf_ids = FilteredSubmittedFormIds.run(asg_names)
    sf_ids2 = sf_ids.any? ? sf_ids : [-1]


    query_string = self.query_string(ats, asgs, sf_ids2)
    ActiveRecord::Base.connection.execute(query_string)
  end

  private

  def self.query_string(ats, asgs, sf_ids)
    at_names_string = ats.map { |name| "'" + name + "'" }.join(', ')
    asg_ids_string = asgs.map { |asg| asg[:id] }.join(', ')

    sf_ids_string = "(#{sf_ids.join(',')})"

    <<-SQL

    WITH all_surveys_with_client_ids AS (
      SELECT fvs.string_value as client_id,
             fvs.submitted_form_id as sf_id
      FROM form_values fvs
      JOIN form_fields ffs
        ON ffs.name = 'clientId' AND ffs.id = fvs.form_field_id
      WHERE fvs.submitted_form_id IN #{sf_ids_string}
    ),

    all_deleted_surveys AS (
      SELECT fvs.submitted_form_id as sf_id
        FROM form_values fvs
        JOIN form_fields ffs
          ON fvs.form_field_id = ffs.id
       WHERE ffs.name = 'isSoftDeleted'
         AND fvs.boolean_value = 'true'
    ),

    all_deleted_surveys_with_client_ids AS (
      SELECT fvs.string_value as client_id,
             fvs.submitted_form_id as sf_id
      FROM form_values fvs
      JOIN form_fields ffs
        ON ffs.name = 'clientId' AND ffs.id = fvs.form_field_id
      WHERE fvs.submitted_form_id IN (SELECT sf_id FROM all_deleted_surveys)
    ),

    surveys AS (
      SELECT all_surveys_with_client_ids.*
      FROM all_surveys_with_client_ids
      LEFT OUTER JOIN all_deleted_surveys_with_client_ids
      ON all_surveys_with_client_ids.sf_id = all_deleted_surveys_with_client_ids.sf_id
      WHERE all_deleted_surveys_with_client_ids.sf_id IS NULL
    )

    SELECT
      asgs.id as assignment_id,
      COUNT(DISTINCT surveys.client_id) as submitted_forms_count

    FROM assignments asgs
    LEFT JOIN assignment_types ats
      ON asgs.assignment_type_id = ats.id
    LEFT JOIN form_value_options fvos
      ON asgs.id = fvos.assignment_id
    LEFT JOIN form_values fvs
      ON fvos.id = fvs.form_value_option_id
    LEFT JOIN surveys
      ON surveys.sf_id = fvs.submitted_form_id

    WHERE asgs.id IN (#{asg_ids_string})
      AND ats.name IN (#{at_names_string})
    GROUP BY asgs.id
    SQL

  end
end
