module Seed::All

  def self.run
    Seed::Delete.run

    Seed::AssignmentTypes.run
    Seed::AutomaticAssignments.run
    Seed::SwitchBasedCheckOuts.run
    Seed::AutomaticAssignmentFormValues.run

    Seed::Assignments.run
    Seed::Teams.run
    Seed::RouteGeometry.run


    Seed::CountInstance.run

    Seed::UiItems::Main.run
    Seed::AccessSets.run
    Seed::ExpectedFields.run

  end
end
