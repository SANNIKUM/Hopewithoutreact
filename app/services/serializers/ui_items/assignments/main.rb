module Serializers::UiItems::Assignments::Main

  def self.run(args)
    assignment_ids_1 = args[:ui_items].reduce([]) do |acc, ui_item|
      acc.concat(ui_item[:assignments] || []).compact.uniq
    end

    assignment_ids = assignment_ids_1.empty? ? [0] : assignment_ids_1

    assignment_ids_string =  "(#{assignment_ids.join(', ')})"

    query = <<-SQL
      SELECT form_fields.id AS form_field_id,
             assignments.id AS assignment_id
        FROM form_fields
        JOIN assignment_types
          ON form_fields.assignment_type_id = assignment_types.id
        JOIN assignments
          ON assignment_types.id = assignments.assignment_type_id
       WHERE assignments.id IN (#{assignment_ids.join(', ')})
    SQL

    result = ActiveRecord::Base.connection.execute(query).to_a

    ui_items_with_updated_assignments = args[:ui_items].map do |u|
      asg_ids = u[:assignments] || []
      ff_asg_hash = self.ff_hash(asg_ids, result)
      u.deep_merge({assignments: ff_asg_hash})
    end

    { ui_items: ui_items_with_updated_assignments }
  end

  def self.ff_hash(asg_ids, result)
    x = result.select{|r| asg_ids.include?(r['assignment_id'].to_s)}
    x.reduce({}) do |acc, r|
      k = r['form_field_id']
      v = r['assignment_id']
      acc[k] = v
      acc
    end
  end

end
