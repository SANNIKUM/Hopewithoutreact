module SubmitForm::UpdateAssignmentStatus::Main

  def self.run(data)
    form_fields = data[:form_fields]
    return data unless self.have_check_in_or_check_out?(form_fields)

    assignment_type, new_status = self.find_form_type_and_new_status(form_fields)
    target_assignment = self.find_target_assignment(form_fields, assignment_type)
    self.update_status(new_status, target_assignment.id, form_fields, assignment_type)
    data
  end

  private

  def self.have_check_in_or_check_out?(form_fields)
    asg_check_in = ::Assignment.find_by(name: 'checkIn')
    asg_check_out = ::Assignment.find_by(name: 'checkOut')

    form_fields.find { |ff| ff[:value].to_s == asg_check_in.id.to_s || ff[:value].to_s == asg_check_out.id.to_s }
  end

  def self.find_form_type_and_new_status(form_fields)
    ff_ft = FormField.find_by(name: 'formType')
    form_type_assignment_id = form_fields.find { |ff| ff[:form_field_id].to_i == ff_ft.id }
    form_type_assignment_id = form_type_assignment_id[:value]
    form_type_name = Assignment.find(form_type_assignment_id).name
    form_type_name.split('Check').map(&:downcase)
  end

  def self.find_target_assignment(form_fields, assignment_type)
    at_id = AssignmentType.find_by(name: assignment_type).id
    ff_id = FormField.find_by(assignment_type_id: at_id).id
    target_form_field = form_fields.find { |ff| ff[:form_field_id].to_i == ff_id }

    if target_form_field[:input_type] == 'string'
      ::Assignment.find_by(name: target_form_field[:value])
    else
      ::Assignment.find(target_form_field[:value])
    end
  end

  def self.update_status(new_status, asg_id, form_fields, at_name)
    ats_for_switch = AssignmentType.find(SwitchBasedCheckOut.all.map(&:target_assignment_type_id)).map(&:name)
    if ats_for_switch.include?(at_name)
      # do nothing
    else
      if new_status == 'in'
        SubmitForm::UpdateAssignmentStatus::Helper.run(asg_id, nil, form_fields, at_name)
      elsif new_status == 'out'
        SubmitForm::UpdateAssignmentStatus::Helper.run(nil, asg_id, form_fields, at_name)
      end
    end
  end

end
