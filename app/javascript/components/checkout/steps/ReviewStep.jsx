import React from 'react';

const ReviewStep = ({ checkoutData, onComplete, onBack }) => {
  const { order, billingShipping, payment } = checkoutData;

  const formatAddress = (address) => {
    if (!address) return '';
    const {
      first_name,
      last_name,
      address_line1,
      address_line2,
      city,
      state,
      postal_code,
      country
    } = address;

    return `${first_name} ${last_name}
${address_line1}
${address_line2 ? address_line2 + '\n' : ''}${city}, ${state} ${postal_code}
${country}`;
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(amount);
  };

  const handleSubmit = () => {
    onComplete({
      confirmed: true,
      confirmation_time: new Date().toISOString()
    });
  };

  return (
    <div className="space-y-8">
      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-xl font-semibold mb-6">Order Summary</h2>
        
        <div className="space-y-6">
          <div className="border-b pb-6">
            <h3 className="text-lg font-medium mb-4">Items</h3>
            {order.line_items.map((item) => (
              <div key={item.id} className="flex justify-between items-start mb-4">
                <div>
                  <h4 className="font-medium">{item.product.name}</h4>
                  <p className="text-sm text-gray-600">
                    {item.width}" × {item.height}"
                    {item.glass_option && ` with ${item.glass_option}`}
                  </p>
                  <p className="text-sm text-gray-600">
                    Finish: {item.finish}
                  </p>
                  <p className="text-sm text-gray-600">
                    Quantity: {item.quantity}
                  </p>
                </div>
                <div className="text-right">
                  <p className="font-medium">{formatCurrency(item.total_price)}</p>
                  <p className="text-sm text-gray-600">
                    {formatCurrency(item.price_per_unit)} each
                  </p>
                </div>
              </div>
            ))}
          </div>

          <div className="border-b pb-6">
            <h3 className="text-lg font-medium mb-4">Shipping Address</h3>
            <pre className="whitespace-pre-line text-gray-600">
              {formatAddress(billingShipping.shipping_address)}
            </pre>
          </div>

          <div className="border-b pb-6">
            <h3 className="text-lg font-medium mb-4">Billing Address</h3>
            <pre className="whitespace-pre-line text-gray-600">
              {formatAddress(
                billingShipping.billing_address.same_as_shipping
                  ? billingShipping.shipping_address
                  : billingShipping.billing_address
              )}
            </pre>
          </div>

          <div className="border-b pb-6">
            <h3 className="text-lg font-medium mb-4">Payment Method</h3>
            <p className="text-gray-600">
              Card ending in {payment.last_four}
            </p>
          </div>

          <div>
            <h3 className="text-lg font-medium mb-4">Order Total</h3>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-gray-600">Subtotal</span>
                <span>{formatCurrency(order.total_price)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Shipping</span>
                <span>Free</span>
              </div>
              <div className="flex justify-between font-medium text-lg pt-2 border-t">
                <span>Total</span>
                <span>{formatCurrency(order.total_price)}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <p className="text-sm text-blue-800">
          By placing this order, you agree to our Terms of Service and Privacy Policy.
          Your card will be charged {formatCurrency(order.total_price)} upon submission.
        </p>
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
          type="button"
          onClick={handleSubmit}
          className="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700"
        >
          Place Order
        </button>
      </div>
    </div>
  );
};

export default ReviewStep; 