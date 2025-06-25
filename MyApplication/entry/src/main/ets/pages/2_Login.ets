import router from '@ohos.router';

@Entry
@Component
struct LoginPage {
  build() {
    Column()
    {
      // Logo
      Image($r('app.media.splash'))
        .width(120)
        .height(120)
        .margin({ bottom: 48 })

      // Welcome to
      Text('Welcome to')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#222')
        .margin({ bottom: 8 })

      // ChattyAI 👋
      Row() {
        Text('心屿')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#14DCA0')
        Text(' 👋')
          .fontSize(36)
          .margin({ left: 4 })
      }
      .margin({ bottom: 48 })

      // Log in 按钮
      Button('登录')
        .width('80%')
        .height(56)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#fff')
        .backgroundColor('#14DCA0')
        .borderRadius(28)
        .margin({ bottom: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/3_EmailConfirm' });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
} 