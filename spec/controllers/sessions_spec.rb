require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with blank username' do
      it 'render new template with flash error message' do
        post :create

        expect(response).to render_template(:new)
        expect(flash.now[:error]).to be_present
      end
    end

    context 'with valid parameters' do
      let!(:user) { User.create(username: 'test', password: 'test') }

      it 'logs in the user and redirect to user dashboard page' do
        post :create, params: { username: 'test', password: 'test' }

        expect(response).to redirect_to(users_dashboard_path)
      end
    end

    context 'with invalid parameter' do
      let!(:user) { User.create(username: 'test', password: 'test') }
      it 'render new template with flash error' do
        post :create, params: { username: 'invalid', password: 'invalid' }

        expect(response).to render_template(:new)
        expect(flash.now[:error]).to be_present
      end
    end
  end
end
