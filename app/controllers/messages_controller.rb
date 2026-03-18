class MessagesController < ApplicationController
  before_action :require_login!

  # POST /conversations/:conversation_id/messages
  def create
    convo = Conversation.involving(current_user).find(params[:conversation_id])

    msg_attrs = { user: current_user }

    if params[:post_id].present?
      post = Post.find(params[:post_id])
      msg_attrs[:body]    = params[:body].to_s.strip
      msg_attrs[:post_id] = post.id
      msg_attrs[:kind]    = 'post_share'
    elsif params[:image].present?
      msg_attrs[:body] = params[:body].to_s.strip
      msg_attrs[:kind] = 'image'
    else
      msg_attrs[:body] = params[:body].to_s.strip
    end

    msg = convo.messages.build(msg_attrs)
    msg.image.attach(params[:image]) if params[:image].present?
    msg.save!

    render json: serialize_message(msg, true)
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /conversations/:conversation_id/messages/poll?after=ID
  def poll
    convo = Conversation.involving(current_user).find(params[:conversation_id])
    msgs  = convo.messages.sorted.where('id > ?', params[:after].to_i).includes(:user, post: :user)

    msgs.where(read: false).where.not(user: current_user).update_all(read: true)

    render json: msgs.map { |m| serialize_message(m, m.user_id == current_user.id) }
  end

  # GET /conversations/:conversation_id/messages
  def index
    convo = Conversation.involving(current_user).find(params[:conversation_id])
    msgs  = convo.messages.sorted.includes(:user, post: :user)

    msgs.where(read: false).where.not(user: current_user).update_all(read: true)

    render json: msgs.map { |m| serialize_message(m, m.user_id == current_user.id) }
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

  private

  def serialize_message(m, mine)
    data = {
      id:         m.id,
      body:       m.body,
      kind:       m.kind,
      mine:       mine,
      created_at: m.created_at.strftime('%H:%M'),
      user:       { name: m.user.name, username: m.user.username }
    }

    if m.kind == 'image' && m.image.attached?
      data[:image_url] = rails_blob_url(m.image)
    end

    if m.kind == 'post_share' && m.post
      p = m.post
      data[:post] = {
        id:       p.id,
        title:    p.title,
        body:     p.body.to_s[0, 200],
        username: p.user.username,
        name:     p.user.name
      }
    end

    data
  end
end
