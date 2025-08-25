import React, { useState } from 'react';
import { Card, Input, Button, Alert, Spin, Typography, List } from 'antd';
import { UserOutlined, SearchOutlined, CheckCircleOutlined } from '@ant-design/icons';
import axios from 'axios';

const { Title } = Typography;

const UsernameTracker: React.FC = () => {
  const [username, setUsername] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);

  const handleTrack = async () => {
    if (!username.trim()) {
      setError('Please enter a username');
      return;
    }

    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await axios.post('http://localhost:8000/api/track-username', {
        username: username.trim()
      });
      setResult(response.data);
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Search failed, please check username format');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <Card title="Username Tracker" style={{ marginBottom: 16 }}>
        <Alert
          message="Usage Instructions"
          description="Enter a username, and the system will search across multiple mainstream social media platforms to check if the username exists."
          type="info"
          style={{ marginBottom: 16 }}
          showIcon
        />
        <div style={{ display: 'flex', gap: '8px' }}>
          <Input
            placeholder="Enter username, e.g.: john_doe"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            onPressEnter={handleTrack}
            style={{ flex: 1 }}
          />
          <Button 
            type="primary" 
            icon={<SearchOutlined />}
            onClick={handleTrack}
            loading={loading}
          >
            Search
          </Button>
        </div>
      </Card>

      {error && (
        <Alert
          message="Search Failed"
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
            <p style={{ marginTop: 16 }}>Searching username, please wait...</p>
          </div>
        </Card>
      )}

      {result && (
        <div>
          <Card title="Search Statistics" style={{ marginBottom: 16 }}>
            <div style={{ textAlign: 'center' }}>
              <Title level={2} style={{ color: '#1890ff', margin: 0 }}>
                {result.found_count} / {result.total_searched}
              </Title>
              <p>Platforms Found / Total Platforms Searched</p>
            </div>
          </Card>

          {result.found_profiles && result.found_profiles.length > 0 && (
            <Card title={`Found Platforms (${result.found_profiles.length})`} style={{ marginBottom: 16 }}>
              <List
                dataSource={result.found_profiles}
                renderItem={(item: any) => (
                  <List.Item
                    actions={[
                      <a href={item.url} target="_blank" rel="noopener noreferrer" key="visit">
                        Visit
                      </a>
                    ]}
                  >
                    <List.Item.Meta
                      avatar={<CheckCircleOutlined style={{ color: '#52c41a' }} />}
                      title={item.platform}
                      description={item.url}
                    />
                  </List.Item>
                )}
              />
            </Card>
          )}
        </div>
      )}
    </div>
  );
};

export default UsernameTracker;