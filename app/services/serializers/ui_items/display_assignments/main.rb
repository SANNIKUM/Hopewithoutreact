module Serializers::UiItems::DisplayAssignments::Main

  def self.run(args)
    ui_items = args[:ui_items]
    x1, x2 = ui_items.partition{|x| x[:uiItemType] == 'assignmentDisplay' }

    datns = x1.map{|x| x[:assignmentType]}.compact.uniq
    result = self.query(datns, args[:asg_ids])
    x1_2 = x1.map do |ui_item|
      asg = result.find{|x| x[:assignment_type_name] == ui_item[:assignmentType]}
      hash = {
        id: asg[:assignment_id],
        name: asg[:assignment_name],
        label: asg[:assignment_label],
        assignment_type_id: asg[:assignment_type_id],
        assignment_type: {
          id: asg[:assignment_type_id],
          name: asg[:assignment_type_name],
          label: asg[:assignment_type_label],
        },
      }
      ui_item[:assignment] = hash
      ui_item
    end
    { ui_items: x2.concat(x1_2) }
  end

  def self.query(datns, asg_ids)

    narr = datns.empty? ? ["'never-a-name'"] : datns.map{|x| "'#{x}'"}
    datns_string = "(#{narr.join(",")})"

    asrr = asg_ids.empty? ? [0] : asg_ids
    asg_ids_string = "(#{asrr.join(",")})"

    query_string = <<-SQL
      WITH asgs AS (
        SELECT
          assignments.id as id,
          assignments.name as name,
          assignments.label as label,
          assignments.assignment_type_id as assignment_type_id
        FROM assignments
        WHERE assignments.id IN #{asg_ids_string}
      )

      SELECT
        asgs.id as assignment_id,
        asgs.name as assignment_name,
        asgs.label as assignment_label,
        asgs.assignment_type_id as assignment_type_id,
        ats.name as assignment_type_name,
        ats.label as assignment_type_label
      FROM
        asgs
      JOIN assignment_types ats
      ON asgs.assignment_type_id = ats.id
      WHERE ats.name IN #{datns_string}

    SQL
    ActiveRecord::Base.connection.execute(query_string).to_a.map(&:deep_symbolize_keys)
  end

end
