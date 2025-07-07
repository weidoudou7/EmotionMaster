import { AiRole } from '../common/types';
import http from '@ohos.net.http';

// 头像缓存项接口
interface AvatarCacheItem {
  url: string;
  data: string; // base64编码的图片数据
  timestamp: number;
  size: number;
  loading: boolean;
  failed: boolean;
  retryCount: number;
}

// 缓存统计接口
interface CacheStats {
  total: number;
  success: number;
  failed: number;
  loading: number;
}

// 头像加载状态
export enum AvatarLoadState {
  LOADING = 'loading',
  LOADED = 'loaded',
  FAILED = 'failed',
  CACHED = 'cached'
}

// 智能头像组件接口
interface SmartAvatarComponent {
  url: string;
  roleId: number;
  size: number;
  borderRadius: number;
  state: AvatarLoadState;
  retryCount: number;
  load(): Promise<void>;
}

// Base64字符集
const BASE64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

// 智能头像组件类实现
class SmartAvatarComponentImpl implements SmartAvatarComponent {
  url: string;
  roleId: number;
  size: number;
  borderRadius: number;
  state: AvatarLoadState;
  retryCount: number;

  constructor(avatarUrl: string, roleId: number, size: number, borderRadius: number) {
    this.url = avatarUrl;
    this.roleId = roleId;
    this.size = size;
    this.borderRadius = borderRadius;
    this.state = AvatarLoadState.LOADING;
    this.retryCount = 0;
  }

  async load(): Promise<void> {
    try {
      this.state = await AvatarCacheManager.getInstance().loadAvatar(this.url, this.roleId);
      
      if (this.state === AvatarLoadState.FAILED && this.retryCount < 3) {
        this.retryCount++;
        console.log(`🔄 重试加载头像: ${this.roleId}, 第 ${this.retryCount} 次`);
        await new Promise<void>(resolve => setTimeout(resolve, 1000 * this.retryCount));
        await this.load();
      }
    } catch (error) {
      console.error(`❌ 头像加载失败: ${this.roleId}`, error);
      this.state = AvatarLoadState.FAILED;
    }
  }
}

// 头像缓存管理器
export class AvatarCacheManager {
  private static instance: AvatarCacheManager;
  private cache: Map<string, AvatarCacheItem> = new Map();
  private loadingQueue: Set<string> = new Set();
  private maxCacheSize: number = 50; // 最大缓存数量
  private maxCacheAge: number = 24 * 60 * 60 * 1000; // 24小时缓存过期时间
  private retryLimit: number = 3; // 最大重试次数
  private preloadQueue: string[] = []; // 预加载队列

  // 单例模式
  public static getInstance(): AvatarCacheManager {
    if (!AvatarCacheManager.instance) {
      AvatarCacheManager.instance = new AvatarCacheManager();
    }
    return AvatarCacheManager.instance;
  }

  /**
   * 智能头像加载 - 主要接口
   */
  public async loadAvatar(avatarUrl: string, roleId: number): Promise<AvatarLoadState> {
    if (!avatarUrl || avatarUrl.trim() === '') {
      return AvatarLoadState.FAILED;
    }

    const cacheKey = this.generateCacheKey(avatarUrl, roleId);
    
    // 检查缓存
    const cached = this.cache.get(cacheKey);
    if (cached && !this.isExpired(cached)) {
      console.log(`🎯 头像缓存命中: ${roleId}`);
      return AvatarLoadState.CACHED;
    }

    // 检查是否正在加载
    if (this.loadingQueue.has(cacheKey)) {
      console.log(`⏳ 头像正在加载中: ${roleId}`);
      return AvatarLoadState.LOADING;
    }

    // 开始加载
    return this.startLoading(cacheKey, avatarUrl, roleId);
  }

  /**
   * 获取缓存的头像数据
   */
  public getCachedAvatar(avatarUrl: string, roleId: number): string | null {
    const cacheKey = this.generateCacheKey(avatarUrl, roleId);
    const cached = this.cache.get(cacheKey);
    
    if (cached && !this.isExpired(cached) && !cached.failed) {
      return cached.data;
    }
    
    return null;
  }

  /**
   * 预加载头像列表
   */
  public async preloadAvatars(aiRoles: AiRole[]): Promise<void> {
    console.log(`🚀 开始预加载 ${aiRoles.length} 个头像`);
    
    // 过滤出需要预加载的头像
    const toPreload: AiRole[] = [];
    for (const role of aiRoles) {
      const cacheKey = this.generateCacheKey(role.avatarUrl, role.id || 0);
      const cached = this.cache.get(cacheKey);
      if (!cached || this.isExpired(cached) || cached.failed) {
        toPreload.push(role);
      }
    }

    // 分批预加载，避免同时加载过多
    const batchSize = 3;
    for (let i = 0; i < toPreload.length; i += batchSize) {
      const batch = toPreload.slice(i, i + batchSize);
      const promises: Promise<AvatarLoadState>[] = [];
      for (const role of batch) {
        promises.push(this.loadAvatar(role.avatarUrl, role.id || 0));
      }
      
      // 等待所有promise完成，忽略错误
      for (const promise of promises) {
        try {
          await promise;
        } catch (error) {
          // 忽略单个头像加载失败
        }
      }
      
      // 批次间延迟，避免阻塞UI
      if (i + batchSize < toPreload.length) {
        await new Promise<void>(resolve => setTimeout(resolve, 100));
      }
    }
    
    console.log(`✅ 预加载完成，成功加载 ${this.getSuccessCount()} 个头像`);
  }

