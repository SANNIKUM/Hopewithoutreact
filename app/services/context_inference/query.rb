module ContextInference::Query

  def self.run(ids, seed_context_ids)
    string = "
      #{self.assignment_edge(1, ids, seed_context_ids)}
      UNION
      #{self.assignment_edge(2, ids, seed_context_ids)}
    "
    result = ActiveRecord::Base.connection.execute(string)
    self.group_by_assignment_type_and_merge_by_origin(result)
  end

  private

  def self.assignment_edge(self_side, ids, seed_context_ids)
    ids_string = self.ids_string(ids)
    other_side = self_side == 1 ? 2 : 1
    seed_context_ids_string = self.ids_string(seed_context_ids)
    "
      SELECT
        origin_asgs.assignment_type_id as origin_assignment_type_id,
        target_asgs.id as id,
        target_asgs.assignment_type_id as assignment_type_id

      FROM assignments origin_asgs
      JOIN assignment_types origin_types
        ON origin_asgs.assignment_type_id = origin_types.id
      JOIN assignment_relations ars
        ON origin_asgs.id = ars.assignment_#{self_side}_id
      JOIN assignments target_asgs
        ON ars.assignment_#{other_side}_id = target_asgs.id
      WHERE origin_asgs.id IN #{ids_string}
        AND (
              origin_types.predetermined IS NOT FALSE
              OR
              origin_asgs.id IN #{seed_context_ids_string}
            )
    "
  end

  def self.ids_string(arr)
    x = arr.length == 0 ? [0] : arr
    "(#{x.join(',')})"
  end

  def self.group_by_assignment_type_and_merge_by_origin(query_result)
    hs = query_result.map{|x| x.deep_symbolize_keys}.group_by{|x| x[:assignment_type_id] }
    is = hs.reduce({}) do |acc, (k, v)|
      acc[k] = self.helper1(v)
      acc
    end
    is
  end

  def self.helper1(arr)
    ids = arr.map{|x| x[:id]}
    arr.group_by{|x| x[:origin_assignment_type_id]}.reduce(ids) do |acc, (k, v)|
      acc & v.map{|x| x[:id]}
    end
  end
end
