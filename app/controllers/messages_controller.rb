class MessagesController < ApplicationController
  before_action :require_login!

  # POST /conversations/:conversation_id/messages
  def create
    convo = Conversation.involving(current_user).find(params[:conversation_id])
    msg   = convo.messages.create!(user: current_user, body: params[:body].to_s.strip)

    render json: {
      id: msg.id,
      body: msg.body,
      mine: true,
      created_at: msg.created_at.strftime('%H:%M'),
      user: { name: current_user.name, username: current_user.username }
    }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /conversations/:conversation_id/messages/poll?after=ID
  def poll
    convo = Conversation.involving(current_user).find(params[:conversation_id])
    msgs  = convo.messages.sorted.where('id > ?', params[:after].to_i).includes(:user)

    # marchează ca citite
    msgs.where(read: false).where.not(user: current_user).update_all(read: true)

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

  # GET /conversations/unread_count
  def unread_count
    count = Message.joins(:conversation)
                   .where(read: false)
                   .where.not(user: current_user)
                   .where('conversations.sender_id = ? OR conversations.recipient_id = ?',
                          current_user.id, current_user.id)
                   .count
    render json: { count: }
  end
end
