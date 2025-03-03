import React from 'react';
import HealthCheck from './HealthCheck';
import Products from './Products';
import OrderForm from './OrderForm';

const App = () => {
  return (
    <div className="app">
      <h1>Cabinet Doors</h1>
      <HealthCheck />
      <Products />
      <OrderForm />
    </div>
  );
};

export default App; 