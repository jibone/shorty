# Users: username, password
class User < ApplicationRecord
  has_secure_password
  has_many :links, dependent: :destroy

  validates :username, presence: true, uniqueness: true

  before_create :generate_remember_token

  def remember
    self.remember_token = SecureRandom.urlsafe_base64
    save(validate: false)
  end

  private

  def generate_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
end
