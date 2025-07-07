import { globalUserData } from '../models/userdata';
import { Config } from '../common/config';
import { UserInfo, UpdateUserRequest, ApiResponse, Dynamic, CreateDynamicRequest, UserStats, MusicDetailVO, SearchUserResult, CreateAiRoleRequest, GenerateRoleNameRequest, CreateConversationRequest, Conversation, Message, CreateMessageRequest, CommentItem, RoleTypeStatistics, UserRolePreferenceAnalysis, PreviewAvatarResponse } from '../common/types';
import {  AiRole } from '../common/types';
import http from '@ohos.net.http';


// API基础配置 - 从配置文件获取
const API_BASE_URL = Config.getApiBaseUrl();


//const API_BASE_URL = 'http://10.128.156.25:8081/api';

// 定义HTTP请求选项接口
interface HttpRequestOptions {
  method?: http.RequestMethod;
  header?: Record<string, string>;
  body?: string;
}

// AI专栏文章接口返回类型
interface AIArticleResponse {
  content: string;
}

// 评论列表返回类型
interface CommentListResponse {
  comments: CommentItem[];
  totalCount: number;
  currentPage: number;
  pageSize: number;
}

// 回复列表返回类型
interface ReplyListResponse {
  replies: CommentItem[];
  totalCount: number;
  currentPage: number;
  pageSize: number;
}

// 发布评论返回类型
interface PublishCommentResponse {
  commentId: number;
  message: string;
}

// 回复评论返回类型
interface ReplyCommentResponse {
  replyId: number;
  message: string;
}

// 点赞操作返回类型
interface LikeOperationResponse {
  success: boolean;
  message: string;
}

// 删除评论返回类型
interface DeleteCommentResponse {
  success: boolean;
  message: string;
}

// 检查点赞状态返回类型
interface CheckLikeStatusResponse {
  isLiked: boolean;
}

// 回复评论请求体接口
interface ReplyCommentRequestBody {
  aiRoleId: number;
  userId: number;
  content: string;
  rootCommentId: number;
  toCommentId?: number;
}

interface ImageMainColorResponse {
  mainColor: string;
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

      let result: ApiResponse<T>;
      try {
        result = JSON.parse(response.result.toString());
        console.log('🌐 JSON解析成功:', result);
      } catch (e) {
        // 打印原始内容，便于调试
        console.error('🌐 API返回内容不是标准JSON，原始内容如下:');
        console.error(response.result.toString());
        // 直接抛出错误，提示后端返回内容异常
        throw new Error('后端返回内容不是标准JSON，无法解析');
      }

      // 调试模式下的日志
      if (Config.isDebug()) {
        console.log(`🌐 API请求: ${url}`, result);
      }

