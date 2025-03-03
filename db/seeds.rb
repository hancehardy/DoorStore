# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing products
Product.destroy_all

# Door Styles
[
  {
    name: 'Shaker',
    product_type: 'door_style',
    base_price: 100.00,
    price_per_sqft: 15.00,
    description: 'Classic five-piece door with a recessed center panel',
    min_width: 8.0,
    max_width: 48.0,
    min_height: 8.0,
    max_height: 96.0,
    active: true,
    specifications: {
      material: 'Solid Wood',
      construction: '5-piece',
      panel_style: 'Recessed'
    }
  },
  {
    name: 'Flat Panel',
    product_type: 'door_style',
    base_price: 80.00,
    price_per_sqft: 12.00,
    description: 'Modern door with a flat center panel',
    min_width: 8.0,
    max_width: 48.0,
    min_height: 8.0,
    max_height: 96.0,
    active: true,
    specifications: {
      material: 'MDF',
      construction: '5-piece',
      panel_style: 'Flat'
    }
  }
].each do |door_style|
  Product.create!(door_style)
end

# Finishes
[
  {
    name: 'Natural Oak',
    product_type: 'finish',
    base_price: 0.00,
    price_per_sqft: 5.00,
    description: 'Clear finish that highlights the natural wood grain',
    min_width: 0.0,
    max_width: 100.0,
    min_height: 0.0,
    max_height: 100.0,
    active: true,
    specifications: {
      type: 'Stain',
      color: 'Natural',
      sheen: 'Satin'
    }
  },
  {
    name: 'White Paint',
    product_type: 'finish',
    base_price: 0.00,
    price_per_sqft: 6.00,
    description: 'Pure white painted finish',
    min_width: 0.0,
    max_width: 100.0,
    min_height: 0.0,
    max_height: 100.0,
    active: true,
    specifications: {
      type: 'Paint',
      color: 'White',
      sheen: 'Semi-gloss'
    }
  }
].each do |finish|
  Product.create!(finish)
end

# Glass Types
[
  {
    name: 'Clear Glass',
    product_type: 'glass',
    base_price: 50.00,
    price_per_sqft: 20.00,
    description: 'Standard clear tempered glass',
    min_width: 8.0,
    max_width: 36.0,
    min_height: 8.0,
    max_height: 72.0,
    active: true,
    specifications: {
      type: 'Tempered',
      thickness: '4mm',
      transparency: 'Clear'
    }
  },
  {
    name: 'Frosted Glass',
    product_type: 'glass',
    base_price: 60.00,
    price_per_sqft: 25.00,
    description: 'Frosted tempered glass for privacy',
    min_width: 8.0,
    max_width: 36.0,
    min_height: 8.0,
    max_height: 72.0,
    active: true,
    specifications: {
      type: 'Tempered',
      thickness: '4mm',
      transparency: 'Frosted'
    }
  }
].each do |glass|
  Product.create!(glass)
end
