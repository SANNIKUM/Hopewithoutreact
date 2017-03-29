module AssignmentGraph::AssignmentProperties::FetchSpecialProperties::Main

  def self.run(asgs, properties_arr, config_hash)
    hash = Hash.new { |h, k| h[k] = [] }
    properties_arr.each do |el|
      el[:properties].each do |property_name|
        hash[property_name].push(el[:name])
      end
    end

    hash.each do |property_name, ats|
      asgs = self.fetch_properties(property_name, ats, asgs, config_hash)
    end

    asgs
  end

  private

  def self.fetch_properties(property_name, ats, asgs, config_hash)
    return self.handle_status(property_name, ats, asgs) if property_name == 'status'
    return self.handle_location(property_name, ats, asgs) if property_name == 'location'
    return self.handle_submitted_forms_count(property_name, ats, asgs, config_hash) if property_name == 'submitted_forms_count'
    return self.handle_user_checked_in(property_name, ats, asgs) if property_name == 'user_checked_in'
    asgs
  end

  def self.handle_status(property_name, ats, asgs)
    result = AssignmentGraph::AssignmentProperties::FetchSpecialProperties::FetchStatus.run(ats, asgs)
    self.merge_result(property_name, ats, asgs, result)
  end

  def self.handle_location(property_name, ats, asgs)
    result = AssignmentGraph::AssignmentProperties::FetchSpecialProperties::FetchLocation.run(ats, asgs)
    self.merge_result(property_name, ats, asgs, result)
  end

  def self.handle_submitted_forms_count(property_name, ats, asgs, config_hash)
    result = AssignmentGraph::AssignmentProperties::FetchSpecialProperties::FetchSubmittedFormsCount.run(ats, asgs, config_hash)
    self.merge_result(property_name, ats, asgs, result)
  end

  def self.handle_user_checked_in(property_name, ats, asgs)
    result = AssignmentGraph::AssignmentProperties::FetchSpecialProperties::FetchUserCheckedIn.run(ats, asgs)
    self.merge_result(property_name, ats, asgs, result)
  end

  def self.merge_result(property_name, ats, asgs, result)
    result_arr = result.to_a

    asgs.map do |asg|
      assignment_type_name = asg[:assignment_type][:name]
      if !ats.include?(assignment_type_name)
        asg
      else
        result = result_arr.select { |r| r["assignment_id"] == asg[:id] }.first
        result = self.delete_key(result, "assignment_id").deep_symbolize_keys
        properties_hash = {}
        k = property_name.to_sym
        if result.empty?
          properties_hash[k] = nil
        elsif result.length > 1
          properties_hash[k] = result
        else
          properties_hash[k] = result.values.first
        end
        asg.deep_merge(properties: properties_hash)
      end
    end
  end

  def self.delete_key(hash, key)
    return {} if hash.nil?
    hash2 = hash.dup
    hash2.delete(key)
    hash2
  end

end
