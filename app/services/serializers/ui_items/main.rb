module Serializers::UiItems::Main

  def self.run(ui_item_ids, asg_ids)
    # name, form_field_id

    x = self.lift_and_compose_proc(
      self.computed_properties, # basically just is_form
      self.display_assignments,
      self.form_field_properties,
      self.assignments,
      self.expected_form_fields,
      self.extrinsic_properties,
      self.intrinsic_properties
    ).call({ui_item_ids: ui_item_ids, asg_ids: asg_ids})
    x[:ui_items]
  end

  private

  def self.lift_and_compose_proc(*args)
    LiftAndComposeProc.proc(*args)
  end

  def self.assignments
    Serializers::UiItems::Assignments::Main
  end

  def self.expected_form_fields
    Serializers::UiItems::ExpectedFormFields::Main
  end

  def self.intrinsic_properties
    Serializers::UiItems::IntrinsicProperties::Main
  end

  def self.extrinsic_properties
    Serializers::UiItems::ExtrinsicProperties::Main
  end

  def self.form_field_properties
    Serializers::UiItems::FormFieldProperties::Main
  end

  def self.display_assignments
    Serializers::UiItems::DisplayAssignments::Main
  end

  def self.computed_properties
    Serializers::UiItems::ComputedProperties::Main
  end

end
