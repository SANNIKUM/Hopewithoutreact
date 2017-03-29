require 'rails_helper'

describe FilteredSubmittedFormIds do


  def subject(*args)
    FilteredSubmittedFormIds.run(*args)
  end

  def fc(*args) FactoryGirl.create(*args) end

  let!(:sf1) { fc(:submitted_form) }
  let!(:asg1) { fc(:assignment, name: 'asg1') }
  let!(:fvo1) { fc(:form_value_option, assignment_id: asg1.id) }

  it 'works in trivial case' do
    result = subject([])
    expect(result).to eq([sf1.id])
  end

  it 'works in simple case' do
    sf2 = fc(:submitted_form)
    fv = fc(:form_value, form_value_option_id: fvo1.id, submitted_form_id: sf2.id)
    result = subject(['asg1'])
    expect(result).to eq([sf2.id])
  end

  it 'works complex case' do
    sf2 = fc(:submitted_form)
    fc(:form_value, form_value_option_id: fvo1.id, submitted_form_id: sf2.id)

    sf3 = fc(:submitted_form)
    asg2 = fc(:assignment, name: 'asg2')
    fvo2 = fc(:form_value_option, assignment_id: asg2.id)
    fc(:form_value, form_value_option_id: fvo1.id, submitted_form_id: sf3.id)
    fc(:form_value, form_value_option_id: fvo2.id, submitted_form_id: sf3.id)

    result = subject(['asg1', 'asg2'])
    expect(result).to eq([sf3.id])
  end
end
