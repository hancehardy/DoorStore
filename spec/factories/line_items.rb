FactoryBot.define do
  factory :line_item do
    order
    association :product, :door_style
    quantity { 1 }
    width { 24.0 }
    height { 30.0 }
    finish { 'Natural Oak' }
    glass_option { nil }
    price_per_unit { 200.00 }
    total_price { 200.00 }
  end
end
