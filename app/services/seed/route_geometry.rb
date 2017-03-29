module Seed::RouteGeometry

  def self.run
    self.cool('nyc')
  end

  def self.sf
    self.cool('sf')
  end

  def self.clear_and_run
    apt1 = AssignmentPropertyType.where(name: 'multipolygon_coordinates')
    apt2 = AssignmentPropertyType.where(name: 'point_coordinates')
    apt_ids = apt1.to_a.concat(apt2.to_a).map(&:id)
    ap = AssignmentProperty.where(assignment_property_type: apt_ids)
    ap.delete_all
    self.run
  end

  private

  def self.cool(cityname)
    data = ActiveSupport::JSON.decode(File.read("app/services/seed/data/#{cityname}/qc_route_geometry.json"))
    data['features'].each do |f|
      self.helper(f)
    end
  end

  def self.helper(f)
    n = f['properties']['Name']
    zn = f['properties']['zone']
    g = f['geometry']
    t = g['type']
    c = g['coordinates'].to_s

    type = (t == 'MultiPolygon') ? 'multipolygon' : 'point'

    at = AssignmentType.find_by(name: "route")

    z = Assignment.find_by(name: zn)
    sz_art = AssignmentRelationType.find_by name: "Site to Zone"
    rs_art = AssignmentRelationType.find_by name: "Route to Site"
    sz_ar = AssignmentRelation.where(assignment_relation_type_id: sz_art.id, assignment_2_id: z.id)
    site_id = sz_ar.first.assignment_1_id
    rs_ars = AssignmentRelation.where(assignment_relation_type_id: rs_art.id, assignment_2_id: site_id)
    routes = Assignment.where(id: rs_ars.map(&:assignment_1_id))

    asg = routes.find_by(label: n.downcase) || routes.find_by(label: n)
    
    if asg.present?
      asg.update(label: n)
      apt = AssignmentPropertyType.find_or_create_by(name: "#{type}_coordinates", is_singleton: true)
      ap = AssignmentProperty.find_or_create_by(assignment: asg, assignment_property_type: apt, value: c)
    end
  end
end











#
