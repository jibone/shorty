require 'rails_helper'

RSpec.describe ShortCodeCacheWriter, type: :service do
  let(:short_code) { 'abcdef' }
  let(:link) { 'https://example.com' }
  let(:namespace) { 'shorty' }
  let(:cache_key) { "#{namespace}:#{short_code}" }
  let(:service) { ShortCodeCacheWriter.new(short_code, link) }

  describe '#call' do
    before do
      allow(Rails.cache).to receive(:write)
      allow(Rails.logger).to receive(:info)
    end

    it 'writes the link to the cache with the correct key and expiration' do
      service.call

      expect(Rails.cache).to have_received(:write).with(
        cache_key,
        link,
        expires_in: 7.days
      )
    end

    it 'logs the cache write action' do
      service.call

      expect(Rails.logger).to have_received(:info).with(
        "Write cache: #{namespace}:#{short_code} with #{link}"
      )
    end
  end
end
