# Weather App

## Overview

A Ruby on Rails app that accepts an address or ZIP code, retrieves (simulated) weather data, and caches results by ZIP code for 30 minutes.

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

# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
