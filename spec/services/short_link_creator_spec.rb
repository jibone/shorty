require 'rails_helper'

RSpec.describe ShortLinkCreator do
  describe '#call' do
    let(:link) { Link.new(title: 'Jibone blog', target_url: 'https://jshamsul.com') }
    let(:seed) { 'random-seed-x' }

    it 'generates a short code' do
      service = ShortLinkCreator.new(link, seed)
      result = service.call

      expect(result.short_code).to be_present
      expect(result.short_code.length).to eq(6)
    end

    it 'generate a unique short code based on the target_url and seed' do
      service1 = ShortLinkCreator.new(link, 'seed01')
      service2 = ShortLinkCreator.new(link, 'seed02')

      short_code1 = service1.call.short_code
      short_code2 = service2.call.short_code

      expect(short_code1).to_not eq(short_code2)
    end
  end
end
