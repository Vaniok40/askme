class FeedController < ApplicationController
  def index
    tag_ids = current_user&.interests&.pluck(:tag_id)

    @posts = if tag_ids.present?
      Post.for_interests(tag_ids)
    else
      Post.sorted_desc
    end.includes(:user, :tags, :likes, :comments)

    @all_tags = Tag.joins(:posts).distinct.order(:name)
  end
end
