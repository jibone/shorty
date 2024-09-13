# frozen_string_literal: true

require "rails_helper"

RSpec.describe HeaderComponent, type: :component do
  let(:user) { create(:user) }

  it 'render Shorty title' do
    render_inline(described_class.new(user))
    expect(page).to have_text 'Shorty'
  end
end
