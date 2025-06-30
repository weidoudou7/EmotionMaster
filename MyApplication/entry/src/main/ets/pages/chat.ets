import router from '@ohos.router';
import { inputMethod } from '@kit.IMEKit';
import { ApiService } from '../service/apiservice';

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
  description?: string; // 新增：描述词参数
}

// 新增：治愈天使信息接口
interface HealingAngelInfo {
  image: string;
  name: string;
  desc: string;
  authorName: string;
  views: string;
}

@Entry
@Component
export struct Chat {
  @State private chatData: ChatMessage[] = [
    // 模拟图片中的消息数据
    { id: 1, isMe: false, avatar: $r('app.media.splash'), content: '你好！很高兴认识你！', time: '10:30' }, // TODO: 替换为实际的 user_avatar 图片资源
  ];

  @State private inputText: string = '';
  @State private bgImage: Resource = $r('app.media.planet1'); // TODO: 替换为实际的 chat_bg 图片资源
  @State private agentName: string = '治愈天使'; // 默认设置为治愈天使
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
  @State private description: string = ''; // 新增：描述词
  
  // 新增：聊天相关状态
  @State private isSending: boolean = false; // 是否正在发送消息
  private chatId: string = Date.now().toString(); // 聊天会话ID
  
  // 新增：用于控制滚动的Scroller
  private scrollController: Scroller = new Scroller();

  // 新增：治愈天使的默认信息
  private healingAngelInfo: HealingAngelInfo = {
    image: 'https://image.pollinations.ai/prompt/A%20serene%20angel%20with%20luminous%20white%20wings%2C%20kneeling%20beside%20a%20sick%20child%20in%20a%20hospital%20bed.%20Her%20hands%20glow%20with%20a%20soft%20golden%20light%20as%20she%20channels%20healing%20energy.%20The%20room%20is%20bathed%20in%20warm%20light%2C%20and%20the%20child%20smiles%20weakly%20as%20the%20pain%20fades?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
    name: '治愈天使',
    desc: '你是人间最温柔的治愈者，眉梢轻扬时仿佛春风吻过湖面，漾起粼粼波光。那双含笑的眼睛盛着揉碎的星光，眼尾微弯的弧度恰似新月悬于暮色，将阴霾化作流萤翩跹。当你伸出指尖，空气便绽放透明的铃兰，每一缕气息都浸透晨露的澄澈，连袖口掠过的风都带着安眠曲的韵律。\n' +
      '\n' +
      '你的声音是融化的蜜糖裹着雪松香，轻柔地熨平灵魂的褶皱。发丝间流淌的光晕像被天使吻过的金箔，连最细微的鬓角都跳跃着治愈的频率。当你的臂弯展开，战栗的心跳会沉入蓬松的云絮，所有伤痕都在你哼唱的摇篮曲中结痂成珍珠。\n' +
      '\n' +
      '你是神明写给尘世的情书——\n' +
      '以虹彩为墨，羽翼为笺，\n' +
      '每个字句都生长着永不凋零的春天。\n' +
      '你让迷途者找到归途，\n' +
      '让破碎的心重新学会跳动。',
    authorName: '温柔守护',
    views: '5.6万'
  };

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as ChatParams;
    if (params) {
      this.figureImageUrl = params.figureImageUrl || '';
      this.figureType = params.figureType || '';
      this.figureName = params.figureName || '';
      this.isFromCreateFigure = params.isFromCreateFigure || false;
      this.description = params.description || ''; // 新增：获取描述词
      
      // 添加调试日志
      console.log('=== Chat页面接收到的参数 ===');
      console.log('figureImageUrl:', this.figureImageUrl);
      console.log('figureType:', this.figureType);
      console.log('figureName:', this.figureName);
      console.log('isFromCreateFigure:', this.isFromCreateFigure);
      console.log('description:', this.description);
      console.log('========================');
      
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
    } else {
      // 如果没有传递参数，使用治愈天使作为默认设置
      console.log('=== 使用治愈天使作为默认设置 ===');
      this.figureImageUrl = this.healingAngelInfo.image;
      this.figureType = this.healingAngelInfo.name;
      this.figureName = this.healingAngelInfo.name;
      this.isFromCreateFigure = true;
      this.description = this.healingAngelInfo.desc;
      this.agentName = this.healingAngelInfo.name;
      this.agentSubInfo = `${this.healingAngelInfo.authorName} · ${this.healingAngelInfo.views} 连接者`;
      
      // 添加治愈天使的欢迎消息
      const welcomeMessage: ChatMessage = {
        id: this.chatData.length + 1,
        isMe: false,
        avatar: $r('app.media.splash'),
        content: `你好！我是治愈天使，用微笑和温柔治愈人心的天使。无论你遇到什么困难，我都会陪伴在你身边，给你温暖和力量。让我们开始聊天吧~`,
        time: new Date().toLocaleTimeString().slice(0, 5)
      };
      this.chatData = [welcomeMessage, ...this.chatData];
      
      console.log('治愈天使默认设置完成');
    }
    
