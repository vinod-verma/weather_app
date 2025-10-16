# Simulates weather data and caches it by postal code for 30 minutes.
class WeatherSimulatorService
  CACHE_TTL = 30.minutes

  # Fetches weather data by postal code, using cache if available.
  # @param postal_code [String]
  # @return [Hash] { data: {...}, cached: true/false } or error hash
  def fetch_by_postal(postal_code)
    postal_code = postal_code.to_s.strip
    return { error: 'postal code blank', status: :bad_request } if postal_code.empty?

    cache_key = "weather_simulator:postal:#{postal_code}"
    cached = Rails.cache.read(cache_key)
    return { data: cached.merge(postal_code: postal_code), cached: true } if cached

    data = simulated_payload(postal_code)
    Rails.cache.write(cache_key, data, expires_in: CACHE_TTL)
    { data: data.merge(postal_code: postal_code), cached: false }
  end

  private

  # Generates simulated weather data for a given postal code.
  def simulated_payload(postal_code)
    seed = postal_code.hash.abs
    base_temp = 10 + (seed % 20)
    {
      city: "SimCity_#{postal_code}",
      country: "XX",
      temperature_c: base_temp,
      temp_min_c: base_temp - (1 + seed % 3),
      temp_max_c: base_temp + (1 + seed % 4),
      feels_like_c: base_temp + (seed % 2),
      humidity: 40 + (seed % 50),
      condition: %w[Clear Cloudy Rainy Stormy].fetch(seed % 4),
      wind_speed_m_s: 1 + (seed % 6),
      fetched_at: Time.now.utc.iso8601
    }
  end
end