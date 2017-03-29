module SubmitForm::AutomaticAssignmentFormValueProcess

  def self.run(data)
    sf_id = data[:sf_id]
    data = self.submitted_form_assignment_ids(data)
    data = self.submitted_form_extended_assignment_ids(data)
    trigger_candidate_ids = self.trigger_candidate_ids(data)
    target_candidate_ids = self.target_candidate_ids(data)
    trigger_candidates = Assignment.where(id: trigger_candidate_ids)
    target_candidates = Assignment.where(id: target_candidate_ids)

    trigger_at_ids = trigger_candidates.map(&:assignment_type_id)
    target_at_ids = target_candidates.map(&:assignment_type_id)

    aafvs = AutomaticAssignmentFormValue.where({
        trigger_type_id: trigger_at_ids,
        target_type_id: target_at_ids
    })

    aafvs.each do |aafv|
      self.helper({sf_id: sf_id, target_candidates: target_candidates, trigger_candidates: trigger_candidates}).call(aafv)
    end
    data[:submitted_form_assignment_ids] = nil # invalidate cache
    data[:submitted_form_extended_assignment_ids] = nil # invalidate cache
    data
  end

  private

  def self.helper(args)
    lambda do |aafv|
      target_asg = args[:target_candidates].find_by(assignment_type_id: aafv.target_type_id)
      ff = FormField.find_or_create_by(
        assignment_type_id: aafv.target_type_id,
        name: AssignmentType.find(aafv.target_type_id).name
      )
      fvo = FormValueOption.find_or_create_by(assignment_id: target_asg.id)
      fv = FormValue.create(
        submitted_form_id: args[:sf_id],
        form_value_option_id: fvo.id,
        form_field: ff
      )
    end
  end

  def self.trigger_candidate_ids(data)
    data[:submitted_form_assignment_ids]
  end

  def self.target_candidate_ids(data)
    data[:submitted_form_extended_assignment_ids]
  end

  def self.submitted_form_assignment_ids(*args)
    SubmitForm::SubmittedFormAssignmentIds.run(*args)
  end

  def self.submitted_form_extended_assignment_ids(*args)
    SubmitForm::SubmittedFormExtendedAssignmentIds.run(*args)
  end

end
