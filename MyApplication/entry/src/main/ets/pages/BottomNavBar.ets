// import router from '@ohos.router';
// import { Chat } from './chat';
// import { CreateFigurePage } from './CreateFigure';
// import { FMHomePage } from './fmhome';
// import { HomePage } from './homepage';
// import { YourPage } from './yourpage';
// import {FeaturedList} from './FeaturedList';
// import { MessagePage } from './fm_message';
//
// @Entry
// @Component
// export struct BottomNavBar {
//   @State currentIndex:number = 0
//   @State private chatTopTabIndex: number = 2 // 默认"综合"
//   @State private chatTopTabIndex2: number = 0
//   private tabsController: TabsController = new TabsController()
//   private topTabsController: TabsController=new TabsController()
//   private topTabsController2: TabsController=new TabsController()
//   @State activeTab: number = 0
//   private tabs: string[] = ['首页', '消息', '+', '电台', '个人'];
//   @State activeSubTab: number = 0
//   private subTabs: string[] = ['消息', '贴吧'];
//   @State activeHomeSubTab: number = 0
//   private subTabsHome: string[] = ['推荐', '综合'];
//
//   //自定义组件
//   @Builder
//   TabBuilder(title:string,targetIndex:number){
//     Column(){
//       Text(title)
//         .padding({top:2})
//         .fontSize(20)
//         .fontColor(this.currentIndex == targetIndex?'#ffda7f':Color.White)
//     }
//     //.opacity(0.4)透明度
//     .backgroundColor('rgba(255,255,255,0.7)')
//     .width('100%')
//     .height(50)
//     .justifyContent(FlexAlign.Center)
//     .onClick(()=>{
//       this.currentIndex = targetIndex
//       this.tabsController.changeIndex(this.currentIndex)
//     })
//   }
//
//   @Builder
//   TopTabBuilder(title:string,targetIndex:number){
//     Column(){
//       Text(title)
//         .fontSize(20)
//         .fontColor(this.chatTopTabIndex == targetIndex?'#ffda7f':Color.White)
//     }
//     .backgroundColor('#222222')
//     .width('100%')
//     .height(50)
//     .justifyContent(FlexAlign.Center)
//     .onClick(()=>{
//       this.chatTopTabIndex = targetIndex
//       this.topTabsController.changeIndex(this.chatTopTabIndex)
//     })
//   }
//
//   @Builder
//   TopTabBuilder2(title:string,targetIndex:number){
//     Column(){
//       Text(title)
//         .fontSize(20)
//         .fontColor(this.chatTopTabIndex2 == targetIndex?'#ffda7f':Color.White)
//     }
//     .backgroundColor('#222222')
//     .width('100%')
//     .height(50)
//     .justifyContent(FlexAlign.Center)
//     .onClick(()=>{
//       this.chatTopTabIndex2 = targetIndex
//       this.topTabsController2.changeIndex(this.chatTopTabIndex2)
//     })
//   }
//
//   build() {
//     Column() {
//       // 主内容区用Column包裹，外链.layoutWeight(1)
//       Column() {
//         if (this.activeTab == 0) {
//           if (this.activeHomeSubTab == 0) {
//             Column() {
//               // 顶部子TabBar
//               Row() {
//                 ForEach(this.subTabsHome, (tab: string, idx: number) => {
//                   Column() {
//                     Text(tab)
//                       .fontSize(16)
//                       .fontColor(this.activeHomeSubTab === idx ? '#0D9FFB' : 'rgba(255,255,255,0.7)')
//                       .fontWeight(this.activeHomeSubTab === idx ? FontWeight.Bold : FontWeight.Normal)
//                     if (this.activeHomeSubTab === idx) {
//                       Blank().height(2).width(24).backgroundColor('#0D9FFB').margin({ top: 2 })
//                     }
//                   }
//                   .onClick(() => { this.activeHomeSubTab = idx })
//                   .margin({ right: 24 })
//                 }, (tab: string) => tab)
//                 Blank()
//               }
//               .width('100%')
//               .padding({ left: 16, right: 16, top: 16, bottom: 8 })
//
//               // 综合内容
//               Chat()
//             }
//             .width('100%')
//             .height('100%')
//           } else if (this.activeHomeSubTab == 1) {
//             // 综合Tab
//             Column() {
//               // 顶部子TabBar
//               Row() {
//                 ForEach(this.subTabsHome, (tab: string, idx: number) => {
//                   Column() {
//                     Text(tab)
//                       .fontSize(16)
//                       .fontColor(this.activeHomeSubTab === idx ? '#0D9FFB' : 'rgba(255,255,255,0.7)')
//                       .fontWeight(this.activeHomeSubTab === idx ? FontWeight.Bold : FontWeight.Normal)
//                     if (this.activeHomeSubTab === idx) {
//                       Blank().height(2).width(24).backgroundColor('#0D9FFB').margin({ top: 2 })
//                     }
//                   }
//                   .onClick(() => { this.activeHomeSubTab = idx })
//                   .margin({ right: 24 })
//                 }, (tab: string) => tab)
//                 Blank()
//               }
//               .width('100%')
//               .padding({ left: 16, right: 16, top: 16, bottom: 8 })
//
//               // 综合内容
//               FeaturedList()
//             }
//             .width('100%')
//             .height('100%')
//           }
//         } else if (this.activeTab == 1) {
//           // 顶部子TabBar
//           Row() {
//             ForEach(this.subTabs, (tab: string, idx: number) => {
//               Column() {
//                 Text(tab)
//                   .fontSize(16)
//                   .fontColor(this.activeSubTab === idx ? '#0D9FFB' : 'rgba(255,255,255,0.7)')
//                   .fontWeight(this.activeSubTab === idx ? FontWeight.Bold : FontWeight.Normal)
//                 if (this.activeSubTab === idx) {
//                   Blank().height(2).width(24).backgroundColor('#0D9FFB').margin({ top: 2 })
//                 }
//               }
//               .onClick(() => { this.activeSubTab = idx })
//               .margin({ right: 24 })
//             }, (tab: string) => tab)
//             Blank() // 占据剩余空间，让Tab靠左
//           }
//           .width('100%')
//           .padding({ left: 16, right: 16, bottom: 8, top: 16 })
//
//           // 子内容区
//           if (this.activeSubTab == 0) {
//             MessagePage()
//           } else if (this.activeSubTab == 1) {
//             HomePage()
//           }
//         } else if (this.activeTab == 2) {
//           CreateFigurePage()
//         } else if (this.activeTab == 3) {
//           FMHomePage()
//         } else if (this.activeTab == 4) {
//           YourPage()
//         }
//       }
//       .layoutWeight(1)
//
//       // 底部导航栏
//       Row() {
//         ForEach(this.tabs, (tab: string, idx: number) => {
//           Column() {
//             Text(tab)
//               .fontSize(16)
//               .fontColor(this.activeTab === idx ? '#0D9FFB' : 'rgba(255,255,255,0.7)')
//               .fontWeight(this.activeTab === idx ? FontWeight.Bold : FontWeight.Normal)
//             if (this.activeTab === idx) {
//               Blank().height(2).width(24).backgroundColor('#0D9FFB').margin({ top: 2 })
//             }
//           }
//           .onClick(() => { this.activeTab = idx })
//           .layoutWeight(1)
//           .justifyContent(FlexAlign.Center)
//         }, (tab: string) => tab)
//       }
//       .width('100%')
//       .height(56)
//       .backgroundColor('#222222')
//       .zIndex(10)
//       .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
//     }
//     .width('100%')
//     .height('100%')
//     .backgroundColor('#222222')
//   }
//
// }

