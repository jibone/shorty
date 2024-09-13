# LinkClick
#
# Records click events on the short urls.
class LinkClick < ApplicationRecord
  belongs_to :link

  validates :ip_address, presence: true
end
