import { BottomNavBar } from './BottomNavBar';
import router from '@ohos.router';
import { inputMethod } from '@kit.IMEKit';

interface ChatMessage {
  id: number;
  isMe: boolean; // 是否是自己发送的消息
  avatar: Resource; // 头像资源
  content: string; // 消息内容
  time: string; // 发送时间
  type?: 'text' | 'voice'; // 新增消息类型
  duration?: number; // 语音时长，单位秒
}

// 新增：路由参数接口
interface ChatParams {
  figureImageUrl?: string;
  figureType?: string;
  figureName?: string;
  isFromCreateFigure?: boolean;
}

@Entry
@Component
struct Chat {
  @State private chatData: ChatMessage[] = [
    // 模拟图片中的消息数据
    { id: 1, isMe: false, avatar: $r('app.media.splash'), content: '你好！很高兴认识你！', time: '10:30' }, // TODO: 替换为实际的 user_avatar 图片资源
  ];

  @State private inputText: string = '';
  @State private bgImage: Resource = $r('app.media.planet1'); // TODO: 替换为实际的 chat_bg 图片资源
  @State private agentName: string = '六小只 (有...'; // 智能体昵称
  @State private agentSubInfo: string = '5.7万 连接者'; // 智能体副信息
  @State private agentAvatar: Resource = $r('app.media.splash'); // TODO: 替换为实际的 agent_avatar 图片资源

  @State private scrollOffset: number = 0; // 滚动偏移量
  @State private isHeaderCompact: boolean = false; // 顶部栏是否紧凑
  @State private isInputFocused: boolean = false; // 输入框是否获得焦点

