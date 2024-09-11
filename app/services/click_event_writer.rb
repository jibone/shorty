# write the click event into database
class ClickEventWriter
  def initialize(link, request)
    @link = link
    @request = request
  end

  def call
    # Geolocation lookup from IP
    location = Geocoder.search(@request.remote_ip).first

    # Get browser details from user-agent
    browser = Browser.new(@request.user_agent)

    write_event(@link, @request, location, browser)
  end

  private

  def device(browser)
    device = 'desktop'
    device = 'mobile' if browser.device.mobile?
    device = 'tablet' if browser.device.tablet?
    device
  end

  def write_event(link, request, location, browser)
    LinkClick.create!(
      link:,
      ip_address: request.remote_ip,
      country: location&.country,
      region: location&.region,
      city: location&.city,
      device_type: device(browser),
      browser_name: browser.name,
      browser_version: browser.full_version,
      os_name: browser.platform.name,
      os_version: browser.platform.version,
      referer: request.referer
    )
  end
end
