# 高级AI角色推荐系统

## 概述

本系统实现了一个多维度协同过滤推荐算法，为FeaturedList页面提供智能化的AI角色推荐。系统结合了用户行为分析、内容特征匹配、协同过滤和实时反馈学习等多种技术。

## 算法架构

### 1. 混合推荐算法 (Hybrid Recommendation)
- **个性化推荐 (40%)**: 基于用户历史对话、情感分析、话题标签
- **内容推荐 (30%)**: 基于角色描述、类型、作者等特征
- **协同过滤 (30%)**: 基于相似用户的偏好

### 2. 核心特性
- **多维度分析**: 角色类型、话题标签、情感倾向、时间衰减
- **实时学习**: 记录用户行为，持续优化推荐效果
- **智能解释**: 为用户提供推荐原因说明
- **容错机制**: 算法失败时自动降级到热门推荐

## API接口

### 1. 混合推荐接口 (推荐使用)
```
GET /recommendation/hybrid?userId={userId}&limit={limit}
```
- 返回综合多种算法的推荐结果
- 默认推荐10个角色

### 2. 个性化推荐接口
```
GET /recommendation/personalized?userId={userId}&limit={limit}
```
- 基于用户历史行为的个性化推荐

### 3. 内容推荐接口
```
GET /recommendation/content-based?userId={userId}&limit={limit}
```
- 基于角色内容特征的推荐

### 4. 协同过滤接口
```
GET /recommendation/collaborative?userId={userId}&limit={limit}
```
- 基于相似用户偏好的推荐

### 5. 用户行为记录接口
```
POST /recommendation/behavior
{
  "userId": 574,
  "roleId": 364,
  "actionType": "chat",
  "score": 1.0
}
```

### 6. 推荐解释接口
```
GET /recommendation/explanation?userId={userId}&roleIds={roleIds}
```
- 返回推荐原因说明

## 前端集成

### 1. 在FeaturedList中使用
```typescript
// 获取混合推荐
const recommendedRoles = await ApiService.getHybridRecommendations(userId, 20);

// 记录用户行为
await ApiService.recordUserBehavior(userId, roleId, 'view', 0.3);
await ApiService.recordUserBehavior(userId, roleId, 'chat', 1.0);

// 获取推荐解释
const explanation = await ApiService.getRecommendationExplanation(userId, roleIds);
```

### 2. 行为类型说明
- `view`: 查看角色 (权重: 0.3)
- `click`: 点击角色 (权重: 0.5)
- `chat`: 开始聊天 (权重: 1.0)
- `like`: 点赞角色 (权重: 0.8)
- `share`: 分享角色 (权重: 0.6)

## 数据库设计

### 用户行为记录表 (user_behavior)
```sql
CREATE TABLE user_behavior (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    score DOUBLE DEFAULT 1.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id),
    INDEX idx_action_type (action_type),
    INDEX idx_created_at (created_at),
    INDEX idx_user_role (user_id, role_id)
);
```

## 算法优势

### 1. 高精度推荐
- 多维度特征分析
- 实时用户行为学习
- 智能权重调整

### 2. 良好的用户体验
- 快速响应时间
- 智能推荐解释
- 容错降级机制

### 3. 易于扩展
- 模块化设计
- 支持新算法集成
- 配置化权重调整

## 部署说明

### 1. 数据库初始化
```sql
-- 执行 user_behavior.sql 创建用户行为表
source user_behavior.sql;
```

### 2. 后端启动
```bash
# 启动Spring Boot应用
mvn spring-boot:run
```

### 3. 前端集成
- 更新ApiService.ets添加新的API调用
- 在FeaturedList.ets中使用混合推荐算法
- 添加用户行为记录功能

## 性能优化

### 1. 缓存策略
- 推荐结果缓存 (Redis)
- 用户偏好缓存
- 热门角色缓存

### 2. 数据库优化
- 索引优化
- 查询优化
- 分页查询

### 3. 算法优化
- 批量计算
- 异步处理
- 增量更新

## 监控和调优

### 1. 推荐效果监控
- 点击率 (CTR)
- 转化率
- 用户满意度

### 2. 性能监控
- 响应时间
- 并发处理能力
- 资源使用情况

### 3. 算法调优
- 权重参数调整
- 特征工程优化
- 模型重新训练

## 未来扩展

### 1. 深度学习集成
- 神经网络推荐模型
- 深度学习特征提取
- 端到端推荐系统

### 2. 实时推荐
- 流式数据处理
- 实时特征更新
- 动态推荐调整

### 3. 多模态推荐
- 图像特征分析
- 语音特征提取
- 文本语义理解

## 总结

这个高级推荐系统为您的AI角色应用提供了智能化的推荐能力，通过多维度分析和实时学习，能够为用户提供个性化的角色推荐，提升用户体验和平台活跃度。系统设计灵活，易于扩展和维护，为未来的功能增强奠定了良好的基础。 