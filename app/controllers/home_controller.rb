# Home contorller
class HomeController < ApplicationController
  def index
    @current_user = current_user if logged_in?
    @link = Link.new
  end
end
