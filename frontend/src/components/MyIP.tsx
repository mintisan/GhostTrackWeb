import React, { useState, useEffect } from 'react';
import { Card, Button, Alert, Spin, Typography, Descriptions, Row, Col } from 'antd';
import { WifiOutlined, ReloadOutlined, CopyOutlined, GlobalOutlined } from '@ant-design/icons';
import axios from 'axios';

const { Title } = Typography;

const MyIP: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [ipLoading, setIpLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [ipDetails, setIpDetails] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);
  const [ipError, setIpError] = useState<string | null>(null);

  const fetchIPDetails = async (ipAddress: string) => {
    setIpLoading(true);
    setIpError(null);

    try {
      const response = await axios.post('http://localhost:8000/api/track-ip', {
        ip_address: ipAddress
      });
      setIpDetails(response.data);
    } catch (err: any) {
      setIpError(err.response?.data?.detail || 'Failed to get IP details');
    } finally {
      setIpLoading(false);
    }
  };

  const fetchMyIP = async () => {
    setLoading(true);
    setError(null);
    setIpDetails(null);

    try {
      const response = await axios.get('http://localhost:8000/api/my-ip');
      setResult(response.data);
      // 自动获取IP详细信息
      if (response.data.ip) {
        await fetchIPDetails(response.data.ip);
      }
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Failed to get IP');
    } finally {
      setLoading(false);
    }
  };

  const copyToClipboard = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text);
      alert('IP address copied to clipboard');
    } catch (err) {
      const textArea = document.createElement('textarea');
      textArea.value = text;
      document.body.appendChild(textArea);
      textArea.select();
      document.execCommand('copy');
      document.body.removeChild(textArea);
      alert('IP address copied to clipboard');
    }
  };

  useEffect(() => {
    fetchMyIP();
  }, []);

  return (
    <div>
      <Card 
        title="My IP Address"
        extra={
          <Button 
            type="primary" 
            icon={<ReloadOutlined />}
            onClick={fetchMyIP}
            loading={loading}
          >
            Refresh
          </Button>
        }
        style={{ marginBottom: 16 }}
      >
        <Alert
          message="IP Address Information"
          description="Displays the current device's public IP address, which is the IP address that other devices see on the internet."
          type="info"
          style={{ marginBottom: 16 }}
          showIcon
        />

        {error && (
          <Alert
            message="Failed to Get IP"
            description={error}
            type="error"
            style={{ marginBottom: 16 }}
            showIcon
          />
        )}

        {(loading || ipLoading) && (
          <div style={{ textAlign: 'center', padding: '40px 0' }}>
            <Spin size="large" />
            <p style={{ marginTop: 16 }}>
              {loading ? 'Getting IP address...' : 'Loading IP details...'}
            </p>
          </div>
        )}

        {result && !loading && (
          <div>
            <div style={{ textAlign: 'center', padding: '20px 0' }}>
              <Title level={2} style={{ color: '#1890ff', marginBottom: 16 }}>
                {result.ip}
              </Title>
              <Button 
                type="default" 
                icon={<CopyOutlined />}
                onClick={() => copyToClipboard(result.ip)}
                size="large"
                style={{ marginTop: 16 }}
              >
                Copy IP Address
              </Button>
            </div>

            {/* IP详细信息 */}
            {ipDetails && (
              <Card 
                title={<><GlobalOutlined style={{ marginRight: 8 }} />IP Details</>} 
                style={{ marginTop: 24 }}
                loading={ipLoading}
              >
                <Row gutter={[16, 16]}>
                  <Col xs={24} md={12}>
                    <Descriptions column={1} bordered size="small">
                      <Descriptions.Item label="IP Address">{ipDetails.ip}</Descriptions.Item>
                      <Descriptions.Item label="Type">{ipDetails.type}</Descriptions.Item>
                      <Descriptions.Item label="Country">{ipDetails.country}</Descriptions.Item>
                      <Descriptions.Item label="Country Code">{ipDetails.country_code}</Descriptions.Item>
                      <Descriptions.Item label="City">{ipDetails.city}</Descriptions.Item>
                      <Descriptions.Item label="Region">{ipDetails.region}</Descriptions.Item>
                      <Descriptions.Item label="Region Code">{ipDetails.region_code}</Descriptions.Item>
                    </Descriptions>
                  </Col>
                  <Col xs={24} md={12}>
                    <Descriptions column={1} bordered size="small">
                      <Descriptions.Item label="Latitude">{ipDetails.latitude}</Descriptions.Item>
                      <Descriptions.Item label="Longitude">{ipDetails.longitude}</Descriptions.Item>
                      <Descriptions.Item label="Timezone">{ipDetails.timezone?.id}</Descriptions.Item>
                      <Descriptions.Item label="UTC Offset">{ipDetails.timezone?.offset}</Descriptions.Item>
                      <Descriptions.Item label="ISP">{ipDetails.connection?.isp}</Descriptions.Item>
                      <Descriptions.Item label="Organization">{ipDetails.connection?.org}</Descriptions.Item>
                      <Descriptions.Item label="ASN">{ipDetails.connection?.asn}</Descriptions.Item>
                    </Descriptions>
                  </Col>
                </Row>
                
                {ipDetails.maps_url && (
                  <div style={{ textAlign: 'center', marginTop: 16 }}>
                    <Button 
                      type="primary" 
                      href={ipDetails.maps_url} 
                      target="_blank" 
                      rel="noopener noreferrer"
                      icon={<GlobalOutlined />}
                    >
                      View on Google Maps
                    </Button>
                  </div>
                )}
              </Card>
            )}

            {ipError && (
              <Alert
                message="Failed to Load IP Details"
                description={ipError}
                type="warning"
                style={{ marginTop: 16 }}
                showIcon
              />
            )}

            <div style={{ marginTop: 32, textAlign: 'left' }}>
              <Title level={4}>💡 Usage Tips</Title>
              <ul style={{ color: '#666' }}>
                <li>This IP address is your device's unique identifier on the internet</li>
                <li>The detailed information shows your approximate location and ISP</li>
                <li>IP address may change based on network environment changes</li>
                <li>If using proxy or VPN, it will show the proxy server's information</li>
              </ul>
            </div>
          </div>
        )}
      </Card>
    </div>
  );
};

export default MyIP;