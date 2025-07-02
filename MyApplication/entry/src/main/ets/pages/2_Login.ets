import router from '@ohos.router';

@Entry
@Component
struct LoginPage {
  build() {
    Column()
    {
      // Logo
      Image($r('app.media.Xinyu_logo'))
        .width(120)
        .height(120)
        .margin({ bottom: 48 })

      // Welcome to
      Text('Welcome to')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ bottom: 8 })

      // ChattyAI 👋
      Row() {
        Image($r('app.media.word'))
          .width(120)
      }
      .margin({ bottom: 48 })

      // Log in 按钮
      Button('登录')
        .width('80%')
        .height(56)
        .fontSize(20)
        .fontColor('#121114')
        .backgroundColor('#ffda7f')
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
    .backgroundColor('#121114')
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  }
} 