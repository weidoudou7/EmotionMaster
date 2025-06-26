// pages/ConversationList.ets
import router from '@ohos.router';
import fs from '@ohos.file.fs';
import promptAction from '@ohos.promptAction';
import { BottomNavBar } from './BottomNavBar';


interface Conversation {
  id: number;
  title: string;
  lastMessage: string;
  time: string;
  unreadCount: number;
}

@Entry
@Component
struct ConversationList {
  // 从路由参数获取情绪信息
  @Link emotionId: number ;
  @Link emotionName: string ;
  @Link emotionEmoji: string ;

  @State conversations: Conversation[] = [];
  @State isLoading: boolean = true;

  aboutToAppear() {
    if (!this.emotionId || !this.emotionName || !this.emotionEmoji) {
      console.error('未接收到情绪参数');
      router.back();
      return;
    }

    // 加载该情绪的对话记录
    this.loadConversations();
  }

  async loadConversations() {
    try {
      // 实际项目中应从本地存储或云端加载对话记录
      // 这里使用模拟数据
      await new Promise<void>(resolve => setTimeout(resolve, 500));

      // 模拟3条对话记录
      this.conversations = [
        {
          id: 1,
          title: `关于${this.emotionName}的讨论`,
          lastMessage: "我今天感到特别快乐，因为完成了一个重要项目",
          time: "10:23",
          unreadCount: 0
        },
        {
          id: 2,
          title: `${this.emotionName}管理技巧`,
          lastMessage: "试试深呼吸和正念练习，可能会有帮助",
          time: "昨天",
          unreadCount: 2
        },
        {
          id: 3,
          title: `分享${this.emotionName}经历`,
          lastMessage: "这种感觉持续多久了？我们可以一起分析一下",
          time: "3天前",
          unreadCount: 0
        }
      ];

      this.isLoading = false;
    } catch (error) {
      console.error(`加载对话记录失败: ${error}`);
      promptAction.showToast({ message: '加载对话记录失败' });
      this.isLoading = false;
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          // 返回按钮

          Image($r('app.media.return'))
            .width(24)
            .height(24)
            .margin({ left: 16 })
            .onClick(() => router.back())


          // 标题（情绪名称）
          Text(`${this.emotionName}${this.emotionEmoji}对话记录`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 12 })

          // 新建对话按钮
          Button('+')
            .width(32)
            .height(32)
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .borderRadius(16)
            .margin({ right: 16 })
            .onClick(() => this.createNewConversation())
        }
        .width('100%')
        .height(56)
        .backgroundColor('#FFFFFF')
        .alignItems(VerticalAlign.Center)
        .shadow({
          offsetX: 0,       // 修改：使用offsetX替代offset.dx
          offsetY: 1,
          radius: 2,
          color: '#0000001A'
        })

        // 加载状态
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .color('#007DFF')
              .width(50)
              .height(50)

            Text('加载中...')
              .fontSize(14)
              .margin({ top: 10 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          // 对话记录列表
          if (this.conversations.length === 0) {
            // 空状态
            Column() {
              Image($r('app.media.return'))
                .width(120)
                .height(120)
                .margin({ bottom: 20 })

              Text('暂无对话记录')
                .fontSize(16)
                .fontColor('#999999')

              Button('开始新对话')
                .width(160)
                .height(40)
                .margin({ top: 30 })
                .backgroundColor('#007DFF')
                .fontColor('#FFFFFF')
                .borderRadius(20)
                .onClick(() => this.createNewConversation())
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          } else {
            // 有对话记录
            List() {
              ForEach(this.conversations, (conversation: Conversation) => {
                ListItem() {
                  // GestureDetector({
                  //   onClick: () => {
                  //     // 跳转到具体对话页面
                  //     router.pushUrl({
                  //       url: 'pages/ChatPage',
                  //       params: {
                  //         emotionId: this.emotionId,
                  //         emotionName: this.emotionName,
                  //         emotionEmoji: this.emotionEmoji,
                  //         conversationId: conversation.id,
                  //         conversationTitle: conversation.title
                  //       }
                  //     });
                  //   }
                  // }) {
                  Row() {
                    // 对话图标（使用情绪图标）
                    Text(this.emotionEmoji)
                      .fontSize(36)
                      .margin({ left: 16 })

                    Column({ space: 4 }) {
                      // 对话标题
                      Text(conversation.title)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      // 最后一条消息
                      Text(conversation.lastMessage)
                        .fontSize(14)
                        .fontColor('#666666')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .margin({ left: 12 })
                    .width('70%')

                    Column({ space: 8 }) {
                      // 最后更新时间
                      Text(conversation.time)
                        .fontSize(12)
                        .fontColor('#999999')

                      // 未读消息数
                      if (conversation.unreadCount > 0) {
                        Text(conversation.unreadCount.toString())
                          .fontSize(12)
                          .fontColor('#FFFFFF')
                          .width(20)
                          .height(20)
                          .backgroundColor('#FF5B5B')
                          .borderRadius(10)
                          .textAlign(TextAlign.Center)
                      }
                    }
                    .margin({ right: 16 })
                  }
                  .width('100%')
                  .height(80)
                  .backgroundColor('#FFFFFF')
                  .onClick(() => {
                    // 跳转到具体对话页面
                    router.pushUrl({
                      url: 'pages/ChatPage',
                      params: {
                        emotionId: this.emotionId,
                        emotionName: this.emotionName,
                        emotionEmoji: this.emotionEmoji,
                        conversationId: conversation.id,
                        conversationTitle: conversation.title
                      }
                    });
                  })
                }
              })
            }
            .width('100%')
            .layoutWeight(1)
            .padding({ bottom: 80 })
          }
        }
      }
      .width('100%')
      .height('100%')
      
      // 底部导航栏
      BottomNavBar({ navIndex: 'planet' })
    }
  }

  // 创建新对话
  createNewConversation() {
    // 实际项目中应创建新对话记录并跳转到对话页面
    promptAction.showToast({ message: '创建新对话' });

    // 模拟创建新对话后跳转到对话页面
    router.pushUrl({
      url: 'pages/ChatPage',
      params: {
        emotionId: this.emotionId,
        emotionName: this.emotionName,
        emotionEmoji: this.emotionEmoji,
        conversationId: Date.now(), // 使用时间戳作为新对话ID
        conversationTitle: `新对话-${this.emotionName}`
      }
    });
  }
}

