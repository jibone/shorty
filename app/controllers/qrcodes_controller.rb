# QrcodesController
#
# Handles user requesting to download either png or svg QR code.
class QrcodesController < ApplicationController
  def download
    if params[:link].blank?
      head :bad_request
      return
    end

    qr_code = RQRCode::QRCode.new(params[:link])
    image_type = params[:format] == 'svg' ? 'svg' : 'png'

    if image_type == 'png'
      qr_code_png = qr_code.as_png(size: 300)
      send_data qr_code_png.to_s, type: 'image/png', disposition: 'attachment', filename: 'qrcode.png'
    else
      qr_code_svg = qr_code.as_svg(module_size: 6)
      send_data qr_code_svg, type: 'image/svg+xml', disposition: 'attachment', filename: 'qrcode.svg'
    end
  end
end
