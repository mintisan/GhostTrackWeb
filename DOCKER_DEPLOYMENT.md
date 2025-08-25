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

---

## 离线部署方案 📦

当 VPS 无法访问 DockerHub 或网络环境受限时，可以使用离线部署方案。

### 步骤1：创建离线包（在有网络的机器上）

```bash
# 在有网络的机器上运行
cd GhostTrackWeb

# 创建离线部署包
./docker-export.sh

# 压缩以便传输（可选）
./docker-compress.sh
```

### 步骤2：上传到VPS

```bash
# 上传压缩包
scp ghosttrack-offline-*.tar.gz user@your-vps:/path/to/deploy/

# 或上传整个目录
scp -r ghosttrack-offline-* user@your-vps:/path/to/deploy/
```

### 步骤3：在VPS上部署

```bash
# 解压（如果使用了压缩）
tar -xzf ghosttrack-offline-*.tar.gz
cd ghosttrack-offline-*

# 或直接进入目录
cd ghosttrack-offline-*

# 一键部署
./deploy-offline.sh
```

### 手动部署方式

```bash
# 1. 导入所有镜像
./docker-import.sh

# 2. 启动完整应用
docker-compose up -d

# 或仅启动前端
docker-compose -f docker-compose-standalone.yml up -d
```

### 离线包特性

- ✅ **无网络依赖**：完全不需访问 DockerHub
- ✅ **多版本支持**：可指定任意版本导出
- ✅ **压缩传输**：支持 tar.gz/tar.bz2/zip 多种格式
- ✅ **自动部署**：包含交互式部署脚本
- ✅ **完整配置**：包含所有必要的配置文件

### 离线工具列表

| 脚本 | 功能 | 使用时机 |
|-------|------|----------|
| `docker-export.sh` | 创建离线包 | 有网络机器上 |
| `docker-compress.sh` | 压缩离线包 | 有网络机器上 |
| `docker-import.sh` | 批量导入镜像 | VPS上 |
| `deploy-offline.sh` | 自动部署 | VPS上 |

---

## 架构兼容性 💻

### 问题说明

M系列 macOS（ARM64）构建的 Docker 镜像默认不能在 x86_64 架构的 VPS 上运行。

### 架构检测

```bash
# 检查当前镜像架构
docker image inspect mintisan/ghosttrack-frontend:latest | grep Architecture

# 检查服务器架构
uname -m
# x86_64 = Intel/AMD
# aarch64 = ARM64
```

### 解决方案

#### 方案1：多架构构建（推荐）

```bash
# 创建支持 ARM64 和 x86_64 的镜像
./docker-build-multiarch.sh

# 选择: 2) 构建并推送到 DockerHub
```

**优势**：
- ✅ 一个镜像支持多种架构
- ✅ Docker 自动选择匹配架构
- ✅ 最佳用户体验

#### 方案2：分架构离线包

```bash
# 创建 x86_64 架构离线包
./docker-export-arch.sh amd64

# 创建 ARM64 架构离线包
./docker-export-arch.sh arm64
```

**优势**：
- ✅ 针对特定架构优化
- ✅ 离线部署兼容性好
- ✅ 包大小相对较小

#### 方案3：交叉编译

```bash
# 在M系列Mac上构建x86_64镜像
docker buildx build --platform linux/amd64 \
  -t mintisan/ghosttrack-frontend:amd64 \
  --push ./frontend
```

### 架构对照表

| 架构名称 | Docker平台 | 常见设备 |
|---------|-----------|----------|
| x86_64 | linux/amd64 | 大部分VPS、Intel Mac、PC |
| ARM64 | linux/arm64 | M系列Mac、树莓派Pi 4+ |

### 常见错误

```
exec format error
```
**解决**：使用正确架构的镜像

```
no matching manifest for linux/amd64
```
**解决**：需要多架构构建

### 快速修复

如果你的VPS是x86_64架构：

```bash
# 1. 构建多架构镜像
./docker-build-multiarch.sh

# 2. 在VPS上重新部署
docker-compose down
docker-compose pull
docker-compose up -d
```

详细指南请参考：[ARCHITECTURE_COMPATIBILITY.md](./ARCHITECTURE_COMPATIBILITY.md)