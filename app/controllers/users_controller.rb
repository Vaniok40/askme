class UsersController < ApplicationController
  layout 'auth', only: [:new]

  before_action :load_user, except: %i[index create new]
  before_action :require_login!, only: %i[show]
  before_action :authorize_user, except: %i[index new create show disable enable]
  before_action :authorize_admin!, only: %i[disable enable]

  def index
    @users = User.all
    @tags = Tag.with_questions
  end

  def new
    redirect_to root_path, alert: 'Ești deja autentificat!' if current_user.present?
    @user = User.new
  end

  def create
    redirect_to root_path, alert: 'Ești deja autentificat!' if current_user.present?
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: 'Bine ai venit!'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'Profil actualizat'
    else
      render 'edit'
    end
  end

  def show
    @questions       = @user.questions.order(created_at: :desc)
    @questions_count = @questions.count
    @answers_count   = @questions.with_answers.count
    @unanswered_count = @questions_count - @answers_count

    @posts           = @user.posts.includes(:tags, :likes, :comments).order(created_at: :desc).limit(5)
    @posts_count     = @user.posts.count
    @likes_received  = Like.joins(:post).where(posts: { user_id: @user.id }).count
    @interests       = @user.followed_tags.order(:name)

    @new_question    = @user.questions.build
  end

  def destroy
    @user.destroy
    redirect_to root_path, notice: 'Utilizator șters'
  end

  def disable
    @user.update(disabled: true)
    redirect_to user_path(@user), notice: "#{@user.username} a fost dezactivat."
  end

  def enable
    @user.update(disabled: false)
    redirect_to user_path(@user), notice: "#{@user.username} a fost reactivat."
  end

  private

  def authorize_user
    reject_user unless @user == current_user || admin_user?
  end

  def load_user
    @user ||= User.find params[:id]
  end

  def user_params
    permitted = %i[email password password_confirmation name username]
    permitted << :admin if admin_user?
    params.require(:user).permit(permitted)
  end
end
