// homepage.ets
// 导入页面路由模块
import { BusinessError } from '@kit.BasicServicesKit';
@Entry
@Component
struct HomePage {
  @State count: number = 0 // 计数器状态
  @State isDarkMode: boolean = false // 主题状态
  // 主题切换按钮的构建函数
  @Builder
  ThemeToggleButton() {
    Button(this.isDarkMode ? '☀️ 亮色模式' : '🌙 暗色模式')
      .width(120)
      .height(40)
      .margin(10)
      .onClick(() => {
        this.isDarkMode = !this.isDarkMode
      })
  }
  build() {
    Column() {
      // 标题
      Text('HarmonyOS 计数器')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })
      // 计数显示
      Text(`当前计数: ${this.count}`)
        .fontSize(36)
        .fontColor(this.isDarkMode ? '#FFFFFF' : '#000000')
        .margin({ bottom: 20 })
      // 操作按钮
      Row() {
        Button('增加')
          .width(100)
          .height(40)
          .backgroundColor('#0D9FFB')
          .onClick(() => {
            this.count += 1
          })
        Button('减少')
          .width(100)
          .height(40)
          .margin({ left: 20 })
          .backgroundColor('#FF4D4F')
          .onClick(() => {
            this.count -= 1
          })
      }
      .margin({ bottom: 30 })
      // 重置按钮
      Button('重置')
        .width(200)
        .height(40)
        .onClick(() => {
          this.count = 0
        })
      // 主题切换
      this.ThemeToggleButton()
      Button('前往个人主页')
        .width(250)
        .height(40)// 跳转按钮绑定onClick事件，单击时跳转到第二页
        .onClick(() => {
          console.info(`Succeeded in clicking the '前往个人主页' button.`)
          // 获取UIContext
          let uiContext: UIContext = this.getUIContext();
          let router = uiContext.getRouter();
          // 跳转到个人主页
          router.pushUrl({ url: 'pages/yourpage' }).then(() => {
            console.info('Succeeded in jumping to the yourpage.')
          }).catch((err: BusinessError) => {
            console.error(`Failed to jump to the yourpage. Code is ${err.code}, message is ${err.message}`)
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isDarkMode ? '#222222' : '#F5F5F5')
  }
}


