// userdata.ets
// 用户数据模型

import { UserInfo } from '../common/types';

export class UserData {
  userName: string = '用户';
  userUID: string = '100000000';
  userAvatar: string = '';
  isPrivacyVisible: boolean = false;

  constructor(userName?: string, userUID?: string, userAvatar?: string, isPrivacyVisible?: boolean) {
    if (userName) this.userName = userName;
    if (userUID) this.userUID = userUID;
    if (userAvatar) this.userAvatar = userAvatar;
    if (isPrivacyVisible !== undefined) this.isPrivacyVisible = isPrivacyVisible;
  }

  // 更新用户名称
  updateUserName(newName: string): void {
    this.userName = newName;
  }

  // 更新用户UID
  updateUserUID(newUID: string): void {
    this.userUID = newUID;
  }

  // 更新用户头像
  updateUserAvatar(newAvatar: string): void {
    this.userAvatar = newAvatar;
  }

  // 切换隐私可见性
  togglePrivacy(): void {
    this.isPrivacyVisible = !this.isPrivacyVisible;
  }

  // 获取用户信息
  getUserInfo(): UserInfo {
    return {
      userName: this.userName,
      userUID: this.userUID,
      userAvatar: this.userAvatar,
      isPrivacyVisible: this.isPrivacyVisible,
      level: '1',
      gender: '保密',
      signature: '这个人很懒，什么都没有留下',
      registerTime: new Date().toISOString(),
      updateTime: new Date().toISOString()
    };
  }
}

// 全局用户数据实例
export const globalUserData = new UserData();
