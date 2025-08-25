import React, { useState } from 'react';
import { Card, Input, Button, Alert, Spin } from 'antd';
import { SearchOutlined } from '@ant-design/icons';
import axios from 'axios';
import { API_ENDPOINTS } from '../config/api';

const PhoneTracker: React.FC = () => {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);

  const handleTrack = async () => {
    if (!phoneNumber.trim()) {
      setError('Please enter a phone number');
      return;
    }

    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await axios.post(API_ENDPOINTS.TRACK_PHONE, {
        phone_number: phoneNumber.trim()
      });
      setResult(response.data);
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Query failed, please check phone number format');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <Card title="Phone Number Tracker" style={{ marginBottom: 16 }}>
        <Alert
          message="Usage Instructions"
          description="Please enter a complete international format phone number, e.g.: +6281234567890 (Indonesia), +8613800138000 (China)"
          type="info"
          style={{ marginBottom: 16 }}
          showIcon
        />
        
        <div style={{ display: 'flex', gap: '8px' }}>
          <Input
            placeholder="Enter phone number, e.g.: +6281234567890"
            value={phoneNumber}
            onChange={(e) => setPhoneNumber(e.target.value)}
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
            <p style={{ marginTop: 16 }}>Querying phone number information...</p>
          </div>
        </Card>
      )}

      {result && (
        <Card title="Phone Number Information Details">
          <div>
            <p><strong>Original Number:</strong> {result.phone_number}</p>
            <p><strong>Number Validity:</strong> {result.is_valid ? 'Valid' : 'Invalid'}</p>
            <p><strong>Location:</strong> {result.location || 'Unknown'}</p>
            <p><strong>Carrier:</strong> {result.carrier || 'Unknown'}</p>
            <p><strong>Timezone:</strong> {result.timezone}</p>
            <p><strong>International Format:</strong> {result.international_format}</p>
          </div>
        </Card>
      )}
    </div>
  );
};

export default PhoneTracker;