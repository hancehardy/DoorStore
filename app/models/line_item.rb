class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :price_per_unit, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :dimensions_within_product_limits
  validate :valid_glass_option_for_product
  validate :valid_finish_for_product

  before_validation :calculate_price_per_unit
  before_save :calculate_total_price

  def calculate_total_price
    return unless quantity && price_per_unit
    self.total_price = quantity * price_per_unit
  end

  private

  def calculate_price_per_unit
    return unless product && width && height && finish.present?

    glass_product = glass_option.present? ? Product.find_by(name: glass_option, product_type: "glass") : nil
    finish_product = Product.find_by(name: finish, product_type: "finish")

    return unless finish_product

    self.price_per_unit = PricingCalculator.calculate_price(
      width: width,
      height: height,
      door_style: product,
      finish: finish_product,
      glass_option: glass_product
    )
  end

  def dimensions_within_product_limits
    return unless product && width && height

    if width < product.min_width || width > product.max_width
      errors.add(:width, "must be between #{product.min_width} and #{product.max_width}")
    end

    if height < product.min_height || height > product.max_height
      errors.add(:height, "must be between #{product.min_height} and #{product.max_height}")
    end
  end

  def valid_glass_option_for_product
    return unless glass_option.present? && product
    return unless product.product_type == "door_style"

    available_glass = Product.where(product_type: "glass", active: true).pluck(:name)
    unless available_glass.include?(glass_option)
      errors.add(:glass_option, "must be one of: #{available_glass.join(', ')}")
    end
  end

  def valid_finish_for_product
    return unless finish.present? && product
    return unless product.product_type == "door_style"

    available_finishes = Product.where(product_type: "finish", active: true).pluck(:name)
    unless available_finishes.include?(finish)
      errors.add(:finish, "must be one of: #{available_finishes.join(', ')}")
    end
  end
end
