class NotificationsController < ApplicationController
  before_action :require_login!

  # GET /notifications — lista recentă (JSON)
  def index
    notifs = current_user.notifications.recent.includes(:actor, :notifiable)
    render json: notifs.map { |n| serialize(n) }
  end

  # GET /notifications/unread_count
  def unread_count
    render json: { count: current_user.notifications.unread.count }
  end

  # PATCH /notifications/mark_all_read
  def mark_all_read
    current_user.notifications.unread.update_all(read: true)
    render json: { ok: true }
  end

  # PATCH /notifications/:id/mark_read
  def mark_read
    notif = current_user.notifications.find(params[:id])
    notif.update(read: true)
    render json: { ok: true }
  end

  private

  def serialize(n)
    post = case n.notifiable_type
           when 'Post'    then n.notifiable
           when 'Comment' then n.notifiable&.post
           end

    notifiable_url   = post ? "/posts/#{post.id}" : nil
    notifiable_title = post&.title

    {
      id: n.id,
      kind: n.kind,
      read: n.read,
      created_at: time_ago(n.created_at),
      actor: {
        id: n.actor.id,
        name: n.actor.name,
        username: n.actor.username,
        color: helpers.avatar_color(n.actor)
      },
      notifiable_url:,
      notifiable_title:
    }
  end

  def time_ago(time)
    diff = (Time.current - time).to_i
    if diff < 60
      'acum'
    elsif diff < 3600
      "acum #{diff / 60} min"
    elsif diff < 86_400
      "acum #{diff / 3600} h"
    else
      time.strftime('%d %b')
    end
  end
end
