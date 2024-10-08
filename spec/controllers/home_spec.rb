require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    it 'returns a successsful response' do
      get :index
      expect(response).to be_successful
    end
  end
end
