//yourpage.ets
// 导入页面路由模块
import { BusinessError } from '@kit.BasicServicesKit';
import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { UserInfo, UserStats, Dynamic } from '../common/types';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import { Config } from '../common/config';

@Entry
@Component
export struct YourPage {
  @State yourname: string = globalUserData.userName; //用户名称
  @State UID: string = globalUserData.userUID; //用户UID
  @State ooo: boolean = globalUserData.isPrivacyVisible; //用户隐私
  @State message: string = 'Image';
  @State avatarScale: number = 1.0; // 头像缩放动画
  @State isLoading: boolean = false; // 加载状态
  @State userInfo: UserInfo | null = null; // 用户信息
  @State userStats: UserStats | null = null; // 用户统计信息
  @State selectedTab: string = 'dynamic' // 当前选中的标签页：dynamic 或 attic
  @State selectedAtticTab: string = '智能体' // 当前选中的阁楼标签页
  @State cardScale: number = 1.0; // 卡片缩放动画
  @State latestDynamic: Dynamic | null = null; // 最新动态

  // 页面生命周期
  aboutToAppear() {
    // 使用全局数据快速初始化，避免等待API
    this.yourname = globalUserData.userName;
    this.UID = globalUserData.userUID;
    this.ooo = globalUserData.isPrivacyVisible;
    
    // 异步加载详细信息，不阻塞页面显示
    this.loadUserInfoAsync();
    this.loadUserStatsAsync();
    this.loadLatestDynamicAsync();
  }

  // 异步加载用户信息（不阻塞页面显示）
  async loadUserInfoAsync() {
    try {
      const userInfo = await ApiService.getUserInfo(this.UID);
      this.userInfo = userInfo;
      this.yourname = userInfo.userName;
      this.UID = userInfo.userUID;
      this.ooo = userInfo.isPrivacyVisible;
      
      // 处理头像URL拼接
      if (userInfo.userAvatar && userInfo.userAvatar.startsWith('/')) {
        const apiBaseUrl = Config.getApiBaseUrl();
        const serverBaseUrl = apiBaseUrl.replace('/api', ''); // 移除API路径
        
        // 检查并修正错误的路径
        let correctedAvatarUrl = userInfo.userAvatar;
        if (userInfo.userAvatar.startsWith('/images/')) {
          console.log('👤 [YourPage] 检测到错误的/images/路径，修正为/avatars/');
          correctedAvatarUrl = userInfo.userAvatar.replace('/images/', '/avatars/');
        }
        
        const fullAvatarUrl = serverBaseUrl + correctedAvatarUrl;
        console.log('👤 [YourPage] 拼接后的完整头像URL:', fullAvatarUrl);
        this.userInfo.userAvatar = fullAvatarUrl;
      }
    } catch (error) {
      console.error('加载用户信息失败:', error);
      // 不显示错误提示，避免影响用户体验
    }
  }

  // 异步加载用户统计信息（不阻塞页面显示）
  async loadUserStatsAsync() {
    try {
      const userStats = await ApiService.getUserStats(this.UID);
      this.userStats = userStats;
    } catch (error) {
      console.error('加载用户统计信息失败:', error);
      // 不显示错误提示，因为统计信息不是核心功能
    }
  }

  // 异步加载最新动态（不阻塞页面显示）
  async loadLatestDynamicAsync() {
    try {
      const context = getContext(this);
      const preferencesHelper = await preferences.getPreferences(context, 'userData');
      const latestDynamicStr = await preferencesHelper.get('latestDynamic', '') as string;
      
      if (latestDynamicStr) {
        this.latestDynamic = JSON.parse(latestDynamicStr);
      }
    } catch (error) {
      console.error('加载最新动态失败:', error);
      // 不显示错误提示，因为动态信息不是核心功能
    }
  }

  // 格式化时间
  formatTime(timeString: string): string {
    const date = new Date(timeString);
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

  // 个人资料详情切换页面调出的构建函数
  @Builder
  build() {
    Stack() {
      // 渐变背景
      Column() {
        Blank().width('100%').height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['#1a1a2e', 0.0], ['#16213e', 0.3], ['#0f3460', 0.7], ['#533483', 1.0]]
          })
      }
      .width('100%')
      .height('100%')
      
      // 装饰性背景元素
      Column() {
        // 顶部装饰元素
        Row() {
          Image($r('app.media.deroration_1'))
            .width(200)
            .height(200)
            .opacity(0.1)
            .position({ x: -100, y: -50 })
          Image($r('app.media.deroration_2'))
            .width(150)
            .height(150)
            .opacity(0.08)
            .position({ x: 300, y: -30 })
        }
        .width('100%')
        .height(60)
        
        Blank().layoutWeight(1)
        
        // 底部装饰元素
        Row() {
          Image($r('app.media.deroration_3'))
            .width(180)
            .height(180)
            .opacity(0.08)
            .position({ x: -80, y: 20 })
          Image($r('app.media.deroration_4'))
            .width(120)
            .height(120)
            .opacity(0.1)
            .position({ x: 320, y: 40 })
        }
        .width('100%')
        .height(80)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1)
      
