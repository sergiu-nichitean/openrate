class Rule < ApplicationRecord
  belongs_to :message

  enum trigger: %i[open click]

  def trigger_event(subscriber)
    case action_class
    when 'Tag'
      tag = Tag.find_by(id: action_id)
      return unless tag
      return if subscriber.tags.include? tag

      subscriber.tags << tag
    when 'Sequence'
      Sequence.find_by(id: action_id)&.add_subscriber(subscriber)
    end
  end
end
