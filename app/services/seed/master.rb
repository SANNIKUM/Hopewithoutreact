=begin

countType seed
  countType
  routes
  teams
  sites

  relate
    route, countType
    route, team
    route, site
    team, site

countInstance
  countInstance

  relate
    countInstance, countType


ORDER

assignment_types
assignment_relation_types
assignments_and_relations
assignment_geometry
automatic_assignments
automatic_assignment_form_values
switch_based_checkout

ui_items
expected_fields
access_sets

general process :
  input pkg is a json with a key for each of the processes above
  value is either a json hash or a filename string pointing to where the
  data is defined (to be used for csvs, ie assignments_and_their_relations, or other jsons, ie route_geometry)
  ##JSON.parse(File.read('app/assets/javascripts/flickr_feed.json'))
  (or an array of filename strings (for when you want to split csvs up into multiple files))





































=end
