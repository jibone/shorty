require 'rails_helper'

RSpec.describe LinksController, type: :controller do
  describe 'GET #show' do
    let(:link) { create(:link) }

    context 'when short code is valid' do
      context 'when the link has clicks' do
        before do
          create(:link_click, link:, country: 'Singapore', device_type: 'desktop', browser_name: 'Chrome',
                              os_name: 'Windows')
          create(:link_click, link:, country: 'Malaysia', device_type: 'desktop', browser_name: 'Chrome',
                              os_name: 'MacOSX')
          create(:link_click, link:, country: 'Singapore', device_type: 'mobile', browser_name: 'Safari',
                              os_name: 'Windows')

          get :show, params: { short_code: link.short_code }
        end

        it 'assigns the requested link' do
          expect(assigns(:link)).to eq(link)
        end

        it 'assigns all the analytics stats' do
          expect(assigns(:analytics)[:total_clicks]).to eq(3)
          expect(assigns(:analytics)[:clicks_by_country]).to eq({ 'Singapore' => 2, 'Malaysia' => 1 })
          expect(assigns(:analytics)[:clicks_by_device]).to eq({ 'desktop' => 2, 'mobile' => 1 })
          expect(assigns(:analytics)[:clicks_by_browser]).to eq({ 'Chrome' => 2, 'Safari' => 1 })
          expect(assigns(:analytics)[:clicks_by_os]).to eq({ 'Windows' => 2, 'MacOSX' => 1 })
        end

        it 'renders the show template' do
          expect(response).to be_successful
          expect(response).to render_template(:show)
        end
      end

      context 'when the link has no clicks' do
        before do
          get :show, params: { short_code: link.short_code }
        end

        it 'assigns the requested link' do
          expect(assigns(:link)).to eq(link)
        end

        it 'assings 0 and empty for all the analytic stats' do
          expect(assigns(:analytics)[:total_clicks]).to eq(0)
          expect(assigns(:analytics)[:clicks_by_country]).to be_empty
          expect(assigns(:analytics)[:clicks_by_device]).to be_empty
          expect(assigns(:analytics)[:clicks_by_browser]).to be_empty
          expect(assigns(:analytics)[:clicks_by_os]).to be_empty
        end
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
    let(:valid_link_params) { { link: { label: 'Jibone Blog', target_url: 'https://jshamsul.com' } } }
    let(:invalid_url_params) { { link: { label: 'Wrong', target_url: 'ht@@tp:/huhu' } } }

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

        allow_any_instance_of(ShortLinkCreator).to receive(:call).and_raise(ActiveRecord::RecordNotUnique)

        post :create, params: valid_link_params

        expect(response).to redirect_to(new_links_path)
        expect(flash[:error]).to be_present
      end
    end
  end

  describe 'GET #redirect' do
    context 'when a valid short code is provided' do
      let(:ip_geo_locator_stub) { instance_double(IpGeoLocator) }
      let(:ip_geo_locator_result) do
        {
          country: 'Country',
          region: 'Region',
          city: 'City',
        }
      end

      before do
        allow(IpGeoLocator).to receive(:new).with(request.remote_ip).and_return(ip_geo_locator_stub)
        allow(ip_geo_locator_stub).to receive(:call).and_return(ip_geo_locator_result)
      end

      it 'redirects to the external URL' do
        new_link = create(:link, label: 'jibone', target_url: 'https://jshamsul.com')

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
