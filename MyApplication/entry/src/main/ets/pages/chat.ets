interface ChatMessage {
  id: number;
  isMe: boolean; // 是否是自己发送的消息
  avatar: Resource; // 头像资源
  content: string; // 消息内容
  time: string; // 发送时间
}

@Entry
@Component
struct Chat {
  @State private chatData: ChatMessage[] = [
    { id: 1, isMe: false, avatar: $r('app.media.return'), content: '你好呀！今天有空吗？', time: '10:30' },
    { id: 2, isMe: true, avatar: $r('app.media.return'), content: '有的，最近怎么样？', time: '10:32' },
    { id: 3, isMe: false, avatar: $r('app.media.return'), content: '还不错，周末一起吃饭？', time: '10:33' },
  ];

  @State private inputText: string = '';

  private sendMessage() {
    if (this.inputText.trim() === '') return;

    const newMessage: ChatMessage = {
      id: this.chatData.length + 1,
      isMe: true,
      avatar: $r('app.media.return'),
      content: this.inputText,
      time: new Date().toLocaleTimeString().slice(0, 5) // 获取当前时间（如 "14:20"）
    };

    // 更新聊天数据
    this.chatData = [...this.chatData, newMessage];
    this.inputText = ''; // 清空输入框
  }

  build() {

    Stack(){
      Image($r('app.media.bc_blue'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.8) // 设置背景透明度
        .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])


      Column(){

        Row() {
          Image($r('app.media.return')) // 返回按键图片
            .width(20)
            .margin({left: 20})
          //.onClick(()=>{})

          // 2. 中间备注文本（居中）
          Text('备注')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center) // 文本居中
            .layoutWeight(1) // 占据剩余空间，实现居中效果


          Image($r('app.media.return')) // 右侧的图片
            .width(20)
            .height(20)
            .margin({right: 20})
        }
        .width('100%')
        .height(56)
        //.backgroundColor('#F5F5F5') // 背景色
        .backgroundColor('#00FFFFFF') // 透明背景，显示下层的背景图
        .alignItems(VerticalAlign.Center) // 垂直居中
        .border({ width: 1, color: '#DDDDDD' })

        List({ space: 10 }) {
          ForEach(this.chatData, (item: ChatMessage) => {
            ListItem() {
              // 根据 isMe 区分消息左右布局
              if (item.isMe) {
                this.MyMessage(item) // 右侧（自己发送）
              } else {
                this.FriendMessage(item) // 左侧（好友发送）
              }
            }
          }, (item: ChatMessage) => item.id.toString()) // 键生成函数
        }
        .width('100%')
        .layoutWeight(1) // 占据剩余空间
        .backgroundColor('#00FFFFFF') // 透明背景，显示下层的背景图

        Row() {
          TextInput({
            text: this.inputText,
            placeholder: '请输入消息...'
          })

            .height(40)
            .layoutWeight(1)
            .onChange((text: string) => {
              this.inputText = text;
            })

          Button('发送')
            .margin({ left: 8 })
            .onClick(() => this.sendMessage())
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#00FFFFFF') // 透明背景，显示下层的背景图
        .border({ width: 1, color: '#EAEAEA' })

      }
      .width('100%')
      .height('100%')
      .backgroundColor('#00FFFFFF') // 透明背景，显示下层的背景图

    }

  }


  // 好友消息组件（左侧）
  @Builder
  FriendMessage(item: ChatMessage) {
    Row() {
      // 头像
      Image(item.avatar)
        .width(40)
        .height(40)
        .borderRadius(20)
        .margin({ right: 8 })

      // 消息内容+时间
      Column() {
        Text(item.content)
          .fontSize(16)
          .padding(10)
          .backgroundColor('#EAEAEA')
          .borderRadius(8)
        Text(item.time)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .margin({ top: 10 })
  }

  // 我的消息组件（右侧）
  @Builder
  MyMessage(item: ChatMessage) {
    Row() {
      // 消息内容+时间
      Column() {
        Text(item.content)
          .fontSize(16)
          .padding(10)
          .backgroundColor('#1890FF')
          .borderRadius(8)
          .fontColor('#FFFFFF')
        Text(item.time)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }

      // 头像
      Image(item.avatar)
        .width(40)
        .height(40)
        .borderRadius(20)
        .margin({ left: 8 })
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .margin({ top: 10 })
  }
}

