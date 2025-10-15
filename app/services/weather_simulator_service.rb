# Simulates weather data and caches it by postal code for 30 minutes.
class WeatherSimulatorService
  CACHE_TTL = 30.minutes

  # Fetches weather data by postal code, using cache if available.
  # @param postal_code [String]
  # @return [Hash] { data: {...}, cached: true/false }
  def fetch_by_postal(postal_code)
    postal_code = postal_code.to_s.strip
    return { error: 'postal code blank', status: :bad_request } if postal_code.empty?

    cache_key = "weather_simulator:postal:#{postal_code}"
    cached = Rails.cache.read(cache_key)
    return { data: cached.merge(postal_code: postal_code), cached: true } if cached

    simulated = simulated_payload(postal_code)
    Rails.cache.write(cache_key, simulated, expires_in: CACHE_TTL)

    { data: simulated.merge(postal_code: postal_code), cached: false }
  end

  private

  # Generates simulated weather data for a given postal code.
  def simulated_payload(postal_code)
    {
      city: "SimCity_#{postal_code}",
      country: "XX",
      temperature_c: 20 + (postal_code.to_i % 10),
      temp_min_c: 18 + (postal_code.to_i % 5),
      temp_max_c: 25 + (postal_code.to_i % 5),
      feels_like_c: 21 + (postal_code.to_i % 4),
      humidity: 50 + (postal_code.to_i % 20),
      condition: ['Clear', 'Cloudy', 'Rainy', 'Stormy'].sample,
      wind_speed_m_s: 2 + (postal_code.to_i % 5),
      fetched_at: Time.now.utc.iso8601
    }
  end
end