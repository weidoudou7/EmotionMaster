# 用户行为记录与混合推荐系统

## 系统概述

本系统实现了完整的用户行为记录和智能推荐功能，通过多维度数据分析和机器学习算法，为用户提供个性化的AI角色推荐。

## 核心功能

### 1. 用户行为记录

#### 支持的行为类型
- **view**: 用户查看角色（权重: 0.3）
- **click**: 用户点击角色（权重: 0.5）
- **chat**: 用户与角色聊天（权重: 1.0）
- **like**: 用户点赞角色（权重: 0.8）
- **share**: 用户分享角色（权重: 0.6）

#### 行为记录时机
- 用户在FeaturedList页面查看角色时
- 用户点击角色进入聊天时
- 用户在聊天页面发送消息时
- 用户点赞或分享角色时

### 2. 混合推荐算法

#### 个性化推荐
- 基于用户历史对话分析
- 分析用户角色类型偏好
- 分析用户话题偏好
- 分析用户情感偏好
- **新增**: 基于用户行为数据偏好

#### 内容推荐
- 基于用户喜欢的角色特征
- 提取角色描述关键词
- 计算角色相似度
- 推荐相似特征的角色

#### 协同过滤推荐
- 找到相似用户
- 基于相似用户的偏好推荐
- **新增**: 结合用户行为数据

#### 混合推荐
- 综合多种算法结果
- 动态权重分配
- 提供最优推荐结果

## 技术架构

### 后端架构

```
├── entity/
│   └── UserBehavior.java          # 用户行为实体类
├── mapper/
│   ├── UserBehaviorMapper.java    # 用户行为数据访问接口
│   └── UserBehaviorMapper.xml     # SQL映射文件
├── service/
│   ├── UserBehaviorService.java   # 用户行为服务接口
│   ├── impl/
│   │   └── UserBehaviorServiceImpl.java  # 用户行为服务实现
│   ├── RecommendationService.java # 推荐服务接口
│   └── impl/
│       └── RecommendationServiceImpl.java # 推荐服务实现
└── controller/
    ├── UserBehaviorController.java # 用户行为API控制器
    └── RecommendationController.java # 推荐API控制器
```

### 前端架构

```
├── service/
│   └── apiservice.ets             # API服务类
├── pages/
│   ├── FeaturedList.ets           # 特色角色列表页面
│   └── chat.ets                   # 聊天页面
└── common/
    └── types.ets                  # 类型定义
```

## API接口

### 用户行为记录接口

#### 记录用户行为
```http
POST /api/user-behavior/record
参数: userId, roleId, actionType, score
```

#### 记录特定行为
```http
POST /api/user-behavior/record/view
POST /api/user-behavior/record/click
POST /api/user-behavior/record/chat
POST /api/user-behavior/record/like
POST /api/user-behavior/record/share
参数: userId, roleId
```

### 推荐算法接口

#### 混合推荐（推荐使用）
```http
GET /api/recommendation/hybrid?userId={userId}&limit={limit}
```

#### 个性化推荐
```http
GET /api/recommendation/personalized?userId={userId}&limit={limit}
```

#### 内容推荐
```http
GET /api/recommendation/content-based?userId={userId}&limit={limit}
```

#### 协同过滤推荐
```http
GET /api/recommendation/collaborative?userId={userId}&limit={limit}
```

#### 获取推荐解释
```http
GET /api/recommendation/explanation?userId={userId}&roleIds={roleIds}
```

### 数据分析接口

#### 获取用户行为记录
```http
GET /api/user-behavior/user/{userId}
```

#### 获取热门角色
```http
GET /api/user-behavior/popular-roles?limit={limit}
```

#### 获取用户行为分析
```http
GET /api/user-behavior/analysis/user/{userId}
```

## 数据库设计

### user_behavior表
```sql
CREATE TABLE user_behavior (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL COMMENT '用户ID',
    role_id INT NOT NULL COMMENT 'AI角色ID',
    action_type VARCHAR(50) NOT NULL COMMENT '行为类型',
    score DOUBLE DEFAULT 1.0 COMMENT '行为评分',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '行为发生时间',
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id),
    INDEX idx_action_type (action_type),
    INDEX idx_created_at (created_at),
    INDEX idx_user_role (user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## 算法权重配置

### 行为权重
- 聊天行为: 1.0（最高权重）
- 点赞行为: 0.8
- 分享行为: 0.6
- 点击行为: 0.5
- 查看行为: 0.3（最低权重）

### 混合推荐权重
- 个性化推荐: 40%
- 内容推荐: 30%
- 协同过滤推荐: 30%

### 时间衰减
- 使用指数衰减函数
- 衰减系数: 0.1
- 越近的行为权重越高

## 使用示例

### 前端调用示例

```typescript
// 记录用户查看行为
await ApiService.recordViewAction(userId, roleId);

// 记录用户聊天行为
await ApiService.recordChatAction(userId, roleId);

// 获取混合推荐
const recommendations = await ApiService.getHybridRecommendations(userId, 10);

// 获取推荐解释
const explanation = await ApiService.getRecommendationExplanation(userId, roleIds);
```

### 后端调用示例

```java
// 记录用户行为
userBehaviorService.recordViewAction(userId, roleId);

// 获取推荐
List<AiRole> recommendations = recommendationService.getHybridRecommendations(userId, 10);

// 获取推荐解释
String explanation = recommendationService.getRecommendationExplanation(userId, roleIds);
```

## 测试

### 运行测试脚本
```bash
cd backend
python test_user_behavior.py
```

### 测试内容
1. 用户行为记录功能
2. 推荐算法功能
3. 推荐解释功能
4. 用户行为分析功能
5. 热门角色功能

## 性能优化

### 数据库优化
- 建立了合适的索引
- 使用分页查询
- 缓存热门数据

### 算法优化
- 使用时间衰减函数
- 动态权重调整
- 异步处理大量数据

### 前端优化
- 异步记录用户行为
- 错误处理不阻塞主流程
- 本地缓存推荐结果

## 监控和日志

### 日志记录
- 用户行为记录日志
- 推荐算法执行日志
- 错误和异常日志

### 性能监控
- API响应时间监控
- 数据库查询性能监控
- 推荐算法准确率监控

## 扩展功能

### 计划中的功能
1. 实时推荐更新
2. 多维度用户画像
3. A/B测试支持
4. 推荐效果评估
5. 深度学习模型集成

### 可扩展的算法
1. 深度学习推荐
2. 图神经网络推荐
3. 强化学习推荐
4. 多任务学习推荐

## 注意事项

1. **隐私保护**: 用户行为数据仅用于推荐算法，不用于其他用途
2. **数据安全**: 所有API调用都需要用户身份验证
3. **性能考虑**: 大量数据时使用分页和缓存
4. **错误处理**: 推荐失败时返回热门角色作为备选
5. **新用户处理**: 新用户使用热门推荐策略

## 部署说明

1. 确保数据库已创建user_behavior表
2. 启动后端服务
3. 配置前端API地址
4. 运行测试脚本验证功能
5. 监控系统运行状态

## 联系方式

如有问题或建议，请联系开发团队。 