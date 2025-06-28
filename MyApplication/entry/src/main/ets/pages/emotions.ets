import router from '@ohos.router';
import { BottomNavBar } from './BottomNavBar';

interface Emotions {
  id: number;
  name: string;
  emoji: string;
  description: string;
}

@Entry
@Component
struct EmotionList {
  // 定义情绪数据
  private emotions: Emotions[] = [
    {
      id: 1,
      name: "快乐",
      emoji: "😄",
      description: "感到愉悦和满足"
    },
    {
      id: 2,
      name: "悲伤",
      emoji: "😢",
      description: "感到难过和失落"
    },
    {
      id: 3,
      name: "愤怒",
      emoji: "😠",
      description: "感到生气和愤慨"
    },
    {
      id: 4,
      name: "惊讶",
      emoji: "😮",
      description: "因意外而感到震惊"
    },
    {
      id: 5,
      name: "恐惧",
      emoji: "😨",
      description: "感到害怕和不安"
    }
  ];

  build() {

    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.bc_blue'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.8) // 设置背景透明度
        .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])


      Shape() {
        Rect()
      }
      .width('100%')
      .height('100%')
      .fill(Color.Black)
      .opacity(0.3)

      Column() {
        // 页面标题
        Text("情绪列表")
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 30, bottom: 20 })
          .width('100%')
          .textAlign(TextAlign.Center)

        // 情绪列表
        List() {
          ForEach(this.emotions, (emotion: Emotions) => {
            ListItem() {

              Row() {
                // 情绪图标
                Text(emotion.emoji)
                  .fontSize(36)
                  .margin({ left: 20 })

                Column({ space: 3 }) {
                  // 情绪名称
                  Text(emotion.name)
                    .fontSize(20)
                    .fontWeight(FontWeight.Medium)

                  // 情绪描述
                  Text(emotion.description)
                    .fontSize(14)
                    .fontColor('#666666')
                }
                .margin({ left: 15 })
                .width('80%')
              }
              .width('100%')
              .height(80)
              .backgroundColor('#F5F7FA')
              .borderRadius(12)
              .margin({ top: 5, bottom: 5 })
              .onClick(() => {
                // 跳转到对话记录列表，传递情绪ID
                router.pushUrl({
                  url: 'pages/ConversationList',
                  params: {
                    emotionId: emotion.id,
                    emotionName: emotion.name,
                    emotionEmoji: emotion.emoji
                  }
                });
                // .onClick(() => {
                //console.info(点击了情绪: ${emotion.name});
                // 这里可以添加跳转到详情页的逻辑
                //router.pushUrl ({
                // url: 'pages/EmotionDetail',
                // params: {emotionId: emotion.id}
                // });
              })
            }
          })
        }
        .width('90%')
        .margin({ left: 'auto', right: 'auto' })
        .layoutWeight(1)
        .padding({ bottom: 80 })
      }
      .width('100%')
      .height('100%')
      .opacity(0.8)
      

    }
  }
}