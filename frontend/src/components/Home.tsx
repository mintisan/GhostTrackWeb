import React from 'react';
import { Card, Typography, Row, Col, Statistic } from 'antd';
import { 
  GlobalOutlined, 
  PhoneOutlined, 
  UserOutlined, 
  WifiOutlined,
  RocketOutlined
} from '@ant-design/icons';

const { Title, Paragraph } = Typography;

interface HomeProps {
  onNavigate: (key: string) => void;
}

const Home: React.FC<HomeProps> = ({ onNavigate }) => {
  return (
    <div>
      {/* Welcome Section */}
      <Card style={{ marginBottom: 24, textAlign: 'center' }}>
        <RocketOutlined style={{ fontSize: 48, color: '#1890ff', marginBottom: 16 }} />
        <Title level={1} style={{ marginBottom: 16 }}>
          Welcome to GhostTrack Web
        </Title>
        <Title level={3} type="secondary" style={{ marginBottom: 24 }}>
          Modern OSINT Platform
        </Title>
        <Paragraph style={{ fontSize: '16px', maxWidth: '800px', margin: '0 auto' }}>
          GhostTrack is a powerful OSINT (Open Source Intelligence) tool that provides comprehensive 
          information gathering capabilities. Track IP addresses, lookup phone numbers, and search 
          for usernames across multiple social media platforms.
        </Paragraph>
      </Card>

      {/* Features Grid */}
      <Row gutter={[24, 24]} style={{ marginBottom: 24 }}>
        <Col xs={24} sm={12} lg={6}>
          <Card 
            hoverable
            className="home-feature-card"
            style={{ textAlign: 'center', height: '100%' }}
            bodyStyle={{ padding: '32px 24px' }}
            onClick={() => onNavigate('ip-tracker')}
          >
            <GlobalOutlined style={{ fontSize: 40, color: '#1890ff', marginBottom: 16 }} />
            <Title level={4}>IP Tracker</Title>
            <Paragraph>
              Get detailed information about any IP address including location, ISP, and geographical data.
            </Paragraph>
          </Card>
        </Col>
        
        <Col xs={24} sm={12} lg={6}>
          <Card 
            hoverable
            className="home-feature-card"
            style={{ textAlign: 'center', height: '100%' }}
            bodyStyle={{ padding: '32px 24px' }}
            onClick={() => onNavigate('phone-tracker')}
          >
            <PhoneOutlined style={{ fontSize: 40, color: '#52c41a', marginBottom: 16 }} />
            <Title level={4}>Phone Tracker</Title>
            <Paragraph>
              Lookup phone number information including carrier, location, and validity status.
            </Paragraph>
          </Card>
        </Col>
        
        <Col xs={24} sm={12} lg={6}>
          <Card 
            hoverable
            className="home-feature-card"
            style={{ textAlign: 'center', height: '100%' }}
            bodyStyle={{ padding: '32px 24px' }}
            onClick={() => onNavigate('username-tracker')}
          >
            <UserOutlined style={{ fontSize: 40, color: '#fa541c', marginBottom: 16 }} />
            <Title level={4}>Username Tracker</Title>
            <Paragraph>
              Search for usernames across 20+ social media platforms and online services.
            </Paragraph>
          </Card>
        </Col>
        
        <Col xs={24} sm={12} lg={6}>
          <Card 
            hoverable
            className="home-feature-card"
            style={{ textAlign: 'center', height: '100%' }}
            bodyStyle={{ padding: '32px 24px' }}
            onClick={() => onNavigate('my-ip')}
          >
            <WifiOutlined style={{ fontSize: 40, color: '#722ed1', marginBottom: 16 }} />
            <Title level={4}>My IP</Title>
            <Paragraph>
              Quickly check your current public IP address and basic network information.
            </Paragraph>
          </Card>
        </Col>
      </Row>

      {/* Statistics */}
      <Card title="Platform Statistics" style={{ marginBottom: 24 }}>
        <Row gutter={[24, 24]}>
          <Col xs={24} sm={8}>
            <Statistic 
              title="Supported Platforms" 
              value={20} 
              suffix="+"
              valueStyle={{ color: '#1890ff' }}
            />
          </Col>
          <Col xs={24} sm={8}>
            <Statistic 
              title="IP Databases" 
              value={3} 
              valueStyle={{ color: '#52c41a' }}
            />
          </Col>
          <Col xs={24} sm={8}>
            <Statistic 
              title="Phone Formats" 
              value={100} 
              suffix="+"
              valueStyle={{ color: '#fa541c' }}
            />
          </Col>
        </Row>
      </Card>

      {/* Quick Start */}
      <Card title="Quick Start Guide">
        <Row gutter={[24, 24]}>
          <Col xs={24} md={12}>
            <Title level={4}>🎯 For IP Tracking</Title>
            <Paragraph>
              <ol>
                <li>Click on "IP Tracker" in the sidebar</li>
                <li>Enter any public IP address (e.g., 8.8.8.8)</li>
                <li>Get detailed geolocation and ISP information</li>
              </ol>
            </Paragraph>
          </Col>
          <Col xs={24} md={12}>
            <Title level={4}>📱 For Phone Lookup</Title>
            <Paragraph>
              <ol>
                <li>Navigate to "Phone Tracker"</li>
                <li>Enter phone number in international format</li>
                <li>Discover carrier and location details</li>
              </ol>
            </Paragraph>
          </Col>
        </Row>
      </Card>
    </div>
  );
};

export default Home;