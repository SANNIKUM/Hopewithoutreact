module Serializers::UiItems::IntrinsicProperties::Main

  def self.run(args)
    # to get name, form_field_id
    x = UiItem.where(id: args[:ui_item_ids]).map(&:attributes).map(&:deep_symbolize_keys)
    { ui_items: x }
  end

end
