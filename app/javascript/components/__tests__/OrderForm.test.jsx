import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import axios from 'axios';
import OrderForm from '../OrderForm';

jest.mock('axios');

describe('OrderForm', () => {
  const mockProducts = {
    data: {
      data: [
        {
          id: '1',
          attributes: {
            name: 'Shaker',
            product_type: 'door_style',
            base_price: 100,
            price_per_sqft: 15,
            specifications: { material: 'Wood' }
          }
        },
        {
          id: '2',
          attributes: {
            name: 'Natural Oak',
            product_type: 'finish',
            base_price: 0,
            price_per_sqft: 5,
            specifications: { type: 'Stain' }
          }
        },
        {
          id: '3',
          attributes: {
            name: 'Clear Glass',
            product_type: 'glass',
            base_price: 50,
            price_per_sqft: 20,
            specifications: { thickness: '4mm' }
          }
        }
      ]
    }
  };

  beforeEach(() => {
    jest.clearAllMocks();
    axios.get.mockResolvedValue(mockProducts);
  });

  it('displays loading state initially', () => {
    render(<OrderForm />);
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('displays form fields when products are loaded', async () => {
    render(<OrderForm />);

    await waitFor(() => {
      expect(screen.getByText('New Order')).toBeInTheDocument();
      expect(screen.getByLabelText('Door Style:')).toBeInTheDocument();
      expect(screen.getByLabelText('Quantity:')).toBeInTheDocument();
      expect(screen.getByLabelText('Width (inches):')).toBeInTheDocument();
      expect(screen.getByLabelText('Height (inches):')).toBeInTheDocument();
      expect(screen.getByLabelText('Glass Option:')).toBeInTheDocument();
      expect(screen.getByLabelText('Finish:')).toBeInTheDocument();
    });
  });

  it('creates a new order and adds line item', async () => {
    const mockOrder = {
      data: {
        data: {
          id: '1',
          attributes: {
            status: 'draft'
          }
        }
      }
    };

    const mockLineItem = {
      data: {
        data: {
          id: '1',
          attributes: {
            product_id: '1',
            quantity: 2,
            width: 24,
            height: 30,
            glass_option: 'Clear Glass',
            finish: 'Natural Oak',
            price_per_unit: 100,
            total_price: 200,
            product_details: {
              name: 'Shaker'
            }
          }
        }
      }
    };

    axios.post.mockImplementation((url) => {
      if (url === '/api/v1/orders') {
        return Promise.resolve(mockOrder);
      }
      return Promise.resolve(mockLineItem);
    });

    render(<OrderForm />);

    await waitFor(() => {
      expect(screen.getByLabelText('Door Style:')).toBeInTheDocument();
    });

    fireEvent.change(screen.getByLabelText('Door Style:'), { target: { value: '1' } });
    fireEvent.change(screen.getByLabelText('Quantity:'), { target: { value: '2' } });
    fireEvent.change(screen.getByLabelText('Width (inches):'), { target: { value: '24' } });
    fireEvent.change(screen.getByLabelText('Height (inches):'), { target: { value: '30' } });
    fireEvent.change(screen.getByLabelText('Glass Option:'), { target: { value: 'Clear Glass' } });
    fireEvent.change(screen.getByLabelText('Finish:'), { target: { value: 'Natural Oak' } });

    fireEvent.click(screen.getByText('Add Item'));

    await waitFor(() => {
      expect(screen.getByText('Shaker')).toBeInTheDocument();
      expect(screen.getByText('2')).toBeInTheDocument();
      expect(screen.getByText('24" × 30"')).toBeInTheDocument();
      expect(screen.getByText('Clear Glass')).toBeInTheDocument();
      expect(screen.getByText('Natural Oak')).toBeInTheDocument();
    });
  });

  it('displays error message when API call fails', async () => {
    axios.get.mockRejectedValue(new Error('API Error'));
    render(<OrderForm />);

    await waitFor(() => {
      expect(screen.getByText('Failed to fetch products')).toBeInTheDocument();
    });
  });

  it('allows saving the order', async () => {
    const mockOrder = {
      data: {
        data: {
          id: '1',
          attributes: {
            status: 'draft'
          }
        }
      }
    };

    const mockLineItem = {
      data: {
        data: {
          id: '1',
          attributes: {
            product_id: '1',
            quantity: 1,
            width: 24,
            height: 30,
            glass_option: '',
            finish: 'Natural Oak',
            price_per_unit: 100,
            total_price: 100,
            product_details: {
              name: 'Shaker'
            }
          }
        }
      }
    };

    axios.post.mockImplementation((url) => {
      if (url === '/api/v1/orders') {
        return Promise.resolve(mockOrder);
      }
      return Promise.resolve(mockLineItem);
    });

    axios.patch.mockResolvedValue({
      data: {
        data: {
          id: '1',
          attributes: {
            status: 'pending'
          }
        }
      }
    });

    render(<OrderForm />);

    await waitFor(() => {
      expect(screen.getByLabelText('Door Style:')).toBeInTheDocument();
    });

    // Add an item first
    fireEvent.change(screen.getByLabelText('Door Style:'), { target: { value: '1' } });
    fireEvent.change(screen.getByLabelText('Quantity:'), { target: { value: '1' } });
    fireEvent.change(screen.getByLabelText('Width (inches):'), { target: { value: '24' } });
    fireEvent.change(screen.getByLabelText('Height (inches):'), { target: { value: '30' } });
    fireEvent.change(screen.getByLabelText('Finish:'), { target: { value: 'Natural Oak' } });

    fireEvent.click(screen.getByText('Add Item'));

    await waitFor(() => {
      expect(screen.getByText('Save Order')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByText('Save Order'));

    await waitFor(() => {
      expect(axios.patch).toHaveBeenCalledWith('/api/v1/orders/1/mark_as_pending');
    });
  });
}); 