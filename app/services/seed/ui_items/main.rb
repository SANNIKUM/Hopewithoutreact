module Seed::UiItems::Main

  def self.run
    # Dont do anything which would disrupt archival submitted_forms
    AccessSetRelation.delete_all
    AccessSet.delete_all
    UiItemPropertyRelation.delete_all
    UiItemProperty.delete_all
    UiItemPropertyType.delete_all
    UiItem.delete_all
    UiItemRelation.delete_all
    FormFieldValueOption.delete_all
    self.directory
    Seed::AccessSets.run
    Seed::ExpectedFields.run
  end

  def self.part
    self.helper('ui_items_part')
  end

  def self.directory
    directory = Rails.root.join('app', 'services', 'seed', 'data', 'nyc', 'ui_items')

    # search for all json files in all subdirectories (recursively)
    files = Dir.glob(directory.join('**/*.json'))

    files.each do |f|
      puts "start seeding #{f}"
      data = ActiveSupport::JSON.decode(File.read(f))
      Seed::UiItems::SubMain.run(data, false)
    end
  end

  private

  def self.helper(filename)
    data = ActiveSupport::JSON.decode(File.read("app/services/seed/data/#{filename}.json"))
    complete_reset = (filename == 'complete')
    Seed::UiItems::SubMain.run(data, complete_reset)
  end
end