import router from '@ohos.router';
import { Chat } from './chat';
import { CreateFigurePage } from './CreateFigure';
import { FMHomePage } from './fmhome';
import { HomePage } from './homepage';
import { YourPage } from './yourpage';
import {FeaturedList} from './FeaturedList';
import { MessagePage } from './fm_message';

@Entry
@Component
export struct BottomNavBar {
  @State currentIndex:number = 0
  @State private chatTopTabIndex: number = 1// 默认"综合"
  @State private chatTopTabIndex2: number = 0
  private tabsController: TabsController = new TabsController()
  private topTabsController: TabsController=new TabsController()
  private topTabsController2: TabsController=new TabsController()
  //自定义组件
  @Builder
  TabBuilder(title:string,targetIndex:number){
    Column(){
      Text(title)
        .padding({top:2})
        .fontSize(20)
        .fontColor(this.currentIndex == targetIndex?'#ffda7f':Color.White)
    }
    //.opacity(0.4)透明度
    .backgroundColor('#121114')
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .onClick(()=>{
      this.currentIndex = targetIndex
      this.tabsController.changeIndex(this.currentIndex)
    })
  }

  @Builder
  TopTabBuilder(title:string,targetIndex:number){
    Column(){
      Text(title)
        .fontSize(20)
        .fontColor(this.chatTopTabIndex == targetIndex?'#ffda7f':Color.White)
    }
    .backgroundColor('#121114')
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .onClick(()=>{
      this.chatTopTabIndex = targetIndex
      this.topTabsController.changeIndex(this.chatTopTabIndex)
    })
  }

  @Builder
  TopTabBuilder2(title:string,targetIndex:number){
    Column(){
      Text(title)
        .fontSize(20)
        .fontColor(this.chatTopTabIndex2 == targetIndex?'#ffda7f':Color.White)
    }
    .backgroundColor('#121114')
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .onClick(()=>{
      this.chatTopTabIndex2 = targetIndex
      this.topTabsController2.changeIndex(this.chatTopTabIndex2)
    })
  }

  build() {
    Column() {
      Tabs({
        // barPosition:BarPosition.Start  //默认
        barPosition: BarPosition.End, //底部导航
        controller: this.tabsController
      }) {
        TabContent() {
          // ====== 顶部标签栏+内容 ======
          Column() {
            Tabs({
              index: this.chatTopTabIndex,
              barPosition: BarPosition.Start
            }) {
              TabContent() {
                Chat()
              }.tabBar(this.TopTabBuilder("精选",0))
              TabContent() {
                FeaturedList()
              }.tabBar(this.TopTabBuilder("综合",1))
            }
            .scrollable(false) //禁止滑动切换
            .animationDuration(0) //去掉切换页面的动画
          }
        }.tabBar(this.TabBuilder("首页",0))

        TabContent() {
          Column() {
            Tabs({
              index: this.chatTopTabIndex,
              barPosition: BarPosition.Start
            }) {
              TabContent() {
                MessagePage()
              }.tabBar(this.TopTabBuilder("消息",0))
              TabContent() {
                HomePage()
              }.tabBar(this.TopTabBuilder("贴吧",1))
            }
            .scrollable(false) //禁止滑动切换
            .animationDuration(0) //去掉切换页面的动画
          }
        }.tabBar(this.TabBuilder("消息",1))

        TabContent() {
          CreateFigurePage()
        }.tabBar(this.TabBuilder("✚",2))

        TabContent() {
          FMHomePage()
        }.tabBar(this.TabBuilder("电台",3))

        TabContent(){
          YourPage()
        }.tabBar(this.TabBuilder("个人",4))


      }
      .scrollable(false) //禁止滑动切换
      .animationDuration(0) //去掉切换页面的动画
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#121114')
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.BOTTOM,SafeAreaEdge.TOP])
  }

}