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

// 更新用户请求接口
export interface UpdateUserRequest {
  userName?: string;
  userAvatar?: string;
  isPrivacyVisible?: boolean;
  gender?: string;
  signature?: string;
}

// API响应接口
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  timestamp: number;
} 