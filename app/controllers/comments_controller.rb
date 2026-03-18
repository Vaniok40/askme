class CommentsController < ApplicationController
  before_action :require_login!

  def create
    @post    = Post.find(params[:post_id])
    @comment = @post.comments.create(comment_params.merge(user: current_user))

    respond_to do |format|
      format.json do
        render json: {
          id:         @comment.id,
          body:       @comment.body,
          created_at: @comment.created_at.strftime('%b %d, %Y'),
          user: { username: @comment.user.username, name: @comment.user.name }
        }
      end
      format.html { redirect_to feed_path }
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy if current_user == @comment.user || admin_user?
    redirect_back fallback_location: feed_path
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
