# frozen_string_literal: true

# ShortLinkForm
class ShortLinkFormComponent < ViewComponent::Base
  def initialize(link:)
    @link = link
    super
  end
end
