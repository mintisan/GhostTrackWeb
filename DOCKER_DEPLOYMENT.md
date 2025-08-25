# GhostTrack Web Docker 部署指南

## 部署方式说明

### 1. 完整应用部署（推荐）

使用 `docker-compose` 部署完整的前后端应用：

```bash
# 使用本地构建
docker-compose up -d

# 或使用DockerHub镜像
docker-compose -f docker-compose.prod.yml up -d
```

**特点：**
- ✅ 包含完整的前后端功能
- ✅ 自动网络配置
- ✅ 服务间通信正常
- ✅ 所有API功能可用

**访问地址：**
- 前端：http://localhost:8192
- 后端API：http://localhost:8088

---

### 2. 独立前端部署

仅部署前端应用，不包含后端服务：

```bash
# 构建独立前端镜像
./build-standalone-frontend.sh

# 运行独立前端
docker run -p 8080:80 mintisan/ghosttrack-frontend-standalone:latest
```

**特点：**
- ✅ 可以独立启动
- ✅ 前端路由功能完整
- ❌ API功能不可用（IP追踪、电话追踪、用户名追踪）
- ⚠️ 适合展示和UI测试

**访问地址：**
- 前端：http://localhost:8080

---

### 3. Docker Desktop 使用说明

#### 问题原因
当你在 Docker Desktop 中单独点击启动前端容器时，会出现以下错误：
```
host not found in upstream "backend"
```

这是因为：
1. 单独启动的容器没有连接到 Docker 网络
2. nginx 配置中的 "backend" 主机名无法解析
3. 前端容器依赖后端容器，但后端容器未运行

#### 解决方案

**方案1：使用 docker-compose（推荐）**
```bash
# 在项目根目录执行
docker-compose up -d
```

**方案2：使用独立前端镜像**
```bash
# 构建并使用独立前端镜像
./build-standalone-frontend.sh
docker run -p 8080:80 mintisan/ghosttrack-frontend-standalone:latest
```

**方案3：手动创建网络并启动**
```bash
# 创建网络
docker network create ghosttrack-network

# 启动后端
docker run -d --name backend --network ghosttrack-network -p 8088:8000 mintisan/ghosttrack-backend:latest

# 启动前端
docker run -d --name frontend --network ghosttrack-network -p 8192:80 mintisan/ghosttrack-frontend:latest
```

---

## 镜像说明

### 现有镜像

1. **mintisan/ghosttrack-frontend:latest**
   - 标准前端镜像
   - 需要与后端一起使用
   - 包含完整的API代理配置

2. **mintisan/ghosttrack-backend:latest**
   - 后端API服务
   - 提供所有追踪功能

3. **mintisan/ghosttrack-frontend-standalone:latest** ✅ 已发布
   - 独立前端镜像
   - 可单独运行，无需后端依赖
   - API功能降级处理
   - 解决Docker Desktop单独启动问题

### 推荐使用方式

- **生产环境**：使用 `docker-compose.prod.yml`
- **开发测试**：使用 `docker-compose.yml`
- **仅UI展示**：使用独立前端镜像
- **Docker Desktop**：使用 docker-compose 或独立前端镜像

---

## 故障排除

### 1. 前端无法启动
- 检查是否使用了正确的镜像版本
- 确认网络配置是否正确
- 查看容器日志：`docker logs <container_name>`

### 2. API功能不可用
- 确认后端服务是否正常运行
- 检查网络连接：`docker exec frontend ping backend`
- 验证后端健康状态：`curl http://localhost:8088/`

### 3. Docker Desktop 启动问题
- 使用 docker-compose 而不是单独启动容器
- 或使用独立前端镜像进行测试

---

## VPS部署方式

### 方式1：Docker Compose 本地/远程部署

**本地开发/测试环境**：
```bash
# 克隆项目
git clone https://github.com/mintisan/GhostTrackWeb.git
cd GhostTrackWeb

# 使用修改后的docker-compose.yml（支持DockerHub镜像回退）
docker-compose up -d
```

**VPS纯镜像部署**：
```bash
# 无需克隆源码，直接运行
curl -sSL https://raw.githubusercontent.com/mintisan/GhostTrackWeb/main/vps-quick-deploy.sh | bash
```

### 方式2：一键VPS部署脚本

```bash
# 下载并运行部署脚本
curl -sSL https://raw.githubusercontent.com/mintisan/GhostTrackWeb/main/deploy-vps.sh | bash

# 或者自定义参数
wget https://raw.githubusercontent.com/mintisan/GhostTrackWeb/main/deploy-vps.sh
chmod +x deploy-vps.sh

# 使用DockerHub镜像部署（推荐）
./deploy-vps.sh -m dockerhub -p 8080 -b 8000

# 从源码构建部署
./deploy-vps.sh -m 源码 -p 8080 -b 8000
```

### 方式3：Docker Desktop 部署

```bash
# 使用部署向导
./docker-desktop-deploy.sh
```

---

```bash
# 完整应用（生产环境）
docker-compose -f docker-compose.prod.yml up -d

# 完整应用（开发环境）
docker-compose up -d

# 仅前端展示
docker run -p 8080:80 mintisan/ghosttrack-frontend-standalone:latest

# 停止服务
docker-compose down
```