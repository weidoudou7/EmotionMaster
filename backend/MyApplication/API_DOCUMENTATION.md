# AI 多身份聊天 API 文档

## 概述

本系统支持AI根据不同的URL路径切换不同的身份角色，每个身份都有独特的系统提示和对话风格。

## 可用的AI身份

### 1. 默认身份 - 情绪管理助手
- **路径**: `/ai/chat`
- **角色**: 专业的情绪管理助手
- **特点**: 专注于情绪管理和心理健康

### 2. 情绪激励者
- **路径**: `/ai/chat/emotionInspire`
- **角色**: 情绪激励者
- **特点**: 帮助用户找到内心的力量和积极情绪，用温暖、鼓励的语气

### 3. 心理咨询师
- **路径**: `/ai/chat/psychologist`
- **角色**: 专业心理咨询师
- **特点**: 具备丰富的心理学知识，提供专业的心理建议

### 4. 生活导师
- **路径**: `/ai/chat/lifeCoach`
- **角色**: 生活导师
- **特点**: 帮助解决生活中的各种挑战，提供实用的生活建议

### 5. 朋友角色
- **路径**: `/ai/chat/friend`
- **角色**: 真诚的朋友
- **特点**: 平等、理解、支持的态度，朋友般的温暖和真诚

### 6. 学习助手
- **路径**: `/ai/chat/studyHelper`
- **角色**: 学习助手
- **特点**: 帮助制定学习计划、解答问题、提供学习方法

### 7. 创意激发者
- **路径**: `/ai/chat/creativeInspire`
- **角色**: 创意激发者
- **特点**: 帮助突破思维局限，激发创造力和想象力

## API 接口

### 1. 获取所有可用身份
```
GET /ai/identities
```
**响应**: 返回所有可用的身份标识数组

### 2. 特定身份聊天
```
POST /ai/chat/{identity}?prompt={用户输入}&chatId={会话ID}
```

**参数**:
- `identity`: 身份标识（如 emotionInspire, psychologist 等）
- `prompt`: 用户输入的消息
- `chatId`: 会话ID，用于维护对话历史

**示例**:
```
POST /ai/chat/emotionInspire?prompt=我今天心情很低落&chatId=user123
```

### 3. 直接访问特定身份（预定义路径）
```
POST /ai/chat/emotionInspire?prompt={用户输入}&chatId={会话ID}
POST /ai/chat/psychologist?prompt={用户输入}&chatId={会话ID}
POST /ai/chat/lifeCoach?prompt={用户输入}&chatId={会话ID}
POST /ai/chat/friend?prompt={用户输入}&chatId={会话ID}
POST /ai/chat/studyHelper?prompt={用户输入}&chatId={会话ID}
POST /ai/chat/creativeInspire?prompt={用户输入}&chatId={会话ID}
```

## 使用示例

### 情绪激励者示例
```
请求: POST /ai/chat/emotionInspire?prompt=我最近工作压力很大，感觉很疲惫&chatId=user001
预期响应: AI会以情绪激励者的身份，用温暖鼓励的语气帮助用户找到积极情绪
```

### 心理咨询师示例
```
请求: POST /ai/chat/psychologist?prompt=我总是担心未来，晚上睡不着觉&chatId=user002
预期响应: AI会以专业心理咨询师的身份，提供专业的心理分析和建议
```

### 朋友角色示例
```
请求: POST /ai/chat/friend?prompt=我今天和同事吵架了，感觉很委屈&chatId=user003
预期响应: AI会以朋友的身份，用理解和支持的态度与用户交流
```

## 技术特点

1. **独立对话历史**: 每个身份都有独立的对话历史，通过 `chatId_{identity}` 的方式区分
2. **动态身份切换**: 支持通过路径参数动态切换AI身份
3. **错误处理**: 当访问不存在的身份时，会返回错误信息和可用身份列表
4. **流式响应**: 所有接口都支持流式响应，提供更好的用户体验

## 扩展新身份

要添加新的AI身份，只需在 `AIIdentityConfig.java` 中的 `AI_IDENTITIES` 映射中添加新的身份定义：

```java
AI_IDENTITIES.put("newIdentity", "新身份的系统提示内容");
```

系统会自动支持新的身份，无需修改控制器代码。 