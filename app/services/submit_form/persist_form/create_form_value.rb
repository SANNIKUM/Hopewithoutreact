module SubmitForm::PersistForm::CreateFormValue
  def self.run(sf_id, form_fields)
    rows = form_fields.reduce([]) do |acc, ff|
      if ff[:value].nil? || ff[:value] == ''
        acc
      else
        acc.push(self.generate_query(sf_id, ff))
      end
    end

    query = <<-SQL
      INSERT INTO form_values (#{self.column_names.join(', ')})
      VALUES #{rows.join(', ')};
    SQL
    ActiveRecord::Base.connection.execute(query)
  end

  private

  def self.generate_query(sf_id, ff)
    case ff[:field_type]
    when 'assignment'
      self.handle_assignment(sf_id, ff)
    when 'option'
      self.handle_option(sf_id, ff)
    when 'time'
      self.handle_time(sf_id, ff)
    else
      self.handle_default(sf_id, ff)
    end
  end

  def self.handle_assignment(sf_id, ff)
    if ff[:input_type] == 'string'
      at_id = FormField.find(ff[:form_field_id]).assignment_type_id
      asg_id = Assignment.find_or_create_by(name: ff[:value], assignment_type_id: at_id).id
      fvo_id = FormValueOption.find_or_create_by(assignment_id: asg_id).id
    else
      fvo_id = FormValueOption.find_or_create_by(assignment_id: ff[:value]).id
    end
    hash = {
      submitted_form_id: sf_id,
      form_field_id: ff[:form_field_id]
    }
    hash[:form_value_option_id] = fvo_id
    self.generate_insert_values_query(hash)
  end

  def self.handle_option(sf_id, ff)
    hash = {
      submitted_form_id: sf_id,
      form_field_id: ff[:form_field_id]
    }
    hash[:form_value_option_id] = ff[:value]
    self.generate_insert_values_query(hash)
  end

  def self.handle_time(sf_id, ff)
    hash = {
      submitted_form_id: sf_id,
      form_field_id: ff[:form_field_id]
    }
    hash[:datetime_value] = Time.at(ff[:value].to_f/1000).getutc.strftime('%Y-%m-%d %H:%M:%S.%N')
    self.generate_insert_values_query(hash)
  end

  def self.handle_default(sf_id, ff)
    hash = {
      submitted_form_id: sf_id,
      form_field_id: ff[:form_field_id]
    }
    hash["#{ff[:field_type]}_value".to_sym] = ff[:value]
    self.generate_insert_values_query(hash)
  end

  def self.generate_insert_values_query(hash)
    column_names = self.column_names
    values = ['NULL'] * column_names.length
    hash.each do |key, val|
      i = column_names.find_index(key.to_s)
      values[i] = "'#{val}'" if i
    end
    '(' + values.join(', ') + ')'
  end

  def self.column_names
    FormValue.column_names.reject { |name| name == 'id' }
  end
end
