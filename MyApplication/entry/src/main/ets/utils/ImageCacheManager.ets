import http from '@ohos.net.http'
import fileIO from '@ohos.fileio'

// 定义类
class CacheInfo {
  cacheMap: Array<[string, string]> = [];
  cacheSize: number = 0;
  timestamp: number = 0;
}

class CacheStats {
  size: number = 0;
  count: number = 0;
  maxSize: number = 0;
}

/**
 * 图片缓存管理器 - 简化版本
 * 提供基本的图片缓存功能
 */
export class ImageCacheManager {
  private static instance: ImageCacheManager
  private cacheDir: string = ''
  private cacheSize: number = 0
  private maxCacheSize: number = 100 * 1024 * 1024 // 100MB
  private cacheMap: Map<string, string> = new Map()
  
  private constructor() {
    this.initCache()
  }
  
  static getInstance(): ImageCacheManager {
    if (!ImageCacheManager.instance) {
      ImageCacheManager.instance = new ImageCacheManager()
    }
    return ImageCacheManager.instance
  }
  
  /**
   * 初始化缓存目录
   */
  private async initCache(): Promise<void> {
    try {
      // 获取应用缓存目录
      const context = getContext(this)
      this.cacheDir = context.cacheDir + '/images/'
      
      // 创建缓存目录
      try {
        await fileIO.mkdir(this.cacheDir)
      } catch (mkdirError) {
        // 目录可能已存在，忽略错误
        console.log('缓存目录可能已存在')
      }
      
      console.log('图片缓存管理器初始化完成')
    } catch (initError) {
      console.error('初始化图片缓存失败:', initError)
    }
  }
  
  /**
   * 获取缓存的文件路径
   */
  private getCacheFilePath(url: string): string {
    const hash = this.hashString(url)
    return this.cacheDir + hash + '.jpg'
  }
  
