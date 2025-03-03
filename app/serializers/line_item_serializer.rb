class LineItemSerializer
  include JSONAPI::Serializer

  attributes :quantity, :width, :height, :glass_option, :finish,
             :price_per_unit, :total_price, :created_at, :updated_at

  belongs_to :product
  belongs_to :order

  attribute :product_details do |object|
    {
      name: object.product.name,
      type: object.product.product_type,
      description: object.product.description
    }
  end
end
