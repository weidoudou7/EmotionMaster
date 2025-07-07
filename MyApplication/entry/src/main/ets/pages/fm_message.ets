import router from '@ohos.router'
import prompt from '@ohos.prompt'

import { fetchWeather } from '../model/WeatherService';
import { ApiService } from '../service/apiservice';
import { Conversation, AiRole } from '../common/types';
import { getUserId } from '../common/constants';
import { avatarCacheManager } from '../utils/AvatarCacheManager';

// 缓存接口定义
interface CacheItem<T> {
  data: T;
  timestamp: number;
  loading: boolean;
  failed: boolean;
  retryCount: number;
}

interface CacheStats {
  total: number;
  success: number;
  failed: number;
  loading: number;
}

// 错误结果接口
interface ErrorResult {
  status: string;
  reason: string;
}

// 消息页面缓存管理器
class MessagePageCacheManager {
  private static instance: MessagePageCacheManager;
  
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
  
  // 加载队列
  private loadingQueue: Set<string> = new Set();
  
  // 单例模式
  public static getInstance(): MessagePageCacheManager {
    if (!MessagePageCacheManager.instance) {
      MessagePageCacheManager.instance = new MessagePageCacheManager();
    }
    return MessagePageCacheManager.instance;
  }
  
  /**
   * 获取对话列表（带缓存）
   */
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
      console.log('⏳ 对话列表正在加载中:', userId);
      // 等待加载完成
      return this.waitForLoading(cacheKey, () => this.conversationCache.get(userId)?.data || []);
    }
    
    // 开始加载
    return this.loadConversations(userId, cacheKey);
  }
  
  /**
   * 获取AI角色信息（带缓存）
   */
  public async getAiRole(roleId: number): Promise<AiRole | null> {
    // 检查缓存
    const cached = this.aiRoleCache.get(roleId);
    if (cached && !this.isExpired(cached) && !cached.failed) {
      console.log('🎯 AI角色缓存命中:', roleId);
      return cached.data;
    }
    
    // 开始加载
    return this.loadAiRole(roleId);
  }
  
  /**
   * 批量获取AI角色信息（带缓存和预加载）
   */
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
      console.log('📥 批量加载AI角色:', toLoad.length);
      const loadedRoles = await this.loadAiRolesBatch(toLoad);
      for (const entry of loadedRoles.entries()) {
        const roleId = entry[0];
        const role = entry[1];
        result.set(roleId, role);
      }
    }
    
    return result;
  }
  
  /**
   * 获取混合推荐（带缓存）
   */
  public async getHybridRecommendations(userId: number, limit: number = 10): Promise<AiRole[]> {
    const cacheKey = `recommendations_${userId}_${limit}`;
    
    // 检查缓存
    const cached = this.recommendationCache.get(cacheKey);
    if (cached && !this.isExpired(cached) && !cached.failed) {
      console.log('🎯 推荐结果缓存命中:', cacheKey);
      return cached.data;
    }
    
    // 检查是否正在加载
    if (this.loadingQueue.has(cacheKey)) {
      console.log('⏳ 推荐结果正在加载中:', cacheKey);
      return this.waitForLoading(cacheKey, () => this.recommendationCache.get(cacheKey)?.data || []);
    }
    
    // 开始加载
    return this.loadRecommendations(userId, limit, cacheKey);
  }
  
  /**
   * 获取天气信息（带缓存）
   */
  public async getWeatherInfo(): Promise<WeatherInfo> {
    // 检查缓存
    if (this.weatherCache && !this.isExpired(this.weatherCache) && !this.weatherCache.failed) {
      console.log('🎯 天气信息缓存命中');
      return this.weatherCache.data;
    }
    
    // 开始加载
    return this.loadWeatherInfo();
  }
  
  /**
   * 预加载头像
   */
  public async preloadAvatars(aiRoles: AiRole[]): Promise<void> {
    try {
      console.log('🚀 预加载头像:', aiRoles.length);
      await avatarCacheManager.preloadAvatars(aiRoles);
    } catch (error) {
      console.error('❌ 预加载头像失败:', error);
    }
  }
  
  /**
   * 清理过期缓存
   */
  public cleanExpiredCache(): void {
    const now = Date.now();
    let cleanedCount = 0;
    
    // 清理对话缓存
    for (const entry of this.conversationCache.entries()) {
      const key = entry[0];
      const item = entry[1];
      if (this.isExpired(item)) {
        this.conversationCache.delete(key);
        cleanedCount++;
      }
    }
    
    // 清理AI角色缓存
    for (const entry of this.aiRoleCache.entries()) {
      const key = entry[0];
      const item = entry[1];
      if (this.isExpired(item)) {
        this.aiRoleCache.delete(key);
        cleanedCount++;
      }
    }
    
    // 清理推荐缓存
    for (const entry of this.recommendationCache.entries()) {
      const key = entry[0];
      const item = entry[1];
      if (this.isExpired(item)) {
        this.recommendationCache.delete(key);
        cleanedCount++;
      }
    }
    
    // 清理天气缓存
    if (this.weatherCache && this.isExpired(this.weatherCache)) {
      this.weatherCache = null;
      cleanedCount++;
    }
    
    if (cleanedCount > 0) {
      console.log(`🧹 清理了 ${cleanedCount} 个过期缓存`);
    }
  }
  
  /**
   * 获取缓存统计
   */
  public getCacheStats(): CacheStats {
    let total = 0, success = 0, failed = 0, loading = 0;
    
    // 统计对话缓存
    for (const item of this.conversationCache.values()) {
      total++;
      if (item.loading) loading++;
      else if (item.failed) failed++;
      else success++;
    }
    
    // 统计AI角色缓存
    for (const item of this.aiRoleCache.values()) {
      total++;
      if (item.loading) loading++;
      else if (item.failed) failed++;
      else success++;
    }
    
    // 统计推荐缓存
    for (const item of this.recommendationCache.values()) {
      total++;
      if (item.loading) loading++;
      else if (item.failed) failed++;
      else success++;
    }
    
    // 统计天气缓存
    if (this.weatherCache) {
      total++;
      if (this.weatherCache.loading) loading++;
      else if (this.weatherCache.failed) failed++;
      else success++;
    }
    
    return { total, success, failed, loading };
  }
  
  /**
   * 清除用户相关缓存
   */
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
    for (const key of keysToRemove) {
      this.recommendationCache.delete(key);
    }
    
    console.log(`🗑️ 清除用户 ${userId} 相关缓存`);
  }
  
  // ==================== 私有方法 ====================
  
  private async loadConversations(userId: number, cacheKey: string): Promise<Conversation[]> {
    this.loadingQueue.add(cacheKey);
    
    try {
      console.log('📥 开始加载对话列表:', userId);
      
      // 创建缓存项
      const cacheItem: CacheItem<Conversation[]> = {
        data: [],
        timestamp: Date.now(),
        loading: true,
        failed: false,
        retryCount: 0
      };
      
      this.conversationCache.set(userId, cacheItem);
      
      // 调用API
      const conversations = await ApiService.getConversationsByUserId(userId);
      
      // 更新缓存
      cacheItem.data = conversations;
      cacheItem.loading = false;
      cacheItem.failed = false;
      
      console.log('✅ 对话列表加载成功:', conversations.length);
      return conversations;
      
    } catch (error) {
      console.error('❌ 对话列表加载失败:', error);
      
      // 更新失败状态
      const cacheItem = this.conversationCache.get(userId);
      if (cacheItem) {
        cacheItem.loading = false;
        cacheItem.failed = true;
        cacheItem.retryCount++;
      }
      
      return [];
    } finally {
      this.loadingQueue.delete(cacheKey);
    }
  }
  
  private async loadAiRole(roleId: number): Promise<AiRole | null> {
    try {
      console.log('📥 开始加载AI角色:', roleId);
      
      // 创建缓存项
      const cacheItem: CacheItem<AiRole> = {
        data: {} as AiRole,
        timestamp: Date.now(),
        loading: true,
        failed: false,
        retryCount: 0
      };
      
      this.aiRoleCache.set(roleId, cacheItem);
      
      // 调用API
      const aiRole = await ApiService.getAiRoleById(roleId);
      
      // 更新缓存
      cacheItem.data = aiRole;
      cacheItem.loading = false;
      cacheItem.failed = false;
      
      console.log('✅ AI角色加载成功:', roleId);
      return aiRole;
      
    } catch (error) {
      console.error('❌ AI角色加载失败:', roleId, error);
      
      // 更新失败状态
      const cacheItem = this.aiRoleCache.get(roleId);
      if (cacheItem) {
        cacheItem.loading = false;
        cacheItem.failed = true;
        cacheItem.retryCount++;
      }
      
      return null;
    }
  }
  
  private async loadAiRolesBatch(roleIds: number[]): Promise<Map<number, AiRole>> {
    const result = new Map<number, AiRole>();
    
    // 分批加载，避免同时请求过多
    const batchSize = 5;
    for (let i = 0; i < roleIds.length; i += batchSize) {
      const batch = roleIds.slice(i, i + batchSize);
      const promises: Promise<void>[] = [];
      
      for (const roleId of batch) {
        promises.push(
          this.loadAiRole(roleId).then(role => {
            if (role) {
              result.set(roleId, role);
            }
          })
        );
      }
      
      // 等待所有promise完成，忽略错误
      for (const promise of promises) {
        try {
          await promise;
        } catch (error) {
          // 忽略单个角色加载失败
        }
      }
      
      // 批次间延迟
      if (i + batchSize < roleIds.length) {
        await new Promise<void>(resolve => setTimeout(resolve, 100));
      }
    }
    
    return result;
  }
  
  private async loadRecommendations(userId: number, limit: number, cacheKey: string): Promise<AiRole[]> {
    this.loadingQueue.add(cacheKey);
    
    try {
      console.log('📥 开始加载推荐结果:', cacheKey);
      
      // 创建缓存项
      const cacheItem: CacheItem<AiRole[]> = {
        data: [],
        timestamp: Date.now(),
        loading: true,
        failed: false,
        retryCount: 0
      };
      
      this.recommendationCache.set(cacheKey, cacheItem);
      
      // 调用API
      const recommendations = await ApiService.getHybridRecommendations(userId, limit);
      
      // 更新缓存
      cacheItem.data = recommendations;
      cacheItem.loading = false;
      cacheItem.failed = false;
      
      console.log('✅ 推荐结果加载成功:', recommendations.length);
      return recommendations;
      
    } catch (error) {
      console.error('❌ 推荐结果加载失败:', error);
      
      // 更新失败状态
      const cacheItem = this.recommendationCache.get(cacheKey);
      if (cacheItem) {
        cacheItem.loading = false;
        cacheItem.failed = true;
        cacheItem.retryCount++;
      }
      
      return [];
    } finally {
      this.loadingQueue.delete(cacheKey);
    }
  }
  
  private async loadWeatherInfo(): Promise<WeatherInfo> {
    try {
      console.log('📥 开始加载天气信息');
      
      // 创建缓存项
      const cacheItem: CacheItem<WeatherInfo> = {
        data: new WeatherInfo(),
        timestamp: Date.now(),
        loading: true,
        failed: false,
        retryCount: 0
      };
      
      this.weatherCache = cacheItem;
      
      // 调用API
      const data = await fetchWeather('101200101'); // 武汉
      
      if (data && data.status === 200 && data.data && data.cityInfo) {
        cacheItem.data.city = data.cityInfo.city;
        cacheItem.data.temperature = data.data.wendu + '°';
        cacheItem.data.desc = data.data.forecast && data.data.forecast.length > 0 ? data.data.forecast[0].type : '';
        cacheItem.data.icon = this.iconMap(cacheItem.data.desc);
      } else {
        cacheItem.data.city = '获取失败';
        cacheItem.data.temperature = '--°';
        cacheItem.data.desc = '天气获取失败';
        cacheItem.data.icon = '❌';
      }
      
      cacheItem.loading = false;
      cacheItem.failed = false;
      
      console.log('✅ 天气信息加载成功');
      return cacheItem.data;
      
    } catch (error) {
      console.error('❌ 天气信息加载失败:', error);
      
      if (this.weatherCache) {
        this.weatherCache.loading = false;
        this.weatherCache.failed = true;
        this.weatherCache.retryCount++;
      }
      
      return new WeatherInfo();
    }
  }
  
  private iconMap(desc: string): string {
    switch (desc) {
      case '晴': return '☀️';
      case '多云': return '🌤️';
      case '阴': return '☁️';
      case '小雨': return '🌧️';
      case '中雨': return '🌧️';
      case '大雨': return '⛈️';
      case '雷阵雨': return '⛈️';
      case '雪': return '❄️';
      case '雾': return '🌫️';
      default: return '❓';
    }
  }
  
  private isExpired(cacheItem: CacheItem<Conversation[] | AiRole | AiRole[] | WeatherInfo>): boolean {
    const expireTime = cacheItem.data instanceof WeatherInfo ? this.WEATHER_CACHE_EXPIRE_TIME : this.CACHE_EXPIRE_TIME;
    return Date.now() - cacheItem.timestamp > expireTime;
  }
  
  private async waitForLoading<T>(cacheKey: string, getData: () => T): Promise<T> {
    // 等待加载完成
    let attempts = 0;
    const maxAttempts = 50; // 最多等待5秒
    
    while (this.loadingQueue.has(cacheKey) && attempts < maxAttempts) {
      await new Promise<void>(resolve => setTimeout(resolve, 100));
      attempts++;
    }
    
    return getData();
  }
}

