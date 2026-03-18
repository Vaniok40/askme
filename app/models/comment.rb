class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  validates :body, presence: true, length: { maximum: 1000 }

  after_create :notify_post_owner

  private

  def notify_post_owner
    return if post.user_id == user_id

    Notification.create!(
      user: post.user,
      actor: user,
      kind: 'comment',
      notifiable: self
    )
  end
end
