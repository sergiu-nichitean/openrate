class Message < ApplicationRecord
  belongs_to :user
  has_one :broadcast
  has_many :sent_messages
  has_many :snapshot_subscribers
  has_many :rules

  def open_rule
    rules.where(trigger: 'open').first
  end

  def click_rule
    rules.where(trigger: 'click').first
  end

  def open_rule_for_select
    return nil unless open_rule

    "#{open_rule.action_class}-#{open_rule.action_id}"
  end

  def click_rule_for_select
    return nil unless click_rule

    "#{click_rule.action_class}-#{click_rule.action_id}"
  end

  def init_snapshot_subscribers(subscribers)
    arr = []
    subscribers.each do |s|
      arr << { message_id: id, subscriber_id: s.id, status: 'pending' }
    end
    SnapshotSubscriber.import arr
  end

  def done_sending?
    snapshot_subscribers.where(status: 'pending').empty?
  end
end
