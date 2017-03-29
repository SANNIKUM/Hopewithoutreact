module Serializers::UiItems::ExpectedFormFields::Main

  def self.run(args)
    assignment_ids = args[:ui_items].reduce([]) do |acc, ui_item|
      acc.concat(ui_item[:assignments] || []).compact.uniq
    end

    expected_fields = ::ExpectedField.where(assignment_id: assignment_ids)

    ui_items_with_expected_fields = args[:ui_items].map do |u|
      form_field_ids = expected_fields.where(assignment_id: u[:assignments] || []).map(&:form_field_id).compact.uniq
      u.deep_merge({expected_form_field_ids: form_field_ids})
    end

    { ui_items: ui_items_with_expected_fields }
  end

end