// 获取缓存管理器实例
const messageCacheManager = MessagePageCacheManager.getInstance();

class WeatherInfo {
  city: string = '加载中';
  temperature: string = '--°';
  icon: string = '❓';
  desc: string = '加载中';
}

class MessageItem {
  avatar: Resource = $r('app.media.splash');
  name: string = '';
  desc: string = '';
  time: string = '';
  followed: boolean = false;
  unread: number = 0;
  isOfficial?: boolean = false;
  isSystem?: boolean = false;
}

@Entry
@Component
export struct MessagePage {
  @State weatherInfo: WeatherInfo = new WeatherInfo();
  @State currentTime: string = '';
  @State currentDate: string = '';
  @State private conversations: Conversation[] = [];
  @State private aiRoleMap: Record<number, AiRole> = {};
  @State arcRotation: number = 0 // 圆弧旋转角度
  @State starTwinkle: number = 0 // 星星闪烁效果
  @State glowOpacity: number = 0.5 // 发光效果透明度
  @State textOpacity: number = 0.8 // 文字透明度
  @State nebulaOpacity: number = 0.3 // 星云透明度
  @State private isLoading: boolean = false; // 加载状态
  @State private cacheStats: CacheStats = { total: 0, success: 0, failed: 0, loading: 0 }; // 缓存统计
  @State private longPressTimer: number = -1; // 长按定时器
  @State private isLongPressing: boolean = false; // 是否正在长按
  @State private showLongPressHint: boolean = false; // 显示长按提示
  @State private isRefreshing: boolean = false;
  @State private scrollY: number = 0;
  @State private pulling: boolean = false;
  @State private pullStartY: number = 0;

