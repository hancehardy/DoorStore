class ProductSerializer
  include JSONAPI::Serializer

  attributes :name, :product_type, :base_price, :price_per_sqft,
             :description, :min_width, :max_width, :min_height, :max_height,
             :active, :specifications, :created_at, :updated_at

  attribute :meta do |object|
    {
      title: object.meta_title,
      description: object.meta_description
    }
  end

  attribute :dimensions do |object|
    {
      width: {
        min: object.min_width,
        max: object.max_width
      },
      height: {
        min: object.min_height,
        max: object.max_height
      }
    }
  end
end
