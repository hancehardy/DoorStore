import React, { useState, useEffect } from 'react';
import { useStripe, useElements, CardElement } from '@stripe/stripe-react-js';

const CARD_ELEMENT_OPTIONS = {
  style: {
    base: {
      color: '#32325d',
      fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
      fontSmoothing: 'antialiased',
      fontSize: '16px',
      '::placeholder': {
        color: '#aab7c4'
      }
    },
    invalid: {
      color: '#fa755a',
      iconColor: '#fa755a'
    }
  }
};

const PaymentStep = ({ initialData, onComplete, onBack }) => {
  const stripe = useStripe();
  const elements = useElements();
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const [shippingRates, setShippingRates] = useState([]);
  const [selectedShipping, setSelectedShipping] = useState(null);

  useEffect(() => {
    if (initialData?.shipping_address?.postal_code) {
      fetchShippingRates(initialData.shipping_address.postal_code);
    }
  }, [initialData]);

  const fetchShippingRates = async (postalCode) => {
    try {
      const response = await fetch('/api/v1/shipping_rates/calculate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          shipping: { postal_code: postalCode }
        })
      });

      if (!response.ok) throw new Error('Failed to fetch shipping rates');

      const data = await response.json();
      setShippingRates(data.rates);
      setSelectedShipping(data.rates[0]); // Default to first option
    } catch (err) {
      setError('Unable to calculate shipping rates. Please try again.');
    }
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    if (!stripe || !elements || !selectedShipping) {
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const { error, paymentMethod } = await stripe.createPaymentMethod({
        type: 'card',
        card: elements.getElement(CardElement)
      });

      if (error) {
        throw error;
      }

      onComplete({
        payment_method_id: paymentMethod.id,
        shipping_method: selectedShipping.service,
        shipping_rate: selectedShipping.rate,
        estimated_delivery_date: selectedShipping.delivery_date,
        carrier: selectedShipping.carrier
      });
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-8">
      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-xl font-semibold mb-6">Payment Information</h2>

        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-md">
            <p className="text-red-600">{error}</p>
          </div>
        )}

        <div className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Card Details
            </label>
            <div className="border border-gray-300 rounded-md p-4">
              <CardElement options={CARD_ELEMENT_OPTIONS} />
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-xl font-semibold mb-6">Shipping Method</h2>

        <div className="space-y-4">
          {shippingRates.map((rate) => (
            <label
              key={rate.service}
              className={`block p-4 border rounded-lg cursor-pointer ${
                selectedShipping?.service === rate.service
                  ? 'border-blue-500 bg-blue-50'
                  : 'border-gray-200'
              }`}
            >
              <div className="flex items-center">
                <input
                  type="radio"
                  name="shipping_method"
                  value={rate.service}
                  checked={selectedShipping?.service === rate.service}
                  onChange={() => setSelectedShipping(rate)}
                  className="h-4 w-4 text-blue-600 border-gray-300"
                />
                <div className="ml-3 flex-1">
                  <div className="flex justify-between">
                    <span className="font-medium">{rate.service}</span>
                    <span className="font-medium">
                      ${rate.rate.toFixed(2)}
                    </span>
                  </div>
                  <p className="text-sm text-gray-500">
                    Estimated delivery: {new Date(rate.delivery_date).toLocaleDateString()}
                  </p>
                </div>
              </div>
            </label>
          ))}
        </div>
      </div>

      <div className="flex justify-between">
        <button
          type="button"
          onClick={onBack}
          className="bg-gray-200 text-gray-700 px-6 py-2 rounded-md hover:bg-gray-300"
        >
          Back
        </button>
        <button
          type="submit"
          disabled={loading || !stripe}
          className={`bg-blue-600 text-white px-6 py-2 rounded-md ${
            loading ? 'opacity-50 cursor-not-allowed' : 'hover:bg-blue-700'
          }`}
        >
          {loading ? 'Processing...' : 'Continue to Review'}
        </button>
      </div>
    </form>
  );
};

export default PaymentStep; 