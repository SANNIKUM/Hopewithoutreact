module SubmitForm::UpdateAssignmentStatus::Helper

  def self.run(asg_id_to_check_in, asg_id_to_check_out, form_fields, at_name)
    self.update_status(asg_id_to_check_in, form_fields, 'in', at_name) unless asg_id_to_check_in.nil?
    self.update_status(asg_id_to_check_out, form_fields, 'out', at_name) if asg_id_to_check_out && asg_id_to_check_in != asg_id_to_check_out
  end

  def self.update_status(target_id, form_fields, in_or_out, at_name)

    ff_ci = ::FormField.find_by(name: 'countInstance')
    ci_id = form_fields.find { |ff| ff[:form_field_id].to_i == ff_ci.id }[:value].to_i
    return if ci_id.nil?

    count_instance = ::Assignment.find(ci_id)

    at_ci = AssignmentType.find_by(name: 'countInstance')
    at_status = AssignmentType.find_by(name: "countInstanceStatus")
    at_target = AssignmentType.find_by(name: at_name)

    art_ci_to_status = AssignmentRelationType.find_by(assignment_1_type_id: [at_ci.id, at_status.id], assignment_2_type_id: [at_ci.id, at_status.id])
    ars_ci_status = AssignmentRelation.where(assignment_relation_type_id: art_ci_to_status.id)
                                      .where("assignment_1_id = ? OR assignment_2_id = ?", ci_id, ci_id)

    status_ids = ars_ci_status.reduce([]) do |acc, h|
      acc.push(h[:assignment_1_id])
      acc.push(h[:assignment_2_id])
    end.reject { |id| id == ci_id }
    statuses = ::Assignment.find(status_ids)
    status_in_progress = statuses.find { |x| x.label == 'in_progress' }
    status_completed = statuses.find { |x| x.label == 'completed' }

    art_target_to_status = AssignmentRelationType.find_by(assignment_1_type_id: [at_target.id, at_status.id], assignment_2_type_id: [at_target.id, at_status.id])
    art_target_to_status ||= AssignmentRelationType.create(
      assignment_1_type_id: at_target.id,
      assignment_2_type_id: at_status.id,
      name: "#{at_name.camelize} to CountInstanceStatus"
    )

    if art_target_to_status.assignment_1_type_id == at_target.id
      ar = AssignmentRelation.where(
        assignment_1_id: target_id,
        assignment_2_id: status_ids,
        assignment_relation_type_id: art_target_to_status.id
      ).first
      ar ||= AssignmentRelation.find_or_initialize_by(assignment_1_id: target_id, assignment_relation_type_id: art_target_to_status.id)
      if in_or_out == 'in'
        ar.update_attributes(assignment_2_id: status_in_progress.id)
      elsif in_or_out == 'out'
        ar.update_attributes(assignment_2_id: status_completed.id)
      end
    else
      ar = AssignmentRelation.where(
        assignment_1_id: status_ids,
        assignment_2_id: target_id,
        assignment_relation_type_id: art_target_to_status.id
      ).first
      ar ||= AssignmentRelation.find_or_initialize_by(assignment_2_id: target_id, assignment_relation_type_id: art_target_to_status.id)
      if in_or_out == 'in'
        ar.update_attributes(assignment_1_id: status_in_progress.id)
      elsif in_or_out == 'out'
        ar.update_attributes(assignment_1_id: status_completed.id)
      end
    end
  end
end
