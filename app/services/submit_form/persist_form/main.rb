module SubmitForm::PersistForm::Main

  def self.run(data)
    form_fields = (data[:form_fields].length > 0) ? data[:form_fields] : data[:form_fields].concat(trivial_form_fields)
    self.create_form_value(data[:sf_id], form_fields)
    data.merge({form_fields: form_fields})
  end

  private

  def self.create_form_value(sf_id, form_fields)
    SubmitForm::PersistForm::CreateFormValue.run(sf_id, form_fields)
  end

  def self.trivial_form_fields
    assignment_type = AssignmentType.find_or_create_by(name: 'formType')
    assignment = Assignment.find_or_create_by(name: 'blankStateAppOpen', assignment_type: assignment_type)
    form_field = FormField.find_or_create_by(name: 'formType', field_type: 'assignment', assignment_type: assignment_type)
    [
      {
        form_field_id: form_field.id,
        field_type: form_field.field_type,
        input_type: 'id',
        value: assignment.id
      }
    ]
  end
end
