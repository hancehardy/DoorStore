class OrderSerializer
  include JSONAPI::Serializer

  attributes :status, :total, :notes, :expires_at, :created_at, :updated_at

  belongs_to :user
  has_many :line_items
  has_many :products, through: :line_items

  attribute :items_count do |object|
    object.line_items.count
  end

  attribute :is_draft do |object|
    object.status == "draft"
  end

  attribute :is_expired do |object|
    object.expires_at.present? && object.expires_at < Time.current
  end

  attribute :items do |object|
    object.line_items.map do |item|
      {
        id: item.id,
        product_id: item.product_id,
        quantity: item.quantity,
        price: item.price,
        total: item.total
      }
    end
  end
end
