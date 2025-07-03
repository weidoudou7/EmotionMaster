import router from '@ohos.router';
import { inputMethod } from '@kit.IMEKit';
import { ApiService } from '../service/apiservice';
import { CreateConversationRequest } from '../common/types';
import { ReadStateCode, TextReader, TextReaderIcon } from '@kit.SpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@ohos.arkui.UIContext';

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
  createdAiRoleId?: number; // 新增
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
  @State private bgImage: string | Resource = $r('app.media.planet1'); // 支持网络图片和本地资源
  @State private agentName: string = '治愈天使'; // 默认设置为治愈天使
  @State private agentSubInfo: string = '5.7万 连接者'; // 智能体副信息
  @State private agentAvatar: string | Resource = $r('app.media.splash'); // TODO: 替换为实际的 agent_avatar 图片资源

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

  @State readStateMap: Map<number, ReadStateCode> = new Map(); // 存储每条消息的朗读状态（key为消息id）
  @State isReaderInit: boolean = false; // 朗读控件初始化状态
  @State readState: ReadStateCode = ReadStateCode.WAITING;

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

  @State private createdAiRoleId: number = 0; // 新增：创建的AI角色ID

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as ChatParams;
    if (params) {
      this.figureImageUrl = params.figureImageUrl || '';
      this.figureType = params.figureType || '';
      this.figureName = params.figureName || '';
      this.isFromCreateFigure = params.isFromCreateFigure || false;
      this.description = params.description || '';
      this.createdAiRoleId = params.createdAiRoleId || 0; // 新增
      // 添加调试日志
      console.log('=== Chat页面接收到的参数 ===');
      console.log('figureImageUrl:', this.figureImageUrl);
      console.log('figureType:', this.figureType);
      console.log('figureName:', this.figureName);
      console.log('isFromCreateFigure:', this.isFromCreateFigure);
      console.log('description:', this.description);
      console.log('createdAiRoleId:', this.createdAiRoleId);
      console.log('========================');
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
        // 只有从CreateFigure页面来的才创建会话记录
        this.createConversationRecord();
      } else if (this.figureName && this.figureImageUrl) {
        this.agentName = this.figureName;
        this.agentSubInfo = `${this.figureType}风格角色`;
        this.bgImage = this.figureImageUrl; // 允许网络图片作为背景
        this.agentAvatar = this.figureImageUrl; // 头像也用同一图片
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
      // 只有默认治愈天使时才创建会话记录
      this.createConversationRecord();
    }
    
    // 新增：自动创建对话记录
    this.createConversationRecord();

    // 新增：初始化时滚动到底部
    setTimeout(() => {
      this.scrollToBottom();
    }, 200); // 延迟200ms确保页面完全加载

    // 初始化朗读控件
    this.initTextReader();
    // 为现有消息初始化朗读状态
    this.chatData.forEach(item => {
      this.readStateMap.set(item.id, ReadStateCode.WAITING);
    });

  }

  // 新增：初始化朗读控件的方法
  private async initTextReader() {
    const context: Context | undefined = this.getUIContext().getHostContext();
    if (!context) {
      console.error(`context is undefined, failed to init TextReader`);
      return;
    }

    // 设置朗读参数（隐藏品牌信息，适配聊天场景）
    const readerParams: TextReader.ReaderParam = {
      isVoiceBrandVisible: false, // 聊天场景无需显示品牌
      businessBrandInfo: {
        panelName: '消息朗读',
        panelIcon: $r('app.media.startIcon')
      }
    };

    // 初始化朗读控件
    TextReader.init(context, readerParams).then(() => {
      console.info(`TextReader succeeded in initializing.`);
      this.isReaderInit = true;
    }).catch((e: BusinessError) => {
      console.error(`TextReader failed to initialize. Code: ${e.code}, message: ${e.message}`);
    })

    // 监听朗读结束事件
    TextReader.on('requestMore', (id: string) => {
      // 根据朗读id找到对应的消息，更新状态为完成
      const msgId = parseInt(id);
      this.readStateMap.set(msgId, ReadStateCode.COMPLETED);
    });

    // // 监听朗读错误事件
    // TextReader.on('error', (e: BusinessError) => {
    //   console.error(`TextReader error: ${e.code}, ${e.message}`);
    // });

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

    // 添加新消息时初始化朗读状态
    this.readStateMap.set(newMessage.id, ReadStateCode.WAITING);
    this.chatData = [...this.chatData, newMessage];
    this.inputText = ''; // 清空输入框
    
    // 新增：滚动到用户消息
    this.scrollToBottom();

    try {
      let aiResponse: string;

        console.log('使用featured_chat接口，描述词:', this.description);
        aiResponse = await ApiService.featuredChat(userMessage, this.chatId, this.description);


      // 添加AI回复消息
      const aiMessage: ChatMessage = {
        id: this.chatData.length + 1,
        isMe: false,
        avatar: $r('app.media.splash'),
        content: aiResponse,
        time: new Date().toLocaleTimeString().slice(0, 5)
      };

      // 为AI消息初始化朗读状态
      this.readStateMap.set(aiMessage.id, ReadStateCode.WAITING);
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

      this.readStateMap.set(errorMessage.id, ReadStateCode.WAITING);
      this.chatData = [...this.chatData, errorMessage];
      
      // 新增：滚动到错误消息
      this.scrollToBottom();
    } finally {
      this.isSending = false;
    }
  }



  /**
   * 新增：自动创建对话记录
   */
  private async createConversationRecord(): Promise<void> {
    try {
      console.log('开始创建对话记录...');

      // 准备对话信息，符合CreateConversationRequest接口
      const conversationData: CreateConversationRequest = {
        userId: 405, //todo 默认用户ID，实际应用中应该从用户登录信息获取
        aiRoleId: this.isFromCreateFigure && this.createdAiRoleId > 0 ? this.createdAiRoleId : 1, // 用新角色ID
        title: `与${this.agentName}的对话`,
        moodTag: 'normal' // 默认心情标签
      };

      console.log('对话数据:', conversationData);

      // 调用API创建对话记录
      const result = await ApiService.createConversation(conversationData);
      console.log('对话记录创建成功:', result);

      // 可以在这里保存返回的conversationId用于后续的消息记录
      if (result && result.id) {
        this.chatId = result.id.toString();
        console.log('更新聊天ID:', this.chatId);
      }

    } catch (error) {
      console.error('创建对话记录失败:', error);
      // 不显示错误提示，避免影响用户体验
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
          .onClick(() => {
            // 跳转到评论页面，传递AI角色信息
            // 获取当前AI角色ID，优先用this.aiRoleId或其它动态来源
            router.pushUrl({
              url: 'pages/chatComment',
              params: {
                aiRoleId: 311, //TODO : 实际为该界面对应的角色id
                aiRoleName: this.agentName,
                aiRoleAvatar: this.isFromCreateFigure && this.figureImageUrl ? this.figureImageUrl : '',
                aiRoleType: this.figureType || 'default',
                aiRoleDescription: this.description || '',
                currentUserId: 405 // TODO:实际应从用户数据获取
              }
            });
            console.log('跳转到评论页面，AI角色ID:', 311, '名称:', this.agentName);
          })

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

            this.buildReaderIcon(item)// 朗读图标（位于文字末尾）
          }
          .padding({ left: 12, right: 8, top: 12, bottom: 12 }) // 右侧内边距减小，避免图标太靠外
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

            this.buildReaderIcon(item)
          }
          .padding({ left: 12, right: 8, top: 12, bottom: 12 })
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

  @Builder
  buildReaderIcon(item: ChatMessage) {

      TextReaderIcon({
        readState: this.readState
        //readState: (this.readStateMap.get(item.id) || ReadStateCode.WAITING) as ReadStateCode
      })
        .width(18)// 缩小图标尺寸，避免突兀
        .height(18)
        .margin({ left: 6 })// 与文本保持左侧间距
        .onClick(async () => {

          const currentState = this.readStateMap.get(item.id) || ReadStateCode.WAITING;
          const readInfo: TextReader.ReadInfo = {
            id: item.id.toString(),
            title: { text: '消息朗读', isClickable: false },
            author: { text: item.isMe ? '自己' : this.agentName, isClickable: false },
            date: { text: item.time, isClickable: false },
            bodyInfo: item.content
          };

          try {
            if (currentState === ReadStateCode.PLAYING) {
              // 正在播放时，点击暂停
              await TextReader.pause();
              this.readStateMap.set(item.id, ReadStateCode.PAUSED);
            } else if (currentState === ReadStateCode.PAUSED) {
              // 暂停时，点击继续
              await TextReader.resume();
              this.readStateMap.set(item.id, ReadStateCode.PLAYING);
            } else {
              // 停止其他消息的朗读
              await TextReader.stop();
              // 开始朗读当前消息
              await TextReader.start([readInfo], readInfo.id);
              // 更新所有消息状态，只保留当前消息为播放中
              this.chatData.forEach(msg => {
                this.readStateMap.set(
                  msg.id,
                  msg.id === item.id ? ReadStateCode.PLAYING : ReadStateCode.WAITING
                );
              });
            }
          } catch (e) {
            console.error(`TextReader error: ${e.code}, ${e.message}`);
          }
        })
     }
}