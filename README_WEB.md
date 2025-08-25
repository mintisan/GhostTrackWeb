# GhostTrackWeb - 现代化OSINT工具平台

🎯 **从终端到Web的完美蜕变** - 将原始命令行OSINT工具升级为现代化Web应用

## 📋 项目概述

### 🔄 项目演进历程

**原始版本 (GhostTR.py)**
- 📟 纯命令行界面工具
- 🐍 单文件Python脚本 (316行代码)
- 🎨 彩色终端输出界面
- 👤 单用户本地使用
- 🛠️ 依赖: requests + phonenumbers

**Web版本 (GhostTrackWeb)**
- 🌐 现代化Web用户界面
- 🏗️ 前后端分离架构
- 🔐 企业级安全特性
- 👥 多用户并发支持
- 📱 响应式移动端适配
- 🐳 容器化部署方案

### ✨ 核心功能模块

#### 🌍 IP地址追踪器
- **功能**: 获取任意公网IP的详细地理位置和网络信息
- **数据源**: ipwho.is API
- **输出信息**:
  - 地理位置: 国家、城市、地区、经纬度
  - 网络信息: ISP、ASN、组织、域名
  - 时区信息: UTC偏移、当前时间、夏令时状态
  - 其他: 邮政编码、国旗、边境国家
  - Google Maps 直链

#### 📱 手机号码追踪器
- **功能**: 查询手机号码的归属地和运营商信息
- **技术**: phonenumbers 库的深度集成
- **支持格式**: 国际格式 (+86139xxxxxxxx)
- **输出信息**:
  - 归属地信息和地区代码
  - 运营商名称
  - 号码有效性验证
  - 多种格式化输出 (国际/本地/E164)
  - 时区信息
  - 号码类型识别 (手机/固话)

#### 👤 社交媒体用户名追踪器
- **功能**: 在多个社交平台批量搜索用户名
- **覆盖平台**: 18个主流社交媒体和专业平台
  - 社交: Facebook, Twitter, Instagram, LinkedIn
  - 开发: GitHub, Behance, Dribbble
  - 媒体: YouTube, TikTok, SoundCloud
  - 专业: Medium, Quora, Flickr
  - 其他: Telegram, Snapchat, Tumblr, Pinterest, Twitch
- **智能检测**: HTTP状态码验证用户存在性
- **结果统计**: 找到平台数量/总搜索平台数

#### 💻 本机IP查询器
- **功能**: 快速获取当前设备的公网IP地址
- **数据源**: ipify.org API
- **扩展功能**: Web版本集成IP详情自动查询

## 🏗️ 技术架构升级

### 后端技术栈 (FastAPI)
```python
# 主要依赖
FastAPI          # 现代Python Web框架
Uvicorn          # ASGI高性能服务器
Pydantic         # 数据验证和序列化
requests         # HTTP客户端 (沿用原版)
phonennumbers    # 电话号码处理 (沿用原版)
```

**架构特性**:
- 🚀 异步API端点设计
- 🔒 Pydantic数据验证
- 🛡️ 内存限流器 (10请求/分钟)
- 🌐 CORS跨域支持
- 📋 自动API文档生成
- ❤️ 健康检查端点

### 前端技术栈 (React + TypeScript)
```json
{
  "核心框架": "React 18 + TypeScript",
  "构建工具": "Vite (替代Create React App)",
  "UI组件库": "Ant Design 5.x",
  "HTTP客户端": "Axios",
  "状态管理": "React Hooks",
  "样式方案": "CSS-in-JS + CSS Modules"
}
```

**界面特性**:
- 🎨 Material Design风格界面
- 🌓 明/暗主题切换
- 📱 响应式布局设计
- ⚡ 实时加载状态反馈
- 📊 数据可视化展示
- 🔄 智能错误处理

### 部署架构 (Docker + Nginx)
```yaml
# 容器编排
services:
  - ghosttrack-backend   # FastAPI应用服务
  - ghosttrack-frontend  # Nginx + React静态资源
  
# 网络配置
networks:
  - ghosttrack-network   # 内部通信网络
```

