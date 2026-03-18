class ConversationsController < ApplicationController
  before_action :require_login!

  # GET /conversations — lista pentru side panel (JSON)
  def index
    convos = Conversation.involving(current_user)
                         .includes(:sender, :recipient, :messages)
                         .with_latest_message

    render json: convos.map { |c|
      other = c.other_participant(current_user)
      last  = c.messages.max_by(&:created_at)
      {
        id: c.id,
        other_user: {
          id: other.id,
          name: other.name,
          username: other.username,
          color: helpers.avatar_color(other)
        },
        last_message: last ? { body: last.body.truncate(60), created_at: last.created_at.strftime('%d %b') } : nil,
        unread_count: c.unread_count_for(current_user)
      }
    }
  end

  # POST /conversations — pornește sau găsește conversație cu un user
  def create
    other = User.find(params[:recipient_id])
    convo = Conversation.between(current_user, other) ||
            Conversation.create!(sender: current_user, recipient: other)

    render json: {
      id: convo.id,
      other_user: {
        id: other.id,
        name: other.name,
        username: other.username,
        color: helpers.avatar_color(other)
      }
    }
  end

  # GET /conversations/:id/messages — mesajele dintr-o conversație (JSON)
  def messages
    convo = Conversation.involving(current_user).find(params[:id])

    # marchează ca citite mesajele celuilalt
    convo.messages.where(read: false).where.not(user: current_user).update_all(read: true)

    msgs = convo.messages.sorted.includes(:user)
    render json: msgs.map { |m|
      {
        id: m.id,
        body: m.body,
        mine: m.user_id == current_user.id,
        created_at: m.created_at.strftime('%H:%M'),
        user: { name: m.user.name, username: m.user.username }
      }
    }
  end
end
