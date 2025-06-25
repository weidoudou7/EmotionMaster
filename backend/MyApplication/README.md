# AI Companion Backend

## 项目概述

这是一个基于Spring Boot的AI聊天伴侣后端服务，提供AI多身份聊天和用户管理功能。

## 功能特性

### AI聊天功能
- 支持7种不同的AI身份角色
- 流式响应聊天
- 对话历史记忆
- 动态身份切换

### 用户管理功能
- 用户信息管理
- 头像上传
- 隐私设置
- 用户资料编辑

## 技术栈

- **框架**: Spring Boot 3.5.3
- **AI框架**: Spring AI 1.0.0
- **语言**: Java 17
- **构建工具**: Maven
- **API**: RESTful API
- **响应格式**: JSON

## 快速开始

### 环境要求

- JDK 17+
- Maven 3.6+

### 启动步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd backend/MyApplication
   ```

2. **配置API密钥**
   
   编辑 `src/main/resources/application.yml` 文件，配置你的AI API密钥：
   ```yaml
   spring:
     ai:
       openai:
         api-key: your-api-key-here
         base-url: https://api.siliconflow.cn
   ```

3. **启动服务**
   ```bash
   mvn spring-boot:run
   ```

4. **验证服务**
   
   访问 `http://localhost:8080/api/user/health` 检查服务状态

## API文档

### AI聊天API
- 详细文档: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

### 用户管理API
- 详细文档: [USER_API_DOCUMENTATION.md](USER_API_DOCUMENTATION.md)

## 项目结构

```
src/main/java/com/ai/companion/
├── MyApplication.java              # 主启动类
├── controller/                     # 控制器层
│   ├── ChatController.java         # AI聊天控制器
│   ├── ChatHistoryController.java  # 聊天历史控制器
│   └── UserController.java         # 用户管理控制器
├── service/                        # 服务层
│   ├── UserService.java            # 用户服务接口
│   └── impl/
│       └── UserServiceImpl.java    # 用户服务实现
├── config/                         # 配置层
│   ├── AIComConfig.java            # AI组件配置
│   ├── AIIdentityConfig.java       # AI身份配置
│   └── WebConfig.java              # Web配置
└── entity/                         # 实体层
    ├── User.java                   # 用户实体
    └── vo/                         # 视图对象
        ├── UserInfoVO.java         # 用户信息视图对象
        ├── UpdateUserRequest.java  # 更新请求对象
        ├── ApiResponse.java        # API响应对象
        └── MessageVO.java          # 消息视图对象
```

## 配置说明

### 主要配置项

1. **AI模型配置**
   - 模型: DeepSeek-R1-0528-Qwen3-8B
   - 温度: 0.7
   - API提供商: SiliconFlow

2. **文件上传配置**
   - 最大文件大小: 10MB
   - 支持格式: 图片文件（jpg、png、gif等）

3. **服务器配置**
   - 端口: 8080
   - 上下文路径: /api

## 开发指南

### 添加新的AI身份

1. 在 `AIIdentityConfig.java` 中添加新身份：
   ```java
   AI_IDENTITIES.put("newIdentity", "新身份的系统提示内容");
   ```

2. 系统会自动支持新的身份，无需修改控制器代码。

### 扩展用户功能

1. 在 `User.java` 中添加新字段
2. 在 `UserInfoVO.java` 中添加对应字段
3. 在 `UserServiceImpl.java` 中实现相关逻辑
4. 在 `UserController.java` 中添加新的API接口

## 测试

运行测试：
```bash
mvn test
```

## 部署

### 打包
```bash
mvn clean package
```

### 运行JAR文件
```bash
java -jar target/MyApplication-0.0.1-SNAPSHOT.jar
```

## 注意事项

1. **数据持久化**: 当前使用内存存储，生产环境建议使用数据库
2. **文件存储**: 头像文件存储在本地 `uploads/avatars/` 目录
3. **API密钥**: 请妥善保管AI API密钥，不要提交到版本控制系统
4. **跨域配置**: 已配置CORS支持跨域请求

## 贡献

欢迎提交Issue和Pull Request来改进项目。

## 许可证

本项目采用MIT许可证。 
 