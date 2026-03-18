class FeedController < ApplicationController
  def index
    filter_tag_ids = params[:tag_ids].presence&.map(&:to_i)

    base = if filter_tag_ids.present?
             Post.joins(:post_tags).where(post_tags: { tag_id: filter_tag_ids }).distinct
           elsif (interest_ids = current_user&.interests&.pluck(:tag_id)).present?
             Post.for_interests(interest_ids)
           else
             Post.sorted_desc
           end

    @posts    = base.includes(:user, :tags, :likes, :comments)
    @all_tags = Tag.joins(:posts).distinct.order(:name)
    @active_tag_ids = filter_tag_ids || []
  end
end
