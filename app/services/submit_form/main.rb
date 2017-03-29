module SubmitForm::Main

  def self.run(data)
    ComposeProc.proc(
      self.collect_ui_package,
      self.blanket_check_out,
      self.switch_based_check_out,
      self.update_assignment_status,
      self.automatic_assignment_form_value,
      self.automatic_assignments,
      self.persist_form
    ).call(data).slice(:ui_items, :ui_item_relations)
  end

  private

  def self.collect_ui_package
    SubmitForm::CollectUiPackage::Main
  end

  def self.blanket_check_out
    SubmitForm::BlanketCheckOut::Main
  end

  def self.switch_based_check_out
    SubmitForm::SwitchBasedCheckOut::Main
  end

  def self.automatic_assignment_form_value
    SubmitForm::AutomaticAssignmentFormValueProcess
  end

  def self.automatic_assignments
    SubmitForm::AutomaticAssignments::Main
  end

  def self.update_assignment_status
    SubmitForm::UpdateAssignmentStatus::Main
  end

  def self.persist_form
    SubmitForm::PersistForm::Main
  end
end
