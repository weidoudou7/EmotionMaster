//yourpage.ets
// 导入页面路由模块
import { BusinessError } from '@kit.BasicServicesKit';
import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { UserInfo } from '../common/types';
import promptAction from '@ohos.promptAction';
//导入图片模块
import { BottomNavBar } from './BottomNavBar';

@Entry
@Component
struct YourPage {
  @State yourname: string = globalUserData.userName; //用户名称
  @State UID: string = globalUserData.userUID; //用户UID
  @State ooo: boolean = globalUserData.isPrivacyVisible; //用户隐私
  @State message: string = 'Image';
  @State avatarScale: number = 1.0; // 头像缩放动画
  @State isLoading: boolean = false; // 加载状态
  @State userInfo: UserInfo | null = null; // 用户信息

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
        Column() {
          // 1. 头像+名称+UID 卡片
          Row() {
            // 卡片
            Row() {
              // 头像
              Image(this.userInfo?.userAvatar ? this.userInfo.userAvatar : $r("app.media.image"))
                .width(80)
                .height(80)
                .borderRadius(40)
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
                Text(`UID: ${this.UID}`)
                  .fontSize(13)
                  .fontColor('#bbb')
              }
              .margin({ left: 16 })
            }
            .padding(16)
            .backgroundColor('rgba(200,200,200,0.18)')
            .borderRadius(18)
            .width('90%')
          }
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
          // 3. 三个小按钮卡片（去除可见，增加宽度）
          Row() {
            ForEach(["关注", "粉丝", "好友"], (label: string) =>
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
          // 4. 底部两个按钮
          Row() {
            Button('我的动态')
              .fontSize(15)
              .backgroundColor('rgba(200,200,200,0.28)')
              .fontColor('#fff')
              .borderRadius(20)
              .margin({ right: 12 })
              .onClick(() => {
                let uiContext: UIContext = this.getUIContext();
                let router = uiContext.getRouter();
                router.pushUrl({ url: 'pages/DynamicList' });
              })
            Button('我的橱窗')
              .fontSize(15)
              .backgroundColor('rgba(200,200,200,0.28)')
              .fontColor('#fff')
              .borderRadius(20)
              .onClick(() => {
                promptAction.showToast({ message: '橱窗功能正在开发中' });
              })
          }
          .width('90%')
          .justifyContent(FlexAlign.Start)
          .margin({ top: 10, bottom: 10 })
          // 5. 性别和注册时间小按钮区（无背景）
          Row() {
            Button(this.userInfo?.gender || '未设置')
              .fontSize(16)
              .backgroundColor('rgba(200,200,200,0.28)')
              .fontColor('#222')
              .borderRadius(14)
              .margin({ right: 12 })
              .width((this.userInfo?.gender || '未设置') === '未设置' ? undefined : 60)
            Button(this.userInfo?.registerTime ? new Date(this.userInfo.registerTime).toLocaleDateString() : '未知')
              .fontSize(16)
              .backgroundColor('rgba(200,200,200,0.28)')
              .fontColor('#222')
              .borderRadius(14)
              .width((this.userInfo?.registerTime ? new Date(this.userInfo.registerTime).toLocaleDateString() : '未知') === '未知' ? undefined : 60)
          }
          .width('90%')
          .margin({ bottom: 2 })
        }
        .width('100%')
        .padding({ top: 10 })
      }
      // 底部导航栏
      BottomNavBar({ navIndex: 'personal' })
    }
  }
} 