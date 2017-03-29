module Serializers::UiItems::ExtrinsicProperties::Main

  def self.run(args)
    result = self.query(args)
    if result.to_a.empty?
      args
    else
      combined = self.combine_properties(result)
      { ui_items: self.merge(args[:ui_items], combined) }
    end
  end


  private

  def self.query(args)
    Serializers::UiItems::ExtrinsicProperties::Query.run(args)
  end

  def self.combine_properties(result)
    Serializers::UiItems::ExtrinsicProperties::CombineProperties.run(result)
  end

  def self.merge(ui_items, combined)
    ui_items.map do |u|
      properties = combined.find { |x| x[:id] == u[:id] }
      u.deep_merge(properties || {})
    end
  end

end
