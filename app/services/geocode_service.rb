# Service for geocoding addresses to postal codes.
class GeocodeService
  def initialize(timeout: 5)
    @timeout = timeout
  end

  # Finds the postal code for a given address.
  # @param address [String]
  # @return [Hash] { postal_code: '12345' } or { error: 'msg', status: :not_found }
  def find_postal_code_for(address)
    return { error: 'address blank', status: :bad_request } if address.to_s.strip.empty?

    results = Geocoder.search(address)
    if results.empty?
      return { error: 'Could not geocode the address', status: :not_found }
    end

    location = results.first
    postal = location.postal_code || location.data.dig('address', 'postcode') rescue nil

    if postal.blank?
      return { error: 'Postal code not available', status: :not_found }
    end

    { postal_code: postal }
  rescue StandardError => e
    { error: "Geocoding error: #{e.message}", status: :service_unavailable }
  end
end