// utils.ets
// 工具函数

import promptAction from '@ohos.promptAction';

/**
 * 网络连接状态检查工具类
 */
export class NetworkUtils {
  
  /**
   * 检查网络连接状态
   * 简化版本，在实际应用中可以通过其他方式检查网络状态
   */
  static async checkNetworkConnection(): Promise<boolean> {
    try {
      // 模拟网络检查，可以通过HTTP请求测试连接
      // 这里暂时返回true，表示网络连接正常
      return true;
    } catch (error) {
      console.error('网络连接检查失败:', error);
      return false;
    }
  }
  
  /**
   * 显示网络连接错误提示
   */
  static showNetworkError(): void {
    promptAction.showToast({ 
      message: '网络连接失败，请检查网络设置',
      duration: 3000
    });
  }
  
  /**
   * 处理网络请求错误
   */
  static handleNetworkError(error: Error): void {
    console.error('网络请求错误:', error);
    if (error.message && error.message.includes('Network')) {
      NetworkUtils.showNetworkError();
    } else {
      promptAction.showToast({ 
        message: '请求失败，请稍后重试',
        duration: 2000
      });
    }
  }
  
  /**
   * 模拟网络断开状态（用于测试）
   */
  static setMockNetworkStatus(isConnected: boolean): void {
    // 这个方法可以用于测试网络断开场景
    console.log(`模拟网络状态: ${isConnected ? '已连接' : '已断开'}`);
  }
}

/**
 * 通用工具函数
 */
export class CommonUtils {
  
  /**
   * 格式化时间
   */
  static formatTime(timeStr: string): string {
    const date = new Date(timeStr);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    
    const minutes = Math.floor(diff / (1000 * 60));
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    
    if (minutes < 1) return '刚刚';
    if (minutes < 60) return `${minutes}分钟前`;
    if (hours < 24) return `${hours}小时前`;
    if (days < 7) return `${days}天前`;
    
    return date.toLocaleDateString();
  }
  
  /**
   * 验证字符串是否为空
   */
  static isEmpty(str: string): boolean {
    return !str || str.trim().length === 0;
  }
  
  /**
   * 截断字符串
   */
  static truncate(str: string, maxLength: number): string {
    if (!str || str.length <= maxLength) {
      return str;
    }
    return str.substring(0, maxLength) + '...';
  }
}
