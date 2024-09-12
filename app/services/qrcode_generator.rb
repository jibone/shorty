# QR Code generator svg and png
class QrcodeGenerator
  attr_reader :short_link

  def initialize(short_link)
    @short_link = short_link
  end

  def call
    RQRCode::QRCode.new(short_link)
  end
end
