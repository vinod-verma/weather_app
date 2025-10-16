require 'rails_helper'

RSpec.feature 'Check Weather', type: :feature do
  scenario 'user checks weather with valid zip code' do
    visit root_path
    
    fill_in 'ZIP Code', with: '12345'
    click_button 'Get Forecast'

    expect(page).to have_content('Weather Forecast')
    expect(page).to have_content('SimCity_12345')
    expect(page).to have_content('Temperature')
  end

  scenario 'user submits form without input' do
    visit root_path
    
    click_button 'Get Forecast'

    expect(page).to have_content('Please enter an address or ZIP code.')
  end
end