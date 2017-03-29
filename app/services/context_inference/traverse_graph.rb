module ContextInference::TraverseGraph

  def self.run(hash, seed_context_ids)
    ids = self.extract_ids(hash)
    next_batch = self.query(ids, seed_context_ids)
    next_hash = self.merge(hash, next_batch)
    stable = self.stable(hash, next_hash)
    if self.stable(hash, next_hash)
      next_hash
    else
      self.run(next_hash, seed_context_ids)
    end
  end

  private

  def self.query(*args)
    ContextInference::Query.run(*args)
  end

  def self.extract_ids(hash)
    hash.reduce([]){ |acc, (k, v)| acc.concat(v) }
  end

  def self.merge(old_hash, new_hash)
    keys = old_hash.keys.concat(new_hash.keys).uniq
    merged = keys.reduce({}) do |acc, k|
      old_value = old_hash[k]
      new_value = new_hash[k]
      if old_value.nil?
        merged = new_value
      elsif new_value.nil?
        merged = old_value
      else
        merged = old_value & new_value # gets set intersection
      end
      acc[k] = merged
      acc
    end
    merged
  end

  def self.stable(old_hash, new_hash)
    return true if new_hash.empty?
    new_hash.reduce(true) do |acc, (k, v)|
      bool = true
      if old_hash[k].nil?
        bool = false
      else
        bool = (old_hash[k].length == v.length)
      end
      acc && bool
    end
  end
end
