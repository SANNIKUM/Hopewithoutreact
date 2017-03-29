module FilteredSubmittedFormIds

  def self.run(asg_names)
    asg_ids = Assignment.where(name: asg_names).ids
    return self.trivial_case if asg_ids.empty?
    first = asg_ids[0]
    rest = asg_ids.slice(1, asg_ids.length)
    Reduce.run(self.first(first), method(:recursive), rest)
  end

  private

  def self.trivial_case
    SubmittedForm.all.ids
  end

  def self.first(asg_id)
    query_string = <<-SQL
      WITH fvos AS (
        SELECT id
        FROM form_value_options
        WHERE assignment_id = #{asg_id}
      )
      SELECT fvs.submitted_form_id as id
      FROM fvos
      JOIN form_values fvs
        ON fvos.id = fvs.form_value_option_id
    SQL
    self.query(query_string)
  end

  def self.recursive(sf_ids, asg_id)
    sf_ids2 = sf_ids.any? ? sf_ids : [-1]
    sf_ids_string = "(#{sf_ids2.join(",")})"
    query_string = <<-SQL
      WITH fvs AS (
        SELECT id, form_value_option_id, submitted_form_id
        FROM form_values
        WHERE form_values.submitted_form_id IN #{sf_ids_string}
      ),
      fvos AS (
        SELECT id
        FROM form_value_options
        WHERE assignment_id = #{asg_id}
      )
      SELECT fvs.submitted_form_id as id
      FROM fvs
      JOIN fvos
        ON fvs.form_value_option_id = fvos.id
    SQL
    self.query(query_string)
  end

  def self.query(string)
    result = ActiveRecord::Base.connection.execute(string)
    result.to_a.map{ |x| x['id'] }
  end

end
