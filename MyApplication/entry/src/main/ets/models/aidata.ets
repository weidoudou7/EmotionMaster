// aidata.ets - 动态相关类型定义

export interface Dynamic {
  id: string; // 动态ID
  userUID: string; // 用户UID
  userName?: string; // 用户名（可选）
  userAvatar?: string; // 用户头像（可选）
  content: string; // 动态内容
  images?: string[]; // 图片列表（可选）
  topicTags?: string[]; // 话题标签（可选）
  visibility?: string; // 可见性（可选）
  createTime: string; // 创建时间
  updateTime: string; // 更新时间
  likeCount: number; // 点赞数
  commentCount: number; // 评论数
  isPrivate: boolean; // 是否私密
}
