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
  @State private chatTopTabIndex: number = 2 // 默认"综合"
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
              }.tabBar(this.TopTabBuilder("历史",0))
              TabContent() {
                Chat()
              }.tabBar(this.TopTabBuilder("精选",1))
              TabContent() {
                FeaturedList()
              }.tabBar(this.TopTabBuilder("综合",2))
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