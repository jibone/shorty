# HomeController
#
# Handles the main landing page.
class HomeController < ApplicationController
  def index
    @current_user = current_user if logged_in?
    @link = Link.new
  end
end
