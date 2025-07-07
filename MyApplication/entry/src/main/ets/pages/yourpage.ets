//yourpage.ets
// 导入页面路由模块
import { BusinessError } from '@kit.BasicServicesKit';
import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { UserInfo, UserStats, Dynamic } from '../common/types';
import { Config } from '../common/config';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';

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
  @State lastClickTime: number = 0; // 上次点击时间，用于双击检测
  @State userAvatar: Resource | string = $r("app.media.image"); // 用户头像
  @State showAvatarViewer: boolean = false; // 显示头像查看器
  @State lastAtticClickTime: number = 0; // 阁楼标签上次点击
  // 银河系动画状态
  @State arcRotation: number = 0 // 圆弧旋转角度
  @State starTwinkle: number = 0 // 星星闪烁效果
  @State glowOpacity: number = 0.5 // 发光效果透明度
  @State textOpacity: number = 0.8 // 文字透明度
  @State nebulaOpacity: number = 0.3 // 星云透明度

  // 页面生命周期
  aboutToAppear() {
    // 使用全局数据快速初始化，避免等待API
    this.yourname = globalUserData.userName;
    this.UID = globalUserData.userUID;
    this.ooo = globalUserData.isPrivacyVisible;
    
    // 启动银河系动画
    this.startGalaxyAnimations();
    
    // 异步加载详细信息，不阻塞页面显示
    this.loadUserInfoAsync();
    this.loadUserStatsAsync();
    this.loadLatestDynamicAsync();
  }

  // 页面显示时刷新用户信息
  onPageShow() {
    // 刷新用户信息，确保头像是最新的
    this.loadUserInfoAsync();
  }

  // 银河系动画
  private startGalaxyAnimations() {
    // 圆弧旋转动画
    setInterval(() => {
      this.arcRotation += 1.5
    }, 50)
    
    // 星星闪烁动画
    setInterval(() => {
      this.starTwinkle += 0.1
    }, 100)
    
    // 发光效果动画
    setInterval(() => {
      this.glowOpacity = this.glowOpacity === 0.5 ? 0.8 : 0.5
    }, 1200)
    
    // 文字透明度动画
    setInterval(() => {
      this.textOpacity = this.textOpacity === 0.8 ? 1.0 : 0.8
    }, 1800)
    
    // 星云透明度动画
    setInterval(() => {
      this.nebulaOpacity = this.nebulaOpacity === 0.3 ? 0.6 : 0.3
    }, 3000)
  }

  // 异步加载用户信息（不阻塞页面显示）
  async loadUserInfoAsync() {
    try {
      console.log('👤 [yourpage] 开始加载用户信息，用户UID:', this.UID);
      
      const userInfo = await ApiService.getUserInfo(this.UID);
      this.userInfo = userInfo;
      this.yourname = userInfo.userName;
      this.UID = userInfo.userUID;
      this.ooo = userInfo.isPrivacyVisible;

      // 更新头像显示
      await this.updateAvatarDisplay(userInfo.userAvatar);
      
      console.log('👤 [yourpage] 用户信息加载完成');
    } catch (error) {
      console.error('👤 [yourpage] 加载用户信息失败:', error);
      // 不显示错误提示，避免影响用户体验
    }
  }

  // 更新头像显示
  async updateAvatarDisplay(avatarUrl: string | undefined) {
    console.log('🖼️ [yourpage] 开始更新头像显示');
    console.log('🖼️ [yourpage] 原始头像URL:', avatarUrl);
    
    if (avatarUrl && avatarUrl !== '/avatars/default.png' && avatarUrl !== '') {
      // 如果有后端头像，使用后端头像
      let processedAvatarUrl = avatarUrl;
      
      // 处理头像URL - 如果是相对路径，拼接完整URL
      if (avatarUrl.startsWith('/')) {
        const baseUrl = Config.getApiBaseUrl().replace('/api', '');
        processedAvatarUrl = baseUrl + avatarUrl;
        console.log('🖼️ [yourpage] 处理后的头像URL:', processedAvatarUrl);
      }
      
      this.userAvatar = processedAvatarUrl;
      console.log('🖼️ [yourpage] 头像更新成功');
    } else {
      // 使用默认头像
      this.userAvatar = $r("app.media.image");
      console.log('🖼️ [yourpage] 使用默认头像');
    }
  }

  // 获取头像URL（用于显示）
  getAvatarUrl(): Resource | string {
    return this.userAvatar;
  }

  // 显示头像查看器
  showAvatarViewerDialog() {
    this.showAvatarViewer = true;
  }

  // 关闭头像查看器
  closeAvatarViewer() {
    this.showAvatarViewer = false;
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
      // 深色渐变背景 - 改为纯黑色主题
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#000000', 0.0], ['#0a0a0a', 0.5], ['#1a1a1a', 1.0]]
        })
      
      // 旋转的圆弧背景 - 改为黑色系装饰
      Stack() {
        // 多个同心圆弧轨道
        ForEach([0, 1, 2, 3], (index: number) => {
          Stack() {
            // 圆弧轨道 - 改为深灰色
            Column()
              .width(250 + index * 60)
              .height(250 + index * 60)
              .borderRadius((250 + index * 60) / 2)
              .border({ width: 1, color: `rgba(64, 64, 64, ${0.3 - index * 0.05})` })
              .position({ x: '50%', y: '50%' })
              .translate({ x: -(250 + index * 60) / 2, y: -(250 + index * 60) / 2 })
            
            // 旋转的圆弧点 - 改为白色系
            Column()
              .width(6)
              .height(6)
              .backgroundColor(`rgba(255, 255, 255, ${0.6 - index * 0.1})`)
              .borderRadius(3)
              .position({ x: '50%', y: '50%' })
              .translate({ 
                x: -3 + Math.cos((this.arcRotation + index * 90) * Math.PI / 180) * (125 + index * 30),
                y: -3 + Math.sin((this.arcRotation + index * 90) * Math.PI / 180) * (125 + index * 30)
              })
          }
        })
        
        // 外圈装饰点 - 改为银色系
        ForEach([0, 1, 2, 3, 4, 5], (index: number) => {
          Column()
            .width(6)
            .height(6)
            .backgroundColor(`rgba(192, 192, 192, ${0.4 - index * 0.05})`)
            .borderRadius(3)
            .position({ x: '50%', y: '50%' })
            .translate({ 
              x: -3 + Math.cos((this.arcRotation * 0.5 + index * 60) * Math.PI / 180) * 120,
              y: -3 + Math.sin((this.arcRotation * 0.5 + index * 60) * Math.PI / 180) * 120
            })
        })
      }
      .width('100%')
      .height('100%')
      
      // 主体内容
      Scroll() {
        Column() {
          // 上半部分：个人信息卡片
          Column() {
            // 1. 头像+名称+UID 卡片区域（包含右侧按钮）
            Row() {
              // 左侧：头像+名称+UID 卡片
              Stack() {
                // 卡片背景发光效果
                Column()
                  .width('100%')
                  .height('auto')
                  .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
                  .borderRadius(20)
                  .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
                
                Row() {
                  // 头像 - 改为预览器样式显示
                  Stack() {
                    // 头像图片 - 大尺寸显示
                    Image(this.getAvatarUrl())
                      .width(120)
                      .height(120)
                      .borderRadius(60)
                      .backgroundColor('rgba(255,255,255,0.1)')
                      .border({ width: 3, color: 'rgba(255,255,255,0.3)' })
                      .scale({ x: this.avatarScale, y: this.avatarScale })
                      .animation({
                        duration: 120,
                        curve: Curve.EaseInOut
                      })
                      .objectFit(ImageFit.Cover)
                      .onClick(() => {
                        this.avatarScale = 0.92;
                        setTimeout(() => {
                          this.avatarScale = 1.0;
                          this.showAvatarViewerDialog();
                        }, 120);
                      })
                  }
                  .margin({ top: 2, right: 20 })
                  
                  // 名称和UID
                  Column() {
                    Text(this.yourname)
                      .fontSize(24)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#fff')
                      .opacity(this.textOpacity)
                      .margin({ bottom: 2 })
                      .textAlign(TextAlign.Start)
                    Text(`UID: ${this.UID}`)
                      .fontSize(13)
                      .fontColor('rgba(255,255,255,0.6)')
                      .opacity(this.textOpacity)
                      .margin({ bottom: 4 })
                      .textAlign(TextAlign.Start)
                    Text(`性别: ${this.userInfo?.gender || '未设置'}`)
                      .fontSize(13)
                      .fontColor('rgba(255,255,255,0.6)')
                      .opacity(this.textOpacity)
                      .textAlign(TextAlign.Start)
                  }
                  .layoutWeight(1)
                  .justifyContent(FlexAlign.Start)
                }
                .padding({ left: 20, right: 20, top: 20, bottom: 20 })
              }
              .width('100%')
              .backgroundColor('rgba(255, 255, 255, 0.03)')
              .borderRadius(20)
              .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
              .shadow({ radius: 12, color: '#00000030', offsetX: 0, offsetY: 4 })
              .layoutWeight(1)
              .margin({ right: 12 })

              // 右侧：按钮组
              Column() {
                // 查找按钮
                Stack() {
                  // 按钮背景发光效果
                  Column()
                    .width('100%')
                    .height('100%')
                    .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
                    .borderRadius(12)
                    .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
                  
                  Column() {
                    Text('🔍')
                      .fontSize(20)
                      .fontColor('#ffffff')
                      .opacity(this.textOpacity)
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                }
                .width(50)
                .height(50)
                .backgroundColor('rgba(255, 255, 255, 0.03)')
                .borderRadius(12)
                .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
                .shadow({ radius: 6, color: '#00000020', offsetX: 0, offsetY: 2 })
                .onClick(() => {
                  let uiContext: UIContext = this.getUIContext();
                  let router = uiContext.getRouter();
                  router.pushUrl({ url: 'pages/searchpage' });
                })
                .margin({ bottom: 8 })

                // 设置按钮
                Stack() {
                  // 按钮背景发光效果
                  Column()
                    .width('100%')
                    .height('100%')
                    .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
                    .borderRadius(12)
                    .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
                  
                  Column() {
                    Image($r('app.media.setting'))
                      .width(20)
                      .height(20)
                      .fillColor('#ffffff')
                      .opacity(this.textOpacity)
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                }
                .width(50)
                .height(50)
                .backgroundColor('rgba(255, 255, 255, 0.03)')
                .borderRadius(12)
                .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
                .shadow({ radius: 6, color: '#00000020', offsetX: 0, offsetY: 2 })
                .onClick(() => {
                  let uiContext: UIContext = this.getUIContext();
                  let router = uiContext.getRouter();
                  router.pushUrl({ url: 'pages/ProfilePage' });
                })
              }
            }
            .width('100%')
            .margin({ top: 20, left: 16, right: 16, bottom: 16 })

            // 2. 用户统计信息卡片
            Stack() {
              // 统计卡片背景发光效果
              Column()
                .width('100%')
                .height('auto')
                .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
                .borderRadius(16)
                .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
              
              Row() {
                // 动态数量
                Column() {
                  Text(this.userStats?.dynamicCount?.toString() || '0')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#ffffff')
                    .opacity(this.textOpacity)
                  Text('动态')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.7)')
                    .opacity(this.textOpacity)
                }
                .layoutWeight(1)
                .justifyContent(FlexAlign.Center)

                // 分隔线
                Column()
                  .width(1)
                  .height(40)
                  .backgroundColor('rgba(255,255,255,0.2)')
                  .margin({ left: 16, right: 16 })

                // 关注数量
                Column() {
                  Text(this.userStats?.followingCount?.toString() || '0')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#ffffff')
                    .opacity(this.textOpacity)
                  Text('关注')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.7)')
                    .opacity(this.textOpacity)
                }
                .layoutWeight(1)
                .justifyContent(FlexAlign.Center)

                // 分隔线
                Column()
                  .width(1)
                  .height(40)
                  .backgroundColor('rgba(255,255,255,0.2)')
                  .margin({ left: 16, right: 16 })

                // 粉丝数量
                Column() {
                  Text(this.userStats?.followerCount?.toString() || '0')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#ffffff')
                    .opacity(this.textOpacity)
                  Text('粉丝')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.7)')
                    .opacity(this.textOpacity)
                }
                .layoutWeight(1)
                .justifyContent(FlexAlign.Center)
              }
              .padding({ top: 20, bottom: 20 })
            }
            .width('100%')
            .backgroundColor('rgba(255, 255, 255, 0.03)')
            .borderRadius(16)
            .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
            .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 2 })
            .margin({ left: 16, right: 16, bottom: 16 })
          }

          // 下半部分：标签页切换
          Column() {
            // 标签页切换按钮
            Row() {
              Text('动态')
                .fontSize(16)
                .fontWeight(this.selectedTab === 'dynamic' ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.selectedTab === 'dynamic' ? '#ffffff' : 'rgba(255, 255, 255, 0.6)')
                .opacity(this.textOpacity)
                .padding({ left: 20, right: 20, top: 12, bottom: 12 })
                .backgroundColor(this.selectedTab === 'dynamic' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
                .borderRadius(20)
                .onClick(() => {
                  // 双击检测：如果两次点击间隔小于300ms，则认为是双击
                  const currentTime = Date.now();
                  if (currentTime - this.lastClickTime < 300) {
                    // 双击事件：跳转到dynamiclist页面
                    let uiContext: UIContext = this.getUIContext();
                    let router = uiContext.getRouter();
                    router.pushUrl({ url: 'pages/DynamicList' });
                    this.lastClickTime = 0; // 重置点击时间
                  } else {
                    // 单击事件：切换到动态标签页并显示动态内容
                    this.selectedTab = 'dynamic';
                    this.lastClickTime = currentTime;
                  }
                })
              
              Text('阁楼')
                .fontSize(16)
                .fontWeight(this.selectedTab === 'attic' ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.selectedTab === 'attic' ? '#ffffff' : 'rgba(255, 255, 255, 0.6)')
                .opacity(this.textOpacity)
                .padding({ left: 20, right: 20, top: 12, bottom: 12 })
                .backgroundColor(this.selectedTab === 'attic' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
                .borderRadius(20)
                .onClick(() => {
                  this.selectedTab = 'attic';
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
            .padding({ left: 16, right: 16, bottom: 16 })

            // 动态标签页内容
            if (this.selectedTab === 'dynamic') {
              this.buildDynamicContent()
            }

            // 阁楼标签页内容
            if (this.selectedTab === 'attic') {
              this.buildAtticContent()
            }
          }
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      // 头像查看器 - 全屏显示头像
      if (this.showAvatarViewer) {
        Stack({ alignContent: Alignment.Center }) {
          // 半透明背景
          Column() {
            Blank()
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .opacity(0.9)
              .onClick(() => this.closeAvatarViewer())
          }
          .width('100%')
          .height('100%')

          // 头像查看器内容
          Column() {
            // 关闭按钮
            Row() {
              Button() {
                Image($r('app.media.return'))
                  .width(24)
                  .height(24)
                  .fillColor('#fff')
              }
              .width(40)
              .height(40)
              .backgroundColor('rgba(0,0,0,0.5)')
              .borderRadius(20)
              .onClick(() => this.closeAvatarViewer())
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
            .margin({ bottom: 20 })

            // 大尺寸头像显示
            Image(this.userAvatar)
              .width(300)
              .height(300)
              .borderRadius(150)
              .border({ width: 6, color: 'rgba(255,255,255,0.3)' })
              .objectFit(ImageFit.Cover)
              .margin({ bottom: 20 })

            // 操作按钮
            Row() {
              Button('编辑头像')
                .width(120)
                .height(44)
                .backgroundColor('rgba(255,255,255,0.2)')
                .fontColor('#fff')
                .borderRadius(22)
                .onClick(() => {
                  this.closeAvatarViewer();
                  setTimeout(() => {
                    let uiContext: UIContext = this.getUIContext();
                    let router = uiContext.getRouter();
                    router.pushUrl({ url: 'pages/infopage' });
                  }, 300);
                })
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('90%')
          .padding(24)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(999)
      }
    }
    .width('100%')
    .height('100%')
  }

  // 构建动态内容
  @Builder
  buildDynamicContent() {
    Column() {
      if (this.latestDynamic) {
        // 最新动态卡片
        Stack() {
          // 动态卡片背景发光效果
          Column()
            .width('100%')
            .height('auto')
            .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
            .borderRadius(16)
            .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
          
          Column() {
            // 动态头部信息
            Row() {
              // 动态中的头像显示 - 使用统一的方法
              Image(this.getAvatarUrl())
                .width(40)
                .height(40)
                .borderRadius(20)
                .margin({ right: 12 })
                .objectFit(ImageFit.Cover)
              
              Column() {
                Text(this.yourname)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff')
                  .opacity(this.textOpacity)
                Text(this.formatTime(this.latestDynamic.createTime))
                  .fontSize(12)
                  .fontColor('rgba(255,255,255,0.6)')
                  .opacity(this.textOpacity)
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.Start)
            }
            .margin({ bottom: 12 })

            // 动态内容
            Text(this.latestDynamic.content)
              .fontSize(14)
              .fontColor('#ffffff')
              .opacity(this.textOpacity)
              .textAlign(TextAlign.Start)
              .margin({ bottom: 12 })

            // 动态底部操作栏
            Row() {
              Text('❤️')
                .fontSize(16)
                .margin({ right: 8 })
              Text('💬')
                .fontSize(16)
                .margin({ right: 8 })
              Text('📤')
                .fontSize(16)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .width('100%')
        .backgroundColor('rgba(255, 255, 255, 0.03)')
        .borderRadius(16)
        .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
        .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 2 })
        .margin({ left: 16, right: 16, bottom: 12 })
        .onClick(() => {
          // 点击动态卡片时跳转到dynamiclist页面
          let uiContext: UIContext = this.getUIContext();
          let router = uiContext.getRouter();
          router.pushUrl({ url: 'pages/DynamicList' });
        })
      } else {
        // 空状态
        Stack() {
          // 空状态背景发光效果
          Column()
            .width('100%')
            .height('auto')
            .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
            .borderRadius(16)
            .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
          
          Column() {
            Text('📝')
              .fontSize(48)
              .margin({ bottom: 16 })
            Text('还没有动态')
              .fontSize(16)
              .fontColor('#ffffff')
              .opacity(this.textOpacity)
              .margin({ bottom: 8 })
            Text('发布你的第一条动态吧')
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.6)')
              .opacity(this.textOpacity)
          }
          .padding({ top: 40, bottom: 40 })
        }
        .width('100%')
        .backgroundColor('rgba(255, 255, 255, 0.03)')
        .borderRadius(16)
        .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
        .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 2 })
        .margin({ left: 16, right: 16, bottom: 12 })
        .onClick(() => {
          // 点击空状态时跳转到dynamiclist页面
          let uiContext: UIContext = this.getUIContext();
          let router = uiContext.getRouter();
          router.pushUrl({ url: 'pages/DynamicList' });
        })
      }
    }
  }

  // 构建阁楼内容
  @Builder
  buildAtticContent() {
    Column() {
      // 阁楼子标签页
      Row() {
        Text('智能体')
          .fontSize(14)
          .fontWeight(this.selectedAtticTab === '智能体' ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedAtticTab === '智能体' ? '#ffffff' : 'rgba(255, 255, 255, 0.6)')
          .opacity(this.textOpacity)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.selectedAtticTab === '智能体' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
          .borderRadius(16)
          .onClick(() => {
            // 双击检测：如果两次点击间隔小于300ms，则认为是双击
            const currentTime = Date.now();
            if (currentTime - this.lastAtticClickTime < 300) {
              // 双击事件：跳转到myairole页面
              let uiContext: UIContext = this.getUIContext();
              let router = uiContext.getRouter();
              router.pushUrl({ url: 'pages/myairole' });
              this.lastAtticClickTime = 0; // 重置点击时间
            } else {
              // 单击事件：切换到智能体标签页并显示智能体内容
              this.selectedAtticTab = '智能体';
              this.lastAtticClickTime = currentTime;
            }
          })
        
        Text('收藏')
          .fontSize(14)
          .fontWeight(this.selectedAtticTab === '收藏' ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedAtticTab === '收藏' ? '#ffffff' : 'rgba(255, 255, 255, 0.6)')
          .opacity(this.textOpacity)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.selectedAtticTab === '收藏' ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
          .borderRadius(16)
          .onClick(() => {
            // 双击检测：如果两次点击间隔小于300ms，则认为是双击
            const currentTime = Date.now();
            if (currentTime - this.lastAtticClickTime < 300) {
              // 双击事件：跳转到收藏页面（这里可以根据实际页面调整）
              let uiContext: UIContext = this.getUIContext();
              let router = uiContext.getRouter();
              router.pushUrl({ url: 'pages/FeaturedList' });
              this.lastAtticClickTime = 0; // 重置点击时间
            } else {
              // 单击事件：切换到收藏标签页并显示收藏内容
              this.selectedAtticTab = '收藏';
              this.lastAtticClickTime = currentTime;
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({ left: 16, right: 16, bottom: 16 })

      // 智能体内容
      if (this.selectedAtticTab === '智能体') {
        Stack() {
          // 智能体背景发光效果
          Column()
            .width('100%')
            .height('auto')
            .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
            .borderRadius(16)
            .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
          
          Column() {
            Text('🤖')
              .fontSize(48)
              .margin({ bottom: 16 })
            Text('我的智能体')
              .fontSize(16)
              .fontColor('#ffffff')
              .opacity(this.textOpacity)
              .margin({ bottom: 8 })
            Text('创建和管理你的AI智能体')
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.6)')
              .opacity(this.textOpacity)
          }
          .padding({ top: 40, bottom: 40 })
        }
        .width('100%')
        .backgroundColor('rgba(255, 255, 255, 0.03)')
        .borderRadius(16)
        .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
        .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 2 })
        .margin({ left: 16, right: 16, bottom: 12 })
      }

      // 收藏内容
      if (this.selectedAtticTab === '收藏') {
        Stack() {
          // 收藏背景发光效果
          Column()
            .width('100%')
            .height('auto')
            .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
            .borderRadius(16)
            .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
          
          Column() {
            Text('⭐')
              .fontSize(48)
              .margin({ bottom: 16 })
            Text('我的收藏')
              .fontSize(16)
              .fontColor('#ffffff')
              .opacity(this.textOpacity)
              .margin({ bottom: 8 })
            Text('查看你收藏的内容')
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.6)')
              .opacity(this.textOpacity)
          }
          .padding({ top: 40, bottom: 40 })
        }
        .width('100%')
        .backgroundColor('rgba(255, 255, 255, 0.03)')
        .borderRadius(16)
        .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
        .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 2 })
        .margin({ left: 16, right: 16, bottom: 12 })
      }
    }
  }
} 