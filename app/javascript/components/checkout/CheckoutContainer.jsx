import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import BillingShippingStep from './steps/BillingShippingStep';
import PaymentStep from './steps/PaymentStep';
import ReviewStep from './steps/ReviewStep';
import CheckoutProgress from './CheckoutProgress';

const CHECKOUT_STEPS = {
  BILLING_SHIPPING: 1,
  PAYMENT: 2,
  REVIEW: 3
};

const CheckoutContainer = () => {
  const navigate = useNavigate();
  const [currentStep, setCurrentStep] = useState(CHECKOUT_STEPS.BILLING_SHIPPING);
  const [checkoutData, setCheckoutData] = useState({
    billingShipping: null,
    payment: null,
    order: null
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Load order data when component mounts
    fetchOrderData();
  }, []);

  const fetchOrderData = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/v1/orders/current');
      if (!response.ok) throw new Error('Failed to fetch order');
      
      const data = await response.json();
      setCheckoutData(prev => ({ ...prev, order: data }));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleStepComplete = async (step, data) => {
    setCheckoutData(prev => ({ ...prev, [step]: data }));
    
    if (step === 'billingShipping') {
      setCurrentStep(CHECKOUT_STEPS.PAYMENT);
    } else if (step === 'payment') {
      setCurrentStep(CHECKOUT_STEPS.REVIEW);
    } else if (step === 'review') {
      await submitOrder();
    }
  };

  const handleStepBack = () => {
    if (currentStep === CHECKOUT_STEPS.PAYMENT) {
      setCurrentStep(CHECKOUT_STEPS.BILLING_SHIPPING);
    } else if (currentStep === CHECKOUT_STEPS.REVIEW) {
      setCurrentStep(CHECKOUT_STEPS.PAYMENT);
    }
  };

  const submitOrder = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/v1/orders/submit', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify(checkoutData)
      });

      if (!response.ok) throw new Error('Failed to submit order');
      
      const data = await response.json();
      navigate('/orders/confirmation', { state: { orderId: data.id } });
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className="container mx-auto px-4 py-8">
      <CheckoutProgress currentStep={currentStep} />
      
      <div className="mt-8">
        {currentStep === CHECKOUT_STEPS.BILLING_SHIPPING && (
          <BillingShippingStep
            initialData={checkoutData.billingShipping}
            onComplete={(data) => handleStepComplete('billingShipping', data)}
          />
        )}

        {currentStep === CHECKOUT_STEPS.PAYMENT && (
          <PaymentStep
            initialData={checkoutData.payment}
            onComplete={(data) => handleStepComplete('payment', data)}
            onBack={handleStepBack}
          />
        )}

        {currentStep === CHECKOUT_STEPS.REVIEW && (
          <ReviewStep
            checkoutData={checkoutData}
            onComplete={(data) => handleStepComplete('review', data)}
            onBack={handleStepBack}
          />
        )}
      </div>
    </div>
  );
};

export default CheckoutContainer; 