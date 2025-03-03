class CartSerializer
  include JSONAPI::Serializer

  attributes :notes, :expires_at, :created_at, :updated_at

  belongs_to :user
  has_many :cart_items
  has_many :products, through: :cart_items

  attribute :total do |object|
    object.total
  end

  attribute :item_count do |object|
    object.item_count
  end

  attribute :items do |object|
    object.cart_items.map do |item|
      {
        id: item.id,
        product_id: item.product_id,
        quantity: item.quantity,
        price: item.price
      }
    end
  end
end
