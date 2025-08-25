import React, { useState } from 'react';
import { Card, Input, Button, Alert, Spin } from 'antd';
import { SearchOutlined } from '@ant-design/icons';
import axios from 'axios';
import { API_ENDPOINTS } from '../config/api';

const IPTracker: React.FC = () => {
  const [ipAddress, setIpAddress] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);

  const handleTrack = async () => {
    if (!ipAddress.trim()) {
      setError('Please enter an IP address');
      return;
    }

    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await axios.post(API_ENDPOINTS.TRACK_IP, {
        ip_address: ipAddress.trim()
      });
      setResult(response.data);
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Query failed, please check IP address format');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <Card title="IP Address Tracker" style={{ marginBottom: 16 }}>
        <div style={{ display: 'flex', gap: '8px' }}>
          <Input
            placeholder="Enter IP address, e.g.: 8.8.8.8"
            value={ipAddress}
            onChange={(e) => setIpAddress(e.target.value)}
            onPressEnter={handleTrack}
            style={{ flex: 1 }}
          />
          <Button 
            type="primary" 
            icon={<SearchOutlined />}
            onClick={handleTrack}
            loading={loading}
          >
            Track
          </Button>
        </div>
      </Card>

      {error && (
        <Alert
          message="Query Failed"
          description={error}
          type="error"
          style={{ marginBottom: 16 }}
          showIcon
        />
      )}

      {loading && (
        <Card>
          <div style={{ textAlign: 'center', padding: '40px 0' }}>
            <Spin size="large" />
            <p style={{ marginTop: 16 }}>Querying IP information...</p>
          </div>
        </Card>
      )}

      {result && (
        <Card title="IP Information Details">
          <div>
            <p><strong>IP Address:</strong> {result.ip}</p>
            <p><strong>Country:</strong> {result.country}</p>
            <p><strong>City:</strong> {result.city}</p>
            <p><strong>ISP:</strong> {result.connection?.isp}</p>
            {result.maps_url && (
              <p>
                <strong>Map Location:</strong> 
                <a href={result.maps_url} target="_blank" rel="noopener noreferrer">
                  View on Google Maps
                </a>
              </p>
            )}
          </div>
        </Card>
      )}
    </div>
  );
};

export default IPTracker;