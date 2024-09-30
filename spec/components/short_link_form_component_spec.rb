# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShortLinkFormComponent, type: :component do
  let(:link) { FactoryBot.build(:link) }

  it 'renders the create short link form' do
    render_inline(described_class.new(link:))
    expect(page).to have_text 'Label'
    expect(page).to have_text 'URL'
  end
end
