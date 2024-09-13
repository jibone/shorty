# Users Controller
class UsersController < ApplicationController
  before_action :require_user, only: [:dashboard]

  def new
    if logged_in?
      redirect_to users_dashboard_path
      return
    end

    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to user_login_form_path
    else
      flash.now[:error] = @user.errors.full_messages.join(', ')
      render :new
    end
  end

  def dashboard
    if logged_in?
      @user = current_user
      @links = @user.links
    else
      redirect_to root_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

  def require_user
    return if logged_in?

    redirect_to root_path # TODO: Redirect with a flash / alert message?
  end
end
