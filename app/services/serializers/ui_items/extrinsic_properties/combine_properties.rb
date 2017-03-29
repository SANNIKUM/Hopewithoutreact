module Serializers::UiItems::ExtrinsicProperties::CombineProperties

  def self.run(result)
    y = result.to_a.map(&:deep_symbolize_keys).group_by{|x| x[:ui_item_property_parent_type]}
    z1 = y['ui_item'] || []
    z2 = y['ui_item_property_relation'] || []

    self.merge_properties(z1, z2)
  end

  private

  def self.merge_properties(ui_uip_arr, uipr_uip_arr)
    x = ui_uip_arr.group_by{|y| y[:ui_item_property_parent_id]}
    x.reduce([]) do |acc, (parent_id, properties_arr)|
      properties_hash = self.merge_properties_helper(properties_arr, uipr_uip_arr, true)
      new_hash = {id: parent_id}.merge(properties_hash)
      acc.concat([new_hash])
    end
  end

  def self.merge_properties_helper(properties_arr, uipr_uip_arr, is_top_property)
    properties_arr.reduce({}) do |acc, property_hash|
      k = property_hash[:ui_item_property_type_name].to_sym
      v = property_hash[:ui_item_property_value]
      ffid = property_hash[:ui_item_property_form_field_id]
      is_singleton = property_hash[:is_singleton]
      children, uipr_uip_arr = self.find_children(property_hash[:ui_item_property_relation_id], uipr_uip_arr)
      child_id = property_hash[:ui_item_property_child_id]
      if children.any?
        childish_properties = self.merge_properties_helper(children, uipr_uip_arr, false)
        value = {id: child_id, value: v, form_field_id: ffid}.merge(childish_properties)
      elsif !is_top_property || ffid.present?
        value = {id: child_id, value: v, form_field_id: ffid}
      else
        value = v
      end

      if is_singleton
        acc[k] = value
      else
        acc[k] = (acc[k] || []).concat([value])
      end
      acc
    end
  end

  def self.find_children(id, uipr_uip_arr)
    uipr_uip_arr.partition do |uipr_uip|
      uipr_uip[:ui_item_property_parent_id] == id
    end
  end

end
