require 'rails_helper'

RSpec.describe PaymentService do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user, total_price: 299.99) }
  let(:payment_method_id) { 'pm_card_visa' }

  before do
    allow(Stripe::PaymentIntent).to receive(:create).and_return(
      double(
        id: 'pi_123',
        status: 'succeeded',
        payment_method_details: { type: 'card', card: { brand: 'visa', last4: '4242' } }
      )
    )
  end

  describe '.process_payment' do
    context 'with valid payment details' do
      it 'processes the payment successfully' do
        result = PaymentService.process_payment(
          order: order,
          payment_method_id: payment_method_id
        )

        expect(result[:success]).to be true
        expect(order.payment_intent_id).to eq('pi_123')
        expect(order.payment_status).to eq('succeeded')
      end

      it 'creates a payment intent with correct amount' do
        expect(Stripe::PaymentIntent).to receive(:create).with(
          hash_including(
            amount: 29999,
            currency: 'usd',
            payment_method: payment_method_id
          )
        )

        PaymentService.process_payment(
          order: order,
          payment_method_id: payment_method_id
        )
      end
    end

    context 'with invalid payment details' do
      before do
        allow(Stripe::PaymentIntent).to receive(:create).and_raise(
          Stripe::CardError.new('Your card was declined.', nil, nil)
        )
      end

      it 'handles card errors gracefully' do
        result = PaymentService.process_payment(
          order: order,
          payment_method_id: payment_method_id
        )

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Your card was declined.')
        expect(order.payment_status).to eq('failed')
        expect(order.payment_error).to eq('Your card was declined.')
      end
    end

    context 'with Stripe API errors' do
      before do
        allow(Stripe::PaymentIntent).to receive(:create).and_raise(
          Stripe::APIError.new('Stripe API is down.')
        )
      end

      it 'handles Stripe API errors gracefully' do
        result = PaymentService.process_payment(
          order: order,
          payment_method_id: payment_method_id
        )

        expect(result[:success]).to be false
        expect(result[:error]).to eq('An error occurred while processing your payment.')
        expect(order.payment_status).to eq('failed')
      end
    end
  end
end
