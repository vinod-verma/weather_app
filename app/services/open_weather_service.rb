# app/services/open_weather_service.rb
# Fetches real weather data from OpenWeather and caches by ZIP for 30 minutes.
# Returns a unified shape compatible with the views: { data: {...}, cached: true/false }
#
# Environment variables:
# - OPENWEATHER_API_KEY: required to call the API
# - OPENWEATHER_DEFAULT_COUNTRY: optional, default 'us'

require 'httparty'

class OpenWeatherService
  include HTTParty
  base_uri 'https://api.openweathermap.org/data/2.5'

  CACHE_TTL = 30.minutes

  def initialize(api_key: ENV['OPENWEATHER_API_KEY'])
    @api_key = api_key
  end

  # Fetch weather by postal code, caching results.
  # @param postal_code [String]
  # @param country [String] ISO alpha-2 country code, default from env or 'us'
  # @return [Hash] { data: {...}, cached: Boolean } or { error: message, status: symbol }
  def fetch_by_postal(postal_code, country: ENV.fetch('OPENWEATHER_DEFAULT_COUNTRY', 'us'))
    postal_code = postal_code.to_s.strip
    return { error: 'postal code blank', status: :bad_request } if postal_code.empty?
    return { error: 'API key missing', status: :unauthorized } if @api_key.to_s.strip.empty?

    cache_key = "openweather:postal:#{country.downcase}:#{postal_code}"

    if (cached = Rails.cache.read(cache_key))
      return { data: cached.merge(postal_code: postal_code), cached: true }
    end

    response = self.class.get('/weather', query: { zip: "#{postal_code},#{country}", appid: @api_key, units: 'metric' })
    unless response.success?
      return { error: 'Unable to fetch weather data', status: :service_unavailable }
    end

    data = normalize_response(response)
    Rails.cache.write(cache_key, data, expires_in: CACHE_TTL)
    { data: data.merge(postal_code: postal_code), cached: false }
  rescue SocketError, Errno::ECONNREFUSED, Net::OpenTimeout
    { error: 'Weather service unavailable', status: :service_unavailable }
  end

  private

  # Normalize OpenWeather response to our view-friendly hash
  def normalize_response(response)
    {
      city: response['name'],
      country: response.dig('sys', 'country'),
      temperature_c: response.dig('main', 'temp'),
      temp_min_c: response.dig('main', 'temp_min'),
      temp_max_c: response.dig('main', 'temp_max'),
      feels_like_c: response.dig('main', 'feels_like'),
      humidity: response.dig('main', 'humidity'),
      condition: response.dig('weather', 0, 'description'),
      wind_speed_m_s: response.dig('wind', 'speed'),
      fetched_at: Time.now.utc.iso8601
    }
  end
end
