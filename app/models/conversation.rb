class Conversation < ApplicationRecord
  belongs_to :sender,    class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  has_many   :messages,  dependent: :destroy

  validates :sender_id, uniqueness: { scope: :recipient_id }

  scope :involving, ->(user) {
    where(sender_id: user.id).or(where(recipient_id: user.id))
  }

  scope :with_latest_message, -> {
    left_joins(:messages)
      .select('conversations.*, MAX(messages.created_at) AS last_message_at')
      .group('conversations.id')
      .order('last_message_at DESC NULLS LAST')
  }

  def self.between(user_a, user_b)
    where(sender_id: user_a.id, recipient_id: user_b.id)
      .or(where(sender_id: user_b.id, recipient_id: user_a.id))
      .first
  end

  def other_participant(user)
    sender == user ? recipient : sender
  end

  def unread_count_for(user)
    messages.where(read: false).where.not(user: user).count
  end
end
