class Order < ApplicationRecord
  # Associations
  has_many :line_items, dependent: :destroy
  belongs_to :user, optional: true

  # Validations
  validates :status, presence: true, inclusion: { in: %w[draft pending processing completed cancelled] }
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :shipping_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :shipping_address, presence: true, if: :requires_shipping_address?
  validates :billing_address, presence: true, if: :requires_billing_address?
  validates :shipping_method, presence: true, if: :requires_shipping_method?
  validates :payment_intent_id, uniqueness: true, allow_nil: true

  # Callbacks
  before_validation :set_default_status, on: :create
  before_save :calculate_total_price

  # Scopes
  scope :active_drafts, -> { where(status: "draft").where("expires_at > ?", Time.current) }
  scope :pending, -> { where(status: "pending") }
  scope :completed, -> { where(status: "completed") }
  scope :with_payment_status, ->(status) { where(payment_status: status) }

  def calculate_total_price
    subtotal = line_items.sum(&:total_price)
    shipping_cost = shipping_rate || 0
    self.total_price = subtotal + shipping_cost
  end

  def mark_as_pending
    update(status: "pending", expires_at: nil)
  end

  def mark_as_completed
    update(status: "completed", expires_at: nil)
  end

  def mark_as_cancelled
    update(status: "cancelled", expires_at: nil)
  end

  def requires_shipping_address?
    status != "draft" && status != "cancelled"
  end

  def requires_billing_address?
    status != "draft" && status != "cancelled"
  end

  def requires_shipping_method?
    status != "draft" && status != "cancelled"
  end

  def calculate_shipping_rates(to_zip)
    ShippingService.calculate_rates(order: self, to_zip: to_zip)
  end

  def process_payment(payment_method_id)
    PaymentService.process_payment(order: self, payment_method_id: payment_method_id)
  end

  private

  def set_default_status
    self.status ||= "draft"
    self.expires_at ||= 30.days.from_now if status == "draft"
  end
end
