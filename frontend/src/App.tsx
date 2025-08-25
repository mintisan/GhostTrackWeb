import React, { useState, useEffect } from 'react';
import { Layout, Menu, Typography, theme, ConfigProvider, Button } from 'antd';
import { 
  GlobalOutlined, 
  PhoneOutlined, 
  UserOutlined, 
  WifiOutlined,
  EyeOutlined,
  SunOutlined,
  MoonOutlined
} from '@ant-design/icons';
import Home from './components/Home';
import IPTracker from './components/IPTracker';
import PhoneTracker from './components/PhoneTracker';
import UsernameTracker from './components/UsernameTracker';
import MyIP from './components/MyIP';
import './App.css';

const { Header, Content, Sider } = Layout;
const { Title } = Typography;

type MenuItem = {
  key: string;
  icon: React.ReactNode;
  label: string;
};

const items: MenuItem[] = [
  {
    key: 'home',
    icon: <EyeOutlined />,
    label: 'Home',
  },
  {
    key: 'ip-tracker',
    icon: <GlobalOutlined />,
    label: 'IP Tracker',
  },
  {
    key: 'phone-tracker',
    icon: <PhoneOutlined />,
    label: 'Phone Tracker',
  },
  {
    key: 'username-tracker',
    icon: <UserOutlined />,
    label: 'Username Tracker',
  },
  {
    key: 'my-ip',
    icon: <WifiOutlined />,
    label: 'My IP',
  },
];

function App() {
  const [selectedKey, setSelectedKey] = useState('home');
  const [collapsed, setCollapsed] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(() => {
    // 从localStorage获取用户偏好设置，如果没有则使用系统偏好
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) {
      return savedTheme === 'dark';
    }
    // 检测系统主题偏好
    return window.matchMedia('(prefers-color-scheme: dark)').matches;
  });

  // 监听系统主题变化
  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    const handleChange = (e: MediaQueryListEvent) => {
      // 只在用户没有手动设置主题时才跟随系统
      if (!localStorage.getItem('theme')) {
        setIsDarkMode(e.matches);
      }
    };

    mediaQuery.addEventListener('change', handleChange);
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, []);

  // 更新document的data-theme属性
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', isDarkMode ? 'dark' : 'light');
    // 同时设置根元素的背景色
    const rootBg = isDarkMode ? '#141414' : '#ffffff';
    
    // 设置所有可能的根元素背景色
    document.body.style.backgroundColor = rootBg;
    document.body.style.background = rootBg;
    document.documentElement.style.backgroundColor = rootBg;
    document.documentElement.style.background = rootBg;
    
    // 确保html元素也设置背景色
    document.documentElement.style.minHeight = '100%';
    document.body.style.minHeight = '100vh';
    
    // 移除任何可能的默认样式
    document.body.style.margin = '0';
    document.body.style.padding = '0';
    
    // 设置CSS变量以确保主题一致性
    document.documentElement.style.setProperty('--app-bg-color', rootBg);
    
    // 强制刷新页面样式
    const rootElement = document.getElementById('root');
    if (rootElement) {
      rootElement.style.backgroundColor = rootBg;
      rootElement.style.background = rootBg;
    }
  }, [isDarkMode]);

  // 切换主题
  const toggleTheme = () => {
    const newTheme = !isDarkMode;
    setIsDarkMode(newTheme);
    localStorage.setItem('theme', newTheme ? 'dark' : 'light');
  };

  const {
    token: { colorBgContainer, borderRadiusLG, colorBorder, colorBgLayout },
  } = theme.useToken();

  const renderContent = () => {
    switch (selectedKey) {
      case 'ip-tracker':
        return <IPTracker />;
      case 'phone-tracker':
        return <PhoneTracker />;
      case 'username-tracker':
        return <UsernameTracker />;
      case 'my-ip':
        return <MyIP />;
      default:
        return <Home onNavigate={(key) => setSelectedKey(key)} />;
    }
  };

  return (
    <ConfigProvider
      theme={{
        algorithm: isDarkMode ? theme.darkAlgorithm : theme.defaultAlgorithm,
      }}
    >
      <Layout className="fixed-layout" style={{ minHeight: '100vh', height: '100%', overflow: 'hidden', background: colorBgLayout }}>
        <Sider
          breakpoint="lg"
          collapsedWidth="0"
          collapsed={collapsed}
          onCollapse={(collapsed) => setCollapsed(collapsed)}
          className="fixed-sider"
          style={{
            background: colorBgContainer,
            borderRight: `1px solid ${colorBorder}`,
            position: 'fixed',
            left: 0,
            top: 0,
            bottom: 0,
            height: '100vh',
            overflow: 'auto',
            zIndex: 100
          }}
          width={256}
        >
          <div 
            style={{ 
              height: 64, 
              display: 'flex', 
              alignItems: 'center', 
              justifyContent: 'center',
              borderBottom: `1px solid ${colorBorder}`,
              fontWeight: 'bold',
              fontSize: '18px',
              position: 'sticky',
              top: 0,
              background: colorBgContainer,
              zIndex: 101
            }}
          >
            GhostTrackWeb
          </div>
          <Menu
            mode="inline"
            selectedKeys={[selectedKey]}
            items={items}
            onClick={({ key }) => setSelectedKey(key)}
            style={{ border: 'none', paddingBottom: '20px' }}
          />
        </Sider>
        
        <Layout style={{ marginLeft: collapsed ? 0 : 256 }}>
          <Header 
            style={{ 
              padding: '0 24px', 
              background: colorBgContainer,
              borderBottom: `1px solid ${colorBorder}`,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              position: 'sticky',
              top: 0,
              zIndex: 99
            }}
          >
            <Title level={3} style={{ margin: 0 }}>
              {items.find(item => item.key === selectedKey)?.label || 'GhostTrackWeb'}
            </Title>
            
            <Button 
              type="text"
              icon={isDarkMode ? <SunOutlined /> : <MoonOutlined />}
              onClick={toggleTheme}
              size="large"
              className="theme-toggle-btn"
              style={{ 
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
              }}
              title={isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
            />
          </Header>
          
          <Content 
            className="main-content"
            style={{ 
              height: 'calc(100vh - 64px)',
              overflow: 'auto',
              padding: '24px',
              background: colorBgLayout
            }}
          >
            <div
              style={{
                padding: 24,
                background: colorBgContainer,
                borderRadius: borderRadiusLG,
                minHeight: 'calc(100vh - 112px)'
              }}
            >
              {renderContent()}
            </div>
          </Content>
        </Layout>
      </Layout>
    </ConfigProvider>
  );
}

export default App;