**部署特性**:
- 🐳 Docker多阶段构建优化
- 🔄 自动健康检查
- 🔧 环境变量配置
- 📈 生产级性能优化

## 🚀 快速开始

### 开发环境搭建

#### 1. 后端服务启动
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
# 🚀 后端服务: http://localhost:8000
# 📚 API文档: http://localhost:8000/docs
```

#### 2. 前端服务启动
```bash
cd frontend
npm install
npm run dev
# 🌐 前端服务: http://localhost:5173
```

### 生产环境部署

#### Docker Compose 一键部署
```bash
# 🚀 构建并启动全部服务
docker-compose up -d --build

# 📊 查看服务状态
docker-compose ps

# 📋 查看实时日志
docker-compose logs -f

# 🔄 重启服务
docker-compose restart

# 🛑 停止服务
docker-compose down
```

#### VPS自动化部署
```bash
# 📥 下载部署脚本
wget https://raw.githubusercontent.com/mintisan/GhostTrackWeb/main/deploy.sh
chmod +x deploy.sh

# 🚀 执行一键部署
./deploy.sh
```

## 🔗 服务访问地址

| 服务 | 开发环境 | 生产环境 |
|------|----------|----------|
| 🌐 Web界面 | http://localhost:5173 | http://your-domain.com |
| 🔌 API服务 | http://localhost:8000 | http://your-domain.com:8000 |
| 📚 API文档 | http://localhost:8000/docs | http://your-domain.com:8000/docs |
| ❤️ 健康检查 | http://localhost:8000/health | http://your-domain.com:8000/health |

## 📊 功能对比分析

### 🔄 原版 vs Web版本

| 维度 | 原版 GhostTR.py | Web版 GhostTrackWeb | 改进程度 |
|------|----------------|---------------------|----------|
| **用户界面** | 终端彩色文本 | 现代Web界面 | ⭐⭐⭐⭐⭐ |
| **使用门槛** | 需要Python环境 | 零安装浏览器访问 | ⭐⭐⭐⭐⭐ |
| **多用户支持** | ❌ 单用户 | ✅ 多用户并发 | ⭐⭐⭐⭐⭐ |
| **移动端支持** | ❌ 仅桌面终端 | ✅ 响应式适配 | ⭐⭐⭐⭐⭐ |
| **数据展示** | 纯文本输出 | 结构化可视化 | ⭐⭐⭐⭐⭐ |
| **API接口** | ❌ 无 | ✅ RESTful API | ⭐⭐⭐⭐⭐ |
| **安全性** | 本地使用 | 企业级安全机制 | ⭐⭐⭐⭐ |
| **部署复杂度** | 简单脚本 | 容器化自动部署 | ⭐⭐⭐⭐ |
| **扩展性** | 单体脚本 | 微服务架构 | ⭐⭐⭐⭐⭐ |
| **错误处理** | 基础异常捕获 | 完善错误处理机制 | ⭐⭐⭐⭐ |

### 🎯 核心改进亮点

#### 1. 🎨 用户体验革命性提升
- **原版**: 黑色终端界面，需要记忆命令
- **Web版**: 直观的图形界面，点击操作
- **提升**: 从极客工具升级为大众化应用

#### 2. 🔐 企业级安全加固
- **限流保护**: 防止API滥用 (10请求/分钟)
- **输入验证**: 严格的数据格式校验
- **私网保护**: 阻止内网IP查询攻击
- **XSS防护**: 前端输入过滤

#### 3. 📊 数据展示优化
- **原版**: 纯文本列表输出
- **Web版**: 卡片式布局，表格展示
- **增强**: Google Maps集成，直接链接跳转

#### 4. 🚀 性能与可扩展性
- **原版**: 同步执行，单线程
- **Web版**: 异步API，支持并发
- **优化**: 请求缓存，响应速度提升

## 🔌 API接口规范

### 🌍 IP追踪接口
```http
POST /api/track-ip
Content-Type: application/json

