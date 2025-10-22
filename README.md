# Weather App

## Overview
A Ruby on Rails application that provides weather forecasts based on address or ZIP code input, with 30-minute result caching.

## Technical Requirements
- Ruby 3.2.2
- Rails 7.1.3
- SQLite3

## Installation and Setup

```bash
# Clone the repository
git clone <repository-url>
cd weather_app

# Install dependencies
bundle install

# (Optional) Prepare test database
bin/rails db:prepare
```

## Running the Application

```bash
bin/rails server
```

Then open http://localhost:3000 and enter an Address or ZIP Code.

## Running Tests

```bash
bundle exec rspec
```

To run a specific file:

```bash
bundle exec rspec spec/services/weather_simulator_service_spec.rb
bundle exec rspec spec/controllers/forecasts_controller_spec.rb
bundle exec rspec spec/features/check_weather_spec.rb
```

## Configuration

This app supports two providers:

- Simulator (default): deterministic weather data per ZIP, cached for 30 minutes. No external calls.
- OpenWeather (real API): enable with environment vars below.

To enable OpenWeather:

```bash
export OPENWEATHER_API_KEY=your_api_key_here
export WEATHER_PROVIDER=api
# Optional: default country for ZIP lookups (ISO alpha-2)
export OPENWEATHER_DEFAULT_COUNTRY=us
```

When enabled, the app uses `OpenWeatherService#fetch_by_postal` under the hood and caches responses per ZIP for 30 minutes.

## Object Decomposition

- **ForecastsController**: Handles user input, orchestrates geocoding and weather fetching.
- **WeatherSimulatorService**: Simulates and caches weather data by postal code (30-minute TTL).
- **GeocodeService**: Converts addresses to postal codes using the Geocoder gem.
- **Views**: Simple forms and result display.

## Design Patterns

- **Service Object Pattern**: For weather and geocoding logic.
- **Caching**: Rails cache for weather data.

## Scalability

- Caching reduces API/geocoding load.
- Service objects are stateless and easily extensible.

## Testing

- RSpec for unit, controller, and feature tests (see `/spec`).

## Usage

1. Enter an address or ZIP code.
2. View weather data (with cache indicator).

## Best Practices

- Clear naming and encapsulation.
- Single-responsibility methods.
- Code reuse via service objects.