require 'rails_helper'

RSpec.describe 'Checkout Process', type: :system do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user) }
  let(:door_style) { create(:product, :door_style) }
  let(:finish) { create(:product, :finish) }
  let(:glass) { create(:product, :glass) }

  before do
    driven_by(:selenium_chrome_headless)
    sign_in user
    create(:line_item, order: order, product: door_style, finish: finish.name)
  end

  it 'completes the checkout process successfully' do
    visit '/checkout'

    # Step 1: Billing/Shipping Information
    expect(page).to have_content('Shipping Address')

    fill_in 'First Name', with: 'John'
    fill_in 'Last Name', with: 'Doe'
    fill_in 'Address Line 1', with: '123 Main St'
    fill_in 'City', with: 'Anytown'
    fill_in 'State', with: 'CA'
    fill_in 'Postal Code', with: '12345'
    fill_in 'Phone', with: '555-123-4567'

    choose 'Imperial (inches)'
    click_button 'Continue to Payment'

    # Step 2: Payment Information
    expect(page).to have_content('Payment Information')

    fill_in 'Name on Card', with: 'John Doe'
    fill_in 'Card Number', with: '4111111111111111'
    fill_in 'Month', with: '12'
    fill_in 'Year', with: '25'
    fill_in 'CVV', with: '123'

    click_button 'Continue to Review'

    # Step 3: Review
    expect(page).to have_content('Order Summary')
    expect(page).to have_content(door_style.name)
    expect(page).to have_content(finish.name)

    click_button 'Place Order'

    # Confirmation
    expect(page).to have_content('Order Confirmation')
    expect(page).to have_content(order.id)
  end

  it 'allows navigation between steps' do
    visit '/checkout'

    # Fill out shipping info
    fill_in 'First Name', with: 'John'
    fill_in 'Last Name', with: 'Doe'
    fill_in 'Address Line 1', with: '123 Main St'
    fill_in 'City', with: 'Anytown'
    fill_in 'State', with: 'CA'
    fill_in 'Postal Code', with: '12345'
    fill_in 'Phone', with: '555-123-4567'

    click_button 'Continue to Payment'
    expect(page).to have_content('Payment Information')

    # Go back to shipping
    click_button 'Back'
    expect(page).to have_content('Shipping Address')
    expect(find_field('First Name').value).to eq('John')

    # Go forward to payment again
    click_button 'Continue to Payment'

    # Fill out payment info
    fill_in 'Name on Card', with: 'John Doe'
    fill_in 'Card Number', with: '4111111111111111'
    fill_in 'Month', with: '12'
    fill_in 'Year', with: '25'
    fill_in 'CVV', with: '123'

    click_button 'Continue to Review'
    expect(page).to have_content('Order Summary')

    # Go back to payment
    click_button 'Back'
    expect(page).to have_content('Payment Information')
    expect(find_field('Card Number').value).to eq('4111111111111111')
  end

  it 'validates required fields in each step' do
    visit '/checkout'

    # Step 1: Try to continue without filling required fields
    click_button 'Continue to Payment'
    expect(page).to have_content('First name is required')
    expect(page).to have_content('Address is required')

    # Fill out shipping info
    fill_in 'First Name', with: 'John'
    fill_in 'Last Name', with: 'Doe'
    fill_in 'Address Line 1', with: '123 Main St'
    fill_in 'City', with: 'Anytown'
    fill_in 'State', with: 'CA'
    fill_in 'Postal Code', with: '12345'
    fill_in 'Phone', with: '555-123-4567'

    click_button 'Continue to Payment'

    # Step 2: Try to continue without filling payment info
    click_button 'Continue to Review'
    expect(page).to have_content('Card number is required')
    expect(page).to have_content('CVV is required')

    # Fill out invalid card number
    fill_in 'Card Number', with: '1234'
    click_button 'Continue to Review'
    expect(page).to have_content('Please enter a valid 16-digit card number')
  end

  it 'persists data between steps' do
    visit '/checkout'

    # Fill out shipping info
    fill_in 'First Name', with: 'John'
    fill_in 'Last Name', with: 'Doe'
    fill_in 'Address Line 1', with: '123 Main St'
    fill_in 'City', with: 'Anytown'
    fill_in 'State', with: 'CA'
    fill_in 'Postal Code', with: '12345'
    fill_in 'Phone', with: '555-123-4567'

    click_button 'Continue to Payment'

    # Fill out payment info
    fill_in 'Name on Card', with: 'John Doe'
    fill_in 'Card Number', with: '4111111111111111'
    fill_in 'Month', with: '12'
    fill_in 'Year', with: '25'
    fill_in 'CVV', with: '123'

    click_button 'Continue to Review'

    # Verify data in review step
    expect(page).to have_content('John Doe')
    expect(page).to have_content('123 Main St')
    expect(page).to have_content('Card ending in 1111')
  end
end