  private timerId: number = -1;

  aboutToAppear() {
    this.startGalaxyAnimations()
    this.loadDataWithCache();
    this.updateDateTime();
    this.timerId = setInterval(() => {
      this.updateDateTime();
    }, 1000);
    
    // 定期清理缓存
    setInterval(() => {
      messageCacheManager.cleanExpiredCache();
      this.cacheStats = messageCacheManager.getCacheStats();
    }, 60000); // 每分钟清理一次
  }

  private startGalaxyAnimations() {
    // 圆弧旋转动画
    setInterval(() => {
      this.arcRotation += 1.5
    }, 50)
    
    // 星星闪烁动画
    setInterval(() => {
      this.starTwinkle += 0.1
    }, 100)
    
    // 发光效果动画
    setInterval(() => {
      this.glowOpacity = this.glowOpacity === 0.5 ? 0.8 : 0.5
    }, 1200)
    
    // 文字透明度动画
    setInterval(() => {
      this.textOpacity = this.textOpacity === 0.8 ? 1.0 : 0.8
    }, 1800)
    
    // 星云透明度动画
    setInterval(() => {
      this.nebulaOpacity = this.nebulaOpacity === 0.3 ? 0.6 : 0.3
    }, 3000)
  }

  // 新增：页面显示时刷新对话列表
  onPageShow() {
    console.log('Message页面显示，刷新对话列表');
    this.loadDataWithCache();
  }

