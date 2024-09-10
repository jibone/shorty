require 'rails_helper'

RSpec.describe LinksController, type: :controller do
  describe 'GET #show' do
    context 'when short code is valid' do
      it 'returns a successful response' do
        link = Link.create(title: 'Jibone Blog', target_url: 'https://jshamsul.com', short_code: 'qwerty')
        get :show, params: { short_code: link.short_code }
        expect(response).to be_successful
      end
    end

    context 'when short code is invalid' do
      it 'renders a not found template' do
        get :show, params: { short_code: 'invalid_short_code' }
        expect(response).to render_template(:not_found)
      end
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    let(:valid_link_params) { { link: { title: 'Jibone Blog', target_url: 'https://jshamsul.com' } } }
    let(:invalid_url_params) { { link: { title: 'Wrong', target_url: 'ht@@tp:/huhu' } } }

    context 'with valid attribute' do
      it 'creates a shorten url redirect to shorten link page' do
        post :create, params: valid_link_params

        expect(response).to redirect_to(short_code_links_path(assigns(:link).short_code))
        expect(flash[:success]).to be_present
      end
    end

    context 'when the URL is invalid' do
      it 'does not create a short URL and re-renders the from with error' do
        post :create, params: invalid_url_params

        expect(response).to redirect_to(new_links_path)
        expect(flash[:error]).to be_present
      end
    end

    context 'when a unique short URL collision occurs' do
      it 'handles the collision and retries generation a new short URL' do
        create(:link, target_url: 'https://jshamsul.com')

        allow_any_instance_of(Link).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)

        post :create, params: valid_link_params

        expect(response).to redirect_to(new_links_path)
        expect(flash[:error]).to be_present
      end
    end
  end

  describe 'GET #redirect' do
    context 'when a valid short code is provided' do
      it 'redirects to the external URL' do
        new_link = create(:link, title: 'jibone', target_url: 'https://jshamsul.com')

        get :redirect, params: { short_code: new_link.short_code }

        expect(response).to redirect_to(new_link.target_url)
        expect(response.status).to eq(302)
      end
    end

    context 'when an invalid short code is provided' do
      it 'renders a not found template' do
        get :redirect, params: { short_code: "invalid_short_code" }

        expect(response).to render_template(:not_found)
      end
    end
  end
end
