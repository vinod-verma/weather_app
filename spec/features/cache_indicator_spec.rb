require 'rails_helper'

RSpec.feature 'Cache Indicator', type: :feature do
  around do |example|
    old_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.clear
    example.run
  ensure
    Rails.cache = old_cache
  end

  scenario 'shows No on first request and Yes on subsequent request for the same ZIP' do
    visit root_path
    fill_in 'ZIP Code', with: '12345'
    click_button 'Get Forecast'

    expect(page).to have_content('Weather Forecast')
    expect(page).to have_content('Cached: No')

    # Navigate back to the form and submit the same ZIP again
    click_link 'Check Another'
    fill_in 'ZIP Code', with: '12345'
    click_button 'Get Forecast'

    expect(page).to have_content('Cached: Yes')
  end
end
