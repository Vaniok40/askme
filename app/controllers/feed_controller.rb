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

    @posts          = base.order(created_at: :desc).includes(:user, :tags, :likes, :comments)
    @all_tags       = Tag.order(:name)
    @active_tag_ids = filter_tag_ids || []
  end

  def discover
    filter_tag_ids = params[:tag_ids].presence&.map(&:to_i)
    @query = params[:q].to_s.strip

    base = filter_tag_ids.present? \
      ? Post.joins(:post_tags).where(post_tags: { tag_id: filter_tag_ids }).distinct
      : Post.all

    base = base.where('posts.title LIKE :q OR posts.body LIKE :q', q: "%#{@query}%") if @query.present?

    @posts          = base.order(created_at: :desc).limit(30).includes(:user, :tags, :likes, :comments)
    @all_tags       = Tag.order(:name)
    @active_tag_ids = filter_tag_ids || []
  end
end
