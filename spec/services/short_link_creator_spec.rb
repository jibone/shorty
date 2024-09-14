require 'rails_helper'

RSpec.describe ShortLinkCreator, type: :service do
  let(:target_url) { 'https://example.com' }
  let(:link) { Link.new(target_url:) }
  let(:service) { ShortLinkCreator.new(link) }

  describe '#call' do
    context 'when short code is generated without collisions' do
      it 'generates and saves a short code for the link' do
        allow(link).to receive(:save).and_return(true) # Ensure save is successful
        result = service.call
        expect(result).to be true
        expect(link.short_code).to be_a(String)
        expect(link.short_code.length).to eq(6)
        expect(link.short_code).not_to be_empty
        expect(link).to have_received(:save) # Verify that the link was saved
      end
    end

    context 'when the maximum number of retries is exceeded' do
      before do
        allow(link).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)
        allow(service).to receive(:generate_short_code).and_return('123456')
      end

      it 'raises an ActiveRecord::RecordNotUnique exception after max retries' do
        expect { service.call }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
