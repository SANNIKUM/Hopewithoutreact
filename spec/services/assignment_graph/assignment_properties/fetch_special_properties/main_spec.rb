require 'rails_helper'

describe AssignmentGraph::AssignmentProperties::FetchSpecialProperties::Main do

  let!(:at_t) { FactoryGirl.create(:assignment_type, name: 'team') }
  let!(:at_r) { FactoryGirl.create(:assignment_type, name: 'route') }
  let!(:at_ft) { FactoryGirl.create(:assignment_type, name: 'formType') }
  let!(:at_ftc) { FactoryGirl.create(:assignment_type, name: 'formTypeCategory') }

  let!(:survey) { FactoryGirl.create(:assignment, name: 'survey', assignment_type: at_ftc)}
  let!(:team_1) { FactoryGirl.create(:assignment, name: 'team_1', assignment_type: at_t)}
  let!(:route_1) { FactoryGirl.create(:assignment, name: 'route_1', assignment_type: at_r)}
  let!(:route_2) { FactoryGirl.create(:assignment, name: 'route_2', assignment_type: at_r)}
  let!(:route_3) { FactoryGirl.create(:assignment, name: 'route_3', assignment_type: at_r)}

  let!(:t_to_r) { FactoryGirl.create(:assignment_relation_type, assignment_1_type: at_t, assignment_2_type: at_r)}
  let!(:t1_r1) { FactoryGirl.create(:assignment_relation, assignment_1: team_1, assignment_2: route_1, assignment_relation_type: t_to_r) }
  let!(:t1_r2) { FactoryGirl.create(:assignment_relation, assignment_1: team_1, assignment_2: route_2, assignment_relation_type: t_to_r) }
  let!(:t1_r3) { FactoryGirl.create(:assignment_relation, assignment_1: team_1, assignment_2: route_3, assignment_relation_type: t_to_r) }

  let!(:ff_ft) { FactoryGirl.create(:form_field, name: 'formType', field_type: 'assignment', assignment_type: at_ft) }
  let!(:ff_ftc) { FactoryGirl.create(:form_field, name: 'formTypeCategory', field_type: 'assignment', assignment_type: at_ftc) }
  let!(:ff_r) { FactoryGirl.create(:form_field, name: 'route', field_type: 'assignment', assignment_type: at_r) }
  let!(:ff_t) { FactoryGirl.create(:form_field, name: 'team', field_type: 'assignment', assignment_type: at_t) }
  let!(:ff_lat) { FactoryGirl.create(:form_field, name: 'latitude', field_type: 'string') }
  let!(:ff_lng) { FactoryGirl.create(:form_field, name: 'longitude', field_type: 'string') }
  let!(:ff_time) { FactoryGirl.create(:form_field, name: 'submittedAt', field_type: 'time')}
  let!(:ff_deleted) { FactoryGirl.create(:form_field, name: 'isSoftDeleted', field_type: 'boolean')}

  let!(:fvo_survey) { FactoryGirl.create(:form_value_option, form_field_id: ff_ftc, assignment_id: survey.id)}
  let!(:fvo_team_1) { FactoryGirl.create(:form_value_option, form_field_id: ff_t.id, assignment_id: team_1.id)}
  let!(:fvo_route_1) { FactoryGirl.create(:form_value_option, form_field_id: ff_r.id, assignment_id: route_1.id)}
  let!(:fvo_route_2) { FactoryGirl.create(:form_value_option, form_field_id: ff_r.id, assignment_id: route_2.id)}
  let!(:fvo_route_3) { FactoryGirl.create(:form_value_option, form_field_id: ff_r.id, assignment_id: route_3.id)}

  let!(:asg_1_r) { {id: route_1.id, assignment_type: {name: 'route'}} }
  let!(:asg_2_r) { {id: route_2.id, assignment_type: {name: 'route'}, properties: {}} }
  let!(:asg_3_r) { {id: route_3.id, assignment_type: {name: 'route'}, properties: {awesome_property: "awesome_value"}} }
  let!(:asg_4_t) { {id: team_1.id, assignment_type: {name: 'team'}} }
  let!(:assignments) {[asg_1_r, asg_2_r, asg_3_r, asg_4_t]}


  # fv = FormValue.find_or_create_by(form_field_id: ff1.id, submitted_form_id: sf.id)
  # fv.update(boolean_value: true)

  let!(:data) do
    {
      request_id: rand.to_s,
      form_fields: [
        {field_type: 'string', value: '0.123456789', form_field_id: ff_lat.id},
        {field_type: 'string', value: '-0.123456789', form_field_id: ff_lng.id},
        {field_type: 'assignment', value: team_1.id, form_field_id: ff_t.id},
        {input_type: 'option', field_type: 'assignment', value: route_1.id, form_field_id: ff_r.id},
        {field_type: 'assignment', value: survey.id, form_field_id: ff_ftc.id},
        {field_type: 'time', value: 1000000000000, form_field_id: ff_time.id},
        {field_type: 'boolean', value: true, form_field_id: ff_deleted.id}
      ]
    }
  end

  let!(:data_2) do
    {
      request_id: rand.to_s,
      form_fields: [
        {field_type: 'string', value: '1.234567890', form_field_id: ff_lat.id},
        {field_type: 'string', value: '-1.234567890', form_field_id: ff_lng.id},
        {field_type: 'assignment', value: team_1.id, form_field_id: ff_t.id},
        {input_type: 'option', field_type: 'assignment', value: route_2.id, form_field_id: ff_r.id},
        {field_type: 'assignment', value: survey.id, form_field_id: ff_ftc.id},
        {field_type: 'time', value: 2000000000000, form_field_id: ff_time.id}
      ]
    }
  end

  def subject(properties_config)
    AssignmentGraph::AssignmentProperties::FetchSpecialProperties::Main.run(assignments, properties_config)
  end

  before :each do
    [data, data_2].each do |data|
      sf_id = SubmitForm::PersistForm::Main.run(data)
    end
  end

  it 'fetches location' do
    properties_config = [
      {name: 'team', properties: ['location']}
    ]
    result = subject(properties_config)
    expect(result).to contain_exactly(
      asg_1_r,
      asg_2_r,
      asg_3_r,
      asg_4_t.deep_merge(properties: {location: {latitude: "1.234567890", longitude: "-1.234567890"}})
    )
  end

  it 'fetches submitted_forms_count' do
    properties_config = [
      {name: 'route', properties: ['submitted_forms_count']}
    ]
    result = subject(properties_config)
    expect(result).to contain_exactly(
      asg_1_r.deep_merge(properties: {submitted_forms_count: 0}),
      asg_2_r.deep_merge(properties: {submitted_forms_count: 1}),
      asg_3_r.deep_merge(properties: {submitted_forms_count: 0}),
      asg_4_t
    )
  end

end
