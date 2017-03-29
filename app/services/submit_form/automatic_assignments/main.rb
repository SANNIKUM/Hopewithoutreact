module SubmitForm::AutomaticAssignments::Main

  def self.run(data)
    sf_id = data[:sf_id]
    data = self.submitted_form_assignment_ids(data)
    asg_ids = data[:submitted_form_assignment_ids]
    at_ids = Assignment.where(id: asg_ids).map(&:assignment_type_id).compact.uniq
    aa = AutomaticAssignment.where(origin_type_id: at_ids)
                            .where(connector_type_id: at_ids)

    aa.each do |aa|
      self.handle_aa(aa, at_ids, asg_ids)
    end
    data[:submitted_form_extended_assignment_ids] = nil # need to invalidate this cache
    data
  end

  private

  def self.handle_aa(aa, at_ids, asg_ids)

    origin_id = Assignment.where(id: asg_ids, assignment_type_id: aa.origin_type_id).first.id
    connector_id   =  Assignment.where(id: asg_ids, assignment_type_id: aa.connector_type_id).first.id
    target_type_id =  aa.target_type_id


    if aa.connector_type_id == target_type_id
      target_id = connector_id
      self.create_assignment_relation(aa, origin_id, target_id)
    else
      x = self.assignment_edge_ids(connector_id, asg_ids)
      eligible_target_ids = Assignment.where(id: x).where(assignment_type_id: target_type_id).map(&:id)
      y = AssignmentRelation.where(assignment_1_id: eligible_target_ids, assignment_2_id: origin_id)
      z = AssignmentRelation.where(assignment_1_id: origin_id, assignment_2_id: eligible_target_ids)
      if (eligible_target_ids.length > 0) && y.length == 0 && z.length == 0
        target_id = self.highest_rank_target_id(eligible_target_ids, aa)
        self.create_assignment_relation(aa, origin_id, target_id)
      end
    end
  end

  def self.create_assignment_relation(aa, origin_id, target_id)
    art = AssignmentRelationType.find_by(id: aa.assignment_relation_type_id)
    if art.assignment_1_type_id == aa.origin_type_id
      a1_id = origin_id
      a2_id = target_id
    else
      a1_id = target_id
      a2_id = origin_id
    end
    AssignmentRelation.find_or_create_by(
      assignment_1_id: a1_id,
      assignment_2_id: a2_id,
      assignment_relation_type_id: art.id
    )
  end

  def self.highest_rank_target_id(ids, aa)
    origin_type_id = aa.origin_type_id
    connection_limit = aa.connection_limit
    ids_string = "(#{ids.join(',')})"
    string = <<-SQL
      WITH table1 AS (
        SELECT
          CASE WHEN asgs1.assignment_type_id = #{origin_type_id}
               THEN asgs2.id
               ELSE asgs1.id
          END
          as target_id,

          COUNT( DISTINCT
            CASE WHEN asgs1.assignment_type_id = #{origin_type_id}
                 THEN asgs1.id
                 ELSE asgs2.id
            END
          )
          as connection_count

          FROM assignment_relations ars
          JOIN assignments asgs1
            ON ars.assignment_1_id = asgs1.id
          JOIN assignments asgs2
            ON ars.assignment_2_id = asgs2.id

          WHERE (
            (
                  (ars.assignment_1_id IN #{ids_string})
              AND (asgs2.assignment_type_id = #{origin_type_id})
            )
            OR
            (
                  (ars.assignment_2_id IN #{ids_string})
              AND (asgs1.assignment_type_id = #{origin_type_id})
            )
          )
          GROUP BY target_id
      ),
      table2 AS (
        SELECT asgs.id as target_id,
               0 as connection_count
        FROM assignments asgs
        WHERE asgs.id IN #{ids_string}
        AND asgs.id NOT IN (SELECT target_id FROM table1)
      ),

      table3 AS (
        SELECT
          target_id,
          connection_count
        FROM table1
        UNION

        SELECT
          target_id,
          connection_count
        FROM table2
      )

      SELECT
        table3.target_id as id,
        CASE WHEN table3.connection_count + 1 > #{connection_limit}
             THEN (-1*table3.connection_count)
             ELSE table3.connection_count
        END
        as rank,
        table3.connection_count as connection_count,
        asgs.label as target_label
      FROM table3
      JOIN assignments as asgs
        ON asgs.id = table3.target_id
    SQL

    x = ActiveRecord::Base.connection.execute(string).to_a

    if x.empty?
      result =ids[0]
    else
      x = x.sort_by do |h|
        h["target_label"].split('_')[1].to_i
      end
      result = x.find { |h| h["connection_count"] < connection_limit }["id"]
      if result.nil?
        result = x.min_by { |h| h["connection_count"] }["id"]
      end
    end
    result
  end

  def self.assignment_edge_ids(node_id, node_ids)
    ids_string = "(#{node_ids.join(',')})"
    string = <<-SQL
      SELECT
        CASE WHEN assignment_1_id = #{node_id}
             THEN assignment_2_id
             ELSE assignment_1_id
        END
        as id
      FROM assignment_relations ars
      LEFT JOIN higher_order_assignment_relations hars
        ON ars.id = hars.assignment_relation_id

      WHERE (
           (ars.assignment_1_id = #{node_id})
        OR (ars.assignment_2_id = #{node_id})
      )
      AND (
        (hars.id IS NULL)
        OR hars.id IN #{ids_string}
      )
    SQL
    ActiveRecord::Base.connection.execute(string).map{|x| x['id']}
  end

  def self.submitted_form_assignment_ids(*args)
    SubmitForm::SubmittedFormAssignmentIds.run(*args)
  end

end
