results = [
  {ui_item_property_relation_id: 1, parent_id: 1, parent_type: },
  {ui_item_property_relation_id: 2, parent_id: 2, parent_type: }
]


results_with_recursive_properties = results.map do |hash|
  self.attach_properties(hash, results)
end


def self.attach_properties(hash, results)
  my_properties = self.find_my_properties(hash, results)
  my_properties2 = my_properties.map{|h| self.attach_properties(h, results) }
  hash.merge({properties: my_properties2})
end

def self.find_my_properties(hash, results)
  results.select do |x|
       x[:parent_type] == 'ui_item_property_relation'
    && x[:parent_id] == hash[:ui_item_property_relation_id]
  end
end
