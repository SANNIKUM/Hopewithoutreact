require 'rails_helper'

describe SubmitForm::PersistForm do

  def subject(data)
    SubmitForm::PersistForm::Main.run(data)
  end

  def fc(*args) FactoryGirl.create(*args) end

  context 'handles assignment type' do
    let!(:assignment_type) { fc(:assignment_type) }
    let!(:assignment) { fc(:assignment, assignment_type: assignment_type) }
    let!(:form_field) { fc(:form_field, field_type: 'assignment', assignment_type_id: assignment_type.id) }
    let!(:form_value_option) { fc(:form_value_option, form_field_id: form_field.id, value: 'value', assignment_id: assignment.id)}

    let!(:data) do
      {
        request_id: '0.123456789',
        form_fields: [
          {
            form_field_id: form_field.id,
            field_type: form_field.field_type,
            value: form_value_option.id,
            input_type: 'id',
          }
        ]
      }
    end

    before :each do
      @submitted_form = SubmittedForm.find(subject(data))
    end

    it 'creates submitted form' do
      expect(@submitted_form.id).to be_present
    end

    it 'creates form value' do
      form_value_option = FormValueOption.find_by(assignment_id: assignment.id)
      form_value = FormValue.find_by(submitted_form_id: @submitted_form.id, form_value_option: form_value_option)
      expect(form_value).to be_present
    end

  end
end
