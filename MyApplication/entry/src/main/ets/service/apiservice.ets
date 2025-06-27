import { globalUserData } from '../models/userdata';
import { Config } from '../common/config';
import { UserInfo, UpdateUserRequest, ApiResponse, Dynamic, CreateDynamicRequest } from '../common/types';
import http from '@ohos.net.http';

// API基础配置 - 从配置文件获取
const API_BASE_URL = Config.getApiBaseUrl();

// 定义HTTP请求选项接口
interface HttpRequestOptions {
  method?: http.RequestMethod;
  header?: Record<string, string>;
  body?: string;
}

/**
 * API服务类
 */
export class ApiService {
  
  /**
   * 通用HTTP请求方法
   */
  private static async request<T>(
    url: string, 
    options: HttpRequestOptions = {}
  ): Promise<ApiResponse<T>> {
    try {
      const httpRequest = http.createHttp();
      
      // 设置请求头
      const headers: Record<string, string> = {
        'Content-Type': 'application/json'
      };
      
      // 合并自定义请求头
      const customHeader = options.header ?? {};
      Object.keys(customHeader).forEach(key => {
        headers[key] = customHeader[key];
      });

      // 设置请求选项
      const requestOptions: http.HttpRequestOptions = {
        method: options.method || http.RequestMethod.GET,
        header: headers,
        readTimeout: Config.getTimeout(),
        connectTimeout: Config.getTimeout()
      };

      // 如果有请求体，添加到选项中
      if (options.body) {
        requestOptions.extraData = options.body;
      }

      const response = await httpRequest.request(url, requestOptions);
      httpRequest.destroy();

      if (response.responseCode !== 200) {
        throw new Error(`HTTP error! status: ${response.responseCode}`);
      }

      const result: ApiResponse<T> = JSON.parse(response.result.toString());
      
      // 调试模式下的日志
      if (Config.isDebug()) {
        console.log(`API请求: ${url}`, result);
      }
      
      return result;
    } catch (error) {
      console.error('API请求失败:', error);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error('Unknown error occurred');
      }
    }
  }

  /**
   * 获取用户信息
   */
  static async getUserInfo(userUID: string): Promise<UserInfo> {
    const response = await ApiService.request<UserInfo>(`${API_BASE_URL}/user/${userUID}`);
    if (response.success) {
      // 同步到前端全局状态
      globalUserData.updateUserName(response.data.userName);
      globalUserData.updateUserUID(response.data.userUID);
      globalUserData.updateUserAvatar(response.data.userAvatar);
      if (response.data.isPrivacyVisible !== globalUserData.isPrivacyVisible) {
        globalUserData.togglePrivacy();
      }
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get user info');
    }
  }

  /**
   * 更新用户信息
   */
  static async updateUserInfo(userUID: string, userData: UpdateUserRequest): Promise<UserInfo> {
    const response = await ApiService.request<UserInfo>(`${API_BASE_URL}/user/${userUID}`, {
      method: http.RequestMethod.PUT,
      body: JSON.stringify(userData)
    });

    if (response.success) {
      // 同步到前端全局状态
      if (userData.userName) {
        globalUserData.updateUserName(userData.userName);
      }
      if (userData.userAvatar) {
        globalUserData.updateUserAvatar(userData.userAvatar);
      }
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to update user info');
    }
  }

  /**
   * 上传用户头像 (简化版本，使用base64)
   */
  static async uploadAvatar(userUID: string, imageData: string): Promise<string> {
    try {
      const response = await ApiService.request<string>(`${API_BASE_URL}/user/${userUID}/avatar`, {
        method: http.RequestMethod.POST,
        body: JSON.stringify({ imageData: imageData })
      });

      if (response.success) {
        // 同步到前端全局状态
        globalUserData.updateUserAvatar(response.data);
        return response.data;
      } else {
        throw new Error(response.message || 'Failed to upload avatar');
      }
    } catch (error) {
      console.error('头像上传失败:', error);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error('Avatar upload failed');
      }
    }
  }

  /**
   * 切换隐私可见性
   */
  static async togglePrivacy(userUID: string): Promise<boolean> {
    const response = await ApiService.request<boolean>(`${API_BASE_URL}/user/${userUID}/privacy/toggle`, {
      method: http.RequestMethod.POST
    });

    if (response.success) {
      // 同步到前端全局状态
      globalUserData.togglePrivacy();
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to toggle privacy');
    }
  }

  /**
   * 创建新用户
   */
  static async createUser(userUID: string, userName: string): Promise<UserInfo> {
    const response = await ApiService.request<UserInfo>(`${API_BASE_URL}/user/create?userUID=${userUID}&userName=${encodeURIComponent(userName)}`, {
      method: http.RequestMethod.POST
    });

    if (response.success) {
      // 同步到前端全局状态
      globalUserData.updateUserName(response.data.userName);
      globalUserData.updateUserUID(response.data.userUID);
      globalUserData.updateUserAvatar(response.data.userAvatar);
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to create user');
    }
  }

  /**
   * 健康检查
   */
  static async healthCheck(): Promise<boolean> {
    try {
      const response = await ApiService.request<string>(`${API_BASE_URL}/user/health`);
      return response.success;
    } catch (error) {
      console.error('健康检查失败:', error);
      return false;
    }
  }

  /**
   * AI聊天接口
   */
  static async chatWithAI(prompt: string, chatId: string, identity: string = 'default'): Promise<string> {
    const url = `${API_BASE_URL}/ai/chat/${identity}?prompt=${encodeURIComponent(prompt)}&chatId=${encodeURIComponent(chatId)}`;
    const response = await ApiService.request<string>(url, {
      method: http.RequestMethod.POST
    });
    return response.data;
  }

  /**
   * 生成形象描述接口
   */
  static async generateDescription(userInput: string): Promise<string> {
    try {
      const url = `${API_BASE_URL}/ai/generate-description?userInput=${encodeURIComponent(userInput)}`;
      
      console.log('发送请求到:', url);
      console.log('用户输入:', userInput);
      
      // 测试连接
      const testUrl = `${API_BASE_URL}/user/health`;
      const testRequest = http.createHttp();
      const testResponse = await testRequest.request(testUrl, { method: http.RequestMethod.GET });
      testRequest.destroy();
      console.log('连接测试结果:', testResponse.responseCode);
      
      const httpRequest = http.createHttp();
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        readTimeout: Config.getTimeout(),
        connectTimeout: Config.getTimeout()
      };

      const response = await httpRequest.request(url, requestOptions);
      httpRequest.destroy();

      console.log('响应状态码:', response.responseCode);
      console.log('响应头:', JSON.stringify(response.header));
      console.log('响应内容长度:', response.result.toString().length);
      console.log('响应内容:', response.result.toString());

      if (response.responseCode !== 200) {
        throw new Error(`HTTP error! status: ${response.responseCode}, message: ${response.result.toString()}`);
      }

      // 直接返回响应内容，因为后端返回的是纯文本
      const result = response.result.toString();
      console.log('生成的描述:', result);
      return result;
    } catch (error) {
      console.error('生成形象描述失败:', error);
      console.error('错误类型:', typeof error);
      console.error('错误详情:', JSON.stringify(error));
      
      // 检查是否是超时错误
      if (error && typeof error === 'object') {
        const errorObj = error as Record<string, string | number>;
        if (errorObj.code === 2300028) {
          throw new Error('生成描述超时，请稍后重试。AI生成需要较长时间，请耐心等待。');
        }
      }
      
      if (error instanceof Error) {
        throw new Error(`生成描述失败: ${error.message}`);
      } else {
        throw new Error('生成描述失败: 未知错误');
      }
    }
  }

  /**
   * 生成形象图片接口
   */
  static async generateFigure(userInput: string, style: string): Promise<string> {
    try {
      const url = `${API_BASE_URL}/ai/generate-figure?userInput=${encodeURIComponent(userInput)}&style=${encodeURIComponent(style)}`;
      
      console.log('发送生成图片请求到:', url);
      console.log('用户输入:', userInput);
      console.log('风格:', style);
      
      const httpRequest = http.createHttp();
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        readTimeout: 180000, // 3分钟超时，专门用于图片生成
        connectTimeout: 30000 // 30秒连接超时
      };

      const response = await httpRequest.request(url, requestOptions);
      httpRequest.destroy();

      console.log('图片生成响应状态码:', response.responseCode);
      console.log('图片生成响应内容:', response.result.toString());

      if (response.responseCode !== 200) {
        throw new Error(`HTTP error! status: ${response.responseCode}, message: ${response.result.toString()}`);
      }

      // 直接返回响应内容，因为后端返回的是图片URL
      const result = response.result.toString();
      console.log('生成的图片URL:', result);
      return result;
    } catch (error) {
      console.error('生成形象图片失败:', error);
      console.error('错误类型:', typeof error);
      console.error('错误详情:', JSON.stringify(error));
      
      // 检查是否是超时错误
      if (error && typeof error === 'object') {
        const errorObj = error as Record<string, string | number>;
        if (errorObj.code === 2300028) {
          throw new Error('生成图片超时，请稍后重试。AI生成需要较长时间，请耐心等待。');
        }
      }
      
      if (error instanceof Error) {
        throw new Error(`生成图片失败: ${error.message}`);
      } else {
        throw new Error('生成图片失败: 未知错误');
      }
    }
  }

  /**
   * 获取AI身份列表
   */
  static async getAIIdentities(): Promise<string[]> {
    const response = await ApiService.request<string[]>(`${API_BASE_URL}/ai/identities`);
    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get AI identities');
    }
  }

  /**
   * 获取当前服务器地址
   */
  static getServerUrl(): string {
    return API_BASE_URL;
  }

  /**
   * 获取当前环境信息
   */
  static getEnvironmentInfo(): string {
    return `环境: ${Config.getCurrentEnv()}, 服务器: ${API_BASE_URL}`;
  }

  /**
   * 创建动态
   */
  static async createDynamic(userUID: string, dynamicData: CreateDynamicRequest): Promise<Dynamic> {
    const response = await ApiService.request<Dynamic>(`${API_BASE_URL}/dynamic/create/${userUID}`, {
      method: http.RequestMethod.POST,
      body: JSON.stringify(dynamicData)
    });

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to create dynamic');
    }
  }

  /**
   * 获取用户的所有动态
   */
  static async getUserDynamics(userUID: string): Promise<Dynamic[]> {
    const response = await ApiService.request<Dynamic[]>(`${API_BASE_URL}/dynamic/user/${userUID}`);
    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get user dynamics');
    }
  }

  /**
   * 获取用户的公开动态
   */
  static async getUserPublicDynamics(userUID: string): Promise<Dynamic[]> {
    const response = await ApiService.request<Dynamic[]>(`${API_BASE_URL}/dynamic/user/${userUID}/public`);
    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get user public dynamics');
    }
  }

  /**
   * 点赞动态
   */
  static async likeDynamic(dynamicId: string): Promise<boolean> {
    const response = await ApiService.request<boolean>(`${API_BASE_URL}/dynamic/${dynamicId}/like`, {
      method: http.RequestMethod.POST
    });

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to like dynamic');
    }
  }

  /**
   * 取消点赞动态
   */
  static async unlikeDynamic(dynamicId: string): Promise<boolean> {
    const response = await ApiService.request<boolean>(`${API_BASE_URL}/dynamic/${dynamicId}/unlike`, {
      method: http.RequestMethod.POST
    });

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to unlike dynamic');
    }
  }

  /**
   * 删除动态
   */
  static async deleteDynamic(dynamicId: string, userUID: string): Promise<boolean> {
    const response = await ApiService.request<boolean>(`${API_BASE_URL}/dynamic/${dynamicId}/delete/${userUID}`, {
      method: http.RequestMethod.DELETE
    });

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to delete dynamic');
    }
  }

  /**
   * 获取所有公开动态
   */
  static async getAllPublicDynamics(): Promise<Dynamic[]> {
    const response = await ApiService.request<Dynamic[]>(`${API_BASE_URL}/dynamic/public`);
    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get public dynamics');
    }
  }
}
