module SubmitForm::BlanketCheckOut::Main

  def self.run(data)
    # it does only route check out for now.
    if self.blanket_check_out?(data)
      data = self.submitted_form_extended_assignment_ids(data)

      self.helper(data)

      data[:submitted_form_extended_assignment_ids] = nil # invalidate cache
    end
    data
  end

  private

  def self.blanket_check_out?(data)
    asg = ::Assignment.find_by(name: 'blanketCheckOut')
    data[:form_fields].find { |ff| ff[:value] == asg.id || ff[:value] == asg.id.to_s}
  end

  def self.helper(data)
    at_name =  self.get_at_name(data) # route
    asg_ids = self.get_asg_ids(data[:submitted_form_extended_assignment_ids], at_name)
    asg_ids.each do |asg_id|
      SubmitForm::UpdateAssignmentStatus::Helper.run(nil, asg_id, data[:form_fields], at_name)
    end
  end

  def self.get_at_name(data)
    formType = self.get_form_type_name(data)
    formType.split("BlanketCheckOut")[0]
  end

  def self.get_form_type_name(data)
    asg_id = data[:form_fields].find { |ff| ff[:form_field_id].to_i == ::FormField.find_by(name: 'formType').id }[:value].to_i
    ::Assignment.find(asg_id).name
  end

  def self.get_asg_ids(sfe_asg_ids, at_name)
    at_id = AssignmentType.find_by(name: at_name).id
    Assignment.where(id: sfe_asg_ids, assignment_type_id: at_id).ids
  end

  def self.submitted_form_extended_assignment_ids(*args)
    SubmitForm::SubmittedFormExtendedAssignmentIds.run(*args)
  end
end
