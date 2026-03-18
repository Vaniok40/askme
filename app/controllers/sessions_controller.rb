class SessionsController < ApplicationController
  layout 'auth', only: %i[new create]

  def new; end

  def create
    @user = User.authenticate(params[:email], params[:password])

    if @user.present? && !@user.disabled?
      session[:user_id] = @user[:id]
      redirect_to root_path, notice: 'Bine ai venit!'
    elsif @user&.disabled?
      flash.now.alert = 'Acest cont a fost dezactivat.'
      render :new
    else
      flash.now.alert = 'Email sau parolă incorectă.'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'Te-ai deconectat!'
  end
end
