# Session controller for user login and logout
class SessionsController < ApplicationController
  def new
    return unless logged_in?

    redirect_to users_dashboard_path
    nil
  end

  def create
    user = User.find_by(username: params[:username])

    if user.blank?
      flash.now[:error] = t('session.error.invalid_login')
      render :new
    else
      login_user(user, params)
    end
  end

  def destroy
    logout_user if user_logged_in?
    redirect_to root_path
  end

  private

  def login_user(user, params)
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      remember(user) if params[:remember_me] == '1'
      redirect_to users_dashboard_path(user)
    else
      flash.now[:error] = t('session.error.invalid_login')
      render 'new'
    end
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def logout_user
    puts 'logout the user'
    session.delete(:user_id)
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
    @current_user = nil
  end

  def user_logged_in?
    !session[:user_id].nil?
  end
end
