require 'httparty'

# IpGeoLocator find location from ipaddress
class IpGeoLocator
  CACHE_EXPIRY = 24.hours

  def initialize(ip)
    @ip = ip
  end

  def call
    Rails.logger.info "Read cache: #{cache_key}"
    cached_location = Rails.cache.read(cache_key)
    return cached_location if cached_location

    Rails.logger.info "Cache missed: #{cache_key}"
    location_data = fetch_ip_location

    Rails.cache.write(cache_key, location_data, expires_in: CACHE_EXPIRY) if location_data[:country] != 'unknown'
    location_data
  end

  private

  def cache_key
    "geo_loc:#{@ip}"
  end

  def default_location_data
    {
      ip: @ip,
      city: 'unknown',
      region: 'unknown',
      country: 'unknown',
    }
  end

  def fetch_ip_location
    unknown_location_data = default_location_data
    api_token = Rails.application.credentials.dig(:ipinfo, :access_token)
    response = HTTParty.get("https://ipinfo.io/#{@ip}?token=#{api_token}")

    return unknown_location_data unless response.code == 200

    location_data = response.parsed_response

    {
      ip: location_data['ip'],
      city: location_data['city'],
      region: location_data['region'],
      country: location_data['country'],
    }
  rescue StandardError
    unknown_location_data
  end
end
