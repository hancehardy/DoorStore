class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_price, on: :create

  private

  def set_price
    self.price = product.price_per_sqft if product.present? && price.nil?
  end
end
