class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user, :admin_user?

  private

  def current_user
    return unless session[:user_id]

    user = User.find_by(id: session[:user_id])
    if user&.disabled?
      session.delete(:user_id)
      return nil
    end
    @current_user ||= user
  end

  def admin_user?
    current_user&.admin?
  end

  def require_login!
    return if current_user

    if request.format.json?
      render json: { error: 'Trebuie să fii autentificat pentru a face asta.' }, status: :unauthorized
    else
      redirect_to log_in_path, alert: 'Trebuie să fii autentificat pentru a face asta.'
    end
  end

  def reject_user
    redirect_to root_path, alert: 'Nu ești autorizat!'
  end

  def authorize_admin!
    reject_user unless admin_user?
  end
end
