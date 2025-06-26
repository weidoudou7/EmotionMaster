import router from '@ohos.router';

@Component
export struct BottomNavBar {
  @Prop navIndex: string;

  build() {
    Row({ space: 0 }) {
      // 首页
      Column() {
        Button('首页')
          .fontSize(14)
          .fontColor(this.navIndex === 'home' ? '#5a4fff' : '#888')
          .backgroundColor('#fff')
          .onClick(() => {
            if (this.navIndex !== 'home') {
              router.replaceUrl({ url: 'pages/homepage' });
            }
          })
      }
      .layoutWeight(1)

      // 聊天
      Column() {
        Button('聊天')
          .fontSize(14)
          .fontColor(this.navIndex === 'chat' ? '#5a4fff' : '#888')
          .backgroundColor('#fff')
          .onClick(() => {
            if (this.navIndex !== 'chat') {
              router.replaceUrl({ url: 'pages/chat' });
            }
          })
      }
      .layoutWeight(1)

      // 星球
      Column() {
        Button('星球')
          .fontSize(14)
          .fontColor(this.navIndex === 'planet' ? '#5a4fff' : '#888')
          .backgroundColor('#fff')
          .onClick(() => {
            if (this.navIndex !== 'planet') {
              router.replaceUrl({ url: 'pages/planetpage' });
            }
          })
      }
      .layoutWeight(1)

      // 个人
      Column() {
        Button('个人')
          .fontSize(14)
          .fontColor(this.navIndex === 'personal' ? '#5a4fff' : '#888')
          .backgroundColor('#fff')
          .onClick(() => {
            if (this.navIndex !== 'personal') {
              router.replaceUrl({ url: 'pages/infopage' });
            }
          })
      }
      .layoutWeight(1)
    }
    .height(56)
    .backgroundColor('#fff')
    .border({ color: '#e0e0e0', width: 1 })
    .position({ x: 0, y: '96%' })
    .width('100%')
    .zIndex(99)
    .align(Alignment.Bottom)
  }
}