FactoryBot.define do
  factory :order do
    total_price { 0.0 }
    status { 'pending' }
    expires_at { 30.days.from_now }
    shipping_address { {
      name: 'John Doe',
      street: '123 Main St',
      city: 'Los Angeles',
      state: 'CA',
      postal_code: '90210',
      country: 'US'
    } }
    billing_address { {
      name: 'John Doe',
      street: '123 Main St',
      city: 'Los Angeles',
      state: 'CA',
      postal_code: '90210',
      country: 'US'
    } }
    shipping_method { 'ground' }
  end
end
