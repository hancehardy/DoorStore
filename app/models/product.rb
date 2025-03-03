class Product < ApplicationRecord
  # Associations
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  # Validations
  validates :name, presence: true
  validates :product_type, presence: true, inclusion: { in: %w[door_style finish glass] }
  validates :price_per_sqft, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [ true, false ] }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(product_type: type) }
end
