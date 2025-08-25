# GhostTrack

**GhostTrack** 是一个专为开源情报（OSINT）设计的强大工具，能够收集IP地址、电话号码和用户名相关的信息。它为侦察和信息收集任务提供了一个集中化的实用工具。

<img src="https://github.com/mintisan/GhostTrackWeb/blob/main/asset/bn.png"/>

## 🌟 主要功能

- **🌍 IP 地址追踪**: 检索IP地址的位置和元数据信息
- **📱 电话号码追踪**: 基于目标电话号码收集相关信息
- **👤 用户名追踪**: 在多个社交媒体平台上搜索用户名
- **📍 本机IP查询**: 显示当前设备的公网IP地址

## 🎯 版本说明

- **CLI版本**: 原始的命令行界面版本（`GhostTR.py`）- Version 2.2
- **Web版本**: 现代化的Web应用界面，支持路由和暗黑模式 - Version 1.0.0

## 🚀 快速开始

### 💻 CLI版本使用

#### 安装要求 (Linux/Debian)
```bash
sudo apt-get install git
sudo apt-get install python3
```

#### 安装要求 (Termux)
```bash
pkg install git
pkg install python3
```

#### 使用步骤
```bash
# 克隆仓库
git clone https://github.com/mintisan/GhostTrackWeb.git
cd GhostTrackWeb

# 安装依赖
pip3 install -r requirements.txt

# 运行应用
python3 GhostTR.py
```

### 🌐 Web版本部署

#### 方式一：Docker Hub 一键部署（推荐）

```bash
# 下载部署脚本
curl -fsSL https://raw.githubusercontent.com/mintisan/GhostTrackWeb/main/deploy-vps.sh -o deploy-vps.sh
chmod +x deploy-vps.sh

# 运行部署（默认端口：前端8192，后端8088）
./deploy-vps.sh

# 或者自定义端口
./deploy-vps.sh -p 80 -b 8000
```

#### 方式二：Docker Compose

```bash
# 下载配置文件
curl -fsSL https://raw.githubusercontent.com/mintisan/GhostTrackWeb/main/docker-compose.prod.yml -o docker-compose.yml

# 启动服务
docker compose up -d
```

#### 方式三：本地开发部署

```bash
# 克隆仓库
git clone https://github.com/mintisan/GhostTrackWeb.git
cd GhostTrackWeb

# 使用Docker Compose
docker-compose up -d

# 或者手动启动
./docker-deploy-local.sh
```

## 📦 Docker 镜像

GhostTrack 提供预构建的 Docker 镜像：

- **前端**: `mintisan/ghosttrack-frontend`
- **后端**: `mintisan/ghosttrack-backend`

**可用标签**:
- `latest`: 最新稳定版本
- `1.0.0`, `1.1.0` 等: 特定版本号

## 🌐 访问地址

部署成功后，可通过以下地址访问：

- **前端应用**: http://your-server-ip:8192
  - 主页: `/`
  - IP 追踪: `/ip-tracker`
  - 手机号追踪: `/phone-tracker`
  - 用户名追踪: `/username-tracker`
  - 本机 IP: `/my-ip`

- **后端 API**: http://your-server-ip:8088

## 📱 功能展示

### IP Tracker
<img src="https://github.com/mintisan/GhostTrackWeb/blob/main/asset/ip.png " />

在IP Track菜单中，您可以与seeker工具结合使用来获取目标IP
<details>
<summary>⚡ 安装 Seeker :</summary>
- <strong><a href="https://github.com/thewhiteh4t/seeker">获取 Seeker</a></strong>
</details>

### Phone Tracker
<img src="https://github.com/mintisan/GhostTrackWeb/blob/main/asset/phone.png" />

在此菜单中，您可以搜索目标电话号码的信息

### Username Tracker
<img src="https://github.com/mintisan/GhostTrackWeb/blob/main/asset/User.png"/>

在此菜单中，您可以在社交媒体上搜索目标用户名的信息

## 📚 文档

- [Docker 部署指南](DOCKER_DEPLOY.md)
- [本地部署指南](DOCKER_LOCAL_DEPLOY.md)
- [Web版本说明](README_WEB.md)

<details>
<summary>⚡ 作者 :</summary>
- <strong><a href="https://github.com/mintisan">mintisan</a></strong>
</details>