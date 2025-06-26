import { BottomNavBar } from './BottomNavBar'

@Entry
@Component
struct PlanetPagePhone {
  private planetName: string = '希望之星'
  private planetDesc: string = '一个充满活力和希望的星球'
  private planetLevel: number = 5
  private planetImage: string = '/resources/base/media/QQ1222.jpg'
  private ecoPercent: number = 78
  private techPercent: number = 65
  private culturePercent: number = 82
  private talkHours: number = 12.5
  private talkTarget: number = 20
  private taskCount: number = 28
  private taskTarget: number = 50
  private explorePercent: number = 42

  build() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          // 顶部标题
          Text('我的星球')
            .fontSize(24).fontWeight(FontWeight.Bold)
            .fontColor('#222')
            .margin({ top: 18, left: 20, right: 20, bottom: 2 })
          Text('与AI互动，让它茁壮成长')
            .fontSize(13).fontColor('#888')
            .margin({ left: 20, right: 20, bottom: 8 })
          // 星球图片+等级
          Stack() {
            Image(this.planetImage)
              .width(140).height(140)
              .borderRadius(70)
              .shadow({ radius: 16, color: '#e0e6ff', offsetX: 0, offsetY: 6 })
            Text(`等级${this.planetLevel}`)
              .fontSize(13).fontColor('#fff')
              .backgroundColor('#ffb400')
              .borderRadius(10)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .position({ x: 100, y: 12 })
              .zIndex(1)
          }
          .align(Alignment.Center)
          // 星球名称和简介
          Text(this.planetName)
            .fontSize(18).fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Center)
          Text(this.planetDesc)
            .fontSize(13).fontColor('#888')
            .alignSelf(ItemAlign.Center)
          // 三项属性
          Row({ space: 10 }) {
            AttrCard('生态系统', `${this.ecoPercent}%`, '#4caf50', '🔗')
            AttrCard('科技水平', `${this.techPercent}%`, '#3f51b5', '🚀')
            AttrCard('文化发展', `${this.culturePercent}%`, '#ab47bc', '📖')
          }
          .alignSelf(ItemAlign.Center)
          .margin({ top: 8, left: 8, right: 8 })
          // 成长进度
          Text('成长进度').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 20, top: 16, bottom: 4 })
          Column({ space: 12 }) {
            ProgressItem('当前等级', `${this.planetLevel}`, 0.75, '等级 5', '75%到等级6', '#5a4fff')
            ProgressItem('总对话时长', `${this.talkHours} 小时`, this.talkHours / this.talkTarget, `目标: ${this.talkTarget} 小时`, '63%', '#00b386')
            ProgressItem('完成任务数', `${this.taskCount} 个`, this.taskCount / this.taskTarget, `目标: ${this.taskTarget} 个`, '56%', '#ffb400')
            ProgressItem('探索度', `${this.explorePercent}%`, this.explorePercent / 100, '目标: 100%', '42%', '#5a4fff')
          }
          .margin({ left: 20, right: 20 })
          // 成长奖励
          Text('成长奖励').fontSize(15).fontWeight(FontWeight.Bold).margin({ left: 20, top: 12, bottom: 4 })
          Row({ space: 10 }) {
            RewardTag('星球皮肤', true)
            RewardTag('特殊装饰', true)
            RewardTag('火箭飞船', false)
          }
          .margin({ left: 20, right: 20, bottom: 24 })
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
function AttrCard(title: string, value: string, color: string, icon: string) {
  Column({ space: 2 }) {
    Row() {
      Text(icon).fontSize(16)
      Text(title).fontSize(12).fontColor('#888').margin({ left: 2 })
    }
    Text(value).fontSize(15).fontWeight(FontWeight.Bold).fontColor(color)
  }
  .backgroundColor('#fff')
  .borderRadius(10)
  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
  .shadow({ radius: 3, color: '#eee', offsetX: 0, offsetY: 1 })
}

@Builder
function ProgressItem(title: string, value: string, percent: number, subTitle: string, subValue: string, color: string) {
  Column({ space: 2 }) {
    Row({ space: 8 }) {
      Text(title).fontSize(13)
      Text(value).fontSize(13).fontWeight(FontWeight.Bold).fontColor(color)
    }
    Progress({ value: percent * 100, total: 100 })
      .color(color)
      .height(7)
      .backgroundColor('#e0e0e0')
      .borderRadius(3)
    Row({ space: 8 }) {
      Text(subTitle).fontSize(11).fontColor('#888')
      Text(subValue).fontSize(11).fontColor('#888')
    }
  }
}

@Builder
function RewardTag(label: string, unlocked: boolean) {
  Row() {
    Text(label)
      .fontSize(12)
      .fontColor(unlocked ? '#00b386' : '#888')
      .backgroundColor(unlocked ? '#e0ffe6' : '#f0f0f0')
      .borderRadius(7)
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
  }
}
