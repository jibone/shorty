require 'rails_helper'

RSpec.describe ShortCodeCacheRemover, type: :service do
  let(:short_code) { 'abcdef' }
  let(:namespace) { 'shorty' }
  let(:cache_key) { "#{namespace}:#{short_code}" }
  let(:service) { ShortCodeCacheRemover.new(short_code) }

  describe '#call' do
    before do
      allow(Rails.cache).to receive(:delete)
      allow(Rails.logger).to receive(:info)
    end

    it 'logs the cache deletion and deletes the cache entry' do
      expect(Rails.logger).to receive(:info).with("Cache delete: #{namespace}:#{short_code}")
      expect(Rails.cache).to receive(:delete).with(cache_key)

      service.call
    end
  end
end
