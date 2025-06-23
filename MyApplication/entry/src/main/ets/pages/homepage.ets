// homepage.ets
@Entry
@Component
struct HomePage {
  @State count: number = 0  // 计数器状态
  @State isDarkMode: boolean = false  // 主题状态

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
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isDarkMode ? '#222222' : '#F5F5F5')
  }
}