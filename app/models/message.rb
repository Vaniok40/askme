class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :body, presence: true, length: { maximum: 2000 }

  scope :sorted, -> { order(created_at: :asc) }
end
