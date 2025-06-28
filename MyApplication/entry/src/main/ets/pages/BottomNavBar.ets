import router from '@ohos.router';
import { Chat } from './chat';
import { CreateFigurePage } from './CreateFigure';
import { FMHomePage } from './fmhome';
import { HomePage } from './homepage';
import { YourPage } from './yourpage';
import {FeaturedList} from './FeaturedList';

@Entry
@Component
export struct BottomNavBar {
  @State currentIndex: number = 0;
  @State private chatTopTabIndex: number = 2; // 默认"综合"

  build() {
    Tabs({
      barPosition: BarPosition.End,
      index: this.currentIndex
    }) {
      TabContent() {
        HomePage()
      }.tabBar('首页')

      TabContent() {
        // ====== 顶部标签栏+内容 ======
        Column() {
          Tabs({
            index: this.chatTopTabIndex,
            barPosition: BarPosition.Start
          }) {
            TabContent() {
              // 历史内容
              Column() {
                Text('历史对话')
                  .fontSize(24)
                  .fontColor('#fff')
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 50, bottom: 20 })
                  .textAlign(TextAlign.Center)
                
                Text('这里显示历史对话记录')
                  .fontSize(16)
                  .fontColor('#ccc')
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .height('100%')
              .backgroundColor('#181818')
            }.tabBar('历史')

            TabContent() {
              Chat()
            }.tabBar('精选')

            TabContent() {
              FeaturedList()
            }.tabBar('综合')
          }
          .onChange((idx: number) => {
            this.chatTopTabIndex = idx
          })
          .barMode(BarMode.Fixed)
          .barHeight(40)
          .backgroundColor('transparent')
          .barBackgroundColor('rgba(255,255,255,0.8)')
          .barWidth('100%')
        }
      }.tabBar('消息')

      TabContent() {
        CreateFigurePage()
      }.tabBar('+')

      TabContent() {
        FMHomePage()
      }.tabBar('电台')

      TabContent() {
        YourPage()
      }.tabBar('个人')
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .barMode(BarMode.Fixed)
    .barHeight(56)
    .backgroundColor('transparent')
    .barBackgroundColor('rgba(255,255,255,0.8)')
    .barWidth('100%')
  }
}