      // 主体内容
      Scroll() {
        Column() {
          // 上半部分：个人信息卡片
          Column() {
            // 1. 头像+名称+UID 卡片区域（包含右侧按钮）
            Row() {
              // 左侧：头像+名称+UID 卡片
              Stack() {
                // 卡片
                Row() {
                  // 头像
                  Image(this.userInfo?.userAvatar ? this.userInfo.userAvatar : $r("app.media.image"))
                    .width(80)
                    .height(80)
                    .borderRadius(40)
                    .margin({ top: 2, right: 20 })
                    .backgroundColor('rgba(255,255,255,0.1)')
                    .border({ width: 2, color: 'rgba(255,255,255,0.3)' })
                    .scale({ x: this.avatarScale, y: this.avatarScale })
                    .animation({
                      duration: 120,
                      curve: Curve.EaseInOut
                    })
                    .onClick(() => {
                      this.avatarScale = 0.92;
                      setTimeout(() => {
                        this.avatarScale = 1.0;
                        let uiContext: UIContext = this.getUIContext();
                        let router = uiContext.getRouter();
                        router.pushUrl({ url: 'pages/infopage' });
                      }, 120);
                    })
                  // 名称和UID
                  Column() {
                    Text(this.yourname)
                      .fontSize(24)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#fff')
                      .margin({ bottom: 2 })
                      .textAlign(TextAlign.Start)
                    Text(`UID: ${this.UID}`)
                      .fontSize(13)
                      .fontColor('rgba(255,255,255,0.6)')
                      .margin({ bottom: 4 })
                      .textAlign(TextAlign.Start)
                    Text(`性别: ${this.userInfo?.gender || '未设置'}`)
                      .fontSize(13)
                      .fontColor('rgba(255,255,255,0.6)')
                      .textAlign(TextAlign.Start)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .width('70%')
                }
                .width('100%')
                .scale({ x: this.cardScale, y: this.cardScale })
                .animation({
                  duration: 200,
                  curve: Curve.EaseInOut
                })
                .onClick(() => {
                  this.cardScale = 0.98;
                  setTimeout(() => {
                    this.cardScale = 1.0;
                  }, 200);
                })
              }
              .width('70%')
              .padding({ left: 16 })
              
              // 右侧小卡片
              Column() {
                // 设置按钮
                Button() {
                  Image($r('app.media.setting'))
                    .width(28)
                    .height(28)
                    .fillColor('#fff')
                }
                .width(48)
                .height(23)
                .backgroundColor('rgba(128,128,128,0)')
                .borderRadius(24)
                .margin({ bottom: 4 })
                .onClick(() => {
                  let uiContext: UIContext = this.getUIContext();
                  let router = uiContext.getRouter();
                  router.pushUrl({ url: 'pages/infopage' });
                })
                
                // 动态按钮
                Button() {
                  Image($r('app.media.dynamic'))
                    .width(28)
                    .height(28)
                    .fillColor('#fff')
                }
                .width(48)
                .height(48)
                .backgroundColor('rgba(128,128,128,0)')
                .borderRadius(24)
                .margin({ bottom: 4 })
                .onClick(() => {
                  let uiContext: UIContext = this.getUIContext();
                  let router = uiContext.getRouter();
                  router.pushUrl({ url: 'pages/DynamicList' });
                })
              }
              .width('20%')
              .height('100%')
              .justifyContent(FlexAlign.End)
              .alignItems(HorizontalAlign.Center)
            }
            .width('90%')
            .height(100)
            .margin({ top: 12, bottom: 2 })
            
            // 2. 个性签名和社交信息
            Row() {
              // 左侧：个性签名
              Column() {
                // 个性签名
                Column() {
                  Text('个性签名')
                    .fontSize(15)
                    .fontColor('#fff')
                    .margin({ bottom: 8 })
                  Text(this.userInfo?.signature || '这个人很懒，什么都没留下~')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.8)')
                    .textAlign(TextAlign.Start)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ bottom: 4 })
                
                // 社交信息按钮
                Row() {
                  // 查找按钮放在最前面
                  Button('查找')
                    .width(80)
                    .height(28)
                    .fontSize(10)
                    .backgroundColor('rgba(0,128,255,0)')
                    .fontColor('#fff')
                    .borderRadius(14)
                    .margin({ right: 8 })
                    .onClick(() => {
                      let uiContext: UIContext = this.getUIContext();
                      let router = uiContext.getRouter();
                      router.pushUrl({ url: 'pages/searchpage' });
                    })
                  
                  ForEach([
                    `关注:${this.userStats?.followingCount || 0}`,
                    `粉丝:${this.userStats?.followerCount || 0}`,
                    `好友:${this.userStats?.friendCount || 0}`
                  ], (label: string, index: number) => {
                    Button(label)
                      .width(62)
                      .height(28)
                      .fontSize(10)
                      .backgroundColor('rgba(128,128,128,0)')
                      .fontColor('#fff')
                      .borderRadius(14)
                      .margin({ right: 6 })
                      .onClick(() => {
                        promptAction.showToast({ message: '好友功能正在开发中' });
                      })
                  })
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
              }
              .width('70%')
              .padding({ left: 16 })
              
              // 右侧空白区域，保持与头像卡片布局一致
              Blank()
                .width('20%')
            }
            .width('90%')
            .margin({ bottom: 2 })
            
            // 3. 底部两个按钮
            Row() {
              // 左侧：按钮区域
              Row() {
                Column() {
                  Button('我的阁楼')
                    .fontSize(15)
                    .backgroundColor('rgba(128,128,128,0)')
                    .fontColor('#fff')
                    .borderRadius(20)
                    .onClick(() => {
                      this.selectedTab = 'attic';
                    })
                  if (this.selectedTab === 'attic') {
                    Divider()
                      .width(80)
                      .height(2)
                      .color('#fff')
                      .margin({ top: 2 })
                  }
                }
                .margin({ right: 12 })
                
                Column() {
                  Button('我的动态')
                    .fontSize(15)
                    .backgroundColor('rgba(128,128,128,0)')
                    .fontColor('#fff')
                    .borderRadius(20)
                    .onClick(() => {
                      this.selectedTab = 'dynamic';
                    })
                  if (this.selectedTab === 'dynamic') {
                    Divider()
                      .width(80)
                      .height(2)
                      .color('#fff')
                      .margin({ top: 2 })
                  }
                }
              }
              .width('70%')
              .padding({ left: 16 })
              .justifyContent(FlexAlign.Start)
              
              // 右侧空白区域
              Blank()
                .width('20%')
            }
            .width('90%')
            .margin({ bottom: 2 })
            
            // 4. 阁楼内容显示
            Column() {
              if (this.selectedTab === 'attic') {
                // 阁楼五个标签页导航栏（支持滑动）
                Scroll() {
                  Row() {
                    ForEach(["智能体", "故事", "时刻", "群聊", "记忆簿"], (tab: string, index: number) => {
                      Column() {
                        Button(tab)
                          .fontSize(12)
                          .backgroundColor('rgba(128,128,128,0)')
                          .fontColor('#fff')
                          .borderRadius(12)
                          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                          .onClick(() => {
                            this.selectedAtticTab = tab;
                          })
                        if (this.selectedAtticTab === tab) {
                          Divider()
                            .width(40)
                            .height(2)
                            .color('#fff')
                            .margin({ top: 2 })
                        }
                      }
                      .margin({ right: 12 })
                    })
                  }
                  .width('100%')
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
                .margin({ bottom: 8 })
                
                // 阁楼内容显示区域
                Column() {
                  Text('没有可用的内容')
                    .fontSize(16)
                    .fontColor('rgba(255,255,255,0.5)')
                    .textAlign(TextAlign.Center)
                }
                .width('100%')
                .height(120)
                .backgroundColor('rgba(255,255,255,0.08)')
                .borderRadius(16)
                .justifyContent(FlexAlign.Center)
              } else if (this.selectedTab === 'dynamic') {
                // 动态预览内容
                Column() {
                  Text('我的动态')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#fff')
                    .margin({ bottom: 16 })
                  
                  // 最近一条动态预览
                  if (this.latestDynamic) {
                    Column() {
                      Text(this.latestDynamic.content.length > 50 ? 
                        this.latestDynamic.content.substring(0, 50) + '...' : 
                        this.latestDynamic.content)
                        .fontSize(14)
                        .fontColor('rgba(255,255,255,0.8)')
                        .textAlign(TextAlign.Start)
                        .margin({ bottom: 8 })
                      Text(this.formatTime(this.latestDynamic.createTime))
                        .fontSize(12)
                        .fontColor('rgba(255,255,255,0.5)')
                        .textAlign(TextAlign.Start)
                    }
                    .width('100%')
                    .height(120)
                    .backgroundColor('rgba(255,255,255,0.08)')
                    .borderRadius(16)
                    .padding(16)
                    .justifyContent(FlexAlign.Start)
                    .onClick(() => {
                      let uiContext: UIContext = this.getUIContext();
                      let router = uiContext.getRouter();
                      router.pushUrl({ url: 'pages/DynamicList' });
                    })
                  } else {
                    Column() {
                      Text('还没有发布过动态')
                        .fontSize(14)
                        .fontColor('rgba(255,255,255,0.6)')
                        .textAlign(TextAlign.Center)
                      Text('点击发布第一条动态吧')
                        .fontSize(12)
                        .fontColor('rgba(255,255,255,0.4)')
                        .textAlign(TextAlign.Center)
                        .margin({ top: 8 })
                    }
                    .width('100%')
                    .height(120)
                    .backgroundColor('rgba(255,255,255,0.08)')
                    .borderRadius(16)
                    .padding(16)
                    .justifyContent(FlexAlign.Center)
                    .onClick(() => {
                      let uiContext: UIContext = this.getUIContext();
                      let router = uiContext.getRouter();
                      router.pushUrl({ url: 'pages/DynamicList' });
                    })
                  }
                }
                .width('100%')
              }
            }
            .width('90%')
            .height('50%')
            .margin({ bottom: 4 })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ top: 0 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .zIndex(2)
    }
  }
} 