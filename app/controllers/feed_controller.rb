class FeedController < ApplicationController
  def index
    raw = Array.wrap(params[:tag_ids] || params['tag_ids[]']).flatten
    filter_tag_ids = raw.map(&:to_i).presence
    @query = params[:q].to_s.strip

    if current_user
      followed_ids = current_user.following.pluck(:id)
      base = followed_ids.any? ? Post.where(user_id: followed_ids) : Post.all
    else
      base = Post.all
    end

    base = base.joins(:post_tags).where(post_tags: { tag_id: filter_tag_ids }).distinct if filter_tag_ids.present?
    base = base.where('posts.title LIKE :q OR posts.body LIKE :q', q: "%#{@query}%") if @query.present?

    @posts          = base.order(created_at: :desc).includes(:user, :tags, :likes, :comments).page(params[:page]).per(15)
    @all_tags       = Tag.order(:name)
    @active_tag_ids = filter_tag_ids || []
  end

  def discover
    filter_tag_ids = params[:tag_ids].presence&.map(&:to_i)
    @query  = params[:q].to_s.strip
    @offset = params[:offset].to_i.clamp(0, Float::INFINITY)

    base = filter_tag_ids.present? \
      ? Post.joins(:post_tags).where(post_tags: { tag_id: filter_tag_ids }).distinct
      : Post.all

    base = base.where('posts.title LIKE :q OR posts.body LIKE :q', q: "%#{@query}%") if @query.present?

    ordered         = base.order(created_at: :desc)
    @total          = ordered.count
    @posts          = ordered.offset(@offset).limit(30).includes(:user, :tags, :likes, :comments)
    @all_tags       = Tag.order(:name)
    @active_tag_ids = filter_tag_ids || []
    @has_more       = (@offset + 30) < @total

    respond_to do |format|
      format.html
      format.json do
        render json: {
          posts: @posts.map { |p|
            {
              id:           p.id,
              title:        p.title,
              body:         p.body.truncate(100),
              likes_count:  p.likes.size,
              comments_count: p.comments.size,
              tags:         p.tags.first(3).map(&:name),
              user: {
                name:  p.user.name,
                color: helpers.avatar_color(p.user)
              }
            }
          }
        }
      end
    end
  end
end
