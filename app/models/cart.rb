class Cart < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  # Methods
  def total
    cart_items.sum { |item| item.quantity * item.price }
  end

  def empty?
    cart_items.empty?
  end

  def item_count
    cart_items.sum(:quantity)
  end
end
