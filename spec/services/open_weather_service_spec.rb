require 'rails_helper'

RSpec.describe OpenWeatherService, type: :service do
  let(:api_key) { 'dummy_key' }
  let(:service) { described_class.new(api_key: api_key) }

  around do |example|
    old_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.clear
    example.run
  ensure
    Rails.cache = old_cache
  end

  it 'returns normalized data on success' do
    stub_request(:get, /api.openweathermap.org/)
      .with(query: hash_including(zip: '12345,us', appid: api_key, units: 'metric'))
      .to_return(
        body: {
          name: 'Testville',
          sys: { country: 'US' },
          main: { temp: 21.5, temp_min: 19.0, temp_max: 24.0, feels_like: 22.0, humidity: 60 },
          weather: [{ description: 'clear sky' }],
          wind: { speed: 3.2 }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    result = service.fetch_by_postal('12345', country: 'us')
    expect(result[:cached]).to be false
    expect(result[:data]).to include(
      city: 'Testville',
      country: 'US',
      temperature_c: 21.5,
      temp_min_c: 19.0,
      temp_max_c: 24.0,
      feels_like_c: 22.0,
      humidity: 60,
      condition: 'clear sky',
      wind_speed_m_s: 3.2,
      postal_code: '12345'
    )
  end

  it 'caches results for 30 minutes' do
    stub_request(:get, /api.openweathermap.org/)
      .to_return(
        body: {
          name: 'Cachetown',
          sys: { country: 'US' },
          main: { temp: 20.0, temp_min: 18.0, temp_max: 22.0, feels_like: 20.5, humidity: 55 },
          weather: [{ description: 'cloudy' }],
          wind: { speed: 4.0 }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    first = service.fetch_by_postal('99999', country: 'us')
    second = service.fetch_by_postal('99999', country: 'us')

    expect(first[:cached]).to be false
    expect(second[:cached]).to be true
    expect(second[:data]).to eq(first[:data])
  end

  it 'handles missing API key' do
    service = described_class.new(api_key: '')
    result = service.fetch_by_postal('12345')
    expect(result[:error]).to eq('API key missing')
    expect(result[:status]).to eq(:unauthorized)
  end

  it 'propagates service unavailability' do
    stub_request(:get, /api.openweathermap.org/).to_raise(SocketError)
    result = service.fetch_by_postal('12345')
    expect(result[:error]).to eq('Weather service unavailable')
  end
end
