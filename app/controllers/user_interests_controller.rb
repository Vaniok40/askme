class UserInterestsController < ApplicationController
  before_action :reject_user

  def create
    tag = Tag.find(params[:tag_id])
    current_user.interests.find_or_create_by(tag: tag)
    redirect_back fallback_location: feed_path
  end

  def destroy
    current_user.interests.find_by(tag_id: params[:tag_id])&.destroy
    redirect_back fallback_location: feed_path
  end
end
