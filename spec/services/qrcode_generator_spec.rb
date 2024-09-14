require 'rails_helper'

RSpec.describe QrcodeGenerator, type: :service do
  describe '#call' do
    let(:short_link) { 'http://example.com/short' }
    let(:qrcode_generator) { QrcodeGenerator.new(short_link) }

    it 'generates a QR code from the short link' do
      result = qrcode_generator.call

      expect(result).to be_an_instance_of(RQRCode::QRCode)
    end
  end
end