      return result;
    } catch (error) {
      console.error('🌐 API请求失败:', error);
      if (error instanceof Error) {
        console.error('🌐 error.message:', error.message);
        if (error.stack) {
          console.error('🌐 error.stack:', error.stack);
        }
      } else {
        console.error('🌐 error(非Error类型):', JSON.stringify(error));
      }
      try {
        if (typeof error === 'object' && error !== null) {
          const errObj = error as Record<string, string>;
          Object.keys(errObj).forEach((key) => {
            console.error(`🌐 error[${key}]:`, errObj[key]);
          });
        } else {
          console.error('🌐 error(原始):', error);
        }
      } catch (e) {
        console.error('🌐 打印error属性失败:', e);
      }
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error('未知错误: ' + JSON.stringify(error));
      }
    }
  }

  /**
   * 获取用户信息
   */
  static async getUserInfo(userUID: string): Promise<UserInfo> {
    const response = await ApiService.request<UserInfo>(`${API_BASE_URL}/user/${userUID}`);
    if (response.success) {
      // 处理头像URL - 如果是相对路径，拼接完整URL
      let userInfo = response.data;
      if (userInfo.userAvatar && userInfo.userAvatar.startsWith('/')) {
        const baseUrl = Config.getApiBaseUrl().replace('/api', '');
        userInfo.userAvatar = baseUrl + userInfo.userAvatar;
        console.log('👤 [ApiService] 处理后的头像URL:', userInfo.userAvatar);
      }
      
      // 同步到前端全局状态
      globalUserData.updateUserName(userInfo.userName);
      globalUserData.updateUserUID(userInfo.userUID);
      globalUserData.updateUserAvatar(userInfo.userAvatar);
      if (userInfo.isPrivacyVisible !== globalUserData.isPrivacyVisible) {
        globalUserData.togglePrivacy();
      }
      return userInfo;
    } else {
      throw new Error(response.message || 'Failed to get user info');
    }
  }

  /**
   * 获取用户统计信息
   */
  static async getUserStats(userUID: string): Promise<UserStats> {
    const response = await ApiService.request<UserStats>(`${API_BASE_URL}/user/${userUID}/stats`);
    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get user stats');
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
      const response = await ApiService.request<string>(`${API_BASE_URL}/user/${userUID}/avatar/base64`, {
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
        throw new Error('未知错误: ' + JSON.stringify(error));
      }
    }
  }

  /**
   * 生成新的随机头像
   */
  static async generateNewAvatar(userUID: string): Promise<string> {
    try {
      console.log('🎨 [ApiService] 开始生成新头像，用户UID:', userUID);
      
      const response = await ApiService.request<string>(`${API_BASE_URL}/user/${userUID}/avatar/generate`, {
        method: http.RequestMethod.POST
      });

      if (response.success) {
        console.log('🎨 [ApiService] 头像生成成功，原始URL:', response.data);
        
        // 处理头像URL - 如果是相对路径，拼接完整URL
        let avatarUrl = response.data;
        if (avatarUrl && avatarUrl.startsWith('/')) {
          const baseUrl = Config.getApiBaseUrl().replace('/api', '');
          avatarUrl = baseUrl + avatarUrl;
          console.log('🎨 [ApiService] 拼接后的完整URL:', avatarUrl);
        }
        
        // 同步到前端全局状态
        globalUserData.updateUserAvatar(avatarUrl);
        console.log('🎨 [ApiService] 全局状态已更新，头像URL:', avatarUrl);
        return avatarUrl;
      } else {
        throw new Error(response.message || 'Failed to generate avatar');
      }
    } catch (error) {
      console.error('🎨 [ApiService] 头像生成失败:', error);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error('未知错误: ' + JSON.stringify(error));
      }
    }
  }

  /**
   * 生成预览头像
   */
  static async generatePreviewAvatar(userUID: string): Promise<PreviewAvatarResponse> {
    try {
      console.log('👁️ [ApiService] 开始生成预览头像，用户UID:', userUID);
      
      const response = await ApiService.request<PreviewAvatarResponse>(`${API_BASE_URL}/user/${userUID}/avatar/preview`, {
        method: http.RequestMethod.POST
      });

      if (response.success) {
        console.log('👁️ [ApiService] 预览头像生成成功');
        console.log('👁️ [ApiService] 预览种子:', response.data.previewSeed);
        console.log('👁️ [ApiService] 预览图片长度:', response.data.previewImage.length);
        
        return response.data;
      } else {
        throw new Error(response.message || 'Failed to generate preview avatar');
      }
    } catch (error) {
      console.error('👁️ [ApiService] 预览头像生成失败:', error);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error('未知错误: ' + JSON.stringify(error));
      }
    }
  }

  /**
   * 确认并保存预览头像
   */
  static async confirmPreviewAvatar(userUID: string, previewSeed: number): Promise<string> {
    try {
      console.log('💾 [ApiService] 开始确认预览头像，用户UID:', userUID);
      console.log('💾 [ApiService] 预览种子:', previewSeed);
      
      const response = await ApiService.request<string>(`${API_BASE_URL}/user/${userUID}/avatar/confirm?previewSeed=${previewSeed}`, {
        method: http.RequestMethod.POST
      });

      if (response.success) {
        console.log('💾 [ApiService] 头像确认并保存成功，原始URL:', response.data);
        
        // 处理头像URL - 如果是相对路径，拼接完整URL
        let avatarUrl = response.data;
        if (avatarUrl && avatarUrl.startsWith('/')) {
          const baseUrl = Config.getApiBaseUrl().replace('/api', '');
          avatarUrl = baseUrl + avatarUrl;
          console.log('💾 [ApiService] 拼接后的完整URL:', avatarUrl);
        }
        
        // 同步到前端全局状态
        globalUserData.updateUserAvatar(avatarUrl);
        console.log('💾 [ApiService] 全局状态已更新，头像URL:', avatarUrl);
        return avatarUrl;
      } else {
        throw new Error(response.message || 'Failed to confirm preview avatar');
      }
    } catch (error) {
      console.error('💾 [ApiService] 确认预览头像失败:', error);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error('未知错误: ' + JSON.stringify(error));
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
    const response =
      await ApiService.request<UserInfo>(`${API_BASE_URL}/user/create?userUID=${userUID}&userName=${encodeURIComponent(userName)}`,
        {
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
   * 通过邮箱创建或登录用户
   */
  static async createOrLoginUserByEmail(email: string): Promise<UserInfo> {
    const response = await ApiService.request<UserInfo>(`${API_BASE_URL}/user/createOrLoginByEmail?email=${encodeURIComponent(email)}`, {
      method: http.RequestMethod.POST
    });

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
      throw new Error(response.message || 'Failed to create or login user by email');
    }
  }

  /**
   * 根据邮箱获取用户ID
   */
  static async getUserIdByEmail(email: string): Promise<number> {
    const response = await ApiService.request<number>(`${API_BASE_URL}/user/getUserIdByEmail?email=${encodeURIComponent(email)}`);

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get user ID by email');
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
    try {
      const url =
        `${API_BASE_URL}/ai/chat/${identity}?prompt=${encodeURIComponent(prompt)}&chatId=${encodeURIComponent(chatId)}`;

      console.log('发送AI聊天请求到:', url);
      console.log('用户输入:', prompt);
      console.log('聊天ID:', chatId);
      console.log('身份:', identity);

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

      console.log('AI聊天响应状态码:', response.responseCode);
      console.log('AI聊天响应内容:', response.result.toString());

      if (response.responseCode !== 200) {
        throw new Error(`HTTP error! status: ${response.responseCode}, message: ${response.result.toString()}`);
      }

      // 直接返回响应内容，因为后端返回的是纯文本
      const result = response.result.toString();
      console.log('AI回复:', result);
      return result;
    } catch (error) {
      console.error('AI聊天失败:', error);
      console.error('错误类型:', typeof error);
      console.error('错误详情:', JSON.stringify(error));

      if (error instanceof Error) {
        throw new Error(`AI聊天失败: ${error.message}`);
      } else {
        throw new Error('AI聊天失败: 未知错误');
      }
    }
  }

  /**
   * 特色聊天接口 - 使用自定义描述词
   */
  static async featuredChat(prompt: string, chatId: string, desc: string): Promise<string> {
    try {
      const url =
        `${API_BASE_URL}/ai/featured_chat?prompt=${encodeURIComponent(prompt)}&chatId=${encodeURIComponent(chatId)}&desc=${encodeURIComponent(desc)}`;

      console.log('发送特色聊天请求到:', url);
      console.log('用户输入:', prompt);
      console.log('聊天ID:', chatId);
      console.log('描述词:', desc);

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

      console.log('特色聊天响应状态码:', response.responseCode);
      console.log('特色聊天响应内容:', response.result.toString());

      if (response.responseCode !== 200) {
        throw new Error(`HTTP error! status: ${response.responseCode}, message: ${response.result.toString()}`);
      }

      // 直接返回响应内容，因为后端返回的是纯文本
      const result = response.result.toString();
      console.log('AI回复:', result);
      return result;
    } catch (error) {
      console.error('特色聊天失败:', error);
      console.error('错误类型:', typeof error);
      console.error('错误详情:', JSON.stringify(error));

      if (error instanceof Error) {
        throw new Error(`特色聊天失败: ${error.message}`);
      } else {
        throw new Error('特色聊天失败: 未知错误');
      }
    }
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
      const url =
        `${API_BASE_URL}/ai/generate-figure?userInput=${encodeURIComponent(userInput)}&style=${encodeURIComponent(style)}`;

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
    console.log('🌐 ApiService.createDynamic 开始调用');
    console.log('🌐 userUID:', userUID);
    console.log('🌐 dynamicData:', JSON.stringify(dynamicData));
    console.log('🌐 请求URL:', `${API_BASE_URL}/dynamic/create/${userUID}`);

    try {
      const response = await ApiService.request<Dynamic>(`${API_BASE_URL}/dynamic/create/${userUID}`, {
        method: http.RequestMethod.POST,
        body: JSON.stringify(dynamicData)
      });

      console.log('🌐 API响应:', JSON.stringify(response));

      if (response.success) {
        console.log('✅ 创建动态成功:', JSON.stringify(response.data));
        return response.data;
      } else {
        console.log('❌ 创建动态失败:', response.message);
        throw new Error(response.message || 'Failed to create dynamic');
      }
    } catch (error) {
      console.error('❌ ApiService.createDynamic 异常:', error);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error('未知错误: ' + JSON.stringify(error));
      }
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
   * 获取所有公开动态（分页）
   */
  static async getAllPublicDynamics(page: number = 1, size: number = 10): Promise<Dynamic[]> {
    const response = await ApiService.request<Dynamic[]>(`${API_BASE_URL}/dynamic/public?page=${page}&size=${size}`);
    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get public dynamics');
    }
  }

  /**
   * AI生成专栏文章
   */
  static async generateAIArticle(type: 'deep' | 'tech' | 'industry', prompt: string): Promise<string> {
    let url = '';
    if (type === 'deep') url = `${API_BASE_URL}/ai/article/deep-analysis?prompt=${encodeURIComponent(prompt)}`;
    if (type === 'tech') url = `${API_BASE_URL}/ai/article/tech-enjoy?prompt=${encodeURIComponent(prompt)}`;
    if (type === 'industry') url =
      `${API_BASE_URL}/ai/article/industry-observation?prompt=${encodeURIComponent(prompt)}`;

    // 单独设置5分钟超时，方式同generateFigure
    const httpRequest = http.createHttp();
    const requestOptions: http.HttpRequestOptions = {
      method: http.RequestMethod.GET,
      header: {
        'Content-Type': 'application/json'
      },
      readTimeout: 300000, // 5分钟超时
      connectTimeout: 30000 // 30秒连接超时
    };
    const response = await httpRequest.request(url, requestOptions);
    httpRequest.destroy();
    if (response.responseCode !== 200) {
      throw new Error(`HTTP error! status: ${response.responseCode}`);
    }
    let result: ApiResponse<AIArticleResponse>;
    try {
      result = JSON.parse(response.result.toString());
      console.log('🌐 JSON解析成功:', result);
    } catch (e) {
      console.error('🌐 API返回内容不是标准JSON，原始内容如下:');
      console.error(response.result.toString());
      throw new Error('后端返回内容不是标准JSON，无法解析');
    }
    if (!result.success) {
      throw new Error(result.message || 'AI生成失败');
    }
    return result.data.content;
  }

  /**
   * 获取"动漫"、"可爱"、"科幻"、"写实"四种类型，每种类型9个AI角色
   * 后端返回 ApiResponse<Record<string, AiRole[]>>，前端直接取 data 字段。
   */
  static async getFeatured4Types(): Promise<Record<string, AiRole[]>> {
    const response = await ApiService.request<Record<string, AiRole[]>>(`${API_BASE_URL}/ai/role/featured4types`);
    if (response.success !== false && response.data) {
      return response.data;
    } else if (response.data) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get featured roles');
    }
  }

  /**
   * 获取音乐播放URL
   */
  static async getMusicPlayUrl(musicId: string): Promise<string> {
    const response = await ApiService.request<string>(`${API_BASE_URL}/music/${musicId}/play-url`);
    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '获取音乐播放链接失败');
    }
  }

  /**
   * 获取音乐信息
   */
  static async getMusicInfo(musicId: string): Promise<Record<string, string | number | boolean>> {
    const response =
      await ApiService.request<Record<string, string | number | boolean>>(`${API_BASE_URL}/music/${musicId}/info`);
    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '获取音乐信息失败');
    }
  }

  /**
   * 获取音乐详情
   */
  static async getMusicDetail(musicId: string): Promise<MusicDetailVO> {
    const url = `${API_BASE_URL}/music/${musicId}/detail`;
    try {
      const response = await ApiService.request<MusicDetailVO>(url);
      console.log('获取歌曲详情返回：', response);
      if (!response.success) {
        throw new Error(response.message || '获取歌曲详情失败');
      }
      return response.data;
    } catch (e) {
      console.log('进入catch块，id=', musicId);
      console.error('获取歌曲详情失败，id=', musicId, e);
      throw new Error(e instanceof Error ? e.message : '未知错误');
    }
  }

  /**
   * 测试网络连接
   */
  static async testConnection(): Promise<boolean> {
    try {
      console.log('🔍 测试网络连接...');
      console.log('🔍 目标URL:', `${API_BASE_URL}/user/test`);

      const response = await ApiService.request<string>(`${API_BASE_URL}/user/test`);
      console.log('✅ 网络连接测试成功:', response);
      return true;
    } catch (error) {
      console.error('❌ 网络连接测试失败:', error);
      return false;
    }
  }

  /**
   * 搜索用户
   */
  static async searchUser(userUID: string): Promise<SearchUserResult | null> {
    try {
      console.log('🔍 ApiService.searchUser 开始搜索:', userUID);
      console.log('🔍 API_BASE_URL:', API_BASE_URL);
      const url = `${API_BASE_URL}/user/search/${userUID}`;
      console.log('🔍 请求URL:', url);
      console.log('🔍 开始调用 request 方法...');

      const response = await ApiService.request<SearchUserResult>(url);
      console.log('🔍 API响应:', response);
      console.log('🔍 响应类型:', typeof response);
      console.log('🔍 响应success:', response.success);
      console.log('🔍 响应data:', response.data);
      console.log('🔍 响应data类型:', typeof response.data);

      if (response.success) {
        console.log('✅ 搜索成功，返回数据:', response.data);
        console.log('✅ 数据字段检查:');
        console.log('  - userUID:', response.data?.userUID);
        console.log('  - userName:', response.data?.userName);
        console.log('  - userAvatar:', response.data?.userAvatar);
        console.log('  - level:', response.data?.level, '类型:', typeof response.data?.level);
        console.log('  - gender:', response.data?.gender);
        console.log('  - signature:', response.data?.signature);
        return response.data;
      } else {
        console.log('❌ 搜索失败，API返回错误:', response.message);
        return null; // 用户不存在
      }
    } catch (error) {
      console.error('❌ 搜索用户失败:', error);
      console.error('❌ 错误类型:', typeof error);
      console.error('❌ 错误详情:', JSON.stringify(error));
      if (error instanceof Error) {
        console.error('❌ 错误消息:', error.message);
        console.error('❌ 错误堆栈:', error.stack);
      }
      return null; // 搜索失败时返回null
    }
  }

  /**
   * 创建AI角色
   */
  static async createAiRole(aiRoleData: CreateAiRoleRequest): Promise<AiRole> {
    try {
      console.log('🤖 ApiService.createAiRole 开始创建AI角色:', aiRoleData);
      console.log('🤖 API_BASE_URL:', API_BASE_URL);

      const url = `${API_BASE_URL}/ai/role/create`;
      console.log('🤖 请求URL:', url);

      const requestBody: CreateAiRoleRequest = {
        userId: aiRoleData.userId,
        roleName: aiRoleData.roleName,
        roleDescription: aiRoleData.roleDescription,
        roleType: aiRoleData.roleType,
        roleAuthor: aiRoleData.roleAuthor,
        avatarUrl: aiRoleData.avatarUrl,
        isTemplate: aiRoleData.isTemplate || false
      };

      console.log('🤖 请求体:', JSON.stringify(requestBody));

      const response = await ApiService.request<AiRole>(url, {
        method: http.RequestMethod.POST,
        body: JSON.stringify(requestBody)
      });

      console.log('🤖 API响应:', response);

      if (response.success) {
        console.log('✅ AI角色创建成功，返回数据:', response.data);
        return response.data;
      } else {
        console.log('❌ AI角色创建失败，API返回错误:', response.message);
        throw new Error(response.message || 'Failed to create AI role');
      }
    } catch (error) {
      console.error('❌ 创建AI角色失败:', error);
      console.error('❌ 错误类型:', typeof error);
      console.error('❌ 错误详情:', JSON.stringify(error));

      if (error instanceof Error) {
        console.error('❌ 错误消息:', error.message);
        console.error('❌ 错误堆栈:', error.stack);
        throw error;
      } else {
        throw new Error('创建AI角色失败: 未知错误');
      }
    }
  }

  /**
   * 根据描述词生成AI角色名称
   */
  static async generateRoleName(description: string): Promise<string> {
    try {
      console.log('🎯 ApiService.generateRoleName 开始生成角色名称');
      console.log('🎯 描述词:', description);
      console.log('🎯 API_BASE_URL:', API_BASE_URL);

      const url = `${API_BASE_URL}/ai/role/generate-name`;
      console.log('🎯 请求URL:', url);

      const requestBody: GenerateRoleNameRequest = {
        description: description
      };

      console.log('🎯 请求体:', JSON.stringify(requestBody));

      const response = await ApiService.request<string>(url, {
        method: http.RequestMethod.POST,
        body: JSON.stringify(requestBody)
      });

      console.log('🎯 API响应:', response);

      if (response.success) {
        console.log('✅ 角色名称生成成功，返回数据:', response.data);
        return response.data;
      } else {
        console.log('❌ 角色名称生成失败，API返回错误:', response.message);
        throw new Error(response.message || 'Failed to generate role name');
      }
    } catch (error) {
      console.error('❌ 生成角色名称失败:', error);
      console.error('❌ 错误类型:', typeof error);
      console.error('❌ 错误详情:', JSON.stringify(error));

      if (error instanceof Error) {
        console.error('❌ 错误消息:', error.message);
        console.error('❌ 错误堆栈:', error.stack);
        throw error;
      } else {
        throw new Error('生成角色名称失败: 未知错误');
      }
    }
  }

  /**
   * 创建对话
   */
  static async createConversation(conversationData: CreateConversationRequest): Promise<Conversation> {
    try {
      console.log('💬 ApiService.createConversation 开始创建对话:', conversationData);
      console.log('💬 API_BASE_URL:', API_BASE_URL);

      const url = `${API_BASE_URL}/ai/history/conversation/create`;
      console.log('💬 请求URL:', url);

      const requestBody: CreateConversationRequest = {
        userId: conversationData.userId,
        aiRoleId: conversationData.aiRoleId,
        title: conversationData.title,
        moodTag: conversationData.moodTag
      };

      console.log('💬 请求体:', JSON.stringify(requestBody));

      const response = await ApiService.request<Conversation>(url, {
        method: http.RequestMethod.POST,
        body: JSON.stringify(requestBody)
      });

      console.log('💬 API响应:', response);

      if (response.success) {
        console.log('✅ 对话创建成功，返回数据:', response.data);
        return response.data;
      } else {
        console.log('❌ 对话创建失败，API返回错误:', response.message);
        throw new Error(response.message || 'Failed to create conversation');
      }
    } catch (error) {
      console.error('❌ 创建对话失败:', error);
      console.error('❌ 错误类型:', typeof error);
      console.error('❌ 错误详情:', JSON.stringify(error));

      if (error instanceof Error) {
        console.error('❌ 错误消息:', error.message);
        console.error('❌ 错误堆栈:', error.stack);
        throw error;
      } else {
        throw new Error('创建对话失败: 未知错误');
      }
    }
  }

  /**
   * 根据userId查找全部对话
   */
  static async getConversationsByUserId(userId: number): Promise<Conversation[]> {
    const url = `${API_BASE_URL}/ai/history/conversation/list?userId=${userId}`;
    const response = await ApiService.request<Conversation[]>(url);
    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get conversations');
    }
  }

  /**
   * 分析用户最近十条对话中AI角色类型的偏好
   */
  static async analyzeUserRolePreference(userId: number, limit: number = 10): Promise<UserRolePreferenceAnalysis> {
    try {
      console.log('📊 ApiService.analyzeUserRolePreference 开始分析用户角色偏好');
      console.log('📊 用户ID:', userId);
      console.log('📊 分析数量:', limit);

      // 1. 获取用户的所有对话
      const allConversations = await ApiService.getConversationsByUserId(userId);
      
      if (allConversations.length === 0) {
        console.log('📊 用户没有对话记录');
        return {
          totalConversations: 0,
          roleTypeCounts: [],
          mostPreferredRoleType: '无数据',
          mostPreferredCount: 0,
          analysis: '用户暂无对话记录，无法分析角色偏好'
        };
      }

      // 2. 按最后活跃时间排序，取最近limit条对话
      const recentConversations = allConversations
        .sort((a, b) => new Date(b.lastActive).getTime() - new Date(a.lastActive).getTime())
        .slice(0, limit);

      console.log('📊 最近对话数量:', recentConversations.length);

      // 3. 获取这些对话对应的AI角色信息
      const aiRoleIds = Array.from(new Set(recentConversations.map(c => c.aiRoleId)));
      const aiRoleMap: Record<number, AiRole> = {};
      
      for (const id of aiRoleIds) {
        try {
          aiRoleMap[id] = await ApiService.getAiRoleById(id);
        } catch (e) {
          console.error('📊 获取AI角色信息失败，角色ID:', id, e);
          // 失败则跳过，使用默认角色类型
          aiRoleMap[id] = {
            id: id,
            userId: null,
            roleName: '未知角色',
            roleDescription: '',
            roleType: '未知类型',
            roleAuthor: '',
            viewCount: 0,
            avatarUrl: '',
            isTemplate: false,
            createdAt: ''
          };
        }
      }

      // 4. 统计角色类型
      const roleTypeCount: Record<string, number> = {};
      let totalValidConversations = 0;

      for (const conversation of recentConversations) {
        const aiRole = aiRoleMap[conversation.aiRoleId];
        if (aiRole && aiRole.roleType) {
          const roleType = aiRole.roleType;
          roleTypeCount[roleType] = (roleTypeCount[roleType] || 0) + 1;
          totalValidConversations++;
        }
      }

      // 5. 转换为统计结果格式
      const roleTypeCounts: RoleTypeStatistics[] = [];
      for (const entry of Object.entries(roleTypeCount)) {
        const roleType = entry[0];
        const count = entry[1];
        const percentage = Math.round((count / totalValidConversations) * 100);
        roleTypeCounts.push({
          roleType: roleType,
          count: count,
          percentage: percentage
        });
      }
      // 按数量降序排列
      roleTypeCounts.sort((a, b) => b.count - a.count);

      // 6. 找出最受欢迎的角色类型
      const mostPreferred = roleTypeCounts.length > 0 ? roleTypeCounts[0] : null;

      // 7. 生成分析文本
      let analysis = '';
      if (roleTypeCounts.length === 0) {
        analysis = '用户暂无有效的对话记录';
      } else if (roleTypeCounts.length === 1 && mostPreferred !== null) {
        analysis = `用户专注于与${mostPreferred.roleType}类型的AI角色交流`;
      } else if (mostPreferred !== null) {
        const topType = mostPreferred.roleType;
        const topPercentage = mostPreferred.percentage;
        analysis = `用户最喜欢与${topType}类型的AI角色交流，占比${topPercentage}%。`;
        
        if (roleTypeCounts.length > 1) {
          const secondType = roleTypeCounts[1].roleType;
          const secondPercentage = roleTypeCounts[1].percentage;
          analysis += `其次是${secondType}类型，占比${secondPercentage}%。`;
        }
      }

      const result: UserRolePreferenceAnalysis = {
        totalConversations: totalValidConversations,
        roleTypeCounts,
        mostPreferredRoleType: mostPreferred ? mostPreferred.roleType : '无数据',
        mostPreferredCount: mostPreferred ? mostPreferred.count : 0,
        analysis
      };

      console.log('📊 角色偏好分析完成:', result);
      return result;

    } catch (error) {
      console.error('❌ 分析用户角色偏好失败:', error);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error('分析用户角色偏好失败: 未知错误');
      }
    }
  }

  /**
   * 根据aiRoleId获取AI角色详情
   */
  static async getAiRoleById(aiRoleId: number): Promise<AiRole> {
    const url = `${API_BASE_URL}/ai/role/${aiRoleId}`;
    const response = await ApiService.request<AiRole>(url);
    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get ai role');
    }
  }

  /**
   * 保存消息到数据库
   */
  static async saveMessage(messageData: CreateMessageRequest): Promise<Message> {
    try {
      console.log('💬 ApiService.saveMessage 开始保存消息:', messageData);
      console.log('💬 API_BASE_URL:', API_BASE_URL);

      const url = `${API_BASE_URL}/ai/message/save`;
      console.log('💬 请求URL:', url);

      const requestBody: CreateMessageRequest = {
        conversationId: messageData.conversationId,
        senderType: messageData.senderType,
        content: messageData.content,
        audioUrl: messageData.audioUrl,
        sentimentScore: messageData.sentimentScore,
        topicTag: messageData.topicTag
      };

      console.log('💬 请求体:', JSON.stringify(requestBody));

      const response = await ApiService.request<Message>(url, {
        method: http.RequestMethod.POST,
        body: JSON.stringify(requestBody)
      });

      console.log('💬 API响应:', response);

      if (response.success) {
        console.log('✅ 消息保存成功，返回数据:', response.data);
        return response.data;
      } else {
        console.log('❌ 消息保存失败，API返回错误:', response.message);
        throw new Error(response.message || 'Failed to save message');
      }
    } catch (error) {
      console.error('❌ 保存消息失败:', error);
      console.error('❌ 错误类型:', typeof error);
      console.error('❌ 错误详情:', JSON.stringify(error));

      if (error instanceof Error) {
        console.error('❌ 错误消息:', error.message);
        console.error('❌ 错误堆栈:', error.stack);
        throw error;
      } else {
        throw new Error('保存消息失败: 未知错误');
      }
    }
  }

  /**
   * 根据会话ID获取消息列表
   */
  static async getMessagesByConversationId(conversationId: number): Promise<Message[]> {
    try {
      console.log('💬 ApiService.getMessagesByConversationId 开始获取消息列表');
      console.log('💬 会话ID:', conversationId);
      console.log('💬 API_BASE_URL:', API_BASE_URL);

      const url = `${API_BASE_URL}/ai/message/list?conversationId=${conversationId}`;
      console.log('💬 请求URL:', url);

      const response = await ApiService.request<Message[]>(url);

      console.log('💬 API响应:', response);

      if (response.success) {
        console.log('✅ 获取消息列表成功，返回数据:', response.data);
        return response.data;
      } else {
        console.log('❌ 获取消息列表失败，API返回错误:', response.message);
        throw new Error(response.message || 'Failed to get messages');
      }
    } catch (error) {
      console.error('❌ 获取消息列表失败:', error);
      console.error('❌ 错误类型:', typeof error);
      console.error('❌ 错误详情:', JSON.stringify(error));

      if (error instanceof Error) {
        console.error('❌ 错误消息:', error.message);
        console.error('❌ 错误堆栈:', error.stack);
        throw error;
      } else {
        throw new Error('获取消息列表失败: 未知错误');
      }
    }
  }

  /**
   * 根据用户ID和AI角色ID查找对话
   */
  static async findConversationByUserAndRole(userId: number, aiRoleId: number): Promise<Conversation | null> {
    try {
      console.log('💬 ApiService.findConversationByUserAndRole 开始查找对话');
      console.log('💬 用户ID:', userId);
      console.log('💬 AI角色ID:', aiRoleId);
      console.log('💬 API_BASE_URL:', API_BASE_URL);

      const url = `${API_BASE_URL}/ai/history/conversation/find?userId=${userId}&aiRoleId=${aiRoleId}`;
      console.log('💬 请求URL:', url);

      const response = await ApiService.request<Conversation>(url);

      console.log('💬 API响应:', response);

      if (response.success) {
        console.log('✅ 查找对话成功，返回数据:', response.data);
        return response.data;
      } else {
        console.log('❌ 查找对话失败，API返回错误:', response.message);
        // 如果找不到对话，返回null而不是抛出错误
        if (response.message && (response.message.includes('not found') || response.message.includes('未找到'))) {
          console.log('📝 对话不存在，返回null');
          return null;
        }
        throw new Error(response.message || 'Failed to find conversation');
      }
    } catch (error) {
      console.error('❌ 查找对话失败:', error);
      console.error('❌ 错误类型:', typeof error);
      console.error('❌ 错误详情:', JSON.stringify(error));

      if (error instanceof Error) {
        console.error('❌ 错误消息:', error.message);
        console.error('❌ 错误堆栈:', error.stack);
        throw error;
      } else {
        throw new Error('查找对话失败: 未知错误');
      }
    }
  }

  /**
   * 根据用户ID和AI角色ID查找或创建对话
   */
  static async findOrCreateConversation(userId: number, aiRoleId: number, title?: string): Promise<Conversation> {
    try {
      console.log('💬 ApiService.findOrCreateConversation 开始查找或创建对话');
      console.log('💬 用户ID:', userId);
      console.log('💬 AI角色ID:', aiRoleId);
      console.log('💬 标题:', title);

      // 首先尝试查找现有对话
      const existingConversation = await ApiService.findConversationByUserAndRole(userId, aiRoleId);

      if (existingConversation) {
        console.log('✅ 找到现有对话:', existingConversation);
        return existingConversation;
      }

      console.log('📝 未找到现有对话，开始创建新对话...');

      // 如果没有找到，创建新对话
      const conversationData: CreateConversationRequest = {
        userId: userId,
        aiRoleId: aiRoleId,
        title: title || `与AI角色的对话`,
        moodTag: 'normal'
      };

      const newConversation = await ApiService.createConversation(conversationData);
      console.log('✅ 创建新对话成功:', newConversation);
      return newConversation;

    } catch (error) {
      console.error('❌ 查找或创建对话失败:', error);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error('查找或创建对话失败: 未知错误');
      }
    }
  }

  /**
   * 分析对话情绪并更新情绪标签
   */
  static async analyzeConversationEmotion(conversationId: number): Promise<string> {
    try {
      console.log('💬 ApiService.analyzeConversationEmotion 开始分析对话情绪');
      console.log('💬 会话ID:', conversationId);
      console.log('💬 API_BASE_URL:', API_BASE_URL);

      const url = `${API_BASE_URL}/ai/analyze-emotion?conversationId=${conversationId}`;
      console.log('💬 请求URL:', url);

      const response = await ApiService.request<string>(url, {
        method: http.RequestMethod.POST
      });

      console.log('💬 API响应:', response);

      if (response.success) {
        console.log('✅ 情绪分析成功，返回数据:', response.data);
        return response.data;
      } else {
        console.log('❌ 情绪分析失败，API返回错误:', response.message);
        throw new Error(response.message || 'Failed to analyze emotion');
      }
    } catch (error) {
      console.error('❌ 情绪分析失败:', error);
      console.error('❌ 错误类型:', typeof error);
      console.error('❌ 错误详情:', JSON.stringify(error));

      if (error instanceof Error) {
        console.error('❌ 错误消息:', error.message);
        console.error('❌ 错误堆栈:', error.stack);
        throw error;
      } else {
        throw new Error('情绪分析失败: 未知错误');
      }
    }
  }

  /**
   * 生成回复建议
   */
  static async generateReplySuggestions(conversationId: number): Promise<string[]> {
    try {
      console.log('💬 ApiService.generateReplySuggestions 开始生成回复建议');
      console.log('💬 会话ID:', conversationId);
      console.log('💬 API_BASE_URL:', API_BASE_URL);

      const url = `${API_BASE_URL}/ai/generate-replies?conversationId=${conversationId}`;
      console.log('💬 请求URL:', url);

      const response = await ApiService.request<string[]>(url, {
        method: http.RequestMethod.POST
      });

      console.log('💬 API响应:', response);

      if (response.success) {
        console.log('✅ 回复建议生成成功，返回数据:', response.data);
        return response.data;
      } else {
        console.log('❌ 回复建议生成失败，API返回错误:', response.message);
        throw new Error(response.message || 'Failed to generate reply suggestions');
      }
    } catch (error) {
      console.error('❌ 回复建议生成失败:', error);
      console.error('❌ 错误类型:', typeof error);
      console.error('❌ 错误详情:', JSON.stringify(error));

      if (error instanceof Error) {
        console.error('❌ 错误消息:', error.message);
        console.error('❌ 错误堆栈:', error.stack);
        throw error;
      } else {
        throw new Error('回复建议生成失败: 未知错误');
      }
    }
  }


  // ==================== 评论系统接口 ====================

  /**
   * 获取AI角色的评论列表
   */
  static async getCommentsByAiRoleId(aiRoleId: number, page: number = 1,
    size: number = 10): Promise<CommentListResponse> {
    const response =
      await ApiService.request<CommentListResponse>(`${API_BASE_URL}/comments/ai-role/${aiRoleId}?page=${page}&size=${size}`);

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '获取评论列表失败');
    }
  }

  /**
   * 获取评论的回复列表
   */
  static async getRepliesByRootCommentId(rootCommentId: number, page: number = 1,
    size: number = 10): Promise<ReplyListResponse> {
    const response =
      await ApiService.request<ReplyListResponse>(`${API_BASE_URL}/comments/${rootCommentId}/replies?page=${page}&size=${size}`);

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '获取回复列表失败');
    }
  }

  /**
   * 发布评论
   */
  static async publishComment(aiRoleId: number, userId: number, content: string): Promise<PublishCommentResponse> {
    const response = await ApiService.request<PublishCommentResponse>(`${API_BASE_URL}/comments/publish`, {
      method: http.RequestMethod.POST,
      body: JSON.stringify({
        aiRoleId: aiRoleId,
        userId: userId,
        content: content
      })
    });

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '发布评论失败');
    }
  }

  /**
   * 回复评论
   */
  static async replyComment(aiRoleId: number, userId: number, content: string, rootCommentId: number,
    toCommentId?: number): Promise<ReplyCommentResponse> {
    const requestBody: ReplyCommentRequestBody = {
      aiRoleId: aiRoleId,
      userId: userId,
      content: content,
      rootCommentId: rootCommentId
    };

    if (toCommentId) {
      requestBody.toCommentId = toCommentId;
    }

    const response = await ApiService.request<ReplyCommentResponse>(`${API_BASE_URL}/comments/reply`, {
      method: http.RequestMethod.POST,
      body: JSON.stringify(requestBody)
    });

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '发布回复失败');
    }
  }

  /**
   * 点赞评论
   */
  static async likeComment(commentId: number, userId: number): Promise<LikeOperationResponse> {
    const response =
      await ApiService.request<LikeOperationResponse>(`${API_BASE_URL}/comments/${commentId}/like?userId=${userId}`, {
        method: http.RequestMethod.POST
      });

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '点赞失败');
    }
  }

  /**
   * 取消点赞评论
   */
  static async unlikeComment(commentId: number, userId: number): Promise<LikeOperationResponse> {
    const response =
      await ApiService.request<LikeOperationResponse>(`${API_BASE_URL}/comments/${commentId}/like?userId=${userId}`, {
        method: http.RequestMethod.DELETE
      });

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '取消点赞失败');
    }
  }

  /**
   * 删除评论
   */
  static async deleteComment(commentId: number, userId: number): Promise<DeleteCommentResponse> {
    const response =
      await ApiService.request<DeleteCommentResponse>(`${API_BASE_URL}/comments/${commentId}?userId=${userId}`, {
        method: http.RequestMethod.DELETE
      });

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '删除评论失败');
    }
  }

  /**
   * 检查用户是否已点赞评论
   */
  static async checkUserLikedComment(commentId: number, userId: number): Promise<CheckLikeStatusResponse> {
    const response =
      await ApiService.request<CheckLikeStatusResponse>(`${API_BASE_URL}/comments/${commentId}/liked?userId=${userId}`);

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '检查点赞状态失败');
    }
  }

  /**
   * 根据用户ID获取用户创建的AI角色列表
   */
  static async getUserAiRoles(userId: number): Promise<AiRole[]> {
    try {
      console.log('🤖 ApiService.getUserAiRoles 开始获取用户AI角色列表');
      console.log('🤖 用户ID:', userId);
      console.log('🤖 API_BASE_URL:', API_BASE_URL);

      const url = `${API_BASE_URL}/ai/role/user/${userId}`;
      console.log('🤖 请求URL:', url);

      const response = await ApiService.request<AiRole[]>(url);

      console.log('🤖 API响应:', response);

      if (response.success) {
        console.log('✅ 获取用户AI角色列表成功，返回数据:', response.data);
        return response.data;
      } else {
        console.log('❌ 获取用户AI角色列表失败，API返回错误:', response.message);
        throw new Error(response.message || 'Failed to get user AI roles');
      }
    } catch (error) {
      console.error('❌ 获取用户AI角色列表失败:', error);
      console.error('❌ 错误类型:', typeof error);
      console.error('❌ 错误详情:', JSON.stringify(error));

      if (error instanceof Error) {
        console.error('❌ 错误消息:', error.message);
        console.error('❌ 错误堆栈:', error.stack);
        throw error;
      } else {
        throw new Error('获取用户AI角色列表失败: 未知错误');
      }
    }
  }

  /**
   * 更具UID获取用户ID
   */
  static async getUserIdByUID(uid: string): Promise<number> {
    const response = await ApiService.request<number>(`${API_BASE_URL}/user/findIDByUID?uid=${encodeURIComponent(uid)}`);
    if (response && response.success) {
      return response.data;
    } else {
      throw new Error(response?.message || '获取用户ID失败');
    }
  }
}

