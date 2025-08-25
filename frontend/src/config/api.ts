// API配置
const isDevelopment = import.meta.env.DEV;
const isDocker = window.location.hostname === 'localhost' && window.location.port === '8192';

// 根据环境确定API基础URL
export const getApiBaseUrl = (): string => {
  if (isDocker) {
    // Docker环境下，后端运行在8088端口
    return 'http://localhost:8088';
  } else if (isDevelopment) {
    // 本地开发环境
    return 'http://localhost:8000';
  } else {
    // 生产环境，使用相对路径
    return '';
  }
};

export const API_BASE_URL = getApiBaseUrl();

// API端点
export const API_ENDPOINTS = {
  TRACK_IP: `${API_BASE_URL}/api/track-ip`,
  TRACK_PHONE: `${API_BASE_URL}/api/track-phone`,
  TRACK_USERNAME: `${API_BASE_URL}/api/track-username`,
  MY_IP: `${API_BASE_URL}/api/my-ip`,
  HEALTH: `${API_BASE_URL}/`,
};