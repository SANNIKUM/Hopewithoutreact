require 'rails_helper'

describe AssignmentGraph::AssignmentProperties::FetchNormalProperties::Zip do

  def subject(*args)
    AssignmentGraph::AssignmentProperties::FetchNormalProperties::Zip.run(*args)
  end

  def fc(*args)
    FactoryGirl.create(*args)
  end


  it 'works' do
    asg_hashes = [
      {id: 1, assignment_type_id: 1},
      {id: 2, assignment_type_id: 2}
    ]
    properties_arr = [
      {name: 'at1', properties: ['prop1']},
      {name: 'at2', properties: ['prop2']}
    ]
    input_result = [
      {id: 1, assignment_type_id: 1, assignment_type_name: 'at1', prop1: 'value11', prop2: 'value12'},
      {id: 2, assignment_type_id: 2, assignment_type_name: 'at2', prop1: 'value21', prop2: 'value22'}
    ]

    expected = [
      {id: 1, assignment_type_id: 1, properties: {prop1: 'value11'}},
      {id: 2, assignment_type_id: 2, properties: {prop2: 'value22'}}
    ]

    actual = subject(asg_hashes, properties_arr, input_result)
    expect(actual).to match_array(expected)
  end
end
