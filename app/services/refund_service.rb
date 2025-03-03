class RefundService
  class RefundError < StandardError; end

  def self.process(order:, amount:, reason:)
    new(order, amount, reason).process
  end

  def initialize(order, amount, reason)
    @order = order
    @amount = amount
    @reason = reason
  end

  def process
    begin
      # Validate refund amount
      validate_amount!

      # Process refund through Stripe
      refund = create_stripe_refund

      # Update order with refund details
      update_order(refund)

      # Send refund notification
      send_refund_notification

      { success: true, refund: refund }
    rescue Stripe::StripeError => e
      handle_stripe_error(e)
    rescue RefundError => e
      handle_refund_error(e)
    rescue => e
      handle_generic_error(e)
    end
  end

  private

  def validate_amount!
    raise RefundError, "Invalid refund amount" if @amount <= 0
    raise RefundError, "Refund amount exceeds order total" if @amount > @order.total_price
  end

  def create_stripe_refund
    Stripe::Refund.create(
      payment_intent: @order.payment_intent_id,
      amount: (@amount * 100).to_i,
      reason: @reason
    )
  end

  def update_order(refund)
    @order.update!(
      refund_status: "refunded",
      refund_amount: @amount,
      refund_reason: @reason,
      refund_processed_at: Time.current,
      refund_id: refund.id
    )
  end

  def send_refund_notification
    OrderMailer.refund_processed(@order).deliver_later
  end

  def handle_stripe_error(error)
    Rails.logger.error("Stripe refund error: #{error.message}")
    { success: false, error: "Payment processor error: #{error.message}" }
  end

  def handle_refund_error(error)
    Rails.logger.error("Refund validation error: #{error.message}")
    { success: false, error: error.message }
  end

  def handle_generic_error(error)
    Rails.logger.error("Unexpected refund error: #{error.message}")
    { success: false, error: "An unexpected error occurred while processing the refund." }
  end
end
