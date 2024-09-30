require 'uri'

# Link model
#
# Stores the target_link, the generated short code.
# - Validates the link format for the targeted links.
# - Generate the full short url with the request host.
class Link < ApplicationRecord
  belongs_to :user, optional: true
  has_many :link_clicks, dependent: :destroy

  validates :label, presence: true
  # validates :title, presence: true
  validates :short_code, presence: true
  validates :short_code, uniqueness: true
  validates :target_url, presence: true
  validate :valid_url_format

  def full_short_url(request)
    port = ''
    port = ":#{request.port}" if request.port != 443 && request != 80

    "#{request.protocol}#{request.host}#{port}/#{short_code}"
  end

  private

  def valid_url_format
    uri = URI.parse(target_url)
    errors.add(:target_url, "must be a valid URL") unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    errors.add(:target_url, "must be a valid URL")
  end
end
