require 'rails_helper'

describe SubmitForm::SwitchBasedCheckOut do


  let!(:at_t) { FactoryGirl.create(:assignment_type, name: 'team') }
  let!(:at_r) { FactoryGirl.create(:assignment_type, name: 'route') }
  let!(:switch) { FactoryGirl.create(:switch_based_check_out, name: 'Route by Team', target_assignment_type_id: at_r.id, helper_assignment_type_id: at_t.id)}

  let!(:at_ft) { FactoryGirl.create(:assignment_type, name: 'formType') }
  let!(:at_ftc) { FactoryGirl.create(:assignment_type, name: 'formTypeCategory') }
  let!(:t_to_r) { FactoryGirl.create(:assignment_relation_type, assignment_1_type: at_t, assignment_2_type: at_r)}

  let!(:check_in) { FactoryGirl.create(:assignment, name: 'checkIn', assignment_type: at_ftc) }
  let!(:check_out) { FactoryGirl.create(:assignment, name: 'checkOut', assignment_type: at_ftc) }
  let!(:route_check_in) { FactoryGirl.create(:assignment, name: 'routeCheckIn', assignment_type: at_ft)}
  let!(:route_check_out) { FactoryGirl.create(:assignment, name: 'routeCheckOut', assignment_type: at_ft)}
  let!(:team_1) { FactoryGirl.create(:assignment, name: 'team_1', assignment_type: at_t)}
  let!(:route_1) { FactoryGirl.create(:assignment, name: 'route_1', assignment_type: at_r)}
  let!(:route_2) { FactoryGirl.create(:assignment, name: 'route_2', assignment_type: at_r)}

  let!(:t1_r1) { FactoryGirl.create(:assignment_relation, assignment_1: team_1, assignment_2: route_1, assignment_relation_type: t_to_r) }
  let!(:t1_r2) { FactoryGirl.create(:assignment_relation, assignment_1: team_1, assignment_2: route_2, assignment_relation_type: t_to_r) }

  let!(:ff_ft) { FactoryGirl.create(:form_field, name: 'formType', field_type: 'assignment', assignment_type: at_ft) }
  let!(:ff_ftc) { FactoryGirl.create(:form_field, name: 'formTypeCategory', field_type: 'assignment', assignment_type: at_ftc) }
  let!(:ff_r) { FactoryGirl.create(:form_field, name: 'route', field_type: 'assignment', assignment_type: at_r)}
  let!(:ff_t) { FactoryGirl.create(:form_field, name: 'team', field_type: 'assignment', assignment_type: at_t)}
  let!(:ff_time) { FactoryGirl.create(:form_field, name: 'submittedAt', field_type: 'time')}

  let!(:fvo_check_in) { FactoryGirl.create(:form_value_option, form_field_id: ff_ftc, assignment_id: check_in.id) }
  let!(:fvo_check_out) { FactoryGirl.create(:form_value_option, form_field_id: ff_ftc, assignment_id: check_out.id) }
  let!(:fvo_route_check_in) { FactoryGirl.create(:form_value_option, form_field_id: ff_ft, assignment_id: route_check_in.id) }
  let!(:fvo_route_check_out) { FactoryGirl.create(:form_value_option, form_field_id: ff_ft, assignment_id: route_check_out.id) }
  let!(:fvo_team_1) { FactoryGirl.create(:form_value_option, form_field_id: ff_t.id, assignment_id: team_1.id)}
  let!(:fvo_route_1) { FactoryGirl.create(:form_value_option, form_field_id: ff_r.id, assignment_id: route_1.id)}
  let!(:fvo_route_2) { FactoryGirl.create(:form_value_option, form_field_id: ff_r.id, assignment_id: route_2.id)}

  let!(:data) do
    {
      request_id: rand.to_s,
      form_fields: [
        {input_type: 'option', field_type: 'assignment', value: team_1.id, form_field_id: ff_t.id},
        {input_type: 'option', field_type: 'assignment', value: route_1.id, form_field_id: ff_r.id},
        {value: DateTime.now.strftime('%Q').to_i, field_type: 'time', form_field_id: ff_time.id}
      ]
    }
  end

  def subject(data)
    sf_id = SubmitForm::PersistForm::Main.run(data)
    SubmitForm::SwitchBasedCheckOut::Main.run(sf_id)
  end

  before :each do
    subject(data)
  end

  context 'when submitted for the first time' do
    it 'checks in for the route' do
      ats = ['route']
      asgs = [{id: route_1.id}]
      result = AssignmentGraph::AssignmentProperties::FetchSpecialProperties::FetchStatus.run(ats, asgs)

      route_1_status = result.find { |x| x['assignment_id'] == route_1.id }['status']
      expect(route_1_status).to eq('in_progress')
    end
  end

  context 'when same route survey is submitted' do
    let!(:data_2) do
      {
        request_id: rand.to_s,
        form_fields: [
          {:value => team_1.id, field_type: 'assignment', form_field_id: ff_t.id},
          {input_type: 'option', field_type: 'assignment', value: route_1.id, form_field_id: ff_r.id},
          {value: DateTime.now.strftime('%Q').to_i, field_type: 'string', form_field_id: ff_time.id}
        ]
      }
    end

    it 'does nothing' do
      sf_id = SubmitForm::PersistForm::Main.run(data_2)
      expect{SubmitForm::SwitchBasedCheckOut::Main.run(sf_id)}.to change{SubmittedForm.all.count}.by(0)
    end
  end

  context 'when different route survey is submitted' do
    let!(:data_3) do
      {
        request_id: rand.to_s,
        form_fields: [
          {value: fvo_team_1.id, field_type: 'assignment', form_field_id: ff_t.id},
          {input_type: 'option', field_type: 'assignment', value: fvo_route_2.id, form_field_id: ff_r.id},
          {value: DateTime.now.strftime('%Q').to_i, field_type: 'time', form_field_id: ff_time.id}
        ]
      }
    end

    before :each do
      subject(data_3)
    end

    it 'checks out for the old route' do
      ats = ['route']
      asgs = [{id: route_1.id}, {id: route_2.id}]
      result = AssignmentGraph::AssignmentProperties::FetchSpecialProperties::FetchStatus.run(ats, asgs)

      route_1_status = result.find { |x| x['assignment_id'] == route_1.id }['status']
      expect(route_1_status).to eq('completed')

      route_2_status = result.find { |x| x['assignment_id'] == route_2.id }['status']
      expect(route_2_status).to eq('in_progress')
    end
  end

end
