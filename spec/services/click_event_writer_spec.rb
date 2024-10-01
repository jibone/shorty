require 'rails_helper'

RSpec.describe ClickEventWriter, type: :service do
  describe '#call' do
    let(:link) { create(:link) }
    let(:request) do
      double(
        remote_ip: '192.168.1.1',
        user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Safari/537.3',
        referer: 'http://referer.example.com'
      )
    end
    let(:ip_geo_locator_result) do
      {
        country: 'Country',
        region: 'Region',
        city: 'City',
      }
    end
    let(:device) do
      double(
        mobile?: false,
        tablet?: false
      )
    end
    let(:browser) do
      double(
        device:,
        name: 'Chrome',
        full_version: '58.0.3029.110',
        platform: double(name: 'Windows', version: '10')
      )
    end
    let(:click_event_writer) { ClickEventWriter.new(link, request) }
    let(:ip_geo_locator_stub) { instance_double(IpGeoLocator) }

    before do
      allow(IpGeoLocator).to receive(:new).with(request.remote_ip).and_return(ip_geo_locator_stub)
      allow(ip_geo_locator_stub).to receive(:call).and_return(ip_geo_locator_result)
      allow(Browser).to receive(:new).with(request.user_agent).and_return(browser)
    end

    it 'creates a LinkClick record with correct attributes' do
      expect do
        click_event_writer.call
      end.to change(LinkClick, :count).by(1)

      link_click = LinkClick.last
      expect(link_click.link).to eq(link)
      expect(link_click.ip_address).to eq(request.remote_ip)
      expect(link_click.country).to eq(ip_geo_locator_result[:country])
      expect(link_click.region).to eq(ip_geo_locator_result[:region])
      expect(link_click.city).to eq(ip_geo_locator_result[:city])
      expect(link_click.device_type).to eq('desktop') # Based on the provided user agent
      expect(link_click.browser_name).to eq(browser.name)
      expect(link_click.browser_version).to eq(browser.full_version)
      expect(link_click.os_name).to eq(browser.platform.name)
      expect(link_click.os_version).to eq(browser.platform.version)
      expect(link_click.referer).to eq(request.referer)
    end
  end
end
