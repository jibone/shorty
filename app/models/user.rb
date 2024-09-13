# User
#
# Stores user informatin
class User < ApplicationRecord
  has_secure_password
  has_many :links, dependent: :destroy

  validates :username, presence: true
  # TODO: figure out why rubocop is not picking up the schema,
  #       since I've already add the uniqueness index on the DB.
  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :username, uniqueness: true
  # rubocop:enable Rails/UniqueValidationWithoutIndex

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
