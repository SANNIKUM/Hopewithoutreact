class AddOrderToFormFieldsFormValueOptions < ActiveRecord::Migration[5.0]
  def change
    add_column :form_fields_value_options, :order, :integer
  end
end
