require 'rails_helper'

RSpec.describe WeatherSimulatorService, type: :service do
  let(:service) { described_class.new }
  let(:postal_code) { '12345' }

  describe '#fetch_by_postal' do
    before { Rails.cache.clear }

    it 'returns weather data for valid postal code' do
      result = service.fetch_by_postal(postal_code)
      
      expect(result[:data]).to include(
        city: "SimCity_#{postal_code}",
        country: "XX",
        temperature_c: be_kind_of(Numeric),
        temp_min_c: be_kind_of(Numeric),
        temp_max_c: be_kind_of(Numeric)
      )
      expect(result[:cached]).to be false
    end

    it 'returns error for blank postal code' do
      result = service.fetch_by_postal('')
      
      expect(result[:error]).to eq('postal code blank')
      expect(result[:status]).to eq(:bad_request)
    end
  end
end