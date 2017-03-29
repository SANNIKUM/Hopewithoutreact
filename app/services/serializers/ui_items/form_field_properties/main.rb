module Serializers::UiItems::FormFieldProperties::Main

  def self.run(args)
    ui_item_ids = args[:ui_items].map{|x| x[:id]}
    result = self.query(ui_item_ids, args[:asg_ids])
    final_result = self.merge(args[:ui_items], result)
    { ui_items: final_result }
  end

  private

  def self.query(*args)
    Serializers::UiItems::FormFieldProperties::Query.run(*args)
  end

  def self.merge(hashes, result)
    hashes.map do |hash|
      x = result.select{|y| y[:ui_item_id] === hash[:id] }
      if x.empty?
        hash.merge({
          is_form_field: false
        })
      else
        ele = x[0]
        hash.merge({
          is_form_field: true,
          form_field: {
            id: ele[:form_field_id],
            name: ele[:form_field_name],
            label: ele[:form_field_label],
            field_type: ele[:form_field_field_type],
            assignment_type_id: ele[:form_field_assignment_type_id],
            form_value_options: self.form_value_options(x)
          }
        })
      end
    end
  end

  def self.form_value_options(arr)
    if arr[0][:form_field_field_type] == 'option'
      y = arr.map do |x|
        {
          id: x[:form_value_option_id],
          label: x[:form_value_option_label],
          value: x[:form_value_option_value],
          order: x[:form_field_value_option_order].present? ? x[:form_field_value_option_order] : 0,
        }
      end
      y.sort_by{|x| x[:order] }
    elsif arr[0][:form_field_field_type] == 'assignment'
      z1 = arr.select{|x| x[:assignment_id].present? }
      z2 = z1.group_by{|x| x[:assignment_id]}
      z2.reduce([]) do |acc, (assignment_id, results)|
        fvo = FormValueOption.find_or_create_by(assignment_id: assignment_id)
        hash = {
          id: fvo.id,
          label: fvo.label,
          value: fvo.assignment_id,
          assignment: self.assignment(results)
        }
        acc.concat([hash])
      end
    else
      []
    end
  end

  def self.assignment(results)
    sample = results[0]
    {
      id: sample[:assignment_id],
      name: sample[:assignment_name],
      label: sample[:assignment_label],
      assignment_type_id: sample[:assignment_type_id],
      assignment_type: {
        id: sample[:assignment_type_id],
        name: sample[:assignment_type_name],
        label: sample[:assignment_type_label],
      },
    }.merge(self.assignment_properties(results))
  end

  def self.assignment_properties(results)
    results.select{|x| x[:assignment_property_type_name].present? }.reduce({}) do |acc, result|
      key = result[:assignment_property_type_name].to_sym
      value = result[:assignment_property_value]
      if acc[key].present?
        if acc[key].class.name == "Array"
          acc[key] = acc[key].concat([value])
        else
          acc[key] = [acc[key]].concat([value])
        end
      else
        acc[key] = value
      end
      acc
    end
  end

end
