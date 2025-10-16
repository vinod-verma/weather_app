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
```

## Object Decomposition

- **ForecastsController**: Handles user input, orchestrates geocoding and weather fetching.
- **WeatherSimulatorService**: Simulates and caches weather data by postal code.
- **GeocodeService**: Converts addresses to postal codes using the Geocoder gem.
- **Views**: Simple forms and result display.

## Design Patterns

- **Service Object Pattern**: For weather and geocoding logic.
- **Caching**: Rails cache for weather data.

## Scalability

- Caching reduces API/geocoding load.
- Service objects are stateless and easily extensible.

## Testing

- RSpec for unit and controller tests (see `/spec`).

## Usage

1. Enter an address or ZIP code.
2. View weather data (with cache indicator).

## Best Practices

- Clear naming and encapsulation.
- Single-responsibility methods.
- Code reuse via service objects.