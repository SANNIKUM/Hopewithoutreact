module Seed::AccessSets

  def self.run
    AccessSetRelation.delete_all
    AccessSet.delete_all

    self.update_or_create_initial_access_set

    data = self.access_sets
    data.each do |r|
      access_sets = r[:ui_items].map do |ui_item_name|
        puts " access sets for #{ui_item_name}"
        ui_item = UiItem.find_by(name: ui_item_name)
        AccessSet.create(ui_item_id: ui_item.id)
      end

      asgs = r[:assignments].keys.map do |k|
        at_id = AssignmentType.find_by(name: k.to_s).id
        assignment = Assignment.find_or_create_by(name: r[:assignments][k], assignment_type_id: at_id)
      end

      access_sets.each do |access_set|
        asgs.each do |asg|
          AccessSetRelation.create(access_set: access_set, assignment: asg)
        end
      end
    end
  end

  private

  def self.update_or_create_initial_access_set
    data = {
      assignments: { formType: "blankStateAppOpen" },
      ui_item: "nycQuarterlyCountUserCheckIn"
    }

    ui_item = UiItem.find_or_create_by(name: data[:ui_item])
    access_set = AccessSet.find_or_create_by(ui_item_id: ui_item.id)

    at = AssignmentType.find_by(name: data[:assignments].keys.first)
    asg = Assignment.find_or_create_by(name: data[:assignments].values.first, assignment_type_id: at.id)

    AccessSetRelation.find_or_initialize_by(assignment_id: asg.id).update_attributes(access_set_id: access_set.id)
  end

  def self.access_sets
    all_access_sets = [
      self.nyc_quarterly_count,
      self.nyc_annual_count
    ]
    all_access_sets.reduce([]) { |acc, x| acc.concat(x) }
  end

  def self.nyc_quarterly_count
    [
      {
        assignments: {
          formType: "userSignIn",
          municipality: "nyc",
          countType: "quarterlyCount",
        },
        ui_items: %w(
          nycQuarterlyCountPreSiteCheckIn
          nycQuarterlyCountSiteCheckIn
        )
      },
      {
        assignments: {
          formType: "userCheckIn",
          municipality: "nyc",
          countType: "quarterlyCount"
        },
        ui_items: %w(
          nycQuarterlyCountHome
          nycQuarterlyCountSurvey
          nycQuarterlyCountSummary
          nycQuarterlyCountAfterSiteCheckOutThankYou
        )
      },
      {
        assignments: {
          formType: "homeRefresh",
          municipality: "nyc",
          countType: "quarterlyCount"
        },
        ui_items: %w(
          nycQuarterlyCountHome
          nycQuarterlyCountSurvey
          nycQuarterlyCountSummary
          nycQuarterlyCountAfterSiteCheckOutThankYou
        )
      }
    ]
  end

  def self.nyc_annual_count
    [
      {
        assignments: {
          formType: "userSignIn",
          municipality: "nyc",
          countType: "annualCount",
        },
        ui_items: %w(
          nycAnnualCountPreSiteCheckIn
          nycAnnualCountSiteCheckIn
        )
      },
      {
        assignments: {
          formType: "userCheckIn",
          municipality: "nyc",
          countType: "annualCount",
        },
        ui_items: %w(
          nycAnnualCountSurvey
          nycAnnualCountHome
          nycAnnualCountSummary
          nycAnnualCountAfterSurveySubmit
          nycAnnualCountAfterSiteCheckOutThankYou
        )
      },
      {
        assignments: {
          formType: "homeRefresh",
          municipality: "nyc",
          countType: "annualCount"
        },
        ui_items: %w(
          nycAnnualCountSurvey
          nycAnnualCountHome
          nycAnnualCountSummary
          nycAnnualCountAfterSurveySubmit
          nycAnnualCountAfterSiteCheckOutThankYou
        )
      }
    ]
  end

  def self.sf_count
    [
      {
        assignments: {
          formType: "userCheckIn",
          municipality: "sf",
        },
        ui_items: ["sfSiteCheckIn"]
      },
      {
        assignments: {
          formType: "siteCheckIn",
          municipality: "sf"
      },
        ui_items: %w(
          sfSurvey
          sfHome
          sfRouteCheckIn
          sfAfterSiteCheckOutThankYou
        )
      }
    ]
  end

end
