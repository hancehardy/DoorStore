import React, { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';

const BillingShippingStep = ({ initialData, onComplete }) => {
  const [savedAddresses, setSavedAddresses] = useState([]);
  const [loading, setLoading] = useState(false);
  const [useMetric, setUseMetric] = useState(false);
  
  const { register, handleSubmit, setValue, watch, formState: { errors } } = useForm({
    defaultValues: initialData || {
      shipping_address: {
        first_name: '',
        last_name: '',
        address_line1: '',
        address_line2: '',
        city: '',
        state: '',
        postal_code: '',
        country: 'US',
        phone: ''
      },
      billing_address: {
        same_as_shipping: true,
        first_name: '',
        last_name: '',
        address_line1: '',
        address_line2: '',
        city: '',
        state: '',
        postal_code: '',
        country: 'US',
        phone: ''
      },
      unit_preference: 'imperial'
    }
  });

  const sameAsShipping = watch('billing_address.same_as_shipping');

  useEffect(() => {
    fetchSavedAddresses();
  }, []);

  const fetchSavedAddresses = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/v1/addresses');
      if (!response.ok) throw new Error('Failed to fetch addresses');
      
      const data = await response.json();
      setSavedAddresses(data);
    } catch (err) {
      console.error('Error fetching addresses:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSavedAddressSelect = (addressType, address) => {
    Object.keys(address).forEach(key => {
      setValue(`${addressType}.${key}`, address[key]);
    });
  };

  const onSubmit = (data) => {
    if (data.billing_address.same_as_shipping) {
      data.billing_address = { ...data.shipping_address, same_as_shipping: true };
    }
    onComplete(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-8">
      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-xl font-semibold mb-6">Shipping Address</h2>
        
        {savedAddresses.length > 0 && (
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Select a saved address
            </label>
            <select
              className="w-full border-gray-300 rounded-md shadow-sm"
              onChange={(e) => handleSavedAddressSelect('shipping_address', savedAddresses[e.target.value])}
            >
              <option value="">-- Select an address --</option>
              {savedAddresses.map((address, index) => (
                <option key={index} value={index}>
                  {address.address_line1}, {address.city}, {address.state}
                </option>
              ))}
            </select>
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700">First Name</label>
            <input
              type="text"
              {...register('shipping_address.first_name', { required: 'First name is required' })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
            />
            {errors.shipping_address?.first_name && (
              <p className="mt-1 text-sm text-red-600">{errors.shipping_address.first_name.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Last Name</label>
            <input
              type="text"
              {...register('shipping_address.last_name', { required: 'Last name is required' })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
            />
            {errors.shipping_address?.last_name && (
              <p className="mt-1 text-sm text-red-600">{errors.shipping_address.last_name.message}</p>
            )}
          </div>

          <div className="col-span-2">
            <label className="block text-sm font-medium text-gray-700">Address Line 1</label>
            <input
              type="text"
              {...register('shipping_address.address_line1', { required: 'Address is required' })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
            />
            {errors.shipping_address?.address_line1 && (
              <p className="mt-1 text-sm text-red-600">{errors.shipping_address.address_line1.message}</p>
            )}
          </div>

          <div className="col-span-2">
            <label className="block text-sm font-medium text-gray-700">Address Line 2</label>
            <input
              type="text"
              {...register('shipping_address.address_line2')}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">City</label>
            <input
              type="text"
              {...register('shipping_address.city', { required: 'City is required' })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
            />
            {errors.shipping_address?.city && (
              <p className="mt-1 text-sm text-red-600">{errors.shipping_address.city.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">State</label>
            <input
              type="text"
              {...register('shipping_address.state', { required: 'State is required' })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
            />
            {errors.shipping_address?.state && (
              <p className="mt-1 text-sm text-red-600">{errors.shipping_address.state.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Postal Code</label>
            <input
              type="text"
              {...register('shipping_address.postal_code', { required: 'Postal code is required' })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
            />
            {errors.shipping_address?.postal_code && (
              <p className="mt-1 text-sm text-red-600">{errors.shipping_address.postal_code.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Phone</label>
            <input
              type="tel"
              {...register('shipping_address.phone', { required: 'Phone is required' })}
              className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
            />
            {errors.shipping_address?.phone && (
              <p className="mt-1 text-sm text-red-600">{errors.shipping_address.phone.message}</p>
            )}
          </div>
        </div>
      </div>

      <div className="bg-white p-6 rounded-lg shadow">
        <div className="flex items-center mb-6">
          <h2 className="text-xl font-semibold">Billing Address</h2>
          <label className="ml-6 flex items-center">
            <input
              type="checkbox"
              {...register('billing_address.same_as_shipping')}
              className="rounded border-gray-300 text-blue-600"
            />
            <span className="ml-2 text-sm text-gray-600">Same as shipping</span>
          </label>
        </div>

        {!sameAsShipping && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700">First Name</label>
              <input
                type="text"
                {...register('billing_address.first_name', { required: 'First name is required' })}
                className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
              />
              {errors.billing_address?.first_name && (
                <p className="mt-1 text-sm text-red-600">{errors.billing_address.first_name.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Last Name</label>
              <input
                type="text"
                {...register('billing_address.last_name', { required: 'Last name is required' })}
                className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
              />
              {errors.billing_address?.last_name && (
                <p className="mt-1 text-sm text-red-600">{errors.billing_address.last_name.message}</p>
              )}
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700">Address Line 1</label>
              <input
                type="text"
                {...register('billing_address.address_line1', { required: 'Address is required' })}
                className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
              />
              {errors.billing_address?.address_line1 && (
                <p className="mt-1 text-sm text-red-600">{errors.billing_address.address_line1.message}</p>
              )}
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700">Address Line 2</label>
              <input
                type="text"
                {...register('billing_address.address_line2')}
                className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">City</label>
              <input
                type="text"
                {...register('billing_address.city', { required: 'City is required' })}
                className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
              />
              {errors.billing_address?.city && (
                <p className="mt-1 text-sm text-red-600">{errors.billing_address.city.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">State</label>
              <input
                type="text"
                {...register('billing_address.state', { required: 'State is required' })}
                className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
              />
              {errors.billing_address?.state && (
                <p className="mt-1 text-sm text-red-600">{errors.billing_address.state.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Postal Code</label>
              <input
                type="text"
                {...register('billing_address.postal_code', { required: 'Postal code is required' })}
                className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
              />
              {errors.billing_address?.postal_code && (
                <p className="mt-1 text-sm text-red-600">{errors.billing_address.postal_code.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Phone</label>
              <input
                type="tel"
                {...register('billing_address.phone', { required: 'Phone is required' })}
                className="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
              />
              {errors.billing_address?.phone && (
                <p className="mt-1 text-sm text-red-600">{errors.billing_address.phone.message}</p>
              )}
            </div>
          </div>
        )}
      </div>

      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-xl font-semibold mb-6">Preferences</h2>
        <div>
          <label className="block text-sm font-medium text-gray-700">Unit System</label>
          <div className="mt-2">
            <label className="inline-flex items-center">
              <input
                type="radio"
                {...register('unit_preference')}
                value="imperial"
                className="form-radio"
              />
              <span className="ml-2">Imperial (inches)</span>
            </label>
            <label className="inline-flex items-center ml-6">
              <input
                type="radio"
                {...register('unit_preference')}
                value="metric"
                className="form-radio"
              />
              <span className="ml-2">Metric (millimeters)</span>
            </label>
          </div>
        </div>
      </div>

      <div className="flex justify-end">
        <button
          type="submit"
          className="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700"
        >
          Continue to Payment
        </button>
      </div>
    </form>
  );
};

export default BillingShippingStep; 