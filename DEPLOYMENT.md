# GhostTrack Web 版本部署指南

## 🎯 项目概述

GhostTrack Web 版本是原终端OSINT工具的现代化Web应用版本，提供：
- IP地址追踪和地理位置查询
- 手机号码信息查询
- 社交媒体用户名搜索
- 现代化的Web界面

## 🏗️ 技术架构

### 后端
- **框架**: FastAPI (Python)
- **特性**: RESTful API, 自动文档生成, 数据验证
- **安全**: API限流, 输入验证, CORS配置

### 前端
- **框架**: React + TypeScript
- **UI库**: Ant Design
- **构建工具**: Vite

### 部署
- **容器化**: Docker + Docker Compose
- **Web服务器**: Nginx (反向代理)
- **端口**: 80 (前端), 8000 (后端API)

## 🚀 快速部署

### 方法一：一键部署脚本

```bash
# 1. 连接到你的VPS
ssh root@your-vps-ip

# 2. 下载并运行部署脚本
wget https://raw.githubusercontent.com/HunxByts/GhostTrack/main/deploy.sh
chmod +x deploy.sh
./deploy.sh
```

### 方法二：手动部署

#### 1. 环境准备

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 安装Docker Compose
sudo curl -L \"https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 重新登录以应用用户组更改
logout
```

#### 2. 部署应用

```bash
# 克隆项目
cd /opt
sudo mkdir ghosttrack
sudo chown $USER:$USER ghosttrack
cd ghosttrack
git clone https://github.com/HunxByts/GhostTrack.git .

# 启动服务
docker-compose up -d --build

# 查看服务状态
docker-compose ps
```

## 🔧 配置说明

### 环境变量配置

创建 `.env` 文件（可选）：

```bash
# 后端配置
API_HOST=0.0.0.0
API_PORT=8000
MAX_REQUESTS_PER_MINUTE=10

# 前端配置
REACT_APP_API_URL=http://your-domain.com:8000
```

### 防火墙配置

```bash
# Ubuntu/Debian
sudo ufw allow 80/tcp
sudo ufw allow 8000/tcp
sudo ufw enable

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload
```

## 🌐 域名配置（可选）

### 1. 域名解析
在你的域名服务商处添加A记录：
```
Type: A
Name: @
Value: your-vps-ip
```

### 2. SSL证书（推荐）

使用Let's Encrypt免费证书：

```bash
# 安装certbot
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com

# 自动续期
sudo crontab -e
# 添加：0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 监控和维护

### 查看日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend
docker-compose logs -f frontend
```

### 更新应用

```bash
cd /opt/ghosttrack
git pull origin main
docker-compose down
docker-compose up -d --build
```

### 备份和恢复

```bash
# 备份配置
tar -czf ghosttrack-backup-$(date +%Y%m%d).tar.gz /opt/ghosttrack

# 恢复（如需要）
tar -xzf ghosttrack-backup-YYYYMMDD.tar.gz -C /
```

## 🔒 安全建议

1. **定期更新**
   - 定期更新系统和Docker镜像
   - 关注项目更新

2. **访问控制**
   - 使用防火墙限制不必要的端口
   - 考虑使用VPN或IP白名单

3. **监控**
   - 监控资源使用情况
   - 设置日志轮转

4. **备份**
   - 定期备份配置文件
   - 测试恢复流程

## 🛠️ 故障排除

### 常见问题

1. **服务无法启动**
   ```bash
   # 检查端口占用
   sudo netstat -tlnp | grep :80
   sudo netstat -tlnp | grep :8000
   
   # 检查Docker服务
   sudo systemctl status docker
   ```

2. **前端无法访问后端API**
   - 检查CORS配置
   - 确认后端服务正常运行
   - 检查网络连接

3. **API限流问题**
   - 检查请求频率
   - 调整限流配置

### 性能优化

1. **增加API限流上限**（生产环境）
2. **使用CDN**（如有需要）
3. **数据库缓存**（未来版本）

## 📞 技术支持

- **GitHub Issues**: [https://github.com/HunxByts/GhostTrack/issues](https://github.com/HunxByts/GhostTrack/issues)
- **文档**: 项目README.md
- **社区**: 项目讨论区

## 🎉 访问应用

部署完成后，你可以通过以下方式访问：

- **Web界面**: `http://your-vps-ip` 或 `http://your-domain.com`
- **API文档**: `http://your-vps-ip:8000/docs`
- **API健康检查**: `http://your-vps-ip:8000/health`

享受你的OSINT工具Web版本！🎊