require 'rails_helper'

RSpec.describe ShortCodeCacheRead, type: :service do
  let(:short_code) { 'abcdef' }
  let(:namespace) { 'shorty' }
  let(:cache_key) { "#{namespace}:#{short_code}" }
  let(:service) { ShortCodeCacheRead.new(short_code) }
  let(:link) { Link.new(short_code:, target_url: 'https://example.com') }

  describe '#call' do
    before do
      allow(Rails.cache).to receive(:read)
      allow(Rails.logger).to receive(:info)
    end

    context 'when cache contains the link (cache hit)' do
      it 'reads the link from the cache and logs the action' do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(link)

        result = service.call

        expect(result).to eq(link)
        expect(Rails.cache).to have_received(:read).with(cache_key)
      end
    end

    context 'when cache is empty (cache miss)' do
      before do
        allow(Rails.cache).to receive(:read).and_return(nil)
        allow(Link).to receive(:find_by).and_return(link)
        allow_any_instance_of(ShortCodeCacheWriter).to receive(:call)
      end

      it 'logs the cache miss, queries the database, and writes to the cache if link is found' do
        expect(Rails.logger).to receive(:info).with("Read cache: #{namespace}:#{short_code}")
        expect(Rails.logger).to receive(:info).with("Cache missed: #{namespace}:#{short_code}")
        expect_any_instance_of(ShortCodeCacheWriter).to receive(:call)

        result = service.call

        expect(result).to eq(link)
        expect(Link).to have_received(:find_by).with(short_code:)
      end
    end

    context 'when cache is empty and link is not found (cache miss with no link)' do
      before do
        allow(Rails.cache).to receive(:read).and_return(nil)
        allow(Link).to receive(:find_by).and_return(nil)
      end

      it 'logs the cache miss and returns nil if the link is not found' do
        expect(Rails.logger).to receive(:info).with("Read cache: #{namespace}:#{short_code}")
        expect(Rails.logger).to receive(:info).with("Cache missed: #{namespace}:#{short_code}")

        result = service.call

        expect(result).to be_nil
        expect(Link).to have_received(:find_by).with(short_code:)
      end
    end
  end
end
