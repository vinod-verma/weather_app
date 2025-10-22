class ForecastsController < ApplicationController
  def new
    # Renders input form
  end

  def create
    address = forecast_params[:address]&.strip
    zip = forecast_params[:zip]&.strip

    if address.blank? && zip.blank?
      flash.now[:alert] = 'Please enter an address or ZIP code.'
      return render :new
    end

    if zip.present?
      postal_code = zip
    else
      postal_code = fetch_postal_from_address(address)
      return unless postal_code # Halt if fetch_postal_from_address rendered :new
    end

  result = weather_client.fetch_by_postal(postal_code)
    @forecast_result = result[:data]
    @cached = result[:cached]

    render :show
  end

  private

  def forecast_params
    params.permit(:address, :zip)
  end

  def fetch_postal_from_address(address)
    geo = GeocodeService.new.find_postal_code_for(address)
    if geo[:error]
      flash.now[:alert] = geo[:error]
      render :new
      return nil # Ensure the action halts
    end
    geo[:postal_code]
  end

  # Select which weather provider to use.
  # Default to simulator for tests/dev; set WEATHER_PROVIDER=api to use OpenWeather.
  def weather_client
    provider = ENV['WEATHER_PROVIDER']&.downcase
    if provider == 'api'
      OpenWeatherService.new
    else
      WeatherSimulatorService.new
    end
  end
end