  /**
   * 智能头像组件 - 带加载状态和动画
   */
  public createSmartAvatarComponent(
    avatarUrl: string, 
    roleId: number, 
    size: number = 48,
    borderRadius: number = 24
  ): SmartAvatarComponent {
    return new SmartAvatarComponentImpl(avatarUrl, roleId, size, borderRadius);
  }

  /**
   * 清理过期缓存
   */
  public cleanExpiredCache(): void {
    const now = Date.now();
    let cleanedCount = 0;
    
    const keysToDelete: string[] = [];
    for (const entry of this.cache.entries()) {
      const key = entry[0];
      const item = entry[1];
      if (this.isExpired(item)) {
        keysToDelete.push(key);
      }
    }
    
    for (const key of keysToDelete) {
      this.cache.delete(key);
      cleanedCount++;
    }
    
    if (cleanedCount > 0) {
      console.log(`🧹 清理了 ${cleanedCount} 个过期缓存`);
    }
  }

  /**
   * 获取缓存统计信息
   */
  public getCacheStats(): CacheStats {
    let success = 0, failed = 0, loading = 0;
    
    for (const item of this.cache.values()) {
      if (item.loading) loading++;
      else if (item.failed) failed++;
      else success++;
    }
    
    const stats: CacheStats = {
      total: this.cache.size,
      success: success,
      failed: failed,
      loading: loading
    };
    return stats;
  }

  // ==================== 私有方法 ====================

  private async startLoading(cacheKey: string, avatarUrl: string, roleId: number): Promise<AvatarLoadState> {
    this.loadingQueue.add(cacheKey);
    
    try {
      console.log(`📥 开始加载头像: ${roleId}`);
      
      // 创建缓存项
      const cacheItem: AvatarCacheItem = {
        url: avatarUrl,
        data: '',
        timestamp: Date.now(),
        size: 0,
        loading: true,
        failed: false,
        retryCount: 0
      };
      
      this.cache.set(cacheKey, cacheItem);
      
      // 使用http模块加载图片
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(avatarUrl, {
        method: http.RequestMethod.GET,
        readTimeout: 10000,
        connectTimeout: 5000
      });
      httpRequest.destroy();
      
      if (response.responseCode !== 200) {
        throw new Error(`HTTP ${response.responseCode}: 请求失败`);
      }
      
      const imageData = response.result as ArrayBuffer;
      const base64 = this.arrayBufferToBase64(imageData);
      
      // 更新缓存
      cacheItem.data = base64;
      cacheItem.size = imageData.byteLength;
      cacheItem.loading = false;
      cacheItem.failed = false;
      
      // 管理缓存大小
      this.manageCacheSize();
      
      console.log(`✅ 头像加载成功: ${roleId}, 大小: ${(imageData.byteLength / 1024).toFixed(1)}KB`);
      return AvatarLoadState.LOADED;
      
    } catch (error) {
      console.error(`❌ 头像加载失败: ${roleId}`, error);
      
      // 更新失败状态
      const cacheItem = this.cache.get(cacheKey);
      if (cacheItem) {
        cacheItem.loading = false;
        cacheItem.failed = true;
        cacheItem.retryCount++;
      }
      
      return AvatarLoadState.FAILED;
    } finally {
      this.loadingQueue.delete(cacheKey);
    }
  }

  private generateCacheKey(avatarUrl: string, roleId: number): string {
    return `${roleId}_${this.hashString(avatarUrl)}`;
  }

  private isExpired(cacheItem: AvatarCacheItem): boolean {
    return Date.now() - cacheItem.timestamp > this.maxCacheAge;
  }

  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return 'data:image/jpeg;base64,' + this.btoa(binary);
  }

  private btoa(str: string): string {
    let output = '';
    const bytes = new Uint8Array(str.length);
    for (let i = 0; i < str.length; i++) {
      bytes[i] = str.charCodeAt(i);
    }
    
    let byteNum: number;
    let chunk: string[];
    
    for (let i = 0; i < bytes.length; i += 3) {
      byteNum = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2];
      chunk = [
        BASE64_CHARS.charAt((byteNum >> 18) & 0x3F),
        BASE64_CHARS.charAt((byteNum >> 12) & 0x3F),
        BASE64_CHARS.charAt((byteNum >> 6) & 0x3F),
        BASE64_CHARS.charAt(byteNum & 0x3F)
      ];
      output += chunk.join('');
    }
    
    return output;
  }

  private hashString(str: string): string {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // 转换为32位整数
    }
    return Math.abs(hash).toString(36);
  }

  private manageCacheSize(): void {
    if (this.cache.size <= this.maxCacheSize) return;
    
    // 按时间排序，删除最旧的缓存
    const entries: Array<[string, AvatarCacheItem]> = [];
    for (const entry of this.cache.entries()) {
      const key = entry[0];
      const item = entry[1];
      entries.push([key, item]);
    }
    
    entries.sort((a, b) => a[1].timestamp - b[1].timestamp);
    
    const toDelete = entries.slice(0, this.cache.size - this.maxCacheSize);
    for (const entry of toDelete) {
      const key = entry[0];
      this.cache.delete(key);
    }
    
    console.log(`🗑️ 清理了 ${toDelete.length} 个缓存项`);
  }

  private getSuccessCount(): number {
    let count = 0;
    for (const item of this.cache.values()) {
      if (!item.failed && !item.loading) count++;
    }
    return count;
  }
}

// 导出单例实例
export const avatarCacheManager = AvatarCacheManager.getInstance(); 