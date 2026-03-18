class Like < ApplicationRecord
  belongs_to :post
  belongs_to :user
  validates :user_id, uniqueness: { scope: :post_id }

  after_create :notify_post_owner
  after_destroy :remove_notification

  private

  def notify_post_owner
    return if post.user_id == user_id
    Notification.create!(
      user: post.user,
      actor: user,
      kind: 'like',
      notifiable: post
    )
  end

  def remove_notification
    Notification.where(
      user: post.user,
      actor: user,
      kind: 'like',
      notifiable: post
    ).destroy_all
  end
end
