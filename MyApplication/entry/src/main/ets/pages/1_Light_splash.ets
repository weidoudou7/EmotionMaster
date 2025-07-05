import router from '@ohos.router'

@Entry
@Component
struct Splash {
  aboutToAppear() {
    setTimeout(() => {
      router.pushUrl({ url: 'pages/yourpage' })
    }, 3000)
  }
  build() {
    Column()
    {
      Image($r('app.media.Xinyu_logo'))
        .width(180)
        .height(180)
        .margin({ bottom: 32 })
      Image($r('app.media.word'))
        .width(120)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    .backgroundColor('#121114')
  }
}