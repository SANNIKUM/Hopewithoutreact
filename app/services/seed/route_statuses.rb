module Seed::RouteStatuses

  def run
      # This tasks assumes countinstance to route relations are already made.
    puts 'creating countInstanceStatus, countInstance, route assignment types'
    AssignmentType.find_or_initialize_by(name: 'countInstanceStatus').update_attributes(predetermined: true)
    at_status = AssignmentType.find_by(name: 'countInstanceStatus')
    AssignmentType.find_or_initialize_by(name: 'countInstance').update_attributes(predetermined: true)
    at_count_instance = AssignmentType.find_by(name: 'countInstance')
    AssignmentType.find_or_initialize_by(name: 'route').update_attributes(predetermined: true)
    at_route = AssignmentType.find_by(name: 'route')

    puts 'creating assignment relations'
    art_ci_to_status = AssignmentRelationType.where(
      assignment_1_type_id: [at_count_instance.id, at_status.id],
      assignment_2_type_id: [at_count_instance.id, at_status.id]
    ).first
    art_ci_to_status = AssignmentRelationType.create(
      assignment_1_type_id: at_count_instance.id,
      assignment_2_type_id: at_status.id,
      name: 'CountInstance to CountInstanceStatus'
    ) if art_ci_to_status.nil?

    art_route_to_status = AssignmentRelationType.where(
      assignment_1_type_id: [at_route.id, at_status.id],
      assignment_2_type_id: [at_status.id, at_route.id]
    ).first
    art_route_to_status = AssignmentRelationType.create(
      assignment_1_type_id: at_route.id,
      assignment_2_type_id: at_status.id,
      name: 'Route to CountInstanceStatus'
    ) if art_route_to_status.nil?

    art_route_to_ci = AssignmentRelationType.where(
      assignment_1_type_id: [at_route.id, at_count_instance.id],
      assignment_2_type_id: [at_count_instance.id, at_route.id]
    ).first
    art_route_to_ci = AssignmentRelationType.create(
      assignment_1_type_id: at_route.id,
      assignment_2_type_id: at_count_instance.id,
      name: 'Route to CountInstance'
    ) if art_route_to_ci.nil?


    asg_routes = Assignment.where(assignment_type_id: at_route.id)
    asg_count_instances = Assignment.where(assignment_type_id: at_count_instance.id)
    asg_statuses = Assignment.where(assignment_type_id: at_status.id)


    asg_count_instances.each do |ci|
      puts "creating relations for #{ci.name}"
      if art_route_to_ci.assignment_1_type_id == at_route.id
        ars = AssignmentRelation.where(assignment_relation_type_id: art_route_to_ci.id, assignment_2_id: ci.id)
        this_routes_ids = ars.map(&:assignment_1_id)
      else
        ars = AssignmentRelation.where(assignment_relation_type_id: art_route_to_ci.id, assignment_1_id: ci.id)
        this_routes_ids = ars.map(&:assignment_2_id)
      end

      ['not_started', 'in_progress', 'completed'].each do |status|
        x = Assignment.find_or_create_by(name: "#{ci.name}:#{status}", label: status, assignment_type_id: at_status.id)
        AssignmentRelation.find_or_create_by({
          assignment_relation_type_id: art_ci_to_status.id,
          assignment_1_id: ci.id,
          assignment_2_id: x.id
        })

        if status == 'not_started'
          this_routes_ids.each do |ro_id|
            puts "creating route to status relation for assignment id: #{ro_id}"
            AssignmentRelation.find_or_create_by({
              assignment_relation_type_id: art_route_to_status.id,
              assignment_1_id: ro_id,
              assignment_2_id: x.id
            })
          end
        end
      end
    end
  end

end
