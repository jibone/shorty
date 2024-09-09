# frozen_string_literal: true

require "rails_helper"

RSpec.describe HeaderComponent, type: :component do
  it 'render Shorty title' do
    render_inline(described_class.new)
    expect(page).to have_text 'Shorty'
  end
end
