namespace :seed_qc do

  task :run => :environment do
    SeedQc.fix_team_names
  end

  module SeedQc

    def self.fix_team_names
      ci = Assignment.find_by name: 'nycQuarterlyCountApril2017'
      tci_art = AssignmentRelationType.find_by(name: "Team to CountInstance")
      ars = AssignmentRelation.where(assignment_relation_type_id: tci_art.id)
      t_ids = ars.map(&:assignment_1_id)
      ts = Assignment.where(id: t_ids)
      ts.each do |t|
        x = t.name.split(": ")
        site = x[0]
        num = x[1]
        new_name = "#{site}: Team #{num}"
        new_label = "Team #{num}"
        t.update(name: new_name, label: new_label)
      end
    end

    def self.run
      data = CSV.table('app/services/seed/data/nyc/ui_items/quarterly_count/qcdata.csv')
      self.helper(data)
    end

    def self.helper(data)
      x = {route_type: 'route', team_type: 'team', site_type: 'site', zone_type: 'zone'}.reduce({}) do |acc, (k,v)|
        acc[k] = AssignmentType.find_by name: v
        acc
      end

      y = {
            tr_art: "Team to Route",
            rs_art: "Route to Site",
            ts_art: "Team to Site",
            sz_art: "Site to Zone",
            tci_art: "Team to CountInstance",
            rci_art: "Route to CountInstance",
            sci_art: "Site to CountInstance",
            zci_art: "Zone to CountInstance",
        }.reduce({}) do |acc, (k,v)|
        acc[k] = AssignmentRelationType.find_by name: v
        acc
      end

      ci = Assignment.find_by name: "nycQuarterlyCountApril2017"
      AssignmentRelation.where(assignment_1_id: ci.id).delete_all
      AssignmentRelation.where(assignment_2_id: ci.id).delete_all

      config = x.merge(y).merge({ci: ci})



      data.each do |row|
        self.seed_assignments(row.to_hash, config)
      end
    end

    def self.seed_assignments(row, config)
      route_label = row[:route].upcase.lstrip.rstrip
      team_label = "team_#{row[:team].lstrip.rstrip}"
      site_name = row[:site].lstrip.rstrip
      zone_name = row[:zone].lstrip.rstrip

      route_name = "#{site_name}: #{route_label}"
      team_name = "#{site_name}: #{team_label}"

      x = {
        route: {name: route_name, label: route_label},
        team: {name: team_name, label: team_label},
        site: {name: site_name, label: site_name},
        zone: {name: zone_name, label: zone_name}
      }.reduce({}) do |acc, (k,v)|
        at_key = "#{k}_type".to_sym
        at = config[at_key]
        acc[k] = Assignment.find_or_create_by(name: v[:name], label: v[:label], assignment_type_id: at.id)
        acc
      end

      apt = AssignmentPropertyType.find_by name: 'type'
      AssignmentProperty.find_or_create_by(assignment_property_type_id: apt.id, value: 'Street', assignment_id: x[:route].id)

      x2 = x.merge({count_instance: config[:ci]})

      [
        [:team, :route, :tr_art],
        [:route, :site, :rs_art],
        [:team, :site, :ts_art],
        [:site, :zone, :sz_art],
        [:team, :count_instance, :tci_art],
        [:route, :count_instance, :rci_art],
        [:site, :count_instance, :sci_art],
        [:zone, :count_instance, :zci_art]
      ].each do |arr|
        asg1 = x2[arr[0]]
        asg2 = x2[arr[1]]
        art = config[arr[2]]

        z = AssignmentRelation.find_or_create_by(
          assignment_1_id: asg1.id,
          assignment_2_id: asg2.id,
          assignment_relation_type_id: art.id
        )
      end
    end
  end
end
