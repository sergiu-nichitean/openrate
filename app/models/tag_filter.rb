class TagFilter < Filter
  def narrow_query(subscribers)
    subscribers.select do |s|
      if operator == 'eq'
        s.tag_ids.include? value.to_i
      else
        !s.tag_ids.include? value.to_i
      end
    end
  end

  def description
    readable_operator = operator == 'eq' ? 'is' : 'isn\'t'
    tag_name = Tag.find(value).name
    "Tag #{readable_operator} #{tag_name}"
  end
end