  aboutToDisappear() {
    // 清理定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  updateDateTime() {
    const now = new Date();
    
    // 格式化时间 HH:MM
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    this.currentTime = `${hours}:${minutes}`;
    
    // 格式化日期和星期
    const year = now.getFullYear();
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const day = now.getDate().toString().padStart(2, '0');
    const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    const weekday = weekdays[now.getDay()];
    this.currentDate = `${year}年${month}月${day}日 ${weekday}`;
  }

  /**
   * 类型检查方法
   */
  private isConversationArray(value: Conversation[] | ErrorResult): boolean {
    return Array.isArray(value);
  }

  private isWeatherInfo(value: WeatherInfo | ErrorResult): boolean {
    return value !== null && 
           typeof value === 'object' && 
           this.hasProperty(value, 'city') && 
           this.hasProperty(value, 'temperature') && 
           this.hasProperty(value, 'icon') && 
           this.hasProperty(value, 'desc');
  }

  private hasProperty(obj: object, prop: string): boolean {
    try {
      return obj[prop] !== undefined;
    } catch {
      return false;
    }
  }

  /**
   * 删除对话
   */
  async deleteConversation(conversation: Conversation) {
    try {
      console.log('🗑️ 开始删除对话:', conversation.id);
      
      // 调用API删除对话
      const success = await ApiService.deleteConversation(conversation.id);
      
      if (success) {
        console.log('✅ 对话删除成功');
        
        // 从本地列表中移除对话
        const index = this.conversations.findIndex(conv => conv.id === conversation.id);
        if (index !== -1) {
          this.conversations.splice(index, 1);
        }
        
        // 清除缓存中的相关数据
        const userId = getUserId();
        if (userId !== null) {
          messageCacheManager.clearUserCache(userId);
        }
        
        // 显示成功提示
        prompt.showToast({
          message: '对话删除成功',
          duration: 2000
        });
      } else {
        console.error('❌ 对话删除失败');
        prompt.showToast({
          message: '删除失败，请重试',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('❌ 删除对话时发生错误:', error);
      prompt.showToast({
        message: '删除失败，请检查网络连接',
        duration: 2000
      });
    }
  }

  /**
   * 显示删除确认对话框
   */
  showDeleteConfirmDialog(conversation: Conversation) {
    // 直接显示确认对话框
    prompt.showDialog({
      title: '删除对话',
      message: `确定要删除对话"${conversation.title}"吗？此操作不可撤销。`,
      buttons: [
        {
          text: '取消',
          color: '#666666'
        },
        {
          text: '删除',
          color: '#ff4444'
        }
      ]
    }).then((result) => {
      if (result.index === 1) { // 点击了删除按钮
        this.deleteConversation(conversation);
      }
    }).catch((error: Error) => {
      console.error('显示删除确认对话框失败:', error);
    });
  }

  /**
   * 使用缓存加载数据
   */
  async loadDataWithCache() {
    try {
      this.isLoading = true;
      
      // 获取全局用户ID
      const userId = getUserId();
      
      // 检查用户ID是否有效
      if (userId === null) {
        console.warn('用户ID为空，无法加载对话列表');
        this.conversations = [];
        this.aiRoleMap = {};
        this.isLoading = false;
        return;
      }
      
      console.log('🚀 开始使用缓存加载数据，用户ID:', userId);
      
      // 并行加载数据
      const conversationsPromise = messageCacheManager.getConversations(userId);
      const weatherInfoPromise = messageCacheManager.getWeatherInfo();
      
      const conversations = await conversationsPromise.catch((error: string) => {
        console.error('❌ 对话列表加载失败:', error);
        const errorResult: ErrorResult = { status: 'rejected', reason: error };
        return errorResult;
      });
      const weatherInfo = await weatherInfoPromise.catch((error: string) => {
        console.error('❌ 天气信息加载失败:', error);
        const errorResult: ErrorResult = { status: 'rejected', reason: error };
        return errorResult;
      });
      
      // 处理对话列表
      if (conversations && this.isConversationArray(conversations)) {
        this.conversations = conversations as Conversation[];
        console.log('✅ 对话列表加载成功，数量:', this.conversations.length);
        
        // 批量加载AI角色信息
        if (this.conversations.length > 0) {
          const aiRoleIdsSet = new Set<number>();
          for (const conv of this.conversations) {
            aiRoleIdsSet.add(conv.aiRoleId);
          }
          const aiRoleIds: number[] = [];
          for (const id of aiRoleIdsSet) {
            aiRoleIds.push(id);
          }
          const aiRoleMap = await messageCacheManager.getAiRolesBatch(aiRoleIds);
          const entries = aiRoleMap.entries();
          const obj: Record<number, AiRole> = {};
          for (const entry of entries) {
            obj[entry[0]] = entry[1];
          }
          this.aiRoleMap = obj;
          
          // 预加载头像
          const aiRoles: AiRole[] = [];
          for (const role of aiRoleMap.values()) {
            aiRoles.push(role);
          }
          messageCacheManager.preloadAvatars(aiRoles);
        }
      } else {
        const errorResult = conversations as ErrorResult;
        console.error('❌ 对话列表加载失败:', errorResult.reason);
        this.conversations = [];
      }
      
      // 处理天气信息
      if (weatherInfo && this.isWeatherInfo(weatherInfo)) {
        this.weatherInfo = weatherInfo as WeatherInfo;
        console.log('✅ 天气信息加载成功');
      } else {
        const errorResult = weatherInfo as ErrorResult;
        console.error('❌ 天气信息加载失败:', errorResult.reason);
      }
      
      // 更新缓存统计
      this.cacheStats = messageCacheManager.getCacheStats();
      
    } catch (error) {
      console.error('❌ 数据加载失败:', error);
      this.conversations = [];
      this.aiRoleMap = {};
    } finally {
      this.isLoading = false;
    }
  }

  refreshConversations() {
    if (this.isRefreshing) return;
    this.isRefreshing = true;
    const userId = getUserId();
    if (userId !== null) {
      messageCacheManager.clearUserCache(userId);
      this.isLoading = true;
      this.loadDataWithCache().then(() => {
        this.isRefreshing = false;
      }).catch(() => {
        this.isRefreshing = false;
      });
    } else {
      this.isRefreshing = false;
    }
  }

  build(): void {
    Stack() {
      // 深色渐变背景 - 改为纯黑色主题
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#000000', 0.0], ['#0a0a0a', 0.5], ['#1a1a1a', 1.0]]
        })
      
      // 旋转的圆弧背景 - 改为黑色系装饰
      Stack() {
        // 多个同心圆弧轨道
        ForEach([0, 1, 2, 3], (index: number) => {
          Stack() {
            // 圆弧轨道 - 改为深灰色
            Column()
              .width(250 + index * 60)
              .height(250 + index * 60)
              .borderRadius((250 + index * 60) / 2)
              .border({ width: 1, color: `rgba(64, 64, 64, ${0.3 - index * 0.05})` })
              .position({ x: '50%', y: '50%' })
              .translate({ x: -(250 + index * 60) / 2, y: -(250 + index * 60) / 2 })
            
            // 旋转的圆弧点 - 改为白色系
            Column()
              .width(6)
              .height(6)
              .backgroundColor(`rgba(255, 255, 255, ${0.6 - index * 0.1})`)
              .borderRadius(3)
              .position({ x: '50%', y: '50%' })
              .translate({ 
                x: -3 + Math.cos((this.arcRotation + index * 90) * Math.PI / 180) * (125 + index * 30),
                y: -3 + Math.sin((this.arcRotation + index * 90) * Math.PI / 180) * (125 + index * 30)
              })
          }
        })
        
        // 外圈装饰点 - 改为银色系
        ForEach([0, 1, 2, 3, 4, 5], (index: number) => {
          Column()
            .width(6)
            .height(6)
            .backgroundColor(`rgba(192, 192, 192, ${0.4 - index * 0.05})`)
            .borderRadius(3)
            .position({ x: '50%', y: '50%' })
            .translate({ 
              x: -3 + Math.cos((this.arcRotation * 0.5 + index * 60) * Math.PI / 180) * 120,
              y: -3 + Math.sin((this.arcRotation * 0.5 + index * 60) * Math.PI / 180) * 120
            })
        })
      }
      .width('100%')
      .height('100%')
      
      // 主要内容区域
      Column() {
        // 天气卡片部分
        Stack() {
          // 天气卡片背景发光效果
          Column()
            .width('100%')
            .height(160)
            .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.05})`)
            .borderRadius(24)
            .border({ width: 2, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.2})` })
          
          Column() {
            // 上半部分：温度、城市、天气描述和图标
            Row() {
              // 左侧：温度
              Text(this.weatherInfo.temperature)
                .fontSize(42)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff')
                .opacity(this.textOpacity)
                .margin({ left: 20, top: 16, bottom: 0, right: 0 })
              
              // 中间：城市和天气描述
              Column() {
                Text(this.weatherInfo.city)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff')
                  .opacity(this.textOpacity)
                  .margin({ bottom: 4 })
                Text(this.weatherInfo.desc)
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.9)')
                  .opacity(this.textOpacity)
                  .margin({ bottom: 0 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 16, top: 16, bottom: 0, right: 0 })
              
              // 右侧：天气图标
              Blank().layoutWeight(1)
              Text(this.weatherInfo.icon)
                .fontSize(36)
                .fontColor('#ffffff')
                .opacity(this.textOpacity)
                .margin({ right: 20, top: 16, bottom: 0 })
            }
            .width('100%')
            .height(60)
            
            // 下半部分：时间日期
            Column() {
              Text(this.currentTime)
                .fontSize(24)
                .fontColor('#ffffff')
                .fontWeight(FontWeight.Bold)
                .opacity(this.textOpacity)
                .margin({ top: 8, bottom: 4 })
              Text(this.currentDate)
                .fontSize(13)
                .fontColor('rgba(255, 255, 255, 0.8)')
                .opacity(this.textOpacity)
                .margin({ bottom: 16 })
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
          }
          .width('100%')
          .height(160)
          .backgroundColor('rgba(255, 255, 255, 0.03)')
          .borderRadius(24)
          .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
          .margin({ left: 12, right: 12, top: 12, bottom: 16 })
          .shadow({ radius: 16, color: '#00000040', offsetX: 0, offsetY: 6 })
        }
        

        
        // 消息列表
        if (this.isLoading) {
          // 加载状态
          Column() {
            // 加载动画
            Stack() {
              Column()
                .width(60)
                .height(60)
                .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.1})`)
                .borderRadius(30)
                .border({ width: 2, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.3})` })
              
