# LinkAnalyticCalculator calculate links analytics
class LinkAnalyticCalculator
  def initialize(clicks)
    @clicks = clicks
  end

  def call
    {
      total_clicks: @clicks.size,
      clicks_by_country: group_by_attribute(:country),
      clicks_by_device: group_by_attribute(:device_type),
      clicks_by_browser: group_by_attribute(:browser_name),
      clicks_by_os: group_by_attribute(:os_name),
      clicks_by_referer: group_by_attribute(:referer),
    }
  end

  private

  def group_by_attribute(attribute)
    @clicks.group_by(&attribute).transform_values(&:count)
  end
end
