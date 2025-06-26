import { DecorationInfo, chunkArray } from '../common/constants'
import { BottomNavBar } from './BottomNavBar'

@Entry
@Component
struct PlanetDecorationPhonePage {
  private decorations: DecorationInfo[] = [
    {
      title: '茂盛森林', desc: '为星球增添勃勃生机', unlocked: true, image: $r('app.media.deroration_1')
    },
    {
      title: '蓝色海泊', desc: '为星球增添水域区域', unlocked: true, image: $r('app.media.deroration_2')
    },
    {
      title: '未来城市', desc: '为星球增添科技城市', unlocked: true, image: $r('app.media.deroration_3')
    },
    {
      title: '杜甫山脉', desc: '为星球增添山地山脉', unlocked: true, image: $r('app.media.deroration_4')
    },
    {
      title: '卫星系统', desc: '为星球增添卫星卫星', unlocked: true, image: $r('app.media.deroration_5')
    },
    {
      title: '极光效果', desc: '为星球增添极光', unlocked: false, image: $r('app.media.deroration_6'), reward: 100
    },
    {
      title: '太空站', desc: '为星球增添太空站', unlocked: false, image: $r('app.media.deroration_7'), reward: 150
    },
    {
      title: '友好外星生物', desc: '为星球增添外星生物', unlocked: false, image: $r('app.media.deroration_8'), reward: 200
    },
    {
      title: '星际之门', desc: '为星球增添星际之门', unlocked: false, image: $r('app.media.deroration_9'), reward: 300
    },
    {
      title: '宇宙光环', desc: '为星球增添宇宙光环', unlocked: false, image: $r('app.media.deroration_10'), reward: 500
    }
  ];

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          // 顶部标题和按钮
          Text('星球装饰')
            .fontSize(24).fontWeight(FontWeight.Bold)
            .fontColor('#222')
            .margin({ top: 18, left: 20, right: 20, bottom: 2 })
          Text('定制你的星球外观，展示独特个性')
            .fontSize(14).fontColor('#888')
            .margin({ left: 20, right: 20, bottom: 8 })
          Row({ space: 12 }) {
            Button('应用装饰')
              .fontSize(14)
              .fontColor('#fff')
              .backgroundColor('#5a4fff')
              .borderRadius(8)
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            Button('刷新商店')
              .fontSize(14)
              .fontColor('#5a4fff')
              .backgroundColor('#fff')
              .border({ color: '#e0e0e0', width: 1 })
              .borderRadius(8)
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          }
          .margin({ left: 20, right: 20, bottom: 8 })

          // 已解锁装饰
          Text('已解锁装饰').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 20, top: 8, bottom: 4 })
          Column({ space: 12 }) {
            ForEach(this.decorations.filter((item: DecorationInfo) => item.unlocked), (item: DecorationInfo) => {
              DecorationPhoneCard(item)
            })
          }
          .margin({ left: 20, right: 20, bottom: 8 })

          // 未解锁装饰
          Text('未解锁装饰').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 20, top: 18, bottom: 4 })
          Column({ space: 12 }) {
            ForEach(this.decorations.filter((item: DecorationInfo) => !item.unlocked), (item: DecorationInfo) => {
              DecorationPhoneCard(item)
            })
          }
          .margin({ left: 20, right: 20, bottom: 8 })
        }
        .backgroundColor('#fafbff')
      }
      BottomNavBar({ navIndex: 'planet' })
    }
    .width('100%')
    .height('100%')
  }
}

@Builder
function DecorationPhoneCard(item: DecorationInfo) {
  Column() {
    Image(item.image).width('100%').height(120).borderRadius(12)
    Text(item.title).fontSize(15).fontWeight(FontWeight.Bold).margin({ top: 8, bottom: 2 })
    Text(item.desc).fontSize(12).fontColor('#888').maxLines(2)
    Row({ space: 8 }) {
      if (item.unlocked) {
        Row({ space: 4 }) {
          Image($r('app.media.achieve')).width(14).height(14)
          Text('已解锁').fontSize(12).fontColor('#4caf50')
        }
      } else {
        Row({ space: 4 }) {
          Image($r('app.media.achieve')).width(14).height(14)
          Text('解锁').fontSize(12).fontColor('#5a4fff')
        }

        if (item.reward) {
          Row({ space: 2 }) {
            Text(item.reward + '').fontSize(12).fontColor('#ffb400')
            Text('★').fontSize(12).fontColor('#ffb400')
          }
        }
      }
    }
    .margin({ top: 8 })
  }
  .backgroundColor('#fff')
  .borderRadius(14)
  .shadow({
    radius: 8,
    color: '#e5e7eb',
    offsetX: 0,
    offsetY: 2
  })
  .width('100%')
  .padding(14)
  .margin({ bottom: 6 })
}

