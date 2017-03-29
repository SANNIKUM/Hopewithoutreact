require 'rails_helper'


describe SubmitForm::PersistForm::CreateFormValue do

  def fc(*args)
    FactoryGirl.create(*args)
  end

  def subject(sf_id, form_field_data)
    SubmitForm::PersistForm::CreateFormValue.run(sf_id, form_field_data)
  end

  let!(:submitted_form) { fc(:submitted_form) }

  let!(:ff_homeless) { fc(:form_field, name: 'homeless', field_type: 'boolean') }

  let!(:form_field_data) do
    [
      {
        form_field_id: ff_homeless.id,
        field_type: 'boolean',
        value: true,
        input_type: 'boolean'
      }
    ]
  end

  it 'creates string form value' do
    subject(submitted_form.id, form_field_data)
    expect(FormValue.all.count).to eq(1)

    fv = FormValue.first.attributes.deep_symbolize_keys
    expect(fv).to eq({
      id: 1,
      string_value: nil,
      form_field_id: ff_homeless.id,
      form_value_option_id: nil,
      boolean_value: true,
      submitted_form_id: submitted_form.id,
      text_value: nil,
      integer_value: nil,
      numeric_value_1: nil,
      numeric_value_2: nil,
      datetime_value: nil
    })
  end

end
