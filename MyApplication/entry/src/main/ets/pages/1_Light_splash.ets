import router from '@ohos.router'

@Entry
@Component
struct Splash {
  aboutToAppear() {
    setTimeout(() => {
      router.pushUrl({ url: 'pages/2_Login' })
    }, 3000)
  }
  build() {
    Column()
    {
      Image($r('app.media.splash'))
        .width(180)
        .height(180)
        .margin({ bottom: 32 })
      Text('心屿')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)//文字加粗
        .fontColor('#222')
        .fontFamily('SimHei')//更改字体
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}