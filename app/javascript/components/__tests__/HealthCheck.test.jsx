import React from 'react';
import { render, screen, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import axios from 'axios';
import HealthCheck from '../HealthCheck';

jest.mock('axios');

describe('HealthCheck', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('displays loading state initially', async () => {
    let resolveFn;
    const promise = new Promise(resolve => {
      resolveFn = resolve;
    });
    axios.get.mockImplementation(() => promise);

    await act(async () => {
      render(<HealthCheck />);
    });

    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('displays API status when request succeeds', async () => {
    const mockResponse = {
      data: {
        status: 'ok',
        timestamp: '2024-01-01T00:00:00Z'
      }
    };

    let resolveFn;
    const promise = new Promise(resolve => {
      resolveFn = resolve;
    });
    axios.get.mockImplementation(() => promise);

    await act(async () => {
      render(<HealthCheck />);
    });

    await act(async () => {
      resolveFn(mockResponse);
      await promise;
    });

    expect(screen.getByText(/Status: ok/)).toBeInTheDocument();
    expect(screen.getByText(/Timestamp: 2024-01-01T00:00:00Z/)).toBeInTheDocument();
  });

  it('displays error message when request fails', async () => {
    let rejectFn;
    const promise = new Promise((resolve, reject) => {
      rejectFn = reject;
    });
    axios.get.mockImplementation(() => promise);

    await act(async () => {
      render(<HealthCheck />);
    });

    await act(async () => {
      rejectFn(new Error('API Error'));
      try {
        await promise;
      } catch (error) {
        // Expected error
      }
    });

    expect(screen.getByText('Failed to connect to API')).toBeInTheDocument();
  });
}); 