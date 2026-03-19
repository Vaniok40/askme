class FollowsController < ApplicationController
  before_action :require_login!

  def create
    @user = User.find(params[:id])
    current_user.follows_as_follower.find_or_create_by(followed: @user) unless current_user == @user
    redirect_back fallback_location: user_path(@user)
  end

  def destroy
    @user = User.find(params[:id])
    current_user.follows_as_follower.find_by(followed: @user)&.destroy
    redirect_back fallback_location: user_path(@user)
  end
end
