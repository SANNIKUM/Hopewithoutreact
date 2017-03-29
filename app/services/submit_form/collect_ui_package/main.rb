module SubmitForm::CollectUiPackage::Main

  def self.run(data)
    sf_id = data[:sf_id]
    data = self.submitted_form_extended_assignment_ids(data)
    asg_ids = data[:submitted_form_extended_assignment_ids]
    seed_ui_item_ids = self.collect_seed_ui_item_ids(asg_ids)
    ui_item_relations = self.collect_ui_item_relations(seed_ui_item_ids, asg_ids)
    ui_item_ids = seed_ui_item_ids.concat(ui_item_relations.map{ |x| x[:child_ui_item_id] }).compact.uniq
    ui_item_packages = self.ui_item_packages(ui_item_ids, asg_ids)
    data.merge({
      ui_items: ui_item_packages,
      ui_item_relations: ui_item_relations
    })
  end

  private

  def self.submitted_form_extended_assignment_ids(*args)
    SubmitForm::SubmittedFormExtendedAssignmentIds.run(*args)
  end

  def self.collect_seed_ui_item_ids(asg_ids)
    acsrs = AccessSetRelation.where(assignment_id: asg_ids)
    x = acsrs.to_set
    sids = acsrs.map(&:access_set_id)
    sids2 = sids.select do |sid|
      y = AccessSetRelation.where(access_set_id: sid).to_set
      bool = y.subset?(x)
      bool
    end
    acs = AccessSet.where(id: sids2)
    acs.map(&:ui_item_id)
  end

  def self.collect_ui_item_relations(*args)
    SubmitForm::CollectUiPackage::CollectUiItemRelations.run(*args)
  end

  def self.ui_item_packages(ui_item_ids, asg_ids)
    if ui_item_ids.empty?
      []
    else
      Serializers::UiItems::Main.run(ui_item_ids, asg_ids)
    end
  end
end