              Text('⏳')
                .fontSize(30)
                .fontColor('#ffffff')
                .opacity(this.textOpacity)
            }
            .margin({ top: 100, bottom: 24 })
            
            Text('正在加载对话...')
              .fontSize(16)
              .fontColor('#ffffff')
              .opacity(this.textOpacity)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .padding({ bottom: 56 })
        } else if (this.conversations.length > 0) {
          Scroll() {
            Column() {
              ForEach(this.conversations, (conv: Conversation, idx: number) => {
                ListItem() {
                  Stack() {
                    // 消息卡片背景发光
                    Column()
                      .width('100%')
                      .height(80)
                      .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
                      .borderRadius(16)
                      .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
                    
                    Row() {
                      // 使用智能头像组件
                      if (this.aiRoleMap[conv.aiRoleId]?.avatarUrl) {
                        Image(this.aiRoleMap[conv.aiRoleId].avatarUrl)
                          .width(48)
                          .height(48)
                          .borderRadius(24)
                          .border({ width: 2, color: 'rgba(255, 255, 255, 0.2)' })
                          .margin({ left: 16, right: 12 })
                          .alt('头像加载中...')
                      } else {
                        // 默认头像
                        Image($r('app.media.splash'))
                          .width(48)
                          .height(48)
                          .borderRadius(24)
                          .border({ width: 2, color: 'rgba(255, 255, 255, 0.2)' })
                          .margin({ left: 16, right: 12 })
                      }
                      
                      Column({ space: 4 }) {
                        Text(conv.title)
                          .fontSize(16)
                          .fontColor('#ffffff')
                          .fontWeight(FontWeight.Bold)
                          .opacity(this.textOpacity)
                        Text('') // 可扩展为摘要
                          .fontSize(13)
                          .fontColor('rgba(255, 255, 255, 0.7)')
                          .maxLines(1)
                          .margin({ top: 2 })
                      }
                      .layoutWeight(1)
                      Column() {
                        Text(conv.lastActive ? conv.lastActive.replace('T', ' ').slice(0, 16) : '')
                          .fontSize(12)
                          .fontColor('rgba(255, 255, 255, 0.6)')
                          .margin({ bottom: 8 })
                      }
                      .alignItems(HorizontalAlign.End)
                      .margin({ right: 16 })
                    }
                    .width('100%')
                    .height(80)
                    .backgroundColor('rgba(255, 255, 255, 0.03)')
                    .borderRadius(16)
                    .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
                    .margin({ left: 12, right: 12, bottom: 8 })
                    .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 2 })
                  }
                  .onTouch((event: TouchEvent) => {
                    if (event.type === TouchType.Down) {
                      // 开始长按检测
                      this.isLongPressing = false;
                      this.showLongPressHint = false;
                      this.longPressTimer = setTimeout(() => {
                        this.isLongPressing = true;
                        this.showLongPressHint = true;
                        // 显示长按提示
                        prompt.showToast({
                          message: '长按可删除对话',
                          duration: 1000
                        });
                        // 延迟显示删除对话框
                        setTimeout(() => {
                          this.showDeleteConfirmDialog(conv);
                        }, 500);
                      }, 800); // 800ms长按时间
                    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                      // 结束触摸，清除长按定时器
                      if (this.longPressTimer !== -1) {
                        clearTimeout(this.longPressTimer);
                        this.longPressTimer = -1;
                      }
                      this.showLongPressHint = false;
                    }
                  })
                  .onClick(() => {
                    // 只有在没有长按的情况下才执行单击
                    if (!this.isLongPressing) {
                      const aiRole = this.aiRoleMap[conv.aiRoleId];
                      console.log('角色ID:', aiRole.id);
                      router.pushUrl({
                        url: 'pages/chat',
                        params: {
                          figureImageUrl: aiRole?.avatarUrl ,
                          figureType: aiRole?.roleType ,
                          figureName: aiRole?.roleName ,
                          isFromCreateFigure: false,
                          description: aiRole?.roleDescription ,
                          createdAiRoleId: aiRole?.id
                        }
                      });
                    }
                    // 重置长按状态
                    this.isLongPressing = false;
                  })
                }
              }, (conv: Conversation) => conv.id.toString())
            }
          }
          .width('100%')
          .layoutWeight(1)
          .onScroll((xOffset: number, yOffset: number) => {
            this.scrollY = yOffset;
          })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down && this.scrollY <= 0) {
              this.pulling = true;
              this.pullStartY = event.touches[0].y;
            } else if (event.type === TouchType.Move && this.pulling) {
              const deltaY = event.touches[0].y - this.pullStartY;
              if (deltaY > 80) { // 下拉超过80像素触发刷新
                this.pulling = false;
                this.refreshConversations();
              }
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.pulling = false;
            }
          })
        } else {
          // 空状态显示
          Column() {
            // 发光圆圈
            Stack() {
              Column()
                .width(140)
                .height(140)
                .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.05})`)
                .borderRadius(70)
                .border({ width: 2, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.2})` })
              
              Text('💬')
                .fontSize(70)
                .fontColor('#ffffff')
                .opacity(this.textOpacity)
            }
            .margin({ top: 100, bottom: 24 })
            
            Text('暂无对话记录')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#ffffff')
              .opacity(this.textOpacity)
              .margin({ bottom: 12 })
            
            Text('开始与AI角色聊天，创建你的第一个对话吧！')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.7)')
              .textAlign(TextAlign.Center)
              .opacity(this.textOpacity)
              .margin({ left: 40, right: 40 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    
    
  }
} 