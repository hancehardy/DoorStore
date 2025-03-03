import React, { useState, useEffect } from 'react';
import axios from 'axios';

const Products = () => {
  const [products, setProducts] = useState({
    doorStyles: [],
    finishes: [],
    glass: []
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await axios.get('/api/v1/products');
        const allProducts = response.data.data || [];

        // Group products by type
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
              grouped.doorStyles.push(attrs);
              break;
            case 'finish':
              grouped.finishes.push(attrs);
              break;
            case 'glass':
              grouped.glass.push(attrs);
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

  if (loading) {
    return <div className="products-loading">Loading products...</div>;
  }

  if (error) {
    return <div className="products-error">{error}</div>;
  }

  const renderProductList = (items, title) => (
    <div className="product-section" key={title}>
      <h2>{title}</h2>
      <div className="product-grid">
        {items.length > 0 ? (
          items.map((product) => (
            <div key={product.name} className="product-card">
              <h3>{product.name}</h3>
              <p className="description">{product.description}</p>
              <div className="price-info">
                <p>Base Price: ${product.base_price}</p>
                <p>Price per sq ft: ${product.price_per_sqft}</p>
              </div>
              <div className="dimensions">
                <p>Width: {product.min_width}" - {product.max_width}"</p>
                <p>Height: {product.min_height}" - {product.max_height}"</p>
              </div>
              <div className="specifications">
                <h4>Specifications:</h4>
                <ul>
                  {Object.entries(product.specifications || {}).map(([key, value]) => (
                    <li key={key}>{key}: {value}</li>
                  ))}
                </ul>
              </div>
            </div>
          ))
        ) : (
          <div className="product-card empty">
            <p>No {title.toLowerCase()} available</p>
          </div>
        )}
      </div>
    </div>
  );

  return (
    <div className="products-container">
      {renderProductList(products.doorStyles, 'Door Styles')}
      {renderProductList(products.finishes, 'Finishes')}
      {renderProductList(products.glass, 'Glass Options')}
    </div>
  );
};

export default Products; 