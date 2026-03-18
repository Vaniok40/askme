class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user
  belongs_to :post, optional: true
  has_one_attached :image

  validates :body, length: { maximum: 2000 }
  validates :body, presence: true, unless: -> { image.attached? || post_id.present? }

  scope :sorted, -> { order(created_at: :asc) }
end
