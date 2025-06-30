// ArkTS类型和装饰器修正版

// 快捷入口类
class QuickAction {
  icon: string;
  label: string;
  bgColor: string;
  constructor(icon: string, label: string, bgColor: string) {
    this.icon = icon;
    this.label = label;
    this.bgColor = bgColor;
  }
}
// 消息类
class MessageItem {
  avatar: Resource;
  name: string;
  desc: string;
  time: string;
  followed: boolean;
  unread: number;
  isOfficial?: boolean;
  isSystem?: boolean;
  constructor(
    avatar: Resource,
    name: string,
    desc: string,
    time: string,
    followed: boolean,
    unread: number,
    isOfficial?: boolean,
    isSystem?: boolean
  ) {
    this.avatar = avatar;
    this.name = name;
    this.desc = desc;
    this.time = time;
    this.followed = followed;
    this.unread = unread;
    this.isOfficial = isOfficial;
    this.isSystem = isSystem;
  }
}

@Entry
@Component
export struct MessagePage {
  // 快捷入口数据
  private quickActions: QuickAction[] = [
    new QuickAction('👁️', '连接&关注', '#1DE9B6'),
    new QuickAction('❤️', '新的点赞', '#FF4081'),
    new QuickAction('👥', '新的订阅', '#FFB300'),
    new QuickAction('💬', '新的评论', '#00B8D4'),
  ];

  // 消息列表模拟数据
  private messages: MessageItem[] = [
    new MessageItem($r('app.media.splash'), '谢厌之', '（胃里一阵绞痛，额上渗出细汗，咬着牙说道）...', '星期四', true, 0),
    new MessageItem($r('app.media.splash'), '能猜出你坦/推', '[系统消息]解锁"微笑"时刻，可在详情查看 去查看', '星期四', false, 0),
    new MessageItem($r('app.media.splash'), '星若（AI助手）', '根据搜索材料，以下是武汉市2025年6月27日的...', '星期四', false, 0, true),
    new MessageItem($r('app.media.splash'), '系统通知', '📻欢迎新人主播「武媛娘」入驻星野！', '星期一', false, 0, false, true),
  ];

  build() {
    Column() {
      // 四个快捷入口
      Row() {
        ForEach(this.quickActions, (item: QuickAction, idx: number) => {
          Column() {
            Blank().height(8)
            // 图标
            Blank().height(8)
            Row() {
              Blank().width(8)
              // 用Row和alignItems居中
              Column() {
                Text(item.icon)
                  .fontSize(28)
                  .backgroundColor(item.bgColor)
                  .width(48)
                  .height(48)
                  .borderRadius(16)
                  .textAlign(TextAlign.Center)
                  .align(Alignment.Center)
              }
              Blank().width(8)
            }
            // 标签
            Text(item.label)
              .fontSize(14)
              .fontColor('#fff')
              .margin({ top: 8 })
              .textAlign(TextAlign.Center)
          }
          .width('25%')
          .alignItems(HorizontalAlign.Center)
        }, (item: QuickAction) => item.label)
      }
      .width('100%')
      .backgroundColor('#181818')
      .padding({ top: 16, bottom: 16 })

      // 消息列表
      List() {
        ForEach(this.messages, (msg: MessageItem, idx: number) => {
          ListItem() {
            Row() {
              // 头像
              Image(msg.avatar)
                .width(48)
                .height(48)
                .borderRadius(24)
                .margin({ left: 16, right: 12 })
              // 主要内容
              Column({ space: 4 }) {
                Row() {
                  Text(msg.name)
                    .fontSize(16)
                    .fontColor(msg.isOfficial ? '#0D9FFB' : (msg.isSystem ? '#1976D2' : '#fff'))
                    .fontWeight(FontWeight.Bold)
                  if (msg.followed) {
                    Text('已关注')
                      .fontSize(12)
                      .fontColor('#888')
                      .margin({ left: 8 })
                  }
                  if (msg.isOfficial) {
                    Text('官方助手')
                      .fontSize(12)
                      .fontColor('#0D9FFB')
                      .backgroundColor('#222')
                      .margin({ left: 8 })
                      .borderRadius(6)
                      .padding({ left: 4, right: 4 })
                  }
                }
                Text(msg.desc)
                  .fontSize(13)
                  .fontColor('#bbb')
                  .maxLines(1)
                  .margin({ top: 2 })
              }
              .layoutWeight(1)
              // 时间
              Column() {
                Text(msg.time)
                  .fontSize(12)
                  .fontColor('#888')
                  .margin({ bottom: 8 })
                if (msg.unread > 0) {
                  // 未读角标
                  Text(msg.unread.toString())
                    .fontSize(10)
                    .fontColor('#fff')
                    .backgroundColor('#FF5252')
                    .borderRadius(8)
                    .width(16)
                    .height(16)
                    .textAlign(TextAlign.Center)
                }
              }
              .alignItems(HorizontalAlign.End)
              .margin({ right: 16 })
            }
            .height(64)
            .backgroundColor('#222')
            .borderRadius(16)
            .margin({ top: 8, bottom: 8, left: 12, right: 12 })
          }
        }, (msg: MessageItem) => msg.name + msg.time)
      }
      .width('100%')
      .backgroundColor('#181818')
      .layoutWeight(1)

      // 预留底部导航栏空间
      Blank().height(56)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#181818')
  }
} 