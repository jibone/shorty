require 'rails_helper'

RSpec.describe LinkTitleFetcher do
  let(:url) { 'https://jshamsul.com' }
  let(:service) { LinkTitleFetcher.new(url) }

  describe '#call' do
    context 'When the response is successful' do
      it 'returns the title from the HTML' do
        response = instance_double(HTTParty::Response, code: 200,
                                                       body: "<html><head><title>Example Title</title></head></html>")
        allow(HTTParty).to receive(:get).with(url, timeout: 5).and_return(response)

        result = service.call

        expect(result).to eq("Example Title")
      end
    end

    context 'when the response code is not 200' do
      it 'returns an empty string' do
        response = instance_double(HTTParty::Response, code: 404, body: "")
        allow(HTTParty).to receive(:get).with(url, timeout: 5).and_return(response)

        result = service.call

        expect(result).to eq("")
      end
    end

    context 'when the title tag is not found' do
      it 'returns and empty stirng' do
        response = instance_double(HTTParty::Response, code: 200, body: "<html><head></head></html>")
        allow(HTTParty).to receive(:get).with(url, timeout: 5).and_return(response)

        result = service.call

        expect(result).to eq("")
      end
    end
  end
end