{
  "ip_address": "8.8.8.8"
}
```

### 📱 手机号码追踪接口
```http
POST /api/track-phone
Content-Type: application/json

{
  "phone_number": "+8613912345678"
}
```

### 👤 用户名追踪接口
```http
POST /api/track-username
Content-Type: application/json

{
  "username": "john_doe"
}
```

### 💻 本机IP查询接口
```http
GET /api/my-ip
```

## 🔒 安全机制详解

### 🛡️ API安全特性
- **速率限制**: 内存级限流器，防止API滥用
- **输入校验**: Pydantic模型验证，防止注入攻击
- **IP白名单**: 过滤私有IP地址查询
- **CORS配置**: 跨域请求安全控制
- **错误处理**: 统一异常处理，不泄露敏感信息

### 🔐 前端安全特性
- **输入过滤**: 防止XSS跨站脚本攻击
- **HTTPS支持**: 生产环境强制HTTPS
- **CSP策略**: 内容安全策略配置
- **依赖安全**: 定期更新第三方依赖

## 🚨 已知限制与解决方案

### ⚠️ 技术限制
1. **外部API依赖**: ipwho.is服务可用性
   - 解决方案: 添加备用API源
2. **用户名检测准确性**: 部分平台反爬机制
   - 解决方案: 更新User-Agent，添加代理支持
3. **手机号码覆盖范围**: 主要支持国际格式
   - 解决方案: 扩展本地格式支持

### 🔧 性能限制
- **并发限制**: 当前10请求/分钟
- **响应时间**: 依赖外部API响应速度
- **存储限制**: 无持久化数据存储

## 🔮 未来发展路线图

### 🎯 短期目标 (v2.1)
- [ ] 用户认证系统
- [ ] 查询历史记录
- [ ] 批量查询功能
- [ ] API密钥管理

### 🚀 中期目标 (v2.5)
- [ ] 数据导出功能 (PDF/Excel/JSON)
- [ ] 高级搜索过滤器
- [ ] 实时通知系统
- [ ] 多语言国际化

### 🌟 长期目标 (v3.0)
- [ ] 机器学习威胁检测
- [ ] 移动端原生APP
- [ ] 区块链数据集成
- [ ] OSINT工具生态集成

## 🤝 贡献与支持

### 📞 技术支持
- **GitHub Issues**: [报告Bug和功能请求](https://github.com/mintisan/GhostTrackWeb/issues)
- **讨论区**: [技术交流和问答](https://github.com/mintisan/GhostTrackWeb/discussions)
- **文档**: 查看 `DEPLOYMENT.md` 获取详细部署指南

### 🎯 贡献指南
1. Fork项目仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 打开Pull Request

### 🏆 贡献者致谢
- **原始项目**: [HUNX04](https://github.com/HunxByts) - GhostTR.py创始人
- **Web移植**: 现代化架构设计与实现
- **社区贡献**: 感谢所有Issue报告和功能建议

## 📄 许可证声明

本项目基于原始GhostTrack项目开发，遵循以下原则：
- 保持开源免费使用
- 尊重原作者版权声明
- 禁止商业用途未经授权使用
- 使用时请标注原始项目来源

---

## 🎉 总结

**GhostTrackWeb** 代表了从传统命令行工具到现代Web应用的完美进化：

🔄 **技术演进**: 从316行Python脚本到完整的前后端分离架构  
🎨 **体验升级**: 从黑色终端界面到现代化Web UI  
🔐 **安全加固**: 从本地工具到企业级安全防护  
🚀 **性能提升**: 从同步执行到异步并发处理  
📱 **平台扩展**: 从桌面专用到移动端响应式适配  

> **🌟 让OSINT工具更简单、更强大、更安全！**

**从终端极客工具到全民化Web应用，GhostTrackWeb让信息收集变得前所未有的简单直观。**