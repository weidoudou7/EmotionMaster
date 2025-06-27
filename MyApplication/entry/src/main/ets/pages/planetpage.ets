import { BottomNavBar } from './BottomNavBar'
import { globalUserData } from '../models/userdata'
import http from '@ohos.net.http'

interface PlanetDataType {
  id: number;
  userId: number;
  name: string;
  description: string;
  level: number;
  image: string;
  ecoPercent: number;
  techPercent: number;
  culturePercent: number;
  talkHours: number;
  talkTarget: number;
  taskCount: number;
  taskTarget: number;
  explorePercent: number;
  unlockedRewards: string[];
  lockedRewards: string[];
  appearance: string;
  unlockedItems: string;
}

interface PlanetApiResponse {
  success: boolean;
  message: string;
  data: PlanetDataType;
}

@Entry
@Component
struct PlanetPage {
  private planetData: PlanetDataType = {
    id: 0,
    userId: 0,
    name: '',
    description: '',
    level: 0,
    image: '',
    ecoPercent: 0,
    techPercent: 0,
    culturePercent: 0,
    talkHours: 0,
    talkTarget: 0,
    taskCount: 0,
    taskTarget: 0,
    explorePercent: 0,
    unlockedRewards: [],
    lockedRewards: [],
    appearance: '',
    unlockedItems: ''
  }

  aboutToAppear(): void {
    let userUID = globalUserData.userUID
    let httpRequest = http.createHttp()
    httpRequest.request(
      `http://localhost:8080/planet/uid/${userUID}`,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      }
    ).then((response) => {
      let resp = JSON.parse(response.result as string) as PlanetApiResponse
      if (resp.success) {
        this.planetData = resp.data
      } else {
        console.error(resp.message)
      }
    }).catch((err: Error) => {
      console.error('请求失败', err)
    })
  }

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
            Image(this.planetData.image ?? '/resources/base/media/QQ1222.jpg')
              .width(140).height(140)
              .borderRadius(70)
              .shadow({ radius: 16, color: '#e0e6ff', offsetX: 0, offsetY: 6 })
            Text(`等级${this.planetData.level ?? ''}`)
              .fontSize(13).fontColor('#fff')
              .backgroundColor('#ffb400')
              .borderRadius(10)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .position({ x: 100, y: 12 })
              .zIndex(1)
          }
          .align(Alignment.Center)
          // 星球名称和简介
          Text(this.planetData.name ?? '加载中...')
            .fontSize(18).fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Center)
          Text(this.planetData.description ?? '')
            .fontSize(13).fontColor('#888')
            .alignSelf(ItemAlign.Center)
          // 三项属性
          Row({ space: 10 }) {
            AttrCard('生态系统', `${this.planetData.ecoPercent ?? 0}%`, '#4caf50', '🔗')
            AttrCard('科技水平', `${this.planetData.techPercent ?? 0}%`, '#3f51b5', '🚀')
            AttrCard('文化发展', `${this.planetData.culturePercent ?? 0}%`, '#ab47bc', '📖')
          }
          .alignSelf(ItemAlign.Center)
          .margin({ top: 8, left: 8, right: 8 })
          // 成长进度
          Text('成长进度').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 20, top: 16, bottom: 4 })
          Column({ space: 12 }) {
            ProgressItem('当前等级', `${this.planetData.level ?? ''}`, 0.75, `等级 ${this.planetData.level ?? ''}`, '75%到等级6', '#5a4fff')
            ProgressItem('总对话时长', `${this.planetData.talkHours ?? 0} 小时`, (this.planetData.talkHours ?? 0) / (this.planetData.talkTarget ?? 1), `目标: ${this.planetData.talkTarget ?? 0} 小时`, '63%', '#00b386')
            ProgressItem('完成任务数', `${this.planetData.taskCount ?? 0} 个`, (this.planetData.taskCount ?? 0) / (this.planetData.taskTarget ?? 1), `目标: ${this.planetData.taskTarget ?? 0} 个`, '56%', '#ffb400')
            ProgressItem('探索度', `${this.planetData.explorePercent ?? 0}%`, (this.planetData.explorePercent ?? 0) / 100, '目标: 100%', `${this.planetData.explorePercent ?? 0}%`, '#5a4fff')
          }
          .margin({ left: 20, right: 20 })
          // 成长奖励
          // Text('成长奖励').fontSize(15).fontWeight(FontWeight.Bold).margin({ left: 20, top: 12, bottom: 4 })
          // Row({ space: 10 }) {
          //   // 展示已解锁奖励
          //   for (let label of (this.planetData.unlockedRewards ?? [])) {
          //     RewardTag(label, true)
          //   }
          //   // 展示未解锁奖励
          //   for (let label of (this.planetData.lockedRewards ?? [])) {
          //     RewardTag(label, false)
          //   }
          // }
          // .margin({ left: 20, right: 20, bottom: 24 })
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
function AttrCard(title: string, value: string, color: string, icon: string): void {
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
function ProgressItem(title: string, value: string, percent: number, subTitle: string, subValue: string, color: string): void {
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
function RewardTag(label: string, unlocked: boolean): void {
  Row() {
    Text(label)
      .fontSize(12)
      .fontColor(unlocked ? '#00b386' : '#888')
      .backgroundColor(unlocked ? '#e0ffe6' : '#f0f0f0')
      .borderRadius(7)
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
  }
}
