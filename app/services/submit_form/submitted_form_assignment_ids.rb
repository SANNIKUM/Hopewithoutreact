module SubmitForm::SubmittedFormAssignmentIds

  def self.run(data)
    x = data[:submitted_form_assignment_ids]
    if x.nil?
      fvs = FormValue.where(submitted_form_id: data[:sf_id])
      fvos = FormValueOption.where(id: fvs.map(&:form_value_option_id))
      y = fvos.map(&:assignment_id).compact.uniq
      data[:submitted_form_assignment_ids] = y
    end
    data
  end

end
