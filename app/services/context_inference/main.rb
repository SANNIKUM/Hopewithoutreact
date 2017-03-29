module ContextInference::Main

  def self.run(seed_context_ids)
    seed_asgs = Assignment.where(id: seed_context_ids)
    seed_asg_hashes = self.group_by_assignment_type(seed_asgs)
    direct = self.direct(seed_context_ids)
    indirect = self.indirect(seed_asg_hashes, seed_context_ids)
    final = self.merge(seed_asg_hashes, direct, indirect)
  end

  private

  def self.direct(seed_context_ids)
    ContextInference::Query.run(seed_context_ids, seed_context_ids)
  end

  def self.indirect(g2, seed_context_ids)
    hash = self.traverse_graph(g2, seed_context_ids)
    hash
  end

  def self.merge(seed, direct, indirect)
    all_keys = seed.keys.concat(direct.keys).concat(indirect.keys).uniq
    all_keys.reduce([]) do |acc, k|
      if seed[k].present? && seed[k].any?
        value = seed[k]
      elsif direct[k].present? && direct[k].any?
        value = direct[k]
      else
        value = indirect[k]
      end
      acc2 = acc.concat(value)
      acc2
    end
  end

  def self.group_by_assignment_type(asgs)
    hs = asgs.map{|x| x.class.name == "Hash" ? x : x.attributes}.map{|x| x.deep_symbolize_keys}
    gs = hs.group_by{|x| x[:assignment_type_id]}
    is = gs.reduce({}) do |acc, (k, v)|
      acc[k] = v.map{|x| x[:id]}
      acc
    end
    is
  end

  def self.traverse_graph(*args)
    ContextInference::TraverseGraph.run(*args)
  end
end