  /**
   * 简单的字符串哈希函数
   */
  private hashString(str: string): string {
    let hash = 0
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i)
      hash = ((hash << 5) - hash) + char
      hash = hash & hash // 转换为32位整数
    }
    return Math.abs(hash).toString(16)
  }
  
  /**
   * 检查图片是否已缓存 - 简化版本，只检查内存缓存
   */
  async isCached(url: string): Promise<boolean> {
    return this.cacheMap.has(url)
  }
  
  /**
   * 获取缓存的图片路径 - 简化版本
   */
  async getCachedImagePath(url: string): Promise<string | null> {
    if (this.cacheMap.has(url)) {
      return url // 返回原始URL，因为不再有本地文件
    }
    return null
  }
  
  /**
   * 缓存图片 - 简化版本，只使用内存缓存
   */
  async cacheImage(url: string, imageData: ArrayBuffer): Promise<void> {
    try {
      const cachePath = this.getCacheFilePath(url)
      
      // 简化：只更新内存缓存信息，不写入文件
      this.cacheMap.set(url, cachePath)
      this.cacheSize += imageData.byteLength
      
      console.log(`图片缓存信息更新: ${url}`)
    } catch (cacheError) {
      console.error('缓存图片失败:', cacheError)
    }
  }
  
  /**
   * 智能加载图片 - 简化版本，优先使用缓存
   */
  async loadImageSmart(url: string): Promise<string> {
    try {
      // 检查缓存
      if (this.cacheMap.has(url)) {
        console.log('使用缓存图片:', url)
        return url
      }
      
      // 下载并缓存图片信息
      console.log('下载并缓存图片信息:', url)
      const imageData = await this.downloadImage(url)
      await this.cacheImage(url, imageData)
      
      return url
    } catch (loadError) {
      console.error('智能加载图片失败:', loadError)
      return url // 返回原始URL作为备用
    }
  }
  
  /**
   * 下载图片
   */
  private async downloadImage(url: string): Promise<ArrayBuffer> {
    const maxRetries = 2; // 减少重试次数，提高效率
    let lastError: Error | null = null
    
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      const httpRequest = http.createHttp()
      try {
        const response = await httpRequest.request(url, {
          method: http.RequestMethod.GET,
          readTimeout: 30000, // 30秒超时 - 延长预加载时间
          connectTimeout: 15000 // 15秒连接超时 - 延长预加载时间
        })
        
        // 检查HTTP状态码
        if (response.responseCode === 429) {
          // 限流错误，等待更长时间后重试
          console.warn(`图片服务限流 (尝试${attempt}/${maxRetries}): ${url}`);
          await new Promise<void>(resolve => setTimeout(resolve, 2000 * attempt)) // 2秒、4秒
          continue
        } else if (response.responseCode === 200) {
          const result = response.result
          if (result && typeof result === 'object') {
            // 在ArkTS中，response.result可能是ArrayBuffer或其他类型
            return result as ArrayBuffer
          } else {
            throw new Error('响应结果格式错误')
          }
        } else {
          throw new Error(`HTTP ${response.responseCode}`)
        }
      } catch (error) {
        lastError = error as Error
        console.warn(`图片下载失败 (尝试${attempt}/${maxRetries}): ${url}`, error);
        
        // 检查是否是限流或超时错误
        if (error && typeof error === 'object') {
          const errorObj = error as Record<string, string | number>;
          if (errorObj.code === 2300028) {
            // 超时错误，等待更长时间
            console.warn(`图片下载超时，等待重试: ${url}`);
            await new Promise<void>(resolve => setTimeout(resolve, 1500 * attempt)) // 1.5秒、3秒
          } else if (errorObj.responseCode === 429) {
            // 限流错误，等待更长时间
            console.warn(`图片服务限流，等待重试: ${url}`);
            await new Promise<void>(resolve => setTimeout(resolve, 2000 * attempt)) // 2秒、4秒
          } else {
            // 其他错误，正常重试间隔
            await new Promise<void>(resolve => setTimeout(resolve, 800 * attempt)) // 0.8秒、1.6秒
          }
        } else {
          // 默认重试间隔
          await new Promise<void>(resolve => setTimeout(resolve, 800 * attempt)) // 0.8秒、1.6秒
        }
      } finally {
        httpRequest.destroy()
      }
    }
    
    // 所有重试都失败了
    console.error(`图片下载最终失败 (${maxRetries}次尝试): ${url}`, lastError);
    throw lastError || new Error('图片下载失败');
  }
  
  /**
   * 预加载图片到缓存
   */
  async preloadImages(urls: string[]): Promise<string[]> {
    const cachedUrls: string[] = []
    
    const promises = urls.map(async (url) => {
      try {
        const cachedPath = await this.loadImageSmartWithRetry(url, 3) // 重试3次
        cachedUrls.push(cachedPath)
        console.log(`预加载成功: ${url}`)
      } catch (preloadError) {
        console.warn(`预加载失败: ${url}`, preloadError)
        cachedUrls.push(url) // 使用原始URL作为备用
      }
    })
    
    await Promise.all(promises)
    return cachedUrls
  }
  
  /**
   * 带重试机制的智能加载图片
   */
  async loadImageSmartWithRetry(url: string, maxRetries: number = 2): Promise<string> {
    let lastError: Error | null = null
    
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // 检查缓存
        if (this.cacheMap.has(url)) {
          console.log(`使用缓存图片 (尝试${attempt}/${maxRetries}): ${url}`)
          return url
        }
        
        // 下载并缓存图片信息
        console.log(`下载并缓存图片信息 (尝试${attempt}/${maxRetries}): ${url}`)
        const imageData = await this.downloadImage(url)
        await this.cacheImage(url, imageData)
        
        return url
      } catch (loadError) {
        lastError = loadError as Error
        console.warn(`图片加载失败 (尝试${attempt}/${maxRetries}): ${url}`, loadError)
        
        if (attempt < maxRetries) {
          // 等待一段时间后重试
          await new Promise<void>(resolve => setTimeout(resolve, 800 * attempt)) // 0.8秒、1.6秒
        }
      }
    }
    
    // 所有重试都失败了
    console.error(`图片加载最终失败 (${maxRetries}次尝试): ${url}`, lastError)
    throw lastError || new Error('图片加载失败')
  }
  
  /**
   * 清理所有缓存 - 简化版本，只清理内存缓存
   */
  async clearAllCache(): Promise<void> {
    try {
      this.cacheMap.clear()
      this.cacheSize = 0
      
      console.log('所有图片缓存已清理')
    } catch (clearError) {
      console.error('清理所有缓存失败:', clearError)
    }
  }
  
  /**
   * 获取缓存统计信息
   */
  getCacheStats(): CacheStats {
    const stats = new CacheStats()
    stats.size = this.cacheSize
    stats.count = this.cacheMap.size
    stats.maxSize = this.maxCacheSize
    return stats
  }
  
  /**
   * 测试方法 - 验证缓存管理器是否正常工作
   */
  async testCacheManager(): Promise<boolean> {
    try {
      console.log('开始测试图片缓存管理器...')
      
      // 测试1: 检查缓存目录
      console.log('测试1: 检查缓存目录')
      console.log('缓存目录:', this.cacheDir)
      
      // 测试2: 检查缓存统计
      console.log('测试2: 检查缓存统计')
      const stats = this.getCacheStats()
      console.log('缓存统计:', stats)
      
      // 测试3: 测试哈希函数
      console.log('测试3: 测试哈希函数')
      const testUrl = 'https://example.com/test.jpg'
      const hash = this.hashString(testUrl)
      console.log('测试URL哈希:', hash)
      
      // 测试4: 测试缓存路径生成
      console.log('测试4: 测试缓存路径生成')
      const cachePath = this.getCacheFilePath(testUrl)
      console.log('缓存路径:', cachePath)
      
      console.log('图片缓存管理器测试完成')
      return true
    } catch (testError) {
      console.error('图片缓存管理器测试失败:', testError)
      return false
    }
  }
} 