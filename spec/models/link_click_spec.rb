require 'rails_helper'

RSpec.describe LinkClick, type: :model do
  describe 'associations' do
    it { should belong_to(:link) }
  end

  describe 'validation' do
    it { should validate_presence_of(:ip_address) }
  end
end
