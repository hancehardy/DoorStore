class PaymentService
  class PaymentError < StandardError; end

  def self.process_payment(order:, payment_method_id:)
    new(order, payment_method_id).process_payment
  end

  def initialize(order, payment_method_id)
    @order = order
    @payment_method_id = payment_method_id
  end

  def process_payment
    begin
      intent = create_payment_intent
      confirm_payment(intent) if intent.status == "requires_confirmation"

      # Update order with payment details
      @order.update!(
        payment_intent_id: intent.id,
        payment_status: intent.status,
        payment_method_details: intent.payment_method_details&.to_h
      )

      { success: true, intent: intent }
    rescue Stripe::CardError => e
      handle_card_error(e)
    rescue Stripe::StripeError => e
      handle_stripe_error(e)
    rescue => e
      handle_generic_error(e)
    end
  end

  private

  def create_payment_intent
    Stripe::PaymentIntent.create(
      amount: (@order.total_price * 100).to_i, # Convert to cents
      currency: "usd",
      payment_method: @payment_method_id,
      confirmation_method: "manual",
      confirm: true,
      description: "Order ##{@order.id}",
      metadata: {
        order_id: @order.id,
        customer_email: @order.user&.email
      }
    )
  end

  def confirm_payment(intent)
    Stripe::PaymentIntent.confirm(intent.id)
  end

  def handle_card_error(error)
    @order.update(payment_status: "failed", payment_error: error.message)
    { success: false, error: error.message }
  end

  def handle_stripe_error(error)
    @order.update(payment_status: "failed", payment_error: error.message)
    { success: false, error: "An error occurred while processing your payment." }
  end

  def handle_generic_error(error)
    Rails.logger.error("Payment processing error: #{error.message}")
    @order.update(payment_status: "failed", payment_error: "An unexpected error occurred.")
    { success: false, error: "An unexpected error occurred." }
  end
end
