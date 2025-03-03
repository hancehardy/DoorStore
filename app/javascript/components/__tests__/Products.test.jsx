import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import axios from 'axios';
import Products from '../Products';

jest.mock('axios');

describe('Products', () => {
  it('displays loading message initially', () => {
    axios.get.mockImplementation(() => new Promise(() => {}));
    render(<Products />);
    expect(screen.getByText('Loading products...')).toBeInTheDocument();
  });

  it('displays products when data is loaded', async () => {
    const mockProducts = {
      data: {
        data: [
          {
            attributes: {
              name: 'Shaker',
              description: 'Classic shaker style',
              product_type: 'door_style',
              base_price: 100,
              price_per_sqft: 10,
              specifications: { material: 'Wood' }
            }
          },
          {
            attributes: {
              name: 'Natural Oak',
              description: 'Beautiful oak finish',
              product_type: 'finish',
              base_price: 50,
              price_per_sqft: 5,
              specifications: { type: 'Stain' }
            }
          },
          {
            attributes: {
              name: 'Clear Glass',
              description: 'Transparent glass panel',
              product_type: 'glass',
              base_price: 75,
              price_per_sqft: 15,
              specifications: { thickness: '4mm' }
            }
          }
        ]
      }
    };

    axios.get.mockResolvedValue(mockProducts);
    render(<Products />);

    await waitFor(() => {
      expect(screen.getByText('Door Styles')).toBeInTheDocument();
      expect(screen.getByText('Finishes')).toBeInTheDocument();
      expect(screen.getByText('Glass Options')).toBeInTheDocument();
      expect(screen.getByText('Shaker')).toBeInTheDocument();
      expect(screen.getByText('Natural Oak')).toBeInTheDocument();
      expect(screen.getByText('Clear Glass')).toBeInTheDocument();
    });
  });

  it('displays error message when API call fails', async () => {
    axios.get.mockRejectedValue(new Error('API Error'));
    render(<Products />);
    await waitFor(() => {
      expect(screen.getByText('Failed to fetch products')).toBeInTheDocument();
    });
  });

  it('displays empty state message when no products are available', async () => {
    const emptyProducts = {
      data: {
        data: []
      }
    };

    axios.get.mockResolvedValue(emptyProducts);
    render(<Products />);

    await waitFor(() => {
      expect(screen.getByText('No door styles available')).toBeInTheDocument();
      expect(screen.getByText('No finishes available')).toBeInTheDocument();
      expect(screen.getByText('No glass options available')).toBeInTheDocument();
    });
  });
}); 