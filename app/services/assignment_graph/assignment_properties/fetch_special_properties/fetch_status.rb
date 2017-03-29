module AssignmentGraph::AssignmentProperties::FetchSpecialProperties::FetchStatus

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

      table1A AS (
        SELECT
          fvos.id as form_value_option_id,
          table0.asg_id as assignment_id
        FROM table0
        JOIN form_value_options fvos
          ON table0.asg_id = fvos.assignment_id
      ),

      table1B AS (
        SELECT
          fvs.submitted_form_id as submitted_form_id,
          table1A.assignment_id as assignment_id
        FROM table1A
        JOIN form_values fvs
          ON table1A.form_value_option_id = fvs.form_value_option_id
      ),

      table1C AS (
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

      table1D AS (
        SELECT fvs.submitted_form_id as submitted_form_id,
               table1C.form_type_category_name as form_type_category_name,
               table1B.assignment_id as assignment_id
        FROM table1B
        JOIN form_values fvs
          ON table1B.submitted_form_id = fvs.submitted_form_id
        JOIN table1C
          ON fvs.form_value_option_id = table1C.form_value_option_id
      ),

      table1E AS (
        SELECT table1D.submitted_form_id as submitted_form_id,
               table1D.form_type_category_name as form_type_category_name,
               table1D.assignment_id as assignment_id,
               fvs.datetime_value as created_at
        FROM table1D
        JOIN form_values fvs
          ON table1D.submitted_form_id = fvs.submitted_form_id
        JOIN form_fields ffs
          ON fvs.form_field_id = ffs.id
        WHERE ffs.name = 'submittedAt'
      ),


      table2 AS (
        SELECT table1E.assignment_id, MAX(table1E.created_at) as max_created_at
        FROM table1E
        GROUP BY table1E.assignment_id

      ),

      table3 AS (
        SELECT
          table1E.form_type_category_name as form_type_category_name,
          table1E.assignment_id as assignment_id
        FROM table1E
        JOIN table2
          ON     table1E.created_at = table2.max_created_at
             AND table1E.assignment_id = table2.assignment_id
      )
      /*
      table4 AS (
        SELECT asgs1.id as assignment_id,
               asgs2.id as related_assignment_id
        FROM assignments asgs1
        JOIN assignment_relations ars
        ON (
            asgs1.id = ars.assignment_1_id
            OR
            asgs1.id = ars.assignment_2_id
           )
        JOIN assignments asgs2
        ON (
            asgs2.id = ars.assignment_1_id
            OR
            asgs2.id = ars.assignment_2_id
           )
        JOIN assignment_types ats
          ON asgs2.assignment_type_id = ats.id
        WHERE ats.name = 'team'
          AND asgs1.id != asgs2.id
          AND asgs1.id IN (SELECT asg_id FROM table0)
      )
      */
      SELECT
        asgs.id AS assignment_id,
        CASE
          WHEN table3.form_type_category_name IS NULL
            THEN 'not_started'
          WHEN table3.form_type_category_name = 'checkIn'
            THEN 'in_progress'
          WHEN table3.form_type_category_name = 'checkOut'
            THEN 'completed'
        END as status

      FROM assignments asgs
      LEFT JOIN table3
        ON asgs.id = table3.assignment_id
      WHERE asgs.id IN (SELECT asg_id FROM table0)
    SQL
  end

end
