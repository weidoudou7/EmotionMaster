// types.ets
// 共享类型定义

// 用户信息接口
export interface UserInfo {
  userName: string;
  userUID: string;
  userAvatar: string;
  isPrivacyVisible: boolean;
  level: string;
  gender: string;
  signature: string;
  registerTime: string;
  updateTime: string;
}

// 用户统计信息接口
export interface UserStats {
  userUID: string;
  dynamicCount: number;
  followingCount: number;
  followerCount: number;
  friendCount: number;
  totalLikes: number;
  totalViews: number;
}

// 更新用户请求接口
export interface UpdateUserRequest {
  userName?: string;
  userAvatar?: string;
  isPrivacyVisible?: boolean;
  gender?: string;
  signature?: string;
}

// 动态接口
export interface Dynamic {
  id: string;
  userUID: string;
  content: string;
  images?: string[];
  likeCount: number;
  commentCount: number;
  isPrivate: boolean;
  createTime: string;
  updateTime: string;
}

// 创建动态请求接口
export interface CreateDynamicRequest {
  content: string;
  images?: string[];
  isPrivate?: boolean;
}

// API响应接口
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  timestamp: number;
}

export interface MusicDetailVO {
  musicId: string;
  name: string;
  artist: string;
  duration: string; // mm:ss
  coverUrl: string;
}

// 搜索结果用户信息接口
export interface SearchUserResult {
  userUID: string;
  userName: string;
  userAvatar: string;
  isPrivacyVisible: boolean;
  level: number;
  gender: string;
  signature: string;
  registerTime: string;
  updateTime: string;
}

// AI角色接口
export interface AiRole {
  id: number | null;
  userId: number | null;
  roleName: string;
  roleDescription: string;
  roleType: string;
  roleAuthor: string;
  viewCount: number;
  avatarUrl: string;
  isTemplate: boolean;
  createdAt: string; // ISO字符串
}

// 创建AI角色请求接口
export interface CreateAiRoleRequest {
  roleName: string;
  roleDescription: string;
  roleType: string;
  roleAuthor: string;
  avatarUrl: string;
  isTemplate?: boolean;
}

// 生成角色名称请求接口
export interface GenerateRoleNameRequest {
  description: string;
}

// 创建对话请求接口
export interface CreateConversationRequest {
  userId: number;
  aiRoleId: number;
  title: string;
  moodTag?: string;
}

// 对话接口
export interface Conversation {
  id: number;
  userId: number;
  aiRoleId: number;
  turns: number;
  title: string;
  startTime: string;
  lastActive: string;
  moodTag: string;
}

// 消息接口
export interface Message {
  id?: number;
  conversationId: number;
  senderType: string; // 'user' | 'ai'
  content: string;
  audioUrl?: string;
  sentimentScore?: number;
  topicTag?: string;
  timestamp: string;
}

// 创建消息请求接口
export interface CreateMessageRequest {
  conversationId: number;
  senderType: string;
  content: string;
  audioUrl?: string;
  sentimentScore?: number;
  topicTag?: string;
}