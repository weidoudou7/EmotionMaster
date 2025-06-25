# 用户管理 API 文档

## 概述

本系统提供完整的用户管理功能，支持用户信息的增删改查、头像上传、隐私设置等操作。

## 基础信息

- **基础URL**: `http://localhost:8080/api`
- **内容类型**: `application/json`
- **字符编码**: `UTF-8`

## API 接口列表

### 1. 获取用户信息

**接口**: `GET /user/{userUID}`

**描述**: 根据用户UID获取用户详细信息

**参数**:
- `userUID` (路径参数): 用户唯一标识

**响应示例**:
```json
{
  "success": true,
  "message": "获取用户信息成功",
  "data": {
    "userName": "张三",
    "userUID": "100000000",
    "userAvatar": "/avatars/100000000_abc123.jpg",
    "isPrivacyVisible": false,
    "level": "Lv.8",
    "gender": "男",
    "signature": "热爱生活，积极向上！",
    "registerTime": "2023-01-01T10:00:00",
    "updateTime": "2024-01-15T14:30:00"
  },
  "timestamp": 1705312200000
}
```

### 2. 更新用户信息

**接口**: `PUT /user/{userUID}`

**描述**: 更新用户基本信息

**参数**:
- `userUID` (路径参数): 用户唯一标识
- `request` (请求体): 更新请求对象

**请求体示例**:
```json
{
  "userName": "新用户名",
  "userAvatar": "/avatars/new_avatar.jpg",
  "isPrivacyVisible": true,
  "gender": "女",
  "signature": "新的个性签名"
}
```

**响应示例**:
```json
{
  "success": true,
  "message": "更新用户信息成功",
  "data": {
    "userName": "新用户名",
    "userUID": "100000000",
    "userAvatar": "/avatars/new_avatar.jpg",
    "isPrivacyVisible": true,
    "level": "Lv.8",
    "gender": "女",
    "signature": "新的个性签名",
    "registerTime": "2023-01-01T10:00:00",
    "updateTime": "2024-01-15T15:00:00"
  },
  "timestamp": 1705312200000
}
```

### 3. 上传用户头像

**接口**: `POST /user/{userUID}/avatar`

**描述**: 上传用户头像文件

**参数**:
- `userUID` (路径参数): 用户唯一标识
- `file` (表单参数): 头像文件（支持jpg、png、gif等图片格式）

**响应示例**:
```json
{
  "success": true,
  "message": "头像上传成功",
  "data": "/avatars/100000000_xyz789.jpg",
  "timestamp": 1705312200000
}
```

### 4. 切换隐私可见性

**接口**: `POST /user/{userUID}/privacy/toggle`

**描述**: 切换用户的隐私可见性状态

**参数**:
- `userUID` (路径参数): 用户唯一标识

**响应示例**:
```json
{
  "success": true,
  "message": "隐私已隐藏",
  "data": true,
  "timestamp": 1705312200000
}
```

### 5. 创建新用户

**接口**: `POST /user/create`

**描述**: 创建新用户（如果用户不存在）

**参数**:
- `userUID` (查询参数): 用户唯一标识
- `userName` (查询参数): 用户名称

**响应示例**:
```json
{
  "success": true,
  "message": "用户创建成功",
  "data": {
    "userName": "新用户",
    "userUID": "200000000",
    "userAvatar": "/avatars/default.png",
    "isPrivacyVisible": false,
    "level": "Lv.1",
    "gender": "未设置",
    "signature": "这个人很懒，什么都没留下~",
    "registerTime": "2024-01-15T16:00:00",
    "updateTime": "2024-01-15T16:00:00"
  },
  "timestamp": 1705312200000
}
```

### 6. 健康检查

**接口**: `GET /user/health`

**描述**: 检查用户服务运行状态

**响应示例**:
```json
{
  "success": true,
  "message": "用户服务运行正常",
  "data": "OK",
  "timestamp": 1705312200000
}
```

## 错误响应格式

当API调用失败时，会返回以下格式的错误响应：

```json
{
  "success": false,
  "message": "错误描述信息",
  "data": null,
  "timestamp": 1705312200000
}
```

## 常见错误码

- **400**: 请求参数错误
- **404**: 用户不存在
- **500**: 服务器内部错误

## 使用示例

### 前端调用示例（JavaScript）

```javascript
// 获取用户信息
async function getUserInfo(userUID) {
  const response = await fetch(`/api/user/${userUID}`);
  const result = await response.json();
  return result;
}

// 更新用户信息
async function updateUserInfo(userUID, userData) {
  const response = await fetch(`/api/user/${userUID}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(userData)
  });
  const result = await response.json();
  return result;
}

// 上传头像
async function uploadAvatar(userUID, file) {
  const formData = new FormData();
  formData.append('file', file);
  
  const response = await fetch(`/api/user/${userUID}/avatar`, {
    method: 'POST',
    body: formData
  });
  const result = await response.json();
  return result;
}
```

## 注意事项

1. **文件上传限制**: 单个文件最大10MB，支持常见图片格式
2. **头像访问**: 上传的头像可通过 `/avatars/文件名` 路径访问
3. **数据持久化**: 当前使用内存存储，重启后数据会丢失（生产环境建议使用数据库）
4. **跨域支持**: 已配置CORS，支持跨域请求
5. **字符编码**: 所有接口都支持UTF-8编码，可正确处理中文 