  // 新增：从CreateFigure页面传递的参数
  @State private figureImageUrl: string = '';
  @State private figureType: string = '';
  @State private figureName: string = '';
  @State private isFromCreateFigure: boolean = false;

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as ChatParams;
    if (params) {
      this.figureImageUrl = params.figureImageUrl || '';
      this.figureType = params.figureType || '';
      this.figureName = params.figureName || '';
      this.isFromCreateFigure = params.isFromCreateFigure || false;
      
      // 如果是从CreateFigure页面来的，更新聊天信息
      if (this.isFromCreateFigure && this.figureImageUrl) {
        this.agentName = this.figureName;
        this.agentSubInfo = `${this.figureType}风格角色`;
        
        // 添加欢迎消息
        const welcomeMessage: ChatMessage = {
          id: this.chatData.length + 1,
          isMe: false,
          avatar: $r('app.media.splash'),
          content: `你好！我是${this.figureName}，很高兴认识你！让我们开始聊天吧~`,
          time: new Date().toLocaleTimeString().slice(0, 5)
        };
        this.chatData = [welcomeMessage, ...this.chatData];
      }
    }
  }

  private sendMessage() {
    if (this.inputText.trim() === '') return;

    const newMessage: ChatMessage = {
      id: this.chatData.length + 1,
      isMe: true,
      avatar: $r('app.media.splash'), // TODO: 替换为实际的 my_avatar 图片资源
      content: this.inputText,
      time: new Date().toLocaleTimeString().slice(0, 5) // 获取当前时间（如 "14:20"）
    };

    this.chatData = [...this.chatData, newMessage];
    this.inputText = ''; // 清空输入框
  }

  build() {
    Stack() {
      // 全屏背景图片 (Z-index: 0)
      if (this.isFromCreateFigure && this.figureImageUrl) {
        // 如果是从CreateFigure页面来的，使用人物图片作为背景
        Image(this.figureImageUrl)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .position({ x: 0, y: 0 })
          .zIndex(0)
          .align(Alignment.TopStart) // 确保图片从左上角开始填充
          .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
      } else {
        // 默认背景图片
        Image(this.bgImage)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .position({ x: 0, y: 0 })
          .zIndex(0)
          .align(Alignment.TopStart) // 确保图片从左上角开始填充
          .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
      }
        //.expandSafeArea([SafeAreaType.KEYBOARD]) // 避开键盘区域

      Column() {
        // 顶部信息栏 (Z-index: 1)
        Row() {
          // 左侧：智能体头像和名称/连接者信息
          Row() {
            if (this.isFromCreateFigure && this.figureImageUrl) {
              // 如果是从CreateFigure页面来的，使用人物图片作为头像
              Image(this.figureImageUrl)
                .width(this.isHeaderCompact ? 24 : 30).height(this.isHeaderCompact ? 24 : 30).borderRadius(this.isHeaderCompact ? 12 : 24)
                .margin({ right: this.isHeaderCompact ? 4 : 6 })
                .objectFit(ImageFit.Cover)
            } else {
              // 默认头像
              Image(this.agentAvatar)
                .width(this.isHeaderCompact ? 24 : 30).height(this.isHeaderCompact ? 24 : 30).borderRadius(this.isHeaderCompact ? 12 : 24)
                .margin({ right: this.isHeaderCompact ? 4 : 6 })
            }

            Column() {
              Text(this.agentName)
                .fontSize(this.isHeaderCompact ? 12 : 14).fontWeight(FontWeight.Bold).fontColor(Color.White)
                .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(this.agentSubInfo)
                .fontSize(this.isHeaderCompact ? 8 : 10).fontColor(Color.White).opacity(this.isHeaderCompact ? 0.5 : 0.8)
            }
            .alignItems(HorizontalAlign.Start)


            Image($r('app.media.plus_icon')) // TODO: 替换为实际的 plus_icon 图片资源
              .width(this.isHeaderCompact ? 18 : 25).height(this.isHeaderCompact ? 18 : 25) // 缩小图片


          }
          .alignItems(VerticalAlign.Center)
          .padding(this.isHeaderCompact ? { left: 2, right: 5, top: 2, bottom: 2 } : { left: 2, right: 10, top: 5, bottom: 5 })
          .borderRadius(this.isHeaderCompact ? 24 : 35)
          .backgroundColor('rgba(255,255,255,0.2)')


          Button() {
            Row() {
              Image($r('app.media.message_icon')) // TODO: 替换为实际的 message_icon 图片资源
                .width(this.isHeaderCompact ? 16 : 18).height(this.isHeaderCompact ? 16 : 18).margin({ right: 4 }) // 缩小图片
            }
            .alignItems(VerticalAlign.Center)
            .height('100%')
          }
          .height(this.isHeaderCompact ? 28 : 32).borderRadius(this.isHeaderCompact ? 14 : 16) // 缩小按钮高度
          .backgroundColor('rgba(255,255,255,0.2)')
          .padding(this.isHeaderCompact ? { left: 6, right: 4 } : { left: 8, right: 6})
          .margin({ left: this.isHeaderCompact ? 6 : 8 }) // 调整为左侧间距

          Blank() // 占据剩余空间，将右侧按钮推到最右边

          // 右侧按钮组
          Row() {
            // 菜单按钮
            Button() {
              Image($r('app.media.menu_icon')) // TODO: 替换为实际的 menu_icon 图片资源
                .width(this.isHeaderCompact ? 18 : 20).height(this.isHeaderCompact ? 18 : 20) // 缩小图片
            }
            .height(this.isHeaderCompact ? 28 : 32).borderRadius(this.isHeaderCompact ? 14 : 16) // 缩小按钮高度
            .backgroundColor('rgba(255,255,255,0.2)')
            .padding(this.isHeaderCompact ? { left: 6, right: 6, top: 4, bottom: 4 } : { left: 10, right: 10,top:6,bottom:8}) // 添加左右内边距，使其变为椭圆形
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('96%') // 调整宽度
        .height(this.isHeaderCompact ? 48 : 64) // 动态高度
        .padding(this.isHeaderCompact ? { left: 8, right: 8, top: 4, bottom: 4 } : { left: 8, right: 8, top: 10, bottom: 10 }) // 动态padding
        .margin({ top: this.isHeaderCompact ? 10 : 20, bottom: 10 }) // 调整顶部margin
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween) // 改变布局方式
        .zIndex(1)
        .expandSafeArea([SafeAreaType.KEYBOARD]) // 避开键盘区域

        // 聊天消息列表 (Z-index: 1)
        List({ space: 8 }) {
          ForEach(this.chatData, (item: ChatMessage) => {
            ListItem() {
              if (item.isMe) {
                this.MyMessage(item) // 右侧（自己发送）
              } else {
                this.FriendMessage(item) // 左侧（好友发送）
              }
            }
          }, (item: ChatMessage) => item.id.toString())
        }
        .width('100%')
        .layoutWeight(1) // 占据剩余垂直空间
        .padding({ left: 12, right: 12, top: 0, bottom: 10 }) // 列表本身的padding
        .zIndex(1)
        .expandSafeArea([SafeAreaType.KEYBOARD]) // 避开键盘区域
        .scrollBar(BarState.Off) // 隐藏滚动条
        .edgeEffect(EdgeEffect.Spring) // 添加边缘弹性效果
        .onScroll((offsetX: number, offsetY: number) => {
          // 监听滚动事件，可以用于实现下拉刷新等功能
          console.log('聊天列表滚动位置:', offsetX, offsetY);
        })
        .onReachEnd(() => {
          // 滚动到底部时的回调，可以用于加载更多历史消息
          console.log('已滚动到聊天列表底部');
        })
        .onTouch(() => {
          // 点击消息列表区域收起键盘
          if (this.isInputFocused) {
            let inputMethodController = inputMethod.getController();
            inputMethodController.stopInputSession();
            this.isInputFocused = false;
          }
        })


        // 底部输入区域 (Z-index: 4)
        Row() {
          // 左侧语音按钮
          Image($r('app.media.voice_icon')) // TODO: 替换为实际的 ic_voice 图片资源
            .width(26).height(26)
            .margin({ right: 8 })

          // 输入框
          TextInput({
            text: this.inputText,
            placeholder: '发送消息给' + this.agentName
          })
            .type(InputType.Normal)
            .placeholderColor('#aaa')
            .fontColor(Color.White)
            .fontSize(16)
            .layoutWeight(1) // 占据剩余空间
            .height(48)
            .borderWidth(0) // 设置边框宽度为0，移除边框
            //.backgroundColor('rgba(255,255,255,0.2)')
            //.borderRadius(24)
            .padding({ left: 16, right: 16 })
            .margin({ right: 8 })
            .onChange((text: string) => {
              this.inputText = text;
            })
            .onFocus(() => {
              this.isInputFocused = true;
            })
            .onBlur(() => {
              this.isInputFocused = false;
            })

          // 右侧加号按钮 (用于更多功能)
          Image($r('app.media.ic_add_circle')) // TODO: 替换为实际的 ic_add_circle 图片资源
            .width(30).height(30)
            .onClick(() => {
              // 加号按钮只负责打开更多功能面板，不发送消息
              console.log('打开更多功能面板'); // 待实现
            })
            .margin({ right: 8 })

          // 新增发送按钮（图标替换）
          Image($r('app.media.send_icon'))
            .width(26).height(26)
            .opacity(this.inputText.trim().length > 0 ? 1 : 0.4) // 有内容高亮，无内容变淡
            .onClick(() => {
              if (this.inputText.trim().length > 0) {
                this.sendMessage();
              }
            })
        }
        .height(50)
        .width('100%')
        .padding({ left: 24, right: 24, top: 8, bottom: 8 }) // 调整底部输入区域的左右间距
        .backgroundColor('rgba(0,0,0,0.3)') // 底部输入区背景色
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .zIndex(4)
        .borderRadius(35)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween) // 顶部底部内容分开
      .alignItems(HorizontalAlign.Center)
      .padding({ left:8,right:8, bottom: 30 }) // 移除top padding


      // 底部导航栏 (Z-index: 3)
      Column() {
        // Blank() // 移除 Blank()
        BottomNavBar({ navIndex: 'chat' })
      }
      .width('100%')
      // .height('100%') // 移除此属性
      // .justifyContent(FlexAlign.End) // 移除此属性
      .alignItems(HorizontalAlign.Center)
      .zIndex(3) // 确保在最上层
      .align(Alignment.Bottom) // 确保对齐到 Stack 的底部
    }
  }

  // 好友消息组件（左侧）
  @Builder
  FriendMessage(item: ChatMessage) {
    Row() {
      // Image(item.avatar) // 这里的 avatar 已经从 chatData 里传入，所以不再重复替换 $r
      //   .width(40).height(40).borderRadius(20)
      //   .margin({ right: 8 })

      Column() {
        // 语音时长显示 (如果消息类型是语音)
        if (item.type === 'voice' && item.duration) {
          Column() { // 新增的Column作为语音消息气泡
            Row() {
              Image($r('app.media.splash')) // TODO: 替换为实际的 voice_play_icon 图片资源
                .width(20).height(20).margin({ right: 4 })
              Text(`${item.duration}"`)
                .fontSize(16).fontColor(Color.White)
            }
            .width(item.duration * 6 + 60) // 模拟语音条长度随时间变化
            .height(40)
            .alignItems(VerticalAlign.Center)
            .padding({ left: 10, right: 10, bottom: 12 }) // 调整底部padding

            // Text(item.time) // 已删除
            //   .fontSize(12).fontColor(Color.White)
            //   .opacity(0.7)
            //   .padding({ left: 10, right: 10, bottom: 8, top: 0 }) // 调整时间文本的padding
          }
          .backgroundColor('rgba(26, 26, 26, 0.6)') // 语音条背景色调整为半透明
          .borderRadius(8)
          .alignItems(HorizontalAlign.Start) // 气泡内内容左对齐
          .constraintSize({ maxWidth: '70%' }) // 限制整个气泡的最大宽度
        } else { // 文本消息
          Column() { // 新增的Column作为文本消息气泡
            Text(item.content)
              .fontSize(16)
              .fontColor('#eaeaea')
              .padding({ left: 12, right: 12, top: 12, bottom: 12 }) // 调整内容文本的padding
            // Text(item.time) // 已删除
            //   .fontSize(12).fontColor(Color.White)
            //   .opacity(0.7)
            //   .padding({ left: 12, right: 12, bottom: 8, top: 0 }) // 调整时间文本的padding
          }
          .backgroundColor('rgba(26, 26, 26, 0.6)') // 消息气泡背景色调整为半透明
          .borderRadius(8)
          .alignItems(HorizontalAlign.Start) // 气泡内内容左对齐
          .constraintSize({ maxWidth: '70%' }) // 限制整个气泡的最大宽度
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top) // 顶部对齐
    .padding({ left: 10, right: 10 })
  }

  // 我的消息组件（右侧）
  @Builder
  MyMessage(item: ChatMessage) {
    Row() {
      Column() {
        // 语音时长显示 (如果消息类型是语音)
        if (item.type === 'voice' && item.duration) {
          Column() { // 新增的Column作为语音消息气泡
            Row() {
              Text(`${item.duration}"`)
                .fontSize(16).fontColor(Color.Black)
              Image($r('app.media.splash')) // TODO: 替换为实际的 voice_play_icon 图片资源
                .width(20).height(20).margin({ left: 4 })
            }
            .width(item.duration * 6 + 60) // 模拟语音条长度随时间变化
            .height(40)
            .alignItems(VerticalAlign.Center)
            .padding({ left: 10, right: 10, bottom: 12 }) // 调整底部padding

            // Text(item.time) // 已删除
            //   .fontSize(12).fontColor(Color.Black)
            //   .opacity(0.7)
            //   .padding({ left: 10, right: 10, bottom: 8, top: 0 }) // 调整时间文本的padding
          }
          .backgroundColor('rgba(249, 203, 130, 0.7)') // 语音条背景色调整为半透明
          .borderRadius(8)
          .alignItems(HorizontalAlign.End) // 气泡内内容右对齐
          .constraintSize({ maxWidth: '70%' }) // 限制整个气泡的最大宽度
        } else {
          Column() { // 新增的Column作为文本消息气泡
            Text(item.content)
              .fontSize(16)
              .fontColor(Color.Black)
              .padding({ left: 12, right: 12, top: 12, bottom: 12 }) // 调整内容文本的padding
            // Text(item.time) // 已删除
            //   .fontSize(12).fontColor(Color.Black)
            //   .opacity(0.7)
            //   .padding({ left: 12, right: 12, bottom: 8, top: 0 }) // 调整时间文本的padding
          }
          .backgroundColor('rgba(232, 200, 56, 0.7)') // 消息气泡背景色调整为半透明
          .borderRadius(8)
          .alignItems(HorizontalAlign.End) // 气泡内内容右对齐
          .constraintSize({ maxWidth: '70%' }) // 限制整个气泡的最大宽度
        }
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Top) // 顶部对齐
    .padding({ left: 10, right: 10 })
  }
}

