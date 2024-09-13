require 'uri'

# class Link
class Link < ApplicationRecord
  belongs_to :user, optional: true
  has_many :link_clicks, dependent: :destroy

  validates :title, presence: true
  validates :short_code, presence: true
  validates :short_code, uniqueness: true
  validates :target_url, presence: true
  validate :valid_url_format

  private

  def valid_url_format
    uri = URI.parse(target_url)
    errors.add(:target_url, "must be a valid URL") unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    errors.add(:target_url, "must be a valid URL")
  end
end
