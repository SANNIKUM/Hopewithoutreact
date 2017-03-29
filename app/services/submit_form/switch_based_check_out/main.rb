require 'date'

module SubmitForm::SwitchBasedCheckOut::Main

  def self.run(data)
    ::SwitchBasedCheckOut.all.each do |x|
      self.run2(data, x.target_assignment_type, x.helper_assignment_type)
    end
    data
  end

  def self.run2(data, at_target, at_helper)
    sf_id = data[:sf_id]
    form_fields = data[:form_fields]

    # get the route from the sf_id (which is just submitted)
    new_target_id = self.get_target_assignment_id(sf_id, at_target.name)
    return sf_id if new_target_id.nil?

    # find all surveys submitted by these teams (or users) that were assigned to this route and return the most recent one
    last_sf_id = self.get_last_submitted_form(new_target_id, at_target, at_helper, sf_id)

    # get the route's assignment id for the last submitted form
    last_target_id = self.get_target_assignment_id(last_sf_id, at_target.name)


    self.helper(new_target_id, last_target_id, form_fields, at_target.name)

    sf_id
  end

  def self.helper(*args)
    SubmitForm::UpdateAssignmentStatus::Helper.run(*args)
  end

  def self.get_target_assignment_id(sf_id, target_name)
    return nil if sf_id.nil?

    query = <<-SQL
      SELECT form_value_options.assignment_id
        FROM submitted_forms
    	  JOIN form_values
          ON submitted_forms.id = form_values.submitted_form_id
    	  JOIN form_fields
          ON form_fields.id = form_values.form_field_id
        JOIN form_value_options
          ON form_values.form_value_option_id = form_value_options.id
    	 WHERE form_fields.name = '#{target_name}'
         AND submitted_forms.id = #{sf_id}
    SQL
    result = ActiveRecord::Base.connection.execute(query).map { |h| h["assignment_id"] }
    result.first
  end

  def self.get_last_submitted_form(target_id, at_target, at_helper, sf_id)
    query = <<-SQL
      WITH table1 AS (
        SELECT id AS art_id
          FROM assignment_relation_types
         WHERE assignment_1_type_id IN (#{at_target.id}, #{at_helper.id})
           AND assignment_2_type_id IN (#{at_target.id}, #{at_helper.id})
      ),

      table2 AS (
        SELECT assignment_1_id AS assignment_id
          FROM assignment_relations
         WHERE assignment_2_id = #{target_id}
           AND assignment_relation_type_id IN (SELECT art_id FROM table1)

         UNION

        SELECT assignment_2_id AS assignment_id
          FROM assignment_relations
         WHERE assignment_1_id = #{target_id}
           AND assignment_relation_type_id IN (SELECT art_id FROM table1)
      ),

      table3 AS (
        SELECT DISTINCT assignment_id
        FROM table2
      ),

      table4 AS (
        SELECT form_values.submitted_form_id AS sf_id
          FROM form_values
          JOIN form_value_options
            ON form_values.form_value_option_id = form_value_options.id
          JOIN assignments
            ON form_value_options.assignment_id = assignments.id
         WHERE assignments.id IN (SELECT assignment_id FROM table3)
      ),

      /* submitted_forms with route assignments*/
      table5 AS (
        SELECT submitted_forms.id AS sf_id, fv2.datetime_value as submitted_at
          FROM submitted_forms
          JOIN form_values AS fv1
            ON fv1.submitted_form_id = submitted_forms.id
          JOIN form_value_options
            ON fv1.form_value_option_id = form_value_options.id
          JOIN assignments
            ON form_value_options.assignment_id = assignments.id
          JOIN assignment_types
            ON assignments.assignment_type_id = assignment_types.id
          JOIN form_values AS fv2
            ON fv2.submitted_form_id = fv1.submitted_form_id
          JOIN form_fields
            ON fv2.form_field_id = form_fields.id
         WHERE form_fields.name = 'submittedAt'
           AND assignment_types.name = '#{at_target.name}'
      )

      SELECT table5.sf_id AS last_submitted_form_id
      FROM table5
      JOIN table4
        ON table4.sf_id = table5.sf_id
      WHERE table5.sf_id <> #{sf_id}
      ORDER BY table5.submitted_at DESC
      LIMIT 1
    SQL

    result = ActiveRecord::Base.connection.execute(query).map { |h| h['last_submitted_form_id'] }
    result.first
  end

end
