import React, { useState, useEffect, useCallback } from 'react';
import axios from 'axios';

const HealthCheck = () => {
  const [status, setStatus] = useState(null);
  const [error, setError] = useState(null);

  const checkHealth = useCallback(async () => {
    try {
      const response = await axios.get('/api/v1/health/check');
      setStatus(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to connect to API');
      setStatus(null);
    }
  }, []);

  useEffect(() => {
    let mounted = true;

    const fetchData = async () => {
      try {
        const response = await axios.get('/api/v1/health/check');
        if (mounted) {
          setStatus(response.data);
          setError(null);
        }
      } catch (err) {
        if (mounted) {
          setError('Failed to connect to API');
          setStatus(null);
        }
      }
    };

    fetchData();

    return () => {
      mounted = false;
    };
  }, []);

  if (error) {
    return <div className="health-check error">{error}</div>;
  }

  if (!status) {
    return <div className="health-check loading">Loading...</div>;
  }

  return (
    <div className="health-check">
      <div>Status: {status.status}</div>
      <div>Timestamp: {status.timestamp}</div>
    </div>
  );
};

export default HealthCheck; 