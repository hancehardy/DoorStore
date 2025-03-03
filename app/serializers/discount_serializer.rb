class DiscountSerializer
  include JSONAPI::Serializer
  attributes :code, :discount_type, :value, :expiration_date, :active

  attribute :expired do |object|
    object.expired?
  end
end
