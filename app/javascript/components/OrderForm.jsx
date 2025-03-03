import React, { useState, useEffect } from 'react';
import axios from 'axios';

const OrderForm = () => {
  const [order, setOrder] = useState(null);
  const [lineItems, setLineItems] = useState([]);
  const [products, setProducts] = useState({
    doorStyles: [],
    finishes: [],
    glass: []
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [newItem, setNewItem] = useState({
    product_id: '',
    quantity: 1,
    width: '',
    height: '',
    glass_option: '',
    finish: '',
    price_per_unit: ''
  });

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await axios.get('/api/v1/products');
        const allProducts = response.data.data || [];
        const grouped = {
          doorStyles: [],
          finishes: [],
          glass: []
        };

        allProducts.forEach(product => {
          const attrs = product.attributes;
          if (!attrs) return;

          switch (attrs.product_type) {
            case 'door_style':
              grouped.doorStyles.push({ id: product.id, ...attrs });
              break;
            case 'finish':
              grouped.finishes.push({ id: product.id, ...attrs });
              break;
            case 'glass':
              grouped.glass.push({ id: product.id, ...attrs });
              break;
            default:
              break;
          }
        });

        setProducts(grouped);
        setError(null);
      } catch (err) {
        setError('Failed to fetch products');
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  const handleNewItemChange = (e) => {
    const { name, value } = e.target;
    setNewItem(prev => ({ ...prev, [name]: value }));
  };

  const handleAddItem = async (e) => {
    e.preventDefault();
    
    if (!order) {
      try {
        const orderResponse = await axios.post('/api/v1/orders', {
          order: { status: 'draft' }
        });
        setOrder(orderResponse.data.data);
      } catch (err) {
        setError('Failed to create order');
        return;
      }
    }

    try {
      const response = await axios.post(`/api/v1/orders/${order.id}/line_items`, {
        line_item: newItem
      });
      
      setLineItems(prev => [...prev, response.data.data]);
      setNewItem({
        product_id: '',
        quantity: 1,
        width: '',
        height: '',
        glass_option: '',
        finish: '',
        price_per_unit: ''
      });
    } catch (err) {
      setError('Failed to add line item');
    }
  };

  const handleUpdateItem = async (id, updates) => {
    try {
      const response = await axios.patch(`/api/v1/orders/${order.id}/line_items/${id}`, {
        line_item: updates
      });
      
      setLineItems(prev =>
        prev.map(item => item.id === id ? response.data.data : item)
      );
    } catch (err) {
      setError('Failed to update line item');
    }
  };

  const handleDeleteItem = async (id) => {
    try {
      await axios.delete(`/api/v1/orders/${order.id}/line_items/${id}`);
      setLineItems(prev => prev.filter(item => item.id !== id));
    } catch (err) {
      setError('Failed to delete line item');
    }
  };

  const handleSaveOrder = async () => {
    try {
      await axios.patch(`/api/v1/orders/${order.id}/mark_as_pending`);
      setOrder(prev => ({ ...prev, status: 'pending' }));
    } catch (err) {
      setError('Failed to save order');
    }
  };

  if (loading) {
    return <div className="order-form-loading">Loading...</div>;
  }

  if (error) {
    return <div className="order-form-error">{error}</div>;
  }

  return (
    <div className="order-form">
      <h2>New Order</h2>
      
      <form onSubmit={handleAddItem} className="add-item-form">
        <div className="form-group">
          <label>Door Style:</label>
          <select
            name="product_id"
            value={newItem.product_id}
            onChange={handleNewItemChange}
            required
          >
            <option value="">Select a door style</option>
            {products.doorStyles.map(product => (
              <option key={product.id} value={product.id}>
                {product.name}
              </option>
            ))}
          </select>
        </div>

        <div className="form-group">
          <label>Quantity:</label>
          <input
            type="number"
            name="quantity"
            value={newItem.quantity}
            onChange={handleNewItemChange}
            min="1"
            required
          />
        </div>

        <div className="form-group">
          <label>Width (inches):</label>
          <input
            type="number"
            name="width"
            value={newItem.width}
            onChange={handleNewItemChange}
            step="0.1"
            required
          />
        </div>

        <div className="form-group">
          <label>Height (inches):</label>
          <input
            type="number"
            name="height"
            value={newItem.height}
            onChange={handleNewItemChange}
            step="0.1"
            required
          />
        </div>

        <div className="form-group">
          <label>Glass Option:</label>
          <select
            name="glass_option"
            value={newItem.glass_option}
            onChange={handleNewItemChange}
          >
            <option value="">No glass</option>
            {products.glass.map(product => (
              <option key={product.id} value={product.name}>
                {product.name}
              </option>
            ))}
          </select>
        </div>

        <div className="form-group">
          <label>Finish:</label>
          <select
            name="finish"
            value={newItem.finish}
            onChange={handleNewItemChange}
            required
          >
            <option value="">Select a finish</option>
            {products.finishes.map(product => (
              <option key={product.id} value={product.name}>
                {product.name}
              </option>
            ))}
          </select>
        </div>

        <button type="submit" className="add-item-button">
          Add Item
        </button>
      </form>

      <div className="line-items-list">
        <h3>Order Items</h3>
        <table>
          <thead>
            <tr>
              <th>Door Style</th>
              <th>Quantity</th>
              <th>Dimensions</th>
              <th>Glass</th>
              <th>Finish</th>
              <th>Price/Unit</th>
              <th>Total</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {lineItems.map(item => (
              <tr key={item.id}>
                <td>{item.product_details.name}</td>
                <td>{item.quantity}</td>
                <td>{item.width}" × {item.height}"</td>
                <td>{item.glass_option || 'None'}</td>
                <td>{item.finish}</td>
                <td>${item.price_per_unit}</td>
                <td>${item.total_price}</td>
                <td>
                  <button
                    onClick={() => handleDeleteItem(item.id)}
                    className="delete-item-button"
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {order && order.status === 'draft' && lineItems.length > 0 && (
        <div className="order-actions">
          <button onClick={handleSaveOrder} className="save-order-button">
            Save Order
          </button>
        </div>
      )}
    </div>
  );
};

export default OrderForm; 