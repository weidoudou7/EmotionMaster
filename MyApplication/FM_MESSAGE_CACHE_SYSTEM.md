# FM_MESSAGE 混合推荐缓存系统实现

## 概述

在 `fm_message.ets` 页面中实现了一个完整的混合推荐缓存系统，借鉴了后端 `RecommendationServiceImpl` 的缓存策略和前端 `AvatarCacheManager` 的实现方式，为消息页面提供了高性能的数据加载和缓存管理。

## 系统架构

### 1. 缓存管理器 (MessagePageCacheManager)

采用单例模式设计，统一管理所有缓存数据：

```typescript
class MessagePageCacheManager {
  // 缓存存储
  private conversationCache: Map<number, CacheItem<Conversation[]>> = new Map();
  private aiRoleCache: Map<number, CacheItem<AiRole>> = new Map();
  private recommendationCache: Map<string, CacheItem<AiRole[]>> = new Map();
  private weatherCache: CacheItem<WeatherInfo> | null = null;
  
  // 缓存配置
  private readonly CACHE_EXPIRE_TIME = 5 * 60 * 1000; // 5分钟
  private readonly WEATHER_CACHE_EXPIRE_TIME = 10 * 60 * 1000; // 10分钟
  private readonly MAX_CACHE_SIZE = 100;
  private readonly MAX_RETRY_COUNT = 3;
}
```

### 2. 缓存项接口 (CacheItem)

统一的缓存项结构，支持加载状态管理和过期控制：

```typescript
interface CacheItem<T> {
  data: T;
  timestamp: number;
  loading: boolean;
  failed: boolean;
  retryCount: number;
}
```

## 核心功能

### 1. 对话列表缓存

- **缓存策略**: 按用户ID缓存对话列表
- **过期时间**: 5分钟
- **并发控制**: 防止重复加载
- **错误处理**: 失败重试机制

```typescript
public async getConversations(userId: number): Promise<Conversation[]> {
  const cacheKey = `conversations_${userId}`;
  
  // 检查缓存
  const cached = this.conversationCache.get(userId);
  if (cached && !this.isExpired(cached) && !cached.failed) {
    console.log('🎯 对话列表缓存命中:', userId);
    return cached.data;
  }
  
  // 检查是否正在加载
  if (this.loadingQueue.has(cacheKey)) {
    return this.waitForLoading(cacheKey, () => this.conversationCache.get(userId)?.data || []);
  }
  
  // 开始加载
  return this.loadConversations(userId, cacheKey);
}
```

### 2. AI角色信息缓存

- **批量加载**: 支持批量获取AI角色信息
- **智能预加载**: 结合头像预加载
- **缓存共享**: 多个对话共享角色信息

```typescript
public async getAiRolesBatch(roleIds: number[]): Promise<Map<number, AiRole>> {
  const result = new Map<number, AiRole>();
  const toLoad: number[] = [];
  
  // 检查缓存
  for (const roleId of roleIds) {
    const cached = this.aiRoleCache.get(roleId);
    if (cached && !this.isExpired(cached) && !cached.failed) {
      result.set(roleId, cached.data);
    } else {
      toLoad.push(roleId);
    }
  }
  
  // 批量加载未缓存的角色
  if (toLoad.length > 0) {
    const loadedRoles = await this.loadAiRolesBatch(toLoad);
    for (const [roleId, role] of loadedRoles) {
      result.set(roleId, role);
    }
  }
  
  return result;
}
```

### 3. 混合推荐缓存

- **推荐算法缓存**: 缓存混合推荐结果
- **用户个性化**: 按用户ID和推荐数量缓存
- **降级策略**: 推荐失败时降级到热门推荐

```typescript
public async getHybridRecommendations(userId: number, limit: number = 10): Promise<AiRole[]> {
  const cacheKey = `recommendations_${userId}_${limit}`;
  
  // 检查缓存
  const cached = this.recommendationCache.get(cacheKey);
  if (cached && !this.isExpired(cached) && !cached.failed) {
    console.log('🎯 推荐结果缓存命中:', cacheKey);
    return cached.data;
  }
  
  // 开始加载
  return this.loadRecommendations(userId, limit, cacheKey);
}
```

### 4. 天气信息缓存

- **独立缓存**: 天气信息独立缓存，过期时间更长
- **全局共享**: 所有用户共享天气信息
- **错误容错**: 天气获取失败不影响其他功能

```typescript
public async getWeatherInfo(): Promise<WeatherInfo> {
  // 检查缓存
  if (this.weatherCache && !this.isExpired(this.weatherCache) && !this.weatherCache.failed) {
    console.log('🎯 天气信息缓存命中');
    return this.weatherCache.data;
  }
  
  // 开始加载
  return this.loadWeatherInfo();
}
```

## 性能优化策略

### 1. 并行加载

使用 `Promise.allSettled` 并行加载不同类型的数据：

```typescript
async loadDataWithCache() {
  // 并行加载数据
  const [conversations, weatherInfo] = await Promise.allSettled([
    messageCacheManager.getConversations(userId),
    messageCacheManager.getWeatherInfo()
  ]);
}
```

### 2. 批量处理

AI角色信息批量加载，减少网络请求：

```typescript
private async loadAiRolesBatch(roleIds: number[]): Promise<Map<number, AiRole>> {
  // 分批加载，避免同时请求过多
  const batchSize = 5;
  for (let i = 0; i < roleIds.length; i += batchSize) {
    const batch = roleIds.slice(i, i + batchSize);
    // 处理批次...
  }
}
```

### 3. 预加载机制

结合 `AvatarCacheManager` 预加载头像：

```typescript
// 预加载头像
const aiRoles = Array.from(aiRoleMap.values());
messageCacheManager.preloadAvatars(aiRoles);
```

### 4. 智能降级

推荐系统失败时自动降级：

```typescript
// 降级策略：返回热门推荐
try {
  const fallbackRoles = await ApiService.getPopularRoles(limit);
  return fallbackRoles;
} catch (fallbackError) {
  return ApiService.getDefaultRoles(limit);
}
```

## 缓存管理

### 1. 过期清理

定期清理过期缓存：

```typescript
public cleanExpiredCache(): void {
  const now = Date.now();
  let cleanedCount = 0;
  
  // 清理各种缓存...
  
  if (cleanedCount > 0) {
    console.log(`🧹 清理了 ${cleanedCount} 个过期缓存`);
  }
}
```

### 2. 用户缓存清理

用户相关数据更新时清理缓存：

```typescript
public clearUserCache(userId: number): void {
  // 清除对话缓存
  this.conversationCache.delete(userId);
  
  // 清除推荐缓存
  const keysToRemove: string[] = [];
  for (const key of this.recommendationCache.keys()) {
    if (key.includes(`_${userId}_`)) {
      keysToRemove.push(key);
    }
  }
}
```

### 3. 缓存统计

实时监控缓存状态：

```typescript
public getCacheStats(): CacheStats {
  let total = 0, success = 0, failed = 0, loading = 0;
  
  // 统计各种缓存状态...
  
  return { total, success, failed, loading };
}
```

## UI 集成

### 1. 加载状态显示

```typescript
if (this.isLoading) {
  // 显示加载动画
  Column() {
    Stack() {
      Column()
        .width(60)
        .height(60)
        .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.1})`)
        .borderRadius(30)
      
      Text('⏳')
        .fontSize(30)
        .fontColor('#ffffff')
    }
    
    Text('正在加载对话...')
      .fontSize(16)
      .fontColor('#ffffff')
  }
}
```

### 2. 缓存统计显示

```typescript
// 缓存统计信息（调试模式）
if (this.cacheStats.total > 0) {
  Row() {
    Text(`缓存: ${this.cacheStats.success}/${this.cacheStats.total}`)
      .fontSize(12)
      .fontColor('rgba(255, 255, 255, 0.6)')
    Text(`加载中: ${this.cacheStats.loading}`)
      .fontSize(12)
      .fontColor('rgba(255, 255, 255, 0.6)')
    Text(`失败: ${this.cacheStats.failed}`)
      .fontSize(12)
      .fontColor('rgba(255, 255, 255, 0.6)')
  }
}
```

### 3. 智能头像显示

```typescript
// 使用智能头像组件
if (this.aiRoleMap[conv.aiRoleId]?.avatarUrl) {
  Image(this.aiRoleMap[conv.aiRoleId].avatarUrl)
    .width(48)
    .height(48)
    .borderRadius(24)
    .alt('头像加载中...')
} else {
  // 默认头像
  Image($r('app.media.splash'))
    .width(48)
    .height(48)
    .borderRadius(24)
}
```

## 与后端缓存系统的对比

### 相似之处

1. **缓存策略**: 都采用内存缓存 + 过期时间
2. **并发控制**: 都实现了加载队列防止重复请求
3. **错误处理**: 都有失败重试和降级机制
4. **缓存清理**: 都支持过期缓存清理

### 前端特色

1. **UI集成**: 与页面状态管理深度集成
2. **预加载**: 结合头像预加载提升用户体验
3. **实时统计**: 提供缓存状态实时监控
4. **智能降级**: 多级降级策略保证可用性

## 性能提升效果

### 1. 加载速度

- **首次加载**: 并行加载减少等待时间
- **缓存命中**: 数据直接从内存获取，几乎无延迟
- **预加载**: 头像预加载减少后续加载时间

### 2. 用户体验

- **加载状态**: 清晰的加载动画和状态提示
- **错误处理**: 优雅的错误处理和降级显示
- **缓存统计**: 实时显示缓存状态，便于调试

### 3. 网络优化

- **减少请求**: 缓存命中时避免重复网络请求
- **批量加载**: AI角色信息批量获取
- **智能预加载**: 预测性加载提升响应速度

## 使用示例

```typescript
// 在页面中使用缓存系统
async loadDataWithCache() {
  try {
    this.isLoading = true;
    
    const userId = getUserId();
    if (userId === null) return;
    
    // 并行加载数据
    const [conversations, weatherInfo] = await Promise.allSettled([
      messageCacheManager.getConversations(userId),
      messageCacheManager.getWeatherInfo()
    ]);
    
    // 处理结果...
    
  } catch (error) {
    console.error('数据加载失败:', error);
  } finally {
    this.isLoading = false;
  }
}
```

## 总结

通过实现这个混合推荐缓存系统，fm_message页面获得了：

1. **高性能**: 缓存命中时几乎无延迟
2. **高可用**: 多级降级策略保证功能可用
3. **好体验**: 智能加载状态和预加载机制
4. **易维护**: 统一的缓存管理和监控

这个实现充分借鉴了后端推荐系统的缓存策略，并结合前端特性进行了优化，为消息页面提供了企业级的缓存解决方案。 