//yourpage.ets
// 导入页面路由模块
import { BusinessError } from '@kit.BasicServicesKit';
import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { UserInfo } from '../common/types';
import promptAction from '@ohos.promptAction';
//导入图片模块


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
  @State selectedTab: string = 'dynamic' // 当前选中的标签页：dynamic 或 attic
  @State selectedAtticTab: string = '智能体' // 当前选中的阁楼标签页

  // 页面生命周期
  aboutToAppear() {
    this.loadUserInfo();
  }

  // 加载用户信息
  async loadUserInfo() {
    try {
      this.isLoading = true;
      const userInfo = await ApiService.getUserInfo(this.UID);
      this.userInfo = userInfo;
      this.yourname = userInfo.userName;
      this.UID = userInfo.userUID;
      this.ooo = userInfo.isPrivacyVisible;
    } catch (error) {
      console.error('加载用户信息失败:', error);
      promptAction.showToast({ message: '加载用户信息失败' });
    } finally {
      this.isLoading = false;
    }
  }

  // 个人资料详情切换页面调出的构建函数
  @Builder
  build() {
    Stack() {
      // 黑色背景
      Column() {
        Blank().width('100%').height('100%').backgroundColor('#000')
      }
      .width('100%')
      .height('100%')
      
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(50).height(50)
          Text('加载中...').fontSize(16).fontColor('#fff').margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
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
                      .margin({ top: 2 })
                      .backgroundColor('#fff1')
                      .border({ width: 2, color: '#fff3' })
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
                        .fontColor('#bbb')
                        .margin({ bottom: 4 })
                        .textAlign(TextAlign.Start)
                      Text(`性别: ${this.userInfo?.gender || '未设置'}`)
                        .fontSize(13)
                        .fontColor('#bbb')
                        .textAlign(TextAlign.Start)
                    }
                    .margin({ left: 16 })
                    .alignItems(HorizontalAlign.Start)
                    .width('70%')
                  }
                  .padding(16)
                  .backgroundColor('rgba(200,200,200,0.18)')
                  .borderRadius(18)
                  .width('100%')
                }
                .width('70%')
                
                // 右侧小卡片
                Column() {
                  // 设置按钮
                  Button() {
                    Image($r('app.media.setting'))
                      .width(28)
                      .height(28)
                      .opacity(1)
                  }
                  .width(48)
                  .height(48)
                  .backgroundColor('rgba(200,200,200,0.28)')
                  .borderRadius(24)
                  .margin({ bottom: 12 })
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
                      .opacity(1)
                  }
                  .width(48)
                  .height(48)
                  .backgroundColor('rgba(200,200,200,0.28)')
                  .borderRadius(24)
                  .onClick(() => {
                    let uiContext: UIContext = this.getUIContext();
                    let router = uiContext.getRouter();
                    router.pushUrl({ url: 'pages/DynamicList' });
                  })
                }
                .width('20%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .width('90%')
              .height(120)
              .margin({ top: 32, bottom: 12 })
              // 2. 个性签名卡片
              Row() {
                Text('个性签名')
                  .fontSize(15)
                  .fontColor('#fff')
                  .margin({ right: 8 })
                Text(this.userInfo?.signature || '这个人很懒，什么都没留下~')
                  .fontSize(15)
                  .fontColor('#fff')
                  .textAlign(TextAlign.Start)
              }
              .padding(16)
              .backgroundColor('rgba(200,200,200,0.18)')
              .borderRadius(18)
              .width('90%')
              .margin({ bottom: 12 })
              // 3. 三个小按钮卡片
              Row() {
                ForEach(["关注:xx", "粉丝:xx", "好友:xx"], (label: string) =>
                  Button(label)
                    .width(90)
                    .height(32)
                    .fontSize(14)
                    .backgroundColor('rgba(200,200,200,0.28)')
                    .fontColor('#fff')
                    .borderRadius(16)
                    .margin({ right: 12 })
                    .onClick(() => {
                      promptAction.showToast({ message: '好友功能正在开发中' });
                    })
              )
              }
              .padding(16)
              .backgroundColor('rgba(200,200,200,0.18)')
              .borderRadius(18)
              .width('90%')
              .margin({ bottom: 18 })
              // 4. 底部两个按钮（移动到阁楼卡片上方）
              Row() {
                Button('我的阁楼')
                  .fontSize(15)
                  .backgroundColor(this.selectedTab === 'attic' ? 'rgba(255,255,255,0.4)' : 'rgba(200,200,200,0.28)')
                  .fontColor('#fff')
                  .borderRadius(20)
                  .margin({ right: 12 })
                  .onClick(() => {
                    this.selectedTab = 'attic';
                  })
                Button('我的动态')
                  .fontSize(15)
                  .backgroundColor(this.selectedTab === 'dynamic' ? 'rgba(255,255,255,0.4)' : 'rgba(200,200,200,0.28)')
                  .fontColor('#fff')
                  .borderRadius(20)
                  .onClick(() => {
                    this.selectedTab = 'dynamic';
                  })
              }
              .width('90%')
              .justifyContent(FlexAlign.Start)
              .margin({ bottom: 12 })
              // 5. 阁楼内容显示卡片
              Column() {
                if (this.selectedTab === 'attic') {
                  // 阁楼五个标签页导航栏（支持滑动）
                  Scroll() {
                    Row() {
                      ForEach(["智能体", "故事", "时刻", "群聊", "记忆簿"], (tab: string) =>
                        Button(tab)
                          .fontSize(12)
                          .backgroundColor(this.selectedAtticTab === tab ? 'rgba(255,255,255,0.3)' : 'rgba(200,200,200,0.2)')
                          .fontColor('#fff')
                          .borderRadius(12)
                          .margin({ right: 12 })
                          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                          .onClick(() => {
                            this.selectedAtticTab = tab;
                          })
                      )
                    }
                    .width('100%')
                  }
                  .scrollable(ScrollDirection.Horizontal)
                  .scrollBar(BarState.Off)
                  .width('100%')
                  .margin({ bottom: 16 })
                  
                  // 阁楼内容显示区域
                  Column() {
                    Text('没有可用的内容')
                      .fontSize(16)
                      .fontColor('#888')
                      .textAlign(TextAlign.Center)
                  }
                  .width('100%')
                  .height(120)
                  .backgroundColor('rgba(200,200,200,0.1)')
                  .borderRadius(12)
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
                    Column() {
                      Text('今天的心情很好，想要分享给大家...')
                        .fontSize(14)
                        .fontColor('#fff')
                        .textAlign(TextAlign.Start)
                        .margin({ bottom: 8 })
                      Text('2024-01-15 14:30')
                        .fontSize(12)
                        .fontColor('#bbb')
                        .textAlign(TextAlign.Start)
                    }
                    .width('100%')
                    .height(120)
                    .backgroundColor('rgba(200,200,200,0.1)')
                    .borderRadius(12)
                    .padding(16)
                    .justifyContent(FlexAlign.Start)
                    .onClick(() => {
                      let uiContext: UIContext = this.getUIContext();
                      let router = uiContext.getRouter();
                      router.pushUrl({ url: 'pages/DynamicList' });
                    })
                  }
                  .width('100%')
                }
              }
              .padding(16)
              .backgroundColor('rgba(200,200,200,0.18)')
              .borderRadius(18)
              .width('90%')
              .height('50%')
              .margin({ bottom: 18 })
            }
            .width('100%')
            
            // 移除下半部分阁楼预览区域，因为已整合到第五个卡片中
          }
          .width('100%')
          .padding({ top: 10 })
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
      }
      // 底部导航栏

    }
  }
} 