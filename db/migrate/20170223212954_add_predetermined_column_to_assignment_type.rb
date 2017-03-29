class AddPredeterminedColumnToAssignmentType < ActiveRecord::Migration[5.0]
  def change
     add_column :assignment_types, :predetermined, :boolean
  end
end
