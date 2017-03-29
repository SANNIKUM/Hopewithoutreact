module Serializers::UiItems::ComputedProperties::Main

  def self.run(args)
    x = args[:ui_items].map do |u|
      u.merge({ is_form: self.form_names.include?(u[:uiItemType]) })
    end
    {ui_items: x}
  end

  private

  def self.form_names
    %w(
      singlePageForm
      sequenceForm
      instantFormSubmitButton
    )
  end
end
