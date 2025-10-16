require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do
  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid zip code' do
      let(:zip) { '12345' }
      let(:weather_data) do
        {
          data: { city: 'SimCity_12345', temperature_c: 20 },
          cached: false
        }
      end

      before do
        allow_any_instance_of(WeatherSimulatorService)
          .to receive(:fetch_by_postal)
          .with(zip)
          .and_return(weather_data)
      end

      it 'renders show template with forecast data' do
        post :create, params: { zip: zip }
        
        expect(response).to render_template(:show)
        expect(assigns(:forecast_result)).to eq(weather_data[:data])
        expect(assigns(:cached)).to eq(weather_data[:cached])
      end
    end

    context 'with blank inputs' do
      it 'renders new template with error' do
        post :create, params: { address: '', zip: '' }
        
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq('Please enter an address or ZIP code.')
      end
    end
  end
end