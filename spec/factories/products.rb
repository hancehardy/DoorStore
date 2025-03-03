FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { "A sample product description" }
    active { true }
    base_price { 100.00 }
    price_per_sqft { 15.00 }
    min_width { 8.0 }
    max_width { 48.0 }
    min_height { 8.0 }
    max_height { 96.0 }
    product_type { 'door_style' }

    trait :door_style do
      product_type { 'door_style' }
      name { 'Shaker' }
    end

    trait :finish do
      product_type { 'finish' }
      name { 'Natural Oak' }
      base_price { 0.00 }
      price_per_sqft { 5.00 }
    end

    trait :glass do
      product_type { 'glass' }
      name { 'Clear Glass' }
      base_price { 50.00 }
      price_per_sqft { 20.00 }
    end
  end
end