    // 新增：初始化时滚动到底部
    setTimeout(() => {
      this.scrollToBottom();
    }, 200); // 延迟200ms确保页面完全加载
  }

  private async sendMessage() {
    if (this.inputText.trim() === '' || this.isSending) return;

    const userMessage = this.inputText.trim();
    this.isSending = true;

    // 添加用户消息
    const newMessage: ChatMessage = {
      id: this.chatData.length + 1,
      isMe: true,
      avatar: $r('app.media.splash'), // TODO: 替换为实际的 my_avatar 图片资源
      content: userMessage,
      time: new Date().toLocaleTimeString().slice(0, 5) // 获取当前时间（如 "14:20"）
    };

    this.chatData = [...this.chatData, newMessage];
    this.inputText = ''; // 清空输入框
    
    // 新增：滚动到用户消息
    this.scrollToBottom();

    try {
      let aiResponse: string;
      
      // 如果是从CreateFigure页面来的且有描述词，使用featured_chat接口
      if (this.isFromCreateFigure && this.description) {
        console.log('使用featured_chat接口，描述词:', this.description);
        aiResponse = await ApiService.featuredChat(userMessage, this.chatId, this.description);
      } else {
        console.log('使用普通AI聊天接口，figureType:', this.figureType || 'default');
        // 否则使用普通的AI聊天接口
        aiResponse = await ApiService.chatWithAI(userMessage, this.chatId, this.figureType || 'default');
      }

      // 添加AI回复消息
      const aiMessage: ChatMessage = {
        id: this.chatData.length + 1,
        isMe: false,
        avatar: $r('app.media.splash'),
        content: aiResponse,
        time: new Date().toLocaleTimeString().slice(0, 5)
      };

      this.chatData = [...this.chatData, aiMessage];
      
      // 新增：滚动到AI回复消息
      this.scrollToBottom();
    } catch (error) {
      console.error('AI回复失败:', error);
      
      // 添加错误提示消息
      const errorMessage: ChatMessage = {
        id: this.chatData.length + 1,
        isMe: false,
        avatar: $r('app.media.splash'),
        content: '抱歉，我现在无法回复，请稍后再试。',
        time: new Date().toLocaleTimeString().slice(0, 5)
      };

      this.chatData = [...this.chatData, errorMessage];
      
      // 新增：滚动到错误消息
      this.scrollToBottom();
    } finally {
      this.isSending = false;
    }
  }

  /**
   * 新增：滚动到聊天列表底部
   */
  private scrollToBottom(): void {
    // 使用setTimeout确保UI更新完成后再滚动
    setTimeout(() => {
      try {
        // 使用Scroller的scrollTo方法滚动到底部
        this.scrollController.scrollTo({ xOffset: 0, yOffset: 999999 });
        console.log('已触发滚动到聊天列表底部');
      } catch (error) {
        console.error('滚动到底部失败:', error);
      }
    }, 100); // 延迟100ms确保消息已渲染
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
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      } else {
        // 默认背景图片
        Image(this.bgImage)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .position({ x: 0, y: 0 })
          .zIndex(0)
          .align(Alignment.TopStart) // 确保图片从左上角开始填充
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }

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
        Scroll(this.scrollController) {
          Column({ space: 8 }) {
            ForEach(this.chatData, (item: ChatMessage) => {
              if (item.isMe) {
                this.MyMessage(item) // 右侧（自己发送）
              } else {
                this.FriendMessage(item) // 左侧（好友发送）
              }
            }, (item: ChatMessage) => item.id.toString())
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 0, bottom: 10 })
        }
        .width('100%')
        .layoutWeight(1) // 占据剩余垂直空间
        .zIndex(1)
        .expandSafeArea([SafeAreaType.KEYBOARD]) // 避开键盘区域
        .scrollBar(BarState.Off) // 隐藏滚动条
        .edgeEffect(EdgeEffect.Spring) // 添加边缘弹性效果
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
            .padding({ left: 16, right: 16 })
            .margin({ right: 8 })
            .onChange((text: string) => {
              this.inputText = text;
            })
            .onFocus(() => {
              this.isInputFocused = true;
              // 新增：输入框获得焦点时滚动到底部
              this.scrollToBottom();
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
          if (this.isSending) {
            // 发送中状态
            LoadingProgress()
              .width(26)
              .height(26)
              .color(Color.White)
          } else {
            // 正常发送按钮
            Image($r('app.media.send_icon'))
              .width(26)
              .height(26)
              .opacity(this.inputText.trim().length > 0 ? 1 : 0.4) // 有内容高亮，无内容变淡
              .onClick(() => {
                if (this.inputText.trim().length > 0) {
                  this.sendMessage();
                }
              })
          }
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
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .zIndex(3) // 确保在最上层
      .align(Alignment.Bottom) // 确保对齐到 Stack 的底部
    }
  }

  // 好友消息组件（左侧）
  @Builder
  FriendMessage(item: ChatMessage) {
    Row() {
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