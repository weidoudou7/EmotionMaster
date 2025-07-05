// config.ets
// 环境配置管理

// 定义配置接口
interface EnvironmentConfig {
  API_BASE_URL: string;
  TIMEOUT: number;
  DEBUG: boolean;
}

// 定义环境类型
type Environment = 'DEV' | 'TEST' | 'PROD';

export class Config {
  // 开发环境配置
  private static readonly DEV_CONFIG: EnvironmentConfig = {
    API_BASE_URL: 'http://localhost:8081/api', // 如果前后端在同一台机器，使用localhost
    // API_BASE_URL: 'http://10.255.18.25:8081/api', // 如果使用局域网IP
    TIMEOUT: 10000, // 10秒超时
    DEBUG: true
  };

  // 测试环境配置
  private static readonly TEST_CONFIG: EnvironmentConfig = {
    API_BASE_URL: 'http://192.168.1.100:8081/api', // 替换为您的局域网IP
    TIMEOUT: 20000, // 10秒超时
    DEBUG: true
  };

  // 生产环境配置
  private static readonly PROD_CONFIG: EnvironmentConfig = {
    API_BASE_URL: 'https://your-domain.com/api', // 替换为您的生产域名
    TIMEOUT: 20000, // 15秒超时
    DEBUG: false
  };

  // 当前环境 (修改这里切换环境)
  private static readonly CURRENT_ENV: Environment = 'DEV';

  /**
   * 获取当前环境配置
   */
  static getConfig(): EnvironmentConfig {
    switch (Config.CURRENT_ENV) {
      case 'DEV':
        return Config.DEV_CONFIG;
      case 'TEST':
        return Config.TEST_CONFIG;
      case 'PROD':
        return Config.PROD_CONFIG;
      default:
        return Config.DEV_CONFIG;
    }
  }

  /**
   * 获取API基础URL
   */
  static getApiBaseUrl(): string {
    return Config.getConfig().API_BASE_URL;
  }

  /**
   * 获取请求超时时间
   */
  static getTimeout(): number {
    return Config.getConfig().TIMEOUT;
  }

  /**
   * 是否开启调试模式
   */
  static isDebug(): boolean {
    return Config.getConfig().DEBUG;
  }

  /**
   * 获取当前环境名称
   */
  static getCurrentEnv(): Environment {
    return Config.CURRENT_ENV;
  }
} 