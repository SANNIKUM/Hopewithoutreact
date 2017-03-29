module SubmitForm::SubmittedFormExtendedAssignmentIds

  def self.run(data)
    if data[:submitted_form_extended_assignment_ids].nil?
      data = self.submitted_form_assignment_ids(data)
      seed_context_ids = data[:submitted_form_assignment_ids]
      x = self.context_inference(seed_context_ids)
      data[:submitted_form_extended_assignment_ids] = x
    end
    data
  end

  private

  def self.submitted_form_assignment_ids(data)
    SubmitForm::SubmittedFormAssignmentIds.run(data)
  end

  def self.context_inference(*args)
    ContextInference::Main.run(*args)
  end
end
