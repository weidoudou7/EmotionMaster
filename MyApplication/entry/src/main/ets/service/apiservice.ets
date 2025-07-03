import { globalUserData } from '../models/userdata';
import { Config } from '../common/config';
import { UserInfo, UpdateUserRequest, ApiResponse, Dynamic, CreateDynamicRequest, UserStats, MusicDetailVO, SearchUserResult, CreateAiRoleRequest, GenerateRoleNameRequest, CreateConversationRequest, Conversation,CommentItem } from '../common/types';
import {  AiRole } from '../common/types';
import http from '@ohos.net.http';


// API基础配置 - 从配置文件获取
const API_BASE_URL = Config.getApiBaseUrl();
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
      } else if (typeof error === 'string') {
        throw new Error(error);
      } else {
        throw new Error('Unknown error: ' + JSON.stringify(error));
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
    try {
      const url = `${API_BASE_URL}/ai/chat/${identity}?prompt=${encodeURIComponent(prompt)}&chatId=${encodeURIComponent(chatId)}`;
      
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
      const url = `${API_BASE_URL}/ai/featured_chat?prompt=${encodeURIComponent(prompt)}&chatId=${encodeURIComponent(chatId)}&desc=${encodeURIComponent(desc)}`;
      
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

  /**
   * AI生成专栏文章
   */
  static async generateAIArticle(type: 'deep' | 'tech' | 'industry', prompt: string): Promise<string> {
    let url = '';
    if (type === 'deep') url = `${API_BASE_URL}/ai/article/deep-analysis?prompt=${encodeURIComponent(prompt)}`;
    if (type === 'tech') url = `${API_BASE_URL}/ai/article/tech-enjoy?prompt=${encodeURIComponent(prompt)}`;
    if (type === 'industry') url = `${API_BASE_URL}/ai/article/industry-observation?prompt=${encodeURIComponent(prompt)}`;
    const response = await ApiService.request<AIArticleResponse>(url, { method: http.RequestMethod.GET });
    return response.data.content;
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
    const response = await ApiService.request<Record<string, string | number | boolean>>(`${API_BASE_URL}/music/${musicId}/info`);
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
  static async getConversationsByUserId(userId: number = 372): Promise<Conversation[]> {
    const url = `${API_BASE_URL}/ai/history/conversation/list?userId=${userId}`;
    const response = await ApiService.request<Conversation[]>(url);
    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || 'Failed to get conversations');
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

  // ==================== 评论系统接口 ====================

  /**
   * 获取AI角色的评论列表
   */
  static async getCommentsByAiRoleId(aiRoleId: number, page: number = 1, size: number = 10): Promise<CommentListResponse> {
    const response = await ApiService.request<CommentListResponse>(`${API_BASE_URL}/comments/ai-role/${aiRoleId}?page=${page}&size=${size}`);

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '获取评论列表失败');
    }
  }

  /**
   * 获取评论的回复列表
   */
  static async getRepliesByRootCommentId(rootCommentId: number, page: number = 1, size: number = 10): Promise<ReplyListResponse> {
    const response = await ApiService.request<ReplyListResponse>(`${API_BASE_URL}/comments/${rootCommentId}/replies?page=${page}&size=${size}`);

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
  static async replyComment(aiRoleId: number, userId: number, content: string, rootCommentId: number, toCommentId?: number): Promise<ReplyCommentResponse> {
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
    const response = await ApiService.request<LikeOperationResponse>(`${API_BASE_URL}/comments/${commentId}/like?userId=${userId}`, {
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
    const response = await ApiService.request<LikeOperationResponse>(`${API_BASE_URL}/comments/${commentId}/like?userId=${userId}`, {
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
    const response = await ApiService.request<DeleteCommentResponse>(`${API_BASE_URL}/comments/${commentId}?userId=${userId}`, {
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
    const response = await ApiService.request<CheckLikeStatusResponse>(`${API_BASE_URL}/comments/${commentId}/liked?userId=${userId}`);

    if (response.success) {
      return response.data;
    } else {
      throw new Error(response.message || '检查点赞状态失败');
    }
  }
}




