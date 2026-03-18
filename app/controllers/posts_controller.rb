class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :toggle_like]
  before_action :require_login!, only: [:new, :create, :edit, :update, :destroy, :toggle_like, :my_posts]

  def show
    @post.increment!(:views_count)
    @comments = @post.comments.includes(:user).order(created_at: :asc)

    respond_to do |format|
      format.json do
        render json: {
          id: @post.id,
          title: @post.title,
          body: @post.body,
          views_count: @post.views_count,
          likes_count: @post.likes.count,
          liked: @post.liked_by?(current_user),
          created_at: @post.created_at.strftime('%B %d, %Y'),
          user: {
            id: @post.user.id,
            username: @post.user.username,
            name: @post.user.name,
            color: @post.user.color
          },
          tags: @post.tags.map(&:name),
          comments: @comments.map { |c|
            {
              id: c.id,
              body: c.body,
              created_at: c.created_at.strftime('%b %d, %Y'),
              user: { username: c.user.username, name: c.user.name }
            }
          }
        }
      end
    end
  end

  def my_posts
    @posts = current_user.posts.includes(:tags, :likes, :comments).order(created_at: :desc)
  end

  def new
    @post = Post.new
    @all_tags = Tag.order(:name)
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to feed_path, notice: 'Postare publicată!'
    else
      render :new
    end
  end

  def edit
    authorize_post!
    @all_tags = Tag.order(:name)
  end

  def update
    authorize_post!
    if @post.update(post_params)
      redirect_to feed_path, notice: 'Postare actualizată!'
    else
      render :edit
    end
  end

  def destroy
    authorize_post!
    @post.destroy
    redirect_to feed_path
  end

  def toggle_like
    like = @post.likes.find_by(user: current_user)
    if like
      like.destroy
      liked = false
    else
      @post.likes.create(user: current_user) if current_user
      liked = true
    end
    render json: { liked: liked, likes_count: @post.likes.count }
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, tag_ids: [])
  end

  def authorize_post!
    redirect_to feed_path, alert: 'Nu ești autorizat.' unless current_user == @post.user || admin_user?
  end
end
