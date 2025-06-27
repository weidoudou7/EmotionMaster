import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { BottomNavBar } from './BottomNavBar'

@Entry
@Component
struct ChatPage {
  private userName: string = '谢庆之'
  private userAvatar: Resource = $r('app.media.background') // 头像资源
  private bgImage: Resource = $r('app.media.background')   // 聊天背景图（可换成专用背景图）
  private fans: string = '6.9万'
  private comments: number = 127
  private intro: string = '简介 谢庆之，男大，谢家独子，高富帅，有胃病，要亲情有钱，要友情有钱，要爱情还是有钱，习惯用钱解决所有问题，严重缺爱，三观正，有教养，有洁癖。'
  private introExpanded: boolean = false
  private chatText: string = ''

  build(): void {
    Stack() {
      // 聊天背景图
      Image(this.bgImage)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 内容区
      Column() {
        // 顶部信息栏
        Row() {
          Image(this.userAvatar)
            .width(38).height(38)
            .borderRadius(19)
          Column() {
            Text(this.userName)
              .fontSize(16)
              .fontColor('#fff')
              .fontWeight(FontWeight.Bold)
            Text(this.fans + ' 连接者')
              .fontSize(12)
              .fontColor('#aaa')
          }
          .margin({ left: 8 })
          Blank()
          Button('≡')
            .backgroundColor('transparent')
            .fontColor('#fff')
            .fontSize(20)
            .onClick(() => promptAction.showToast({ message: '更多功能开发中' }))
        }
        .width('100%')
        .height(56)
        .backgroundColor('rgba(35,35,35,0.85)')
        .alignItems(VerticalAlign.Center)
        .padding({ left: 10, right: 10, top: 8 })

        // 简介卡片
        Column() {
          Text(this.introExpanded ? this.intro : (this.intro.length > 30 ? this.intro.slice(0, 30) + '…' : this.intro))
            .fontSize(15)
            .fontColor('#fff')
            .margin({ bottom: 4 })
          Row() {
            Button(this.introExpanded ? '收起' : '展开')
              .fontSize(13)
              .fontColor('#FFD700')
              .backgroundColor('transparent')
              .onClick(() => this.introExpanded = !this.introExpanded)
          }
        }
        .width('90%')
        .backgroundColor('rgba(35,35,35,0.92)')
        .borderRadius(14)
        .padding(14)
        .alignSelf(ItemAlign.Center)
        .margin({ top: 16, bottom: 8 })

        Blank().height('60%') // 占位，让输入栏靠底部

        // 底部输入栏（完全还原图片样式）
        Column() {
          // 顶部分割线

          // 主输入区
          Row() {
            // 语音按钮
            Button('🎤') // 改为文字描述，也可以使用图标
              .width(50).height(36)
              .backgroundColor('#F5F5F7')
              .borderRadius(18)
              .fontSize(12) // 调整字体大小以适应文字
              .fontColor('#232323')
              .onClick(() => promptAction.showToast({ message: '语音输入开发中' }))

            // 输入框
            TextInput({ placeholder: '发送消息给' + this.userName })
              .fontSize(15)
              .fontColor('#232323')
              .backgroundColor('transparent')
              .borderRadius(18)
              .width('50%')
              .onChange((v: string) => this.chatText = v)



            // 加号按钮 - 使用HTML实体编码
            Button('➕') // 改为普通加号
              .width(50).height(36)
              .backgroundColor('#F5F5F7')
              .borderRadius(18)
              .fontSize(20)
              .fontColor('#232323')
              .onClick(() => promptAction.showToast({ message: '快捷功能开发中' }))
              .margin({right:8})

            // 发送按钮 - 使用HTML实体编码
            Button('➤') // 改为普通大于号
              .width(50).height(36)
              .backgroundColor('#F5F5F7')
              .borderRadius(18)
              .fontSize(20)
              .fontColor('#232323')
              .onClick(() => {
                promptAction.showToast({ message: '发送功能开发中' })
                this.chatText = ''
              })
          }
          .width('100%')
          .height(44)
          .backgroundColor('#F5F5F7')
          .borderRadius(22)
          .shadow({ radius: 8, color: '#e0e0e0', offsetX: 0, offsetY: 2 })

        }
        .width('100%')
        .padding({ left: 0, right: 0, top: 0, bottom: 8 })
        .backgroundColor('transparent')
        .margin({ bottom: 8 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({bottom:60})

      // 底部导航栏
      BottomNavBar({ navIndex: 'chat' })
    }
    .width('100%')
    .height('100%')
  }
}
