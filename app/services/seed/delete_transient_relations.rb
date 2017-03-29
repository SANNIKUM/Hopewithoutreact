module Seed::DeleteTransientRelations
  def self.run
    arts = AssignmentRelationType.where(name: self.transient_relation_types)
    ars = AssignmentRelation.where(assignment_relation_type_id: arts.ids)
    ars.delete_all
  end


  def self.transient_relation_types
    [
     "User to Site",
     "User to Team",
     "User to Countinstance",
     "User to Municipality",
     "User to CountInstance",
   ]
  end
end
