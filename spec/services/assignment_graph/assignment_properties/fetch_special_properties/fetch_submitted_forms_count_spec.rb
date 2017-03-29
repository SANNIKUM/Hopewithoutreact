require 'rails_helper'

describe AssignmentGraph::AssignmentProperties::FetchSpecialProperties::FetchSubmittedFormsCount do

  def subject(*args)
    AssignmentGraph::AssignmentProperties::FetchSpecialProperties::FetchSubmittedFormsCount.run(*args).to_a.map(&:deep_symbolize_keys)
  end

  def fc(*args) FactoryGirl.create(*args) end



  let!(:at1) { fc(:assignment_type, name: 'at1') }
  let!(:asg1) { fc(:assignment, name: 'asg1', assignment_type_id: at1.id) }

  let!(:at2) { fc(:assignment_type, name: 'at2') }
  let!(:at3) { fc(:assignment_type, name: 'at3') }

  let!(:asg2) { fc(:assignment, name: 'asg2', assignment_type_id: at2.id) }
  let!(:asg3) { fc(:assignment, name: 'asg3', assignment_type_id: at3.id) }

  let!(:fvo1) { fc(:form_value_option, assignment_id: asg1.id) }
  let!(:fvo2) { fc(:form_value_option, assignment_id: asg2.id) }
  let!(:fvo3) { fc(:form_value_option, assignment_id: asg3.id) }

  let!(:ftc) { fc(:assignment_type, name: 'formTypeCategory')}
  let!(:survey) { fc(:assignment, name: 'survey', assignment_type_id: ftc.id)}
  let!(:survey_fvo) { fc(:form_value_option, assignment_id: survey.id) }

  let!(:ff_client_id) { fc(:form_field, name: 'clientId') }
  let!(:ff_sd) { fc(:form_field, name: 'isSoftDeleted')}

  def prepare_sfs(data)
    data.each{ |d| create_sf(d) }
  end

  def create_sf(args)
    sf = fc(:submitted_form)
    args[:fvos].each do |fvo|
      fv = fc(:form_value, submitted_form_id: sf.id, form_value_option_id: fvo.id)
    end
    fv = fc(:form_value, submitted_form_id: sf.id, form_field: ff_client_id, string_value: args[:client_id])
    fv = fc(:form_value, submitted_form_id: sf.id, form_value_option_id: survey_fvo.id)
    if args[:soft_deleted].present? and args[:soft_deleted] == true
      fv = fc(:form_value, submitted_form_id: sf.id, form_field_id: ff_sd.id, boolean_value: true)
    end
  end


  it 'works when theres only 1 survey submitted' do
    prepare_sfs([
      {fvos: [fvo1], client_id: rand}
    ])
    result = subject(['at1'], [ {id: asg1.id} ], {context_assignment_ids: []})
    expect(result).to eq([
      {assignment_id: asg1.id, submitted_forms_count: 1}
    ])
  end

  it 'works when theres 2 surveys submitted' do
    prepare_sfs([
      {fvos: [fvo1], client_id: rand},
      {fvos: [fvo1, fvo2], client_id: rand},
    ])
    result = subject(['at1', 'at2'], [ {id: asg1.id}, {id: asg2.id} ], {context_assignment_ids: []})
    expect(result).to eq([
      {assignment_id: asg1.id, submitted_forms_count: 2},
      {assignment_id: asg2.id, submitted_forms_count: 1}
    ])
  end

  it 'works when 1 survey is soft_deleted' do
    prepare_sfs([
      {fvos: [fvo1], client_id: rand},
      {fvos: [fvo1], client_id: rand, soft_deleted: true},
    ])
    result = subject(['at1'], [ {id: asg1.id} ], {context_assignment_ids: []})
    expect(result).to eq([
      {assignment_id: asg1.id, submitted_forms_count: 1},
    ])
  end

  it 'works when there are multiple surveys with same clientId (edits)' do
    client_id = rand
    prepare_sfs([
      {fvos: [fvo1], client_id: client_id},
      {fvos: [fvo1], client_id: client_id},
    ])
    result = subject(['at1'], [ {id: asg1.id} ], {context_assignment_ids: []})
    expect(result).to eq([
      {assignment_id: asg1.id, submitted_forms_count: 1},
    ])
  end

  it 'works when context_assignment_ids are specified' do
    prepare_sfs([
      {fvos: [fvo1], client_id: rand},
      {fvos: [fvo1, fvo2], client_id: rand},
      {fvos: [fvo1, fvo2], client_id: rand},
    ])
    result = subject(['at1'], [{id: asg1.id}], {context_assignment_ids: [asg2.id]})
    expect(result).to eq([
      {assignment_id: asg1.id, submitted_forms_count: 2},
    ])
  end

=begin
  simple 1 sf : (1 sf, no context_assignment_ids) - make sure it counts it

  2 sf

  2 sf, soft_deleted

  2 sf, same client_id

  2 sf, context_assignment_ids

=end


end
