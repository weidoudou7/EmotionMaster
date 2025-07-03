# 评论系统API文档

## 概述
基于单表设计的评论系统，支持AI角色评论、回复、点赞等功能。

## 数据库设计
- **comments表**: 统一存储评论和回复
- **comment_likes表**: 记录用户点赞状态

### 核心字段说明
- `root_comment_id`: null表示顶级评论，否则为回复
- `to_comment_id`: 回复目标评论ID
- `reply_to_user_id`: 回复目标用户ID
- `reply_to_username`: 回复目标用户昵称（静态存储）

## API接口

### 1. 获取AI角色评论列表
```
GET /api/comments/ai-role/{aiRoleId}?page=1&size=10
```

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "comments": [
      {
        "id": 1,
        "aiRoleId": 1,
        "userId": 1,
        "content": "44w 3 👑 打算开个活动...",
        "likeCount": 757,
        "replyCount": 3,
        "rootCommentId": null,
        "toCommentId": null,
        "replyToUserId": null,
        "replyToUsername": null,
        "isTop": true,
        "isAuthor": true,
        "status": "normal",
        "createdAt": "2024-01-01T10:00:00",
        "updatedAt": "2024-01-01T10:00:00",
        "username": "Spoil 邪安",
        "profileImage": "https://example.com/avatar.jpg",
        "totalReplies": 3
      }
    ],
    "totalCount": 15925,
    "currentPage": 1,
    "pageSize": 10
  }
}
```

### 2. 获取评论回复列表
```
GET /api/comments/{rootCommentId}/replies?page=1&size=10
```

### 3. 发布评论
```
POST /api/comments/publish
Content-Type: application/json

{
  "aiRoleId": 1,
  "userId": 1,
  "content": "这是一条新评论"
}
```

### 4. 回复评论
```
POST /api/comments/reply
Content-Type: application/json

{
  "aiRoleId": 1,
  "userId": 2,
  "content": "这是回复内容",
  "rootCommentId": 1,
  "toCommentId": 1
}
```

### 5. 点赞评论
```
POST /api/comments/{commentId}/like?userId=1
```

### 6. 取消点赞
```
DELETE /api/comments/{commentId}/like?userId=1
```

### 7. 删除评论
```
DELETE /api/comments/{commentId}?userId=1
```

### 8. 检查点赞状态
```
GET /api/comments/{commentId}/liked?userId=1
```

## 使用示例

### 前端调用示例（JavaScript）
```javascript
// 获取评论列表
async function getComments(aiRoleId, page = 1, size = 10) {
  const response = await fetch(`/api/comments/ai-role/${aiRoleId}?page=${page}&size=${size}`);
  const data = await response.json();
  return data.data;
}

// 发布评论
async function publishComment(aiRoleId, userId, content) {
  const response = await fetch('/api/comments/publish', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      aiRoleId: aiRoleId,
      userId: userId,
      content: content
    })
  });
  return await response.json();
}

// 点赞评论
async function likeComment(commentId, userId) {
  const response = await fetch(`/api/comments/${commentId}/like?userId=${userId}`, {
    method: 'POST'
  });
  return await response.json();
}
```

## 数据库查询示例

### 获取顶级评论列表
```sql
SELECT 
    c.*,
    u.username,
    u.profile_image,
    (SELECT COUNT(*) FROM comments WHERE root_comment_id = c.id AND status = 'normal') as total_replies
FROM comments c
LEFT JOIN users u ON c.user_id = u.id
WHERE c.ai_role_id = 1 
    AND c.root_comment_id IS NULL 
    AND c.status = 'normal'
ORDER BY c.is_top DESC, c.created_at DESC
LIMIT 0, 10;
```

### 获取回复列表
```sql
SELECT 
    c.*,
    u.username,
    u.profile_image
FROM comments c
LEFT JOIN users u ON c.user_id = u.id
WHERE c.root_comment_id = 1 
    AND c.status = 'normal'
ORDER BY c.created_at ASC
LIMIT 0, 10;
```

## 注意事项

1. **权限控制**: 用户只能删除自己的评论
2. **软删除**: 删除评论时使用软删除（status='deleted'）
3. **点赞唯一性**: 通过数据库约束确保用户对同一评论只能点赞一次
4. **触发器**: 自动维护评论的回复数和点赞数
5. **分页**: 所有列表接口都支持分页查询

## 扩展功能

- 评论审核功能
- 敏感词过滤
- 评论举报功能
- 评论排序（按时间、点赞数等）
- 评论搜索功能 