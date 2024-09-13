# frozen_string_literal: true

# Header Component
class HeaderComponent < ViewComponent::Base
  def initialize(current_user)
    @current_user = current_user
    super
  end
end
