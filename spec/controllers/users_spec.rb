require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    let(:valid_create_user_params) do
      { user: { username: 'jibone', password: 'password', password_confirm: 'password' } }
    end

    context 'with valid attribute' do
      it 'creates a user' do
        post :create, params: valid_create_user_params

        expect(response).to redirect_to(user_login_form_path)
      end
    end
  end

  describe 'GET #dashboard' do
    let(:user) { create(:user) }

    context 'when user is logged in' do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'renders the user dashboard view' do
        get :dashboard

        expect(response).to be_successful
        expect(response).to render_template(:dashboard)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root path' do
        get :dashboard

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
