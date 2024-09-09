require 'rails_helper'

RSpec.describe Link, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:target_url) }
    it { should validate_presence_of(:short_code) }
    it { should validate_uniqueness_of(:short_code) }

    let(:link) { FactoryBot.build(:link) }

    context 'when the URL is valid' do
      it 'returns valid with HTTP URL' do
        link.target_url = 'http://jshamsul.com'
        expect(link).to be_valid
      end

      it 'returns valid with HTTPS URL' do
        link.target_url = 'https://jshamsul.com'
        expect(link).to be_valid
      end
    end

    context 'when the URL is not valid' do
      it 'returns not valid with URL without scheme' do
        link.target_url = 'jshamsul.com'
        expect(link).not_to be_valid
      end

      it 'returns not valid with non-HTTP/HTTPS URL' do
        link.target_url = 'ftp://jshamsul.com'
        expect(link).not_to be_valid
      end

      it 'returns not valid with malformed URL' do
        link.target_url = 'ht@@tp:/jshamsul.com'
        expect(link).not_to be_valid
      end
    end
  end
end
