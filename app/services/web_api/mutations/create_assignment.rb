module WebApi::Mutations::CreateAssignmentResolver
  def self.call(obj, args, ctx)
    assignment_type = ::AssignmentType.find_or_create_by!(name: args[:assignment][:type])
    assignment = ::Assignment.find_or_create_by!(
      name: args[:assignment][:name],
      label: args[:assignment][:label],
      assignment_type_id: assignment_type.id
    )

    (args[:assignment][:properties] || []).each do |property_input|
      assignment_property_type = AssignmentPropertyType.find_or_create_by!(
        name: property_input[:type]
      ) { |type|
        type.label = property_input[:typeLabel]
      }

      # TODO Should this check for an existing property of this type on this assignment and raise?
      assignment_property = AssignmentProperty.create!(
        value: property_input[:value],
        assignment_id: assignment.id,
        assignment_property_type_id: assignment_property_type.id
      )
    end

    (args[:contextAssignmentIds] || []).each do |relative_id|
      r_at_id = Assignment.find(relative_id).assignment_type_id
      a_at_id = assignment.assignment_type_id
      art1 = AssignmentRelationType.find_by(assignment_1_type_id: r_at_id, assignment_2_type_id: a_at_id)
      if art1.present?
        p_id = assignment.id
        c_id = relative_id
      else # so if an art in another direction exists, or if no art exists (so default)
        p_id = relative_id
        c_id = assignment.id
      end


      WebApi::Mutations::CreateAssignmentRelationResolver.call(nil, {
        parentAssignmentId: p_id,
        childAssignmentId: c_id
      }, nil)
    end
    aps = AssignmentProperty.where(assignment_id: assignment.id)

    properties = aps.reduce({}) do |acc, ap|
      property_type_name = ap.assignment_property_type.name
      value = ap.value
      acc[property_type_name.to_sym] = value
      acc
    end
    x = assignment.attributes.merge({properties: properties}).deep_symbolize_keys
    x
  end
end
