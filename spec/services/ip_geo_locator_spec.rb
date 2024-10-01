require 'rails_helper'
require 'httparty'

RSpec.describe IpGeoLocator do
  let(:ip) { '1.1.1.1' }
  let(:api_token) { 'test_token' }
  let(:service) { IpGeoLocator.new(ip) }
  let(:cache_key) { "geo_loc:#{ip}" }

  before(:each) do
    allow(Rails.application.credentials).to receive(:dig).with(:ipinfo, :access_token).and_return(api_token)
  end

  describe '#call' do
    context 'when location data is cached' do
      let(:cached_location_data) do
        {
          ip:,
          city: 'Bukit Panjang',
          region: 'North West',
          country: 'Singapore',
        }
      end

      it 'returns the cached location data' do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(cached_location_data)

        result = service.call

        expect(result).to eq(cached_location_data)
        expect(Rails.cache).not_to receive(:write)
      end
    end

    context 'when location data is not cached' do
      let(:api_response) do
        instance_double(HTTParty::Response, code: 200, parsed_response: {
                          'ip' => ip,
                          'city' => 'Selayang',
                          'region' => 'Selangor',
                          'country' => 'Malaysia',
                        })
      end

      let(:expected_location) do
        {
          ip:,
          city: 'Selayang',
          region: 'Selangor',
          country: 'Malaysia',
        }
      end

      before do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(nil) # No cache
      end

      it 'fetches the location from the API and caches it' do
        allow(HTTParty).to receive(:get).with("https://ipinfo.io/#{ip}?token=#{api_token}")
                                        .and_return(api_response)

        expect(Rails.cache).to receive(:write).with(cache_key, expected_location, expires_in: 24.hours)

        result = service.call

        expect(result).to eq(expected_location)
      end
    end

    context 'when the API response is unsuccessful' do
      let(:api_response) { instance_double(HTTParty::Response, code: 404) }

      before do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(nil)
        allow(HTTParty).to receive(:get).with("https://ipinfo.io/#{ip}?token=#{api_token}")
                                        .and_return(api_response)
      end

      it 'returns "unknown" and does not cache the result' do
        expect(Rails.cache).not_to receive(:write)

        result = service.call

        expect(result).to eq({
                               ip:,
                               city: 'unknown',
                               region: 'unknown',
                               country: 'unknown',
                             })
      end
    end

    context 'when an error is raised during the API call' do
      before do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(nil) # No cache
        allow(HTTParty).to receive(:get).and_raise(StandardError)
      end

      it 'rescues the error and returns "unknown"' do
        expect(Rails.cache).not_to receive(:write) # Ensure nothing is cached

        result = service.call

        expect(result).to eq({
                               ip:,
                               city: 'unknown',
                               region: 'unknown',
                               country: 'unknown',

                             })
      end
    end
  end
end
