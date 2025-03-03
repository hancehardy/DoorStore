class Discount < ApplicationRecord
  # Validations
  validates :code, presence: true, uniqueness: true
  validates :discount_type, presence: true, inclusion: { in: %w[percentage fixed] }
  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :expiration_date, presence: true
  validates :active, inclusion: { in: [ true, false ] }

  # Scopes
  scope :active, -> { where(active: true).where("expiration_date > ?", Time.current) }

  # Methods
  def expired?
    expiration_date < Time.current
  end

  def calculate_discount(amount)
    return 0 unless active? && !expired?

    if discount_type == "percentage"
      (amount * value / 100.0).round(2)
    else
      [ value, amount ].min
    end
  end
end
