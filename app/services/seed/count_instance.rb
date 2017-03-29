module Seed::CountInstance

  def self.run
    cit = AssignmentType.find_by(name: 'countInstance')

    self.data.each do |hash|
      ci = Assignment.find_or_create_by(name: hash[:countInstance], assignment_type: cit)

      ars1 = AssignmentRelation.where(assignment_1_id: ci.id)
      ars2 = AssignmentRelation.where(assignment_2_id: ci.id)
      ars1.delete_all
      ars2.delete_all


      hash[:specificAssignmentRelations].each do |k, value|
        if value.class.name == "Array"
          value.each{|x| self.helper(cit, ci, k, x) }
        else
          self.helper(cit, ci, k, value)
        end
      end

      hash[:genericAssignmentRelations].each do |at_name|
        at = AssignmentType.find_by(name: at_name)
        asgs = Assignment.where(assignment_type_id: at.id)
        art = AssignmentRelationType.find_or_create_by(
          name: "#{self.format_name(at_name)} to CountInstance",
          assignment_1_type_id: at.id,
          assignment_2_type_id: cit.id
        )
        asgs.each do |asg|
          AssignmentRelation.find_or_create_by(assignment_1_id: asg.id, assignment_2_id: ci.id)
        end
      end
    end
  end

  def self.helper(cit, ci, k, value)
    at = AssignmentType.find_by(name: k.to_s)
    art_name = "#{self.format_name(k.to_s)} to CountInstance"
    art = AssignmentRelationType.find_or_create_by name: art_name, assignment_1_type_id: at.id, assignment_2_type_id: cit.id
    asg = Assignment.find_or_create_by name: value, assignment_type: at
    AssignmentRelation.find_or_create_by(assignment_1_id: asg.id, assignment_2_id: ci.id)
  end


  def self.format_name(s)
    s.titleize.split(" ").join("")
  end

  def self.data
    [
      {
        countInstance: "nycAnnualCountFebruary2017",
        specificAssignmentRelations: {
          countType: "annualCount",
          municipality: "nyc",
          site: [
            "Hunter College",
            "Hostos",
            "Brooklyn College",
            "LaGuardia",
          ]
        },
        genericAssignmentRelations: [
          "team",
          "route",
          "zone"
        ]
      },
      {
        countInstance: "nycQuarterlyCountApril2017",
        specificAssignmentRelations: {
          countType: "quarterlyCount",
          municipality: "nyc",
          site: [
            "Hunter College",
            "Hostos",
            "Brooklyn College",
            "LaGuardia",
          ],
        },
        genericAssignmentRelations: [
          "team",
          "route",
          "zone"
        ]
      }
    ]

  end

end
