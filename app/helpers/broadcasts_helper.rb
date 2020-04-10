module BroadcastsHelper
  def filter_value_input_for(filter_relation, filter_operator)
    input_type = input_type_for(filter_relation, filter_operator)

    if input_type == 'ddl'
      ddl_tag(ddl_values_for(filter_relation)).html_safe
    elsif input_type == 'text'
      text_tag.html_safe
    end
  end

  private

  def input_type_for(filter_relation, filter_operator)
    if %w[tag sequence].include? filter_relation
      'ddl'
    elsif %w[not_null null].include? filter_operator
      nil
    else
      'text'
    end
  end

  def ddl_values_for(filter_relation)
    return unless %w[tag sequence].include? filter_relation

    current_user.send("#{filter_relation}s")
  end

  def ddl_tag(values)
    return_value = '<select class="form-control" id="filter_value" name="filter_value">'
    values.each do |obj|
      return_value << "<option value=\"#{obj.id}\">#{obj.name}</option>"
    end
    return_value << '</select>'
  end

  def text_tag
    '<input type="text" class="form-control" id="filter_value">'
  end
end
