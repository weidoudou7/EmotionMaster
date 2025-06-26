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
    // 渐变背景改为纯色背景
    Stack() {
      // 纯色背景
      Column() {
        Blank()
          .width('100%')
          .height(300)
          .backgroundColor('#6DD5FA')
        Blank().height('100%').backgroundColor('#F5F5F5')
      }
      .width('100%')
      .height('100%')
      
      // 加载状态
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
          Text('加载中...')
            .fontSize(16)
            .fontColor('#666')
            .margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 头像卡片区
        Column() {
          // 头像及昵称卡片
          Column() {
            // 头像（带阴影、缩放动画、可点击）
            Row() {
              Blank().width(20)
              Image(this.userInfo?.userAvatar ? this.userInfo.userAvatar : $r("app.media.image"))
                .width(120)
                .height(120)
                .borderRadius(60)
                .shadow({ radius: 16, color: 'rgba(41,128,185,0.18)', offsetX: 0, offsetY: 8 })
                .scale({ x: this.avatarScale, y: this.avatarScale })
                .backgroundColor('#fff')
                .border({ width: 4, color: '#fff' })
                .onClick(() => {
                  // 点击头像有缩放动画并跳转到编辑页
                  this.avatarScale = 0.92;
                  setTimeout(() => {
                    this.avatarScale = 1.0;
                    let uiContext: UIContext = this.getUIContext();
                    let router = uiContext.getRouter();
                    router.pushUrl({ url: 'pages/infopage' });
                  }, 120);
                })
              Blank().width(20)
            }
            .margin({ top: 60, bottom: 10 })
            // 昵称
            Text(this.yourname)
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor('#222')
              .margin({ bottom: 4 })
              .textAlign(TextAlign.Center)
            // UID
            Text(`UID: ${this.UID}`)
              .fontSize(16)
              .fontColor('#888')
              .margin({ bottom: 10 })
              .textAlign(TextAlign.Center)
            // 等级/性别/签名等
            Row() {
              Text(this.userInfo?.level || 'Lv.1')
                .fontSize(14)
                .fontColor('#2980B9')
                .backgroundColor('#E3F2FD')
                .borderRadius(8)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              Text(' | ')
                .fontSize(14)
                .fontColor('#bbb')
              Text(this.userInfo?.gender || '未设置')
                .fontSize(14)
                .fontColor('#2980B9')
                .backgroundColor('#E3F2FD')
                .borderRadius(8)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            }
            .margin({ bottom: 8 })
            // 签名
            Text(this.userInfo?.signature || '这个人很懒，什么都没留下~')
              .fontSize(15)
              .fontColor('#555')
              .margin({ bottom: 18 })
              .textAlign(TextAlign.Center)
          }
          .width('90%')
          .backgroundColor('#fff')
          .borderRadius(18)
          .shadow({ radius: 12, color: 'rgba(41,128,185,0.10)', offsetX: 0, offsetY: 4 })
          .padding(20)
          
          // 资料卡片区
          Column() {
            // 是否可见
            Row() {
              Text('隐私状态')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333')
              Blank().width('10%')
              Text(this.ooo ? '***' : '公开')
                .fontSize(18)
                .fontColor(this.ooo ? '#FF4D4F' : '#52C41A')
            }
            .margin({ bottom: 18 })
            // 其他资料项
            Row() {
              Text('注册时间')
                .fontSize(16)
                .fontColor('#888')
              Blank().width('10%')
              Text(this.userInfo?.registerTime ? new Date(this.userInfo.registerTime).toLocaleDateString() : '未知')
                .fontSize(16)
                .fontColor('#333')
            }
            .margin({ bottom: 18 })
          }
          .width('90%')
          .backgroundColor('#fff')
          .borderRadius(18)
          .shadow({ radius: 8, color: 'rgba(41,128,185,0.08)', offsetX: 0, offsetY: 2 })
          .padding(20)
          
          // 编辑资料浮动按钮
          Button('编辑资料')
            .width(160)
            .height(48)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#2980B9')
            .fontColor('#fff')
            .borderRadius(24)
            .shadow({ radius: 8, color: 'rgba(41,128,185,0.12)', offsetX: 0, offsetY: 2 })
            .margin({ top: 30, bottom: 10 })
            .onClick(() => {
              let uiContext: UIContext = this.getUIContext();
              let router = uiContext.getRouter();
              router.pushUrl({ url: 'pages/infopage' });
            })
          
          // 底部功能区
          Row() {
            Button('我的动态')
              .width(120)
              .height(40)
              .backgroundColor('#fff')
              .fontColor('#2980B9')
              .borderRadius(20)
              .shadow({ radius: 4, color: 'rgba(41,128,185,0.08)', offsetX: 0, offsetY: 1 })
              .onClick(() => {
                promptAction.showToast({ message: '功能开发中...' });
              })
            Button('我的相册')
              .width(120)
              .height(40)
              .backgroundColor('#fff')
              .fontColor('#2980B9')
              .borderRadius(20)
              .shadow({ radius: 4, color: 'rgba(41,128,185,0.08)', offsetX: 0, offsetY: 1 })
              .margin({ left: 20 })
              .onClick(() => {
                promptAction.showToast({ message: '功能开发中...' });
              })
          }
          .width('90%')
          .justifyContent(FlexAlign.SpaceAround)
          .margin({ top: 20, bottom: 80 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ top: 20 })
      }
      
      // 底部导航栏
      BottomNavBar({ navIndex: 'personal' })
    }
  }
} 