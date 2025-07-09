# 🚀 AI Companion - 智能情感伴侣系统

## 📋 项目概述

AI Companion 是一个基于 Spring Boot 的智能情感伴侣系统，集成了 AI 聊天、用户社交、推荐系统、情感分析等多项功能。系统采用微服务架构设计，提供高性能的 AI 交互体验和丰富的社交功能。

## ✨ 核心功能

### 🤖 AI 智能聊天
- **多身份 AI 角色**: 支持情绪管理助手、心理咨询师、生活导师、朋友角色等7种身份
- **情感分析**: 实时分析用户情绪状态，提供个性化回应
- **对话记忆**: 智能维护对话上下文，提供连贯的聊天体验
- **流式响应**: 支持实时流式输出，提升用户体验
- **语音交互**: 集成语音识别和合成功能

### 👥 用户社交系统
- **用户管理**: 完整的用户注册、登录、信息管理功能
- **动态发布**: 支持文字、图片、话题标签的社交动态
- **评论系统**: 多级评论和回复功能，支持点赞
- **隐私控制**: 灵活的隐私设置和可见性控制
- **用户关系**: 好友系统和用户关系管理

### 🎯 智能推荐系统
- **个性化推荐**: 基于用户行为的个性化 AI 角色推荐
- **混合算法**: 结合协同过滤、内容推荐、热门推荐
- **高性能缓存**: 内存缓存驱动，毫秒级响应
- **智能降级**: 多级降级策略，确保服务稳定性

### 🎮 游戏化元素
- **星球系统**: 用户专属虚拟星球，支持等级和经验
- **头像生成**: AI 驱动的个性化头像生成
- **成就系统**: 用户行为激励和成就解锁

### 📊 数据统计
- **用户行为分析**: 全面的用户行为数据收集和分析
- **情感统计**: 用户情感状态趋势分析
- **系统监控**: 实时系统性能监控和统计

## 🛠️ 技术架构

### 后端技术栈
- **框架**: Spring Boot 3.5.3
- **AI 框架**: Spring AI 1.0.0 (DeepSeek 模型)
- **语言**: Java 17
- **构建工具**: Maven
- **数据库**: MySQL 8.0
- **ORM**: MyBatis + JPA
- **缓存**: Redis + 内存缓存
- **文件存储**: 阿里云 OSS
- **邮件服务**: Spring Mail (QQ SMTP)

### 前端技术栈
- **框架**: HarmonyOS ArkTS
- **UI 组件**: HarmonyOS UI
- **状态管理**: 本地状态管理
- **网络请求**: HTTP 客户端
- **文件处理**: 图片上传和预览

### 第三方服务集成
- **AI 模型**: DeepSeek Chat API
- **语音识别**: 讯飞语音识别
- **音乐服务**: ALAPI 音乐服务
- **图片生成**: Pollinations AI
- **情感分析**: 自研情感分析算法

## 🏗️ 系统架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   External      │
│   (HarmonyOS)   │◄──►│   (Spring Boot) │◄──►│   Services      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   MySQL         │    │   Redis         │    │   Aliyun OSS    │
│   (数据存储)      │    │   (缓存)         │    │   (文件存储)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 核心模块
- **用户模块**: 用户管理、认证、权限控制
- **AI 聊天模块**: 多身份聊天、情感分析、对话管理
- **社交模块**: 动态、评论、用户关系
- **推荐模块**: 智能推荐算法、用户行为分析
- **文件模块**: 头像上传、图片处理、OSS 集成
- **统计模块**: 数据统计、行为分析、系统监控

## 🚀 快速开始

### 环境要求
- **JDK**: 17+
- **Maven**: 3.6+
- **MySQL**: 8.0+
- **Redis**: 6.0+
- **Node.js**: 16+ (前端开发)

### 后端启动

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd backend/MyApplication
   ```

2. **配置数据库**
   ```bash
   # 创建数据库
   mysql -u root -p
   CREATE DATABASE xinyu CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   
   # 导入数据表结构
   mysql -u root -p xinyu < src/main/resources/app.sql
   ```

3. **配置应用参数**
   
   编辑 `src/main/resources/application.properties`:
   ```properties
   # 数据库配置
   spring.datasource.url=jdbc:mysql://localhost:3306/xinyu
   spring.datasource.username=your_username
   spring.datasource.password=your_password
   
   # Redis 配置
   spring.data.redis.host=localhost
   spring.data.redis.port=6379
   
   # AI API 配置
   spring.ai.openai.api-key=your_deepseek_api_key
   spring.ai.openai.base-url=https://api.deepseek.com
   
   # 阿里云 OSS 配置
   aliyun.oss.endpoint=your_endpoint
   aliyun.oss.access-key-id=your_access_key
   aliyun.oss.access-key-secret=your_secret
   aliyun.oss.bucket-name=your_bucket
   ```

4. **启动服务**
   ```bash
   mvn spring-boot:run
   ```

5. **验证服务**
   ```bash
   curl http://localhost:8081/api/user/health
   ```

### 前端启动

1. **安装依赖**
   ```bash
   cd entry
   npm install
   ```

2. **配置开发环境**
   ```bash
   # 配置后端 API 地址
   # 修改 entry/src/main/ets/common/constants/ApiConstants.ets
   ```

3. **启动开发服务器**
   ```bash
   npm run dev
   ```

## 📚 API 文档

### 核心 API 模块
- **AI 聊天 API**: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **用户管理 API**: [USER_API_DOCUMENTATION.md](USER_API_DOCUMENTATION.md)
- **评论系统 API**: [COMMENT_API_DOCUMENTATION.md](COMMENT_API_DOCUMENTATION.md)

### 主要接口

#### AI 聊天接口
```http
POST /api/ai/featured_chat
GET  /api/ai/identities
POST /api/ai/generate-description
POST /api/ai/generate-figure
```

#### 用户管理接口
```http
GET  /api/user/{userUID}
PUT  /api/user/{userUID}
POST /api/user/{userUID}/avatar
POST /api/user/create
```

#### 社交动态接口
```http
POST /api/dynamic/create/{userUID}
GET  /api/dynamic/user/{userUID}
GET  /api/dynamic/public
POST /api/dynamic/{id}/like
```

#### 推荐系统接口
```http
GET  /api/recommendation/hybrid
GET  /api/recommendation/personalized
POST /api/recommendation/behavior
```

## 🏛️ 项目结构

```
MyApplication/
├── src/main/java/com/ai/companion/
│   ├── MyApplication.java              # 主启动类
│   ├── controller/                     # 控制器层
│   │   ├── ChatController.java         # AI 聊天控制器
│   │   ├── UserController.java         # 用户管理控制器
│   │   ├── DynamicController.java      # 动态管理控制器
│   │   ├── RecommendationController.java # 推荐系统控制器
│   │   ├── CommentController.java      # 评论系统控制器
│   │   └── ...
│   ├── service/                        # 服务层
│   │   ├── impl/                       # 服务实现
│   │   │   ├── RecommendationServiceImpl.java # 推荐服务实现
│   │   │   ├── UserServiceImpl.java    # 用户服务实现
│   │   │   └── ...
│   │   └── ...
│   ├── entity/                         # 实体层
│   │   ├── User.java                   # 用户实体
│   │   ├── AiRole.java                 # AI 角色实体
│   │   ├── Dynamic.java                # 动态实体
│   │   ├── Comment.java                # 评论实体
│   │   └── vo/                         # 视图对象
│   ├── mapper/                         # 数据访问层
│   ├── config/                         # 配置层
│   └── utils/                          # 工具类
├── src/main/resources/
│   ├── application.properties          # 应用配置
│   ├── app.sql                         # 数据库结构
│   └── mapper/                         # MyBatis 映射文件
├── entry/                              # 前端代码
│   └── src/main/ets/
└── docs/                               # 项目文档
```

## 🔧 核心特性

### 高性能推荐系统
- **缓存驱动**: 内存缓存 + Redis 缓存
- **智能算法**: 协同过滤 + 内容推荐 + 热门推荐
- **快速响应**: 毫秒级推荐响应
- **智能降级**: 多级降级策略

### 情感分析引擎
- **实时分析**: 用户消息情感实时分析
- **情感标签**: 自动标记情感状态
- **个性化回应**: 基于情感的 AI 回应

### 文件存储系统
- **阿里云 OSS**: 云端文件存储
- **图片处理**: 自动图片压缩和格式转换
- **头像生成**: AI 驱动的个性化头像

### 数据安全
- **隐私控制**: 用户隐私设置
- **数据加密**: 敏感数据加密存储
- **访问控制**: 基于角色的权限控制

## 📊 性能指标

### 响应时间
- **AI 聊天**: < 2秒
- **推荐系统**: < 1秒 (缓存命中)
- **文件上传**: < 3秒
- **数据查询**: < 500ms

### 系统容量
- **并发用户**: 1000+
- **日活跃用户**: 10000+
- **数据存储**: 支持 TB 级数据
- **缓存命中率**: 85%+

## 🧪 测试

### 单元测试
```bash
mvn test
```

### 集成测试
```bash
mvn verify
```

### 性能测试
```bash
# 使用 JMeter 进行压力测试
jmeter -n -t performance-test.jmx -l results.jtl
```

## 🚀 部署

### Docker 部署
```bash
# 构建镜像
docker build -t ai-companion .

# 运行容器
docker run -d -p 8081:8081 --name ai-companion ai-companion
```

### 生产环境配置
```properties
# 生产环境配置
spring.profiles.active=prod
server.port=8081
logging.level.root=WARN
```

## 📈 监控和维护

### 系统监控
- **应用监控**: Spring Boot Actuator
- **数据库监控**: MySQL 慢查询日志
- **缓存监控**: Redis 性能指标
- **错误监控**: 异常日志收集

### 日志管理
```bash
# 查看应用日志
tail -f logs/application.log

# 查看错误日志
grep "ERROR" logs/application.log
```

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

- **项目维护者**: AI Companion Team
- **邮箱**: support@aicompanion.com
- **项目地址**: https://github.com/your-org/ai-companion

## 🙏 致谢

感谢以下开源项目和服务：
- Spring Boot 团队
- DeepSeek AI 团队
- 阿里云 OSS 服务
- 讯飞语音服务
- HarmonyOS 开发团队

---

**AI Companion** - 让 AI 成为你的情感伴侣 🚀
 