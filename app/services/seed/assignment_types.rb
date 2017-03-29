module Seed::AssignmentTypes

  def self.run
    assignment_types = {
      route: true,
      site: true,
      zone: true,
      team: true,
      user: false,
      formType: true,
      formTypeCategory: true,
      municipality: true,
      countInstance: true,
      countType: true
    }

    assignment_types.each do |name, predetermined|
      at = AssignmentType.find_or_create_by(name: name, predetermined: predetermined)
      FormField.find_or_create_by(name: name, label: name, field_type: 'assignment', assignment_type_id: at.id)
    end

  end

end
