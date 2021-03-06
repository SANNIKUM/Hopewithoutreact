module AssignmentGraph::AssignmentProperties::FetchSpecialProperties::FetchUserCheckedIn

  def self.run(ats, asgs)
    query = self.generate_query(ats, asgs)
    ActiveRecord::Base.connection.execute(query)
  end

  private

  def self.generate_query(ats, asgs)
    at_names = ats.map { |name| "'" + name + "'" }.join(', ')
    asg_ids = asgs.map { |asg| asg[:id] }.join(', ')

    <<-SQL
      WITH table0 AS (
        SELECT asgs.id AS asg_id
          FROM assignments AS asgs
          JOIN assignment_types AS ats
            ON asgs.assignment_type_id = ats.id
         WHERE ats.name IN (#{at_names})
           AND asgs.id IN (#{asg_ids})
      ),

      table1 AS (
        SELECT
          fvos.id as form_value_option_id,
          table0.asg_id as assignment_id
        FROM table0
        JOIN form_value_options fvos
          ON table0.asg_id = fvos.assignment_id
      ),

      table2 AS (
        SELECT
          fvs.submitted_form_id as submitted_form_id,
          table1.assignment_id as assignment_id
        FROM table1
        JOIN form_values fvs
          ON table1.form_value_option_id = fvs.form_value_option_id
      ),
      /* ^ submitted_form_ids submitted by this user ^ */

      table3 AS (
        SELECT fvos.id as form_value_option_id,
               asgs.name as form_type_category_name
        FROM form_value_options fvos
        JOIN assignments asgs
          ON fvos.assignment_id = asgs.id
        JOIN assignment_types ats
          ON asgs.assignment_type_id = ats.id
        WHERE ats.name = 'formTypeCategory'
          AND (    asgs.name = 'checkIn'
                OR asgs.name = 'checkOut'
          )
      ),

      table4 AS (
        SELECT fvs.submitted_form_id as submitted_form_id,
               table3.form_type_category_name as form_type_category_name,
               table2.assignment_id as assignment_id
        FROM table2
        JOIN form_values fvs
          ON table2.submitted_form_id = fvs.submitted_form_id
        JOIN table3
          ON fvs.form_value_option_id = table3.form_value_option_id
      ),









      table1 AS (
        SELECT table0.asg_id as assignment_id,
               fvs.submitted_form_id as submitted_form_id
          FROM table0
          JOIN form_value_options fvos
            ON table0.asg_id = fvos.assignment_id
          JOIN form_values fvs
            ON fvos.id = fvs.form_value_option_id
      ),

      table2 AS (
        SELECT table1.assignment_id AS assignment_id,
               table1.submitted_form_id AS submitted_form_id
          FROM form_values fvs
          JOIN table1
            ON table1.submitted_form_id = fvs.submitted_form_id
          JOIN form_fields ffs
            ON fvs.form_field_id = ffs.id
         WHERE ffs.name = 'submittedAt'
         ORDER BY fvs.datetime_value DESC
         LIMIT 1
      )

      SELECT
        table2.assignment_id as assignment_id,
        fvs1.string_value as latitude,
        fvs2.string_value as longitude
      FROM table2
      JOIN form_values fvs1
        ON table2.submitted_form_id = fvs1.submitted_form_id
      JOIN form_fields ffs1
        ON fvs1.form_field_id = ffs1.id

      JOIN form_values fvs2
        ON table2.submitted_form_id = fvs2.submitted_form_id
      JOIN form_fields ffs2
        ON fvs2.form_field_id = ffs2.id

      WHERE ffs1.name = 'latitude'
        AND ffs2.name = 'longitude'
    SQL
  end

end
