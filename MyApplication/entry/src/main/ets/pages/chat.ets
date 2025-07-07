import router from '@ohos.router';
import { inputMethod } from '@kit.IMEKit';
import { ApiService } from '../service/apiservice';
import { CreateConversationRequest } from '../common/types';
import { ReadStateCode, TextReader, TextReaderIcon } from '@kit.SpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@ohos.arkui.UIContext';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import SpeechRecognizerManager from '../utils/SpeechRecognizerManager'
import { Permissions } from '@kit.AbilityKit'
import { AudioCapturerManager } from '../utils/AudioCapturerManager'
import { getUserId } from '../common/constants';
import promptAction from '@ohos.promptAction';
import { globalUserData } from '../models/userdata';

// 新增：点赞图标接口
interface LikeIcon {
  x: number;
  y: number;
  initialX: number;
  initialY: number;
  radius: number;
  emoji: string;
  fontSize: number;
  opacity: number;
  createTime: number;
  lifespan: number;
  scale: number;
  initialScale: number;
  maxScale: number;
  maxOffset: number;
  direction: number;
}

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
  isFromNavBar?: boolean; // 新增：是否从导航栏进入
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
  @State private isFromNavBar: boolean = false; // 新增：是否从导航栏进入
  @State private isVoiceMode: boolean = false;
  @State private isRecording: boolean = false;
  @State private showRecordPanel: boolean = false;
  @State private recordDuration: number = 0;
  @State private isCancelRecord: boolean = false;
  @State private touchStartY: number = 0;
  @State private fileName: string = '';
  @State private volumeLevel: number = 0; // 可选：用于声波动画
  private recordTimer: number = 0;
  private volumeTimer: number = 0;
  @State private hasMicrophonePermission: boolean = false; // 新增：麦克风权限状态

  @State private showExtraInputs: boolean = false; // 控制空白栏显示
  @State private replySuggestions: string[] = ['', '', '']; // 回复建议数组
  @State private isLoadingSuggestions: boolean = false; // 是否正在加载回复建议

  // 新增：角色入场动画相关状态
  @State private _showIntroAnimation: boolean = false; // 是否显示入场动画
  @State private _introOpacity: number = 0.0; // 入场动画透明度
  @State private _introScale: number = 0.8; // 入场动画缩放
  @State private _introOffsetY: number = 50; // 入场动画Y偏移
  @State private _introRotate: number = 15; // 入场动画旋转
  @State private _introNameOpacity: number = 0.0; // 名称透明度
  @State private _introNameOffsetY: number = 20; // 名称Y偏移
  @State private _introBgOpacity: number = 0.3; // 背景图片不透明度
  @State private _introCenterOpacity: number = 1.0; // 中央图片不透明度
  @State private _introCenterScale: number = 1.0; // 中央图片缩放

  // 新增：点赞特效相关状态
  @State private likeIcons: LikeIcon[] = []; // 存储所有点赞图标
  @State private isLikeEffectEnabled: boolean = false; // 控制点赞特效的开启/关闭
  private animationId: number = 0; // 动画ID
  private screenWidth: number = 400; // 屏幕宽度
  private screenHeight: number = 800; // 屏幕高度
  private readonly emojis: string[] = [
    '❤️', '🧡', '💛', '💚', '💙', '💜',
    '🐻', '🐼', '🐨', '🦁', '🐯', '🦊',
    '🎁', '🎀', '🎉', '🎊', '✨', '⭐'
  ];

  // 新增：Canvas相关
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  aboutToAppear() {
    console.log('当前环境:', this.isVirtualMachine() ? '虚拟机' : '真机');

    // 检查麦克风权限
    this.checkMicrophonePermission();

    // 初始化语音识别引擎
    this.initSpeechRecognition();

    // 获取路由参数
    const params = router.getParams() as ChatParams;
    if (params) {
      this.figureImageUrl = params.figureImageUrl || '';
      this.figureType = params.figureType || '';
      this.figureName = params.figureName || '';
      this.isFromCreateFigure = params.isFromCreateFigure || false;
      this.description = params.description || '';
      this.createdAiRoleId = params.createdAiRoleId || 0; // 新增
      this.isFromNavBar = params.isFromNavBar || false; // 新增
      // 添加调试日志
      console.log('=== Chat页面接收到的参数 ===');
      console.log('figureImageUrl:', this.figureImageUrl);
      console.log('figureType:', this.figureType);
      console.log('figureName:', this.figureName);
      console.log('isFromCreateFigure:', this.isFromCreateFigure);
      console.log('description:', this.description);
      console.log('createdAiRoleId:', this.createdAiRoleId);
      console.log('========================');
      if (this.figureImageUrl) {
        this.agentName = this.figureName;
        this.agentSubInfo = `${this.figureType}风格角色`;
        this.bgImage = this.figureImageUrl; // 设置背景图片为角色图片
        this.agentAvatar = this.figureImageUrl; // 设置头像为角色图片
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
      this.bgImage = this.figureImageUrl; // 设置背景图片为治愈天使图片
      this.agentAvatar = this.figureImageUrl; // 设置头像为治愈天使图片

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

    // 每次进入chat时都调用createConversationRecord
    console.log('=== 每次进入chat时都创建/查找对话记录 ===');
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

    // 新增：启动点赞动画循环
    this.startLikeAnimation();

    // 新增：角色入场动画
    if (this.figureImageUrl) {
      this._showIntroAnimation = true;
      this.startIntroAnimation();
    }
  }

  // 新增：组件销毁时清理动画
  aboutToDisappear() {
    // 清除动画循环
    clearInterval(this.animationId);
  }

  // 新增：角色入场动画方法
  private startIntroAnimation() {
    // 延迟100ms开始动画
    setTimeout(() => {
      animateTo({ duration: 800, curve: Curve.Ease }, () => {
        this._introOpacity = 1.0;
        this._introScale = 1.0;
        this._introOffsetY = 0;
        this._introRotate = 0;
      });
    }, 100);

    // 延迟500ms显示名称
    setTimeout(() => {
      animateTo({ duration: 500, curve: Curve.Ease }, () => {
        this._introNameOpacity = 1.0;
        this._introNameOffsetY = 0;
      });
    }, 500);

    // 背景图片逐渐加深动画（与中央图片淡出同步）
    setTimeout(() => {
      animateTo({ duration: 900, curve: Curve.EaseInOut }, () => {
        this._introBgOpacity = 0.8; // 先加深到0.8
        this._introCenterOpacity = 0.0;
        this._introCenterScale = 0.0;
      });
    }, 1400);

    // 背景图片继续加深到完全不透明
    setTimeout(() => {
      animateTo({ duration: 600, curve: Curve.EaseInOut }, () => {
        this._introBgOpacity = 1.0; // 最终完全不透明
      });
    }, 2300);

    // 动画结束后隐藏入场动画层
    setTimeout(() => {
      this._showIntroAnimation = false;
    }, 3000); // 延长总动画时间
  }

  // 新增：点赞特效相关方法
  // 创建一个图标对象
  private createLikeIcon(x: number, y: number, radius: number, emoji: string): LikeIcon {
    // 为图标生成随机属性
    const initialScale = 0.4 + Math.random() * 0.2 // 初始缩放比例0.4-0.6
    const maxScale = 1.0 + Math.random() * 0.3 // 最大缩放比例1.0-1.3
    // 减小摆动幅度，改为最大8-15像素
    const maxOffset = 8 + Math.random() * 7 // 最大摆动幅度8-15像素
    // 随机决定初始摆动方向
    const direction = Math.random() > 0.5 ? 1 : -1

    return {
      x: x,
      y: y,
      initialX: x, // 记录初始X坐标
      initialY: y, // 记录初始Y坐标
      radius: radius,
      emoji: emoji,
      fontSize: Math.floor(radius * 1.2),
      opacity: 1.0,
      createTime: Date.now(),
      lifespan: 1000, // 1秒钟生命周期
      scale: initialScale, // 当前缩放比例
      initialScale: initialScale, // 初始缩放比例
      maxScale: maxScale, // 最大缩放比例
      maxOffset: maxOffset, // 最大摆动幅度
      direction: direction // 初始摆动方向
    }
  }

  // 获取随机emoji
  private getRandomEmoji(): string {
    return this.emojis[Math.floor(Math.random() * this.emojis.length)]
  }

  // 添加新的点赞图标
  private addLikeIcon(x: number, y: number) {
    console.info(`尝试添加点赞图标: ${x}, ${y}, 特效状态: ${this.isLikeEffectEnabled}`);

    // 只有在特效开启时才添加图标
    if (!this.isLikeEffectEnabled) {
      console.info('特效未开启，跳过添加图标');
      return;
    }

    const radius = 80 + Math.random() * 20 // 随机大小80-100
    const emoji = this.getRandomEmoji()

    this.likeIcons.push(this.createLikeIcon(x, y, radius, emoji))
    console.info(`成功添加点赞图标，当前图标数量: ${this.likeIcons.length}`);

    // 确保动画循环正在运行
    if (!this.animationId) {
      console.info('启动动画循环');
      this.startLikeAnimation();
    }
  }

  // 新增：手动触发点赞特效的方法
  public triggerLikeEffect(x?: number, y?: number) {
    console.info(`触发点赞特效，当前状态: ${this.isLikeEffectEnabled}`);

    // 只有在特效开启时才触发
    if (!this.isLikeEffectEnabled) {
      console.info('特效未开启，跳过触发');
      return;
    }

    // 如果没有指定坐标，使用屏幕中心
    const centerX = x || (this.screenWidth / 2)
    const centerY = y || (this.screenHeight / 2)

    console.info(`手动触发点赞特效: ${centerX}, ${centerY}`)

    // 在指定位置添加多个点赞图标
    this.addLikeIcon(centerX, centerY)

    // 在周围添加一些随机偏移的图标
    for (let i = 0; i < 5; i++) {
      const offsetX = centerX + (Math.random() - 0.5) * 100
      const offsetY = centerY + (Math.random() - 0.5) * 100
      this.addLikeIcon(offsetX, offsetY)
    }
  }

  // 新增：清除所有点赞特效的方法
  public clearAllLikeEffects() {
    console.info('清除所有点赞特效');
    this.likeIcons = [];

    // 停止动画循环
    if (this.animationId) {
      clearInterval(this.animationId);
      this.animationId = 0;
    }
  }

  // 开始点赞动画循环
  private startLikeAnimation() {
    this.animationId = setInterval(() => {
      this.updateLikeIcons()
      this.drawAllLikeIcons()
    }, 16) // 约60fps的刷新率
  }

  // 更新所有图标状态
  private updateLikeIcons() {
    const currentTime = Date.now()
    const newIcons: LikeIcon[] = []

    for (let icon of this.likeIcons) {
      // 计算图标已存在的时间
      const existTime = currentTime - icon.createTime

      if (existTime < icon.lifespan) {
        // 计算存在时间比例
        const progress = existTime / icon.lifespan

        // 1. 更新Y坐标 - 向上移动，速度变化更明显
        const verticalDistance = 120 * Math.pow(progress, 0.7) // 使用幂函数让上升更快
        icon.y = icon.initialY - verticalDistance

        // 2. 更新X坐标 - 快速的左右摆动
        // 每0.25秒一个阶段，总共1秒4个阶段
        let horizontalOffset = 0;

        if (progress < 0.25) {
          // 0-0.25s: 无偏移，专注于放大
          horizontalOffset = 0;
        } else if (progress < 0.5) {
          // 0.25-0.5s: 向左偏移
          const phaseProgress = (progress - 0.25) / 0.25;
          horizontalOffset = -icon.maxOffset * phaseProgress * icon.direction;
        } else if (progress < 0.75) {
          // 0.5-0.75s: 从向左偏移变为向右偏移
          const phaseProgress = (progress - 0.5) / 0.25;
          horizontalOffset = icon.maxOffset * (2 * phaseProgress - 1) * icon.direction;
        } else {
          // 0.75-1s: 从向右偏移回到向左偏移
          const phaseProgress = (progress - 0.75) / 0.25;
          horizontalOffset = icon.maxOffset * (1 - 2 * phaseProgress) * icon.direction;
        }

        icon.x = icon.initialX + horizontalOffset;

        // 3. 更新缩放比例 - 快速放大
        // 在生命周期的前20%阶段(0.2s)，缩放从initialScale增大到maxScale
        if (progress < 0.2) {
          // 平滑插值从initialScale到maxScale
          icon.scale = icon.initialScale + (icon.maxScale - icon.initialScale) * (progress / 0.2)
        } else {
          // 保持maxScale
          icon.scale = icon.maxScale
        }

        // 4. 更新透明度 - 前60%保持不变，后40%逐渐消失
        if (progress > 0.6) {
          // 在最后40%的生命周期内改变透明度，使消失更快
          icon.opacity = 1.0 - ((progress - 0.6) / 0.4)
        } else {
          icon.opacity = 1.0
        }

        // 保留未完成生命周期的图标
        newIcons.push(icon)
      }
    }

    // 更新图标数组
    this.likeIcons = newIcons

    // 如果没有图标了，停止动画循环
    if (this.likeIcons.length === 0) {
      // 停止动画循环
      if (this.animationId) {
        clearInterval(this.animationId);
        this.animationId = 0;
      }
    }
  }

  // 绘制所有点赞图标
  private drawAllLikeIcons() {
    // 清除画布
    this.context.clearRect(0, 0, this.context.width, this.context.height)

    console.info(`绘制图标，当前图标数量: ${this.likeIcons.length}`);

    // 绘制所有图标
    for (let icon of this.likeIcons) {
      this.context.save()

      // 设置透明度
      this.context.globalAlpha = icon.opacity

      // 设置缩放（从中心点缩放）
      this.context.translate(icon.x, icon.y)
      this.context.scale(icon.scale, icon.scale)
      this.context.translate(-icon.x, -icon.y)

      // 绘制emoji
      this.context.font = `${icon.fontSize}px`
      this.context.textAlign = 'center'
      this.context.textBaseline = 'middle'
      this.context.fillText(icon.emoji, icon.x, icon.y)

      this.context.restore()
    }
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

      // 新增：在AI回复后延迟进行情绪分析（等待消息保存到数据库）
      setTimeout(() => {
        this.analyzeEmotion();
      }, 2000); // 延迟2秒，确保消息已保存到数据库
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

      const userId = getUserId(); //todo 默认用户ID，实际应用中应该从用户登录信息获取

      // 检查用户ID是否有效
      if (userId === null) {
        console.warn('用户ID为空，无法创建对话记录');
        return;
      }

      const aiRoleId = this.createdAiRoleId; //角色ID
      const title = `与${this.agentName}的对话`;

      console.log('查找或创建对话 - 用户ID:', userId, 'AI角色ID:', aiRoleId, '标题:', title);

      // 使用findOrCreateConversation方法，自动处理查找和创建逻辑
      const conversation = await ApiService.findOrCreateConversation(userId, aiRoleId, title);

      if (conversation && conversation.id) {
        this.chatId = conversation.id.toString();
        console.log('对话ID已设置:', this.chatId);
      } else {
        console.error('对话创建失败，未获取到有效的对话ID');
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

  /**
   * 新增：分析对话情绪
   */
  private async analyzeEmotion(): Promise<void> {
    try {
      // 检查是否有有效的对话ID
      if (!this.chatId || this.chatId === '0' || this.chatId === Date.now().toString()) {
        console.log('对话ID无效，跳过情绪分析');
        return;
      }

      // 检查消息数量，只有当消息数量达到一定数量时才进行分析
      if (this.chatData.length < 4) { // 至少需要2轮对话（4条消息）
        console.log('消息数量不足，跳过情绪分析');
        return;
      }

      console.log('开始分析对话情绪，对话ID:', this.chatId, '消息数量:', this.chatData.length);

      // 调用情绪分析API
      const emotionResult = await ApiService.analyzeConversationEmotion(parseInt(this.chatId));

      console.log('情绪分析结果:', emotionResult);

      // 可以在这里添加情绪显示逻辑，比如在界面上显示当前情绪
      // 例如：this.currentEmotion = emotionResult;

    } catch (error) {
      console.error('情绪分析失败:', error);
      // 不显示错误提示，避免影响用户体验
    }
  }

  /**
   * 新增：生成回复建议
   */
  private async generateReplySuggestions(): Promise<void> {
    try {
      // 检查是否有有效的对话ID
      if (!this.chatId || this.chatId === '0' || this.chatId === Date.now().toString()) {
        console.log('对话ID无效，跳过生成回复建议');
        return;
      }

      // 检查消息数量，只有当消息数量达到一定数量时才生成建议
      if (this.chatData.length < 2) { // 至少需要1轮对话（2条消息）
        console.log('消息数量不足，跳过生成回复建议');
        return;
      }

      this.isLoadingSuggestions = true;
      console.log('开始生成回复建议，对话ID:', this.chatId, '消息数量:', this.chatData.length);

      // 调用生成回复建议API
      const suggestions = await ApiService.generateReplySuggestions(parseInt(this.chatId));

      console.log('回复建议生成结果:', suggestions);

      // 更新回复建议数组
      if (suggestions && suggestions.length > 0) {
        this.replySuggestions = suggestions.slice(0, 3); // 只取前3个建议
        // 如果不足3个，用空字符串补齐
        while (this.replySuggestions.length < 3) {
          this.replySuggestions.push('');
        }
      }

    } catch (error) {
      console.error('生成回复建议失败:', error);
      // 设置默认回复建议
      this.replySuggestions = ['我理解你的感受', '需要聊聊吗？', '我在这里陪着你'];
    } finally {
      this.isLoadingSuggestions = false;
    }
  }

  build() {
    Stack() {
      // 全屏背景图片 (Z-index: 1) - 只在没有角色图片时显示
      if (!this.figureImageUrl) {
        Image(this.bgImage)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .position({ x: 0, y: 0 })
          .zIndex(1)
          .align(Alignment.TopStart)
          .expandSafeArea([SafeAreaType.KEYBOARD]) // 新增：让背景图片扩展到键盘区域
      }

      if (this.figureImageUrl) {
        Stack() {
          // 背景大图 - 动画结束后保持显示
          Image(this.figureImageUrl)
            .clipShape(new Rect({ width: '100%', height: '100%' }))
            .width('100%')
            .height('100%')
              //.clipShape(new Rect({ width: '500px', height: '280px' })
            .objectFit(ImageFit.Cover)
            .position({ x: 0, y: 0 })
            .align(Alignment.TopStart) // 确保图片从左上角开始填充
            .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]) // 新增：让背景图片扩展到键盘区域
            .opacity(this._showIntroAnimation ? this._introBgOpacity : 1.0) // 动画时使用动画透明度，结束后保持完全不透明
            .zIndex(0)


          // 渐变背景 - 只在动画进行时显示
          if (this._showIntroAnimation) {
            Row()
              .width('100%')
              .height('100%')
              .backgroundImage('linear-gradient(135deg, #f8b6d8 0%, #fbeee6 100%)')
          }

          // 中央角色卡片 - 只在动画进行时显示
          if (this._showIntroAnimation) {
            Column() {
              Blank().height('1fr')

              Row() {
                Column() {
                  Image(this.figureImageUrl ?? '')
                    .width(320)
                    .height(180)
                    .borderRadius(12)
                    .objectFit(ImageFit.Cover)
                    .opacity(this._introOpacity * this._introCenterOpacity)
                }
                .backgroundColor('#fff')
                .borderRadius(16)
                .border({ width: 4, color: '#fff' })
                .shadow({ radius: 24, color: '#00000044', offsetX: 0, offsetY: 12 })
                .padding(6)
                .scale({ x: this._introScale * this._introCenterScale, y: this._introScale * this._introCenterScale })
                .translate({ x: 0, y: this._introOffsetY })
                .rotate({ angle: this._introRotate })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)

              // 角色名称
              Text(this.figureName || '')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .margin({ top: 20 })
                .opacity(this._introNameOpacity)
                .translate({ x: 0, y: this._introNameOffsetY })

              Blank().height('1fr')
            }
            .width('100%')
            .height('100%')
          }
        }
        .width('100%')
        .height('100%')
        .zIndex(this._showIntroAnimation ? 5 : 0) // 动画时z-index为5，结束后为1
      }


      Column() {
        // 只有在不显示入场动画时才显示聊天界面内容
        if (!this._showIntroAnimation) {
          // 顶部信息栏 (Z-index: 2)
          Row() {
            // 左侧：智能体头像和名称/连接者信息
            Image($r('app.media.back'))
              .width(25)
              .onClick(() => router.back());
            Row() {
              Image(this.agentAvatar)
                .width(this.isHeaderCompact ? 24 : 30).height(this.isHeaderCompact ? 24 : 30).borderRadius(this.isHeaderCompact ? 12 : 24)
                .margin({ right: this.isHeaderCompact ? 4 : 6 })
                .objectFit(ImageFit.Cover)
                .onClick(() => {
                  // 跳转到人物简介页面，传递AI角色参数
                  router.pushUrl({
                    url: 'pages/ProfilePage',
                    params: {
                      figureImageUrl: this.figureImageUrl,
                      figureType: this.figureType,
                      figureName: this.figureName,
                      description: this.description,
                      createdAiRoleId: this.createdAiRoleId,
                    }
                  });
                })

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

            // 点赞按钮
            Button() {
              Row() {
                Text(this.isLikeEffectEnabled ? '💖' : '🤍') // 根据状态显示不同的爱心图标
                  .fontSize(this.isHeaderCompact ? 14 : 16)
                  .fontWeight(FontWeight.Bold)
              }
              .alignItems(VerticalAlign.Center)
              .height('100%')
            }
            .height(this.isHeaderCompact ? 28 : 32).borderRadius(this.isHeaderCompact ? 14 : 16) // 缩小按钮高度
            .backgroundColor(this.isLikeEffectEnabled ? 'rgba(255,100,100,0.3)' : 'rgba(255,255,255,0.2)') // 根据状态改变背景色
            .padding(this.isHeaderCompact ? { left: 6, right: 4 } : { left: 8, right: 6})
            .margin({ left: this.isHeaderCompact ? 6 : 8 }) // 调整为左侧间距
            .onClick(() => {
              console.info('爱心按钮被点击');
              // 切换点赞特效的开启/关闭状态
              this.isLikeEffectEnabled = !this.isLikeEffectEnabled;
              console.log('点击点赞按钮，点赞特效状态:', this.isLikeEffectEnabled ? '开启' : '关闭');

              if (this.isLikeEffectEnabled) {
                // 开启特效时，启动动画循环并触发一次特效作为视觉反馈
                console.info('开启点赞特效');
                if (!this.animationId) {
                  this.startLikeAnimation();
                }
                this.triggerLikeEffect();
              } else {
                // 关闭特效时，清除所有现有的特效
                console.info('关闭点赞特效');
                this.clearAllLikeEffects();
              }
            })

            // 消息按钮
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
                  aiRoleId: this.createdAiRoleId,
                  aiRoleName: this.agentName,
                  aiRoleAvatar: this.agentAvatar,
                  aiRoleType: this.figureType || 'default',
                  aiRoleDescription: this.description || '',
                  currentUserId: ApiService.getUserIdByUID(globalUserData.userUID)
                }
              });
              console.log('跳转到评论页面，AI角色ID:', this.createdAiRoleId, '名称:', this.agentName);
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
          .width('100%') // 调整宽度
          .height(this.isHeaderCompact ? 48 : 64) // 动态高度
          //.padding(this.isHeaderCompact ? { left: 8, right: 8, bottom: 4 } : { left: 8, right: 8, bottom: 10 }) // 动态padding
          //.margin({ top: this.isFromNavBar ? (this.isHeaderCompact ? 70 : 80) : (this.isHeaderCompact ? 10 : 20), bottom: 10 }) // 根据进入方式调整顶部margin
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween) // 改变布局方式
          .zIndex(10) // 提高z-index，确保在背景之上
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]) // 避开顶部系统安全区域
          .expandSafeArea([SafeAreaType.KEYBOARD])


          // 聊天消息列表 (Z-index: 2)
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
            .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          }
          .width('100%')
          .expandSafeArea([SafeAreaType.KEYBOARD])
          .layoutWeight(1) // 占据剩余垂直空间
          .zIndex(5) // 提高z-index，确保在背景之上
          //.expandSafeArea([SafeAreaType.KEYBOARD]) // 避开键盘区域
          .scrollBar(BarState.Off) // 隐藏滚动条
          .edgeEffect(EdgeEffect.Spring) // 添加边缘弹性效果
          .onReachEnd(() => {
            // 滚动到底部时的回调，可以用于加载更多历史消息
            console.log('已滚动到聊天列表底部');
          })
          .onClick((event: ClickEvent) => {
            // 点击消息列表区域收起键盘
            if (this.isInputFocused) {
              let inputMethodController = inputMethod.getController();
              inputMethodController.stopInputSession();
              this.isInputFocused = false;
            }

            // 只有在点赞特效开启时才响应点赞特效
            if (!this.isLikeEffectEnabled) {
              return;
            }

            // 在消息列表区域点击时触发点赞特效
            console.info(`Scroll点击位置: ${event.x}, ${event.y}`)

            // 计算Canvas中的实际坐标
            // Column有padding: left:8, right:8, bottom: 56
            // Scroll组件有padding: left: 12, right: 12
            const canvasX = event.x + 8 + 12 // 加上Column和Scroll的left padding
            const canvasY = event.y + 56 // 加上Column的bottom padding

            console.info(`Canvas坐标: ${canvasX}, ${canvasY}`)

            // 添加多个点赞图标，创造更丰富的效果
            this.addLikeIcon(canvasX, canvasY)
            // 在点击位置周围添加一些随机偏移的图标
            for (let i = 0; i < 3; i++) {
              const offsetX = canvasX + (Math.random() - 0.5) * 60
              const offsetY = canvasY + (Math.random() - 0.5) * 60
              this.addLikeIcon(offsetX, offsetY)
            }
          })

          // 底部输入区域 (Z-index: 4)
          Row() {
            // 左侧语音按钮
            Image($r('app.media.voice_icon')) // TODO: 替换为实际的 ic_voice 图片资源
              .width(26).height(26)
              .margin({ right: 8 })
              .onClick(() => {
                this.isVoiceMode = !this.isVoiceMode; // 切换语音/文本输入模式
              })

            // 输入框或语音按钮
            if (!this.isVoiceMode) {
              // 文本输入模式
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
            } else {
              // 语音输入模式
              Button() {
                Text(this.isRecording ? '松开发送' : '按住说话')
                  .fontColor(Color.White)
                  .fontSize(16)
              }
              .width('100%')
              .height(48)
              .backgroundColor('rgba(0,0,0,0.3)')
              .borderRadius(24)
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.touchStartY = event.touches[0].y;
                  this.isCancelRecord = false;
                  this.showRecordPanel = true;
                  this.startRecord();
                } else if (event.type === TouchType.Move) {
                  if (this.touchStartY - event.touches[0].y > 50) {
                    this.isCancelRecord = true;
                  } else {
                    this.isCancelRecord = false;
                  }
                } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                  this.showRecordPanel = false;
                  this.stopAndSendRecord();
                }
              })
            }

            // 右侧加号按钮 (用于更多功能)
            Image($r('app.media.ic_add_circle')) // TODO: 替换为实际的 ic_add_circle 图片资源
              .width(30).height(30)
              .onClick(async () => {
                this.showExtraInputs = !this.showExtraInputs;
                console.log('打开更多功能面板');

                // 如果打开面板，则生成回复建议
                if (this.showExtraInputs) {
                  await this.generateReplySuggestions();
                }
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
          .zIndex(3)
          .borderRadius(35)

          if (this.showExtraInputs) {
            Column() {
              // 第一个回复建议
              Row() {
                if (this.isLoadingSuggestions) {
                  LoadingProgress()
                    .width(20).height(20)
                    .color(Color.White)
                    .margin({ right: 12 })
                  Text('正在生成回复建议...')
                    .fontSize(16)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Medium)
                } else {
                  Text(this.replySuggestions[0] || '我理解你的感受')
                    .fontSize(16)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Medium)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .width('100%')
              .height(50)
              .backgroundColor('rgba(255,255,255,0.08)')
              .borderRadius(12)
              .margin({ top: 4, bottom: 2 })
              .padding({ left: 16, right: 16 })
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                if (!this.isLoadingSuggestions && this.replySuggestions[0]) {
                  this.inputText = this.replySuggestions[0];
                  this.showExtraInputs = false;
                  console.log('选择回复建议1:', this.replySuggestions[0]);
                }
              })

              // 第二个回复建议
              Row() {
                if (this.isLoadingSuggestions) {
                  LoadingProgress()
                    .width(20).height(20)
                    .color(Color.White)
                    .margin({ right: 12 })
                  Text('正在生成回复建议...')
                    .fontSize(16)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Medium)
                } else {
                  Text(this.replySuggestions[1] || '需要聊聊吗？')
                    .fontSize(16)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Medium)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .width('100%')
              .height(50)
              .backgroundColor('rgba(255,255,255,0.08)')
              .borderRadius(12)
              .margin({ top: 2, bottom: 2 })
              .padding({ left: 16, right: 16 })
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                if (!this.isLoadingSuggestions && this.replySuggestions[1]) {
                  this.inputText = this.replySuggestions[1];
                  this.showExtraInputs = false;
                  console.log('选择回复建议2:', this.replySuggestions[1]);
                }
              })

              // 第三个回复建议
              Row() {
                if (this.isLoadingSuggestions) {
                  LoadingProgress()
                    .width(20).height(20)
                    .color(Color.White)
                    .margin({ right: 12 })
                  Text('正在生成回复建议...')
                    .fontSize(16)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Medium)
                } else {
                  Text(this.replySuggestions[2] || '我在这里陪着你')
                    .fontSize(16)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Medium)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .width('100%')
              .height(50)
              .backgroundColor('rgba(255,255,255,0.08)')
              .borderRadius(12)
              .margin({ top: 2, bottom: 4 })
              .padding({ left: 16, right: 16 })
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                if (!this.isLoadingSuggestions && this.replySuggestions[2]) {
                  this.inputText = this.replySuggestions[2];
                  this.showExtraInputs = false;
                  console.log('选择回复建议3:', this.replySuggestions[2]);
                }
              })
            }
            .width('100%')
            .padding({ left: 24, right: 24 })
          }
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween) // 顶部底部内容分开
      .alignItems(HorizontalAlign.Center)
      .padding({ left:8,right:8, bottom: 56 }) // 底部padding与底部导航栏高度一致，避免重叠
      .zIndex(2) // 确保Column在背景图片之上


      // 点赞特效Canvas (Z-index: 1，在背景之上但在UI元素之下)
      if (this.isLikeEffectEnabled) {
        Canvas(this.context)
          .width('100%')
          .height('100%')
          .zIndex(1) // 降低z-index，确保在UI元素之下
          .backgroundColor(Color.Transparent) // 设置为透明背景
          .onReady(() => {
            // Canvas已准备好，可以开始绘制
            this.screenWidth = this.context.width
            this.screenHeight = this.context.height
            console.info(`点赞特效Canvas已准备就绪: ${this.screenWidth} x ${this.screenHeight}`)
          })
      }



      // 录音弹窗
      if (this.showRecordPanel) {
        // 蒙层
        Stack() {
          // 半透明背景
          Row() {} // 空Row
          .backgroundColor('rgba(0,0,0,0.3)')
          .width('100%')
          .height('100%')

          // 录音弹窗
          Column() {
            // 声波动画
            Row() {
              ForEach([1,2,3,4,5], (i: number) => {
                Blank()
                  .width(6)
                  .height(30) // 固定高度
                  .backgroundColor(this.isCancelRecord ? '#ff4d4f' : '#00e0ff')
                  .margin({ left: 2, right: 2 })
              })
            }
            .margin({ bottom: 12 })

            // 状态提示
            Text(this.isCancelRecord ? '松开手指，取消发送' : '上滑取消')
              .fontColor(this.isCancelRecord ? '#ff4d4f' : '#fff')
              .fontSize(16)
              .margin({ bottom: 8 })

            // 实时时长
            Text(`${this.recordDuration}"`)
              .fontColor('#fff')
              .fontSize(20)
          }
          .padding({ top: 40, bottom: 40, left: 30, right: 30 })
          .backgroundColor('rgba(0,0,0,0.8)')
          .borderRadius(16)
          .align(Alignment.Center)
        }
        .zIndex(99)
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]) // 避开顶部系统安全区域
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

  // 检查麦克风权限
  private async checkMicrophonePermission(): Promise<void> {
    try {
      let atManager = abilityAccessCtrl.createAtManager();
      let context = getContext();
      if (!context) {
        console.error('无法获取应用上下文');
        this.hasMicrophonePermission = false;
        return;
      }

      // 获取应用的tokenID
      const tokenID = context.applicationInfo.accessTokenId;

      // 先检查当前权限状态
      const permissionStatus = await atManager.verifyAccessToken(tokenID, 'ohos.permission.MICROPHONE');
      console.log('当前麦克风权限状态:', permissionStatus);

      if (permissionStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        this.hasMicrophonePermission = true;
        console.log('麦克风权限已授权');
        return;
      }

      // 如果权限未授权，但不主动申请，等待用户使用时再申请
      this.hasMicrophonePermission = false;
      console.log('麦克风权限未授权，将在使用时申请');

    } catch (error) {
      console.error('权限检查失败:', error);
      this.hasMicrophonePermission = false;
    }
  }

  // 初始化语音识别引擎
  private async initSpeechRecognition(): Promise<void> {
    try {
      console.log('初始化语音识别引擎...');

      // 在真机环境下预初始化语音识别引擎
      if (!this.isVirtualMachine()) {
        // 这里可以预创建引擎，但实际使用时再创建更稳定
        console.log('真机环境，语音识别引擎将在使用时创建');
      } else {
        console.log('虚拟机环境，跳过语音识别引擎初始化');
      }
    } catch (error) {
      console.error('语音识别引擎初始化失败:', error);
    }
  }

  // 申请麦克风权限 - 优化版本
  private async requestMicrophonePermission(): Promise<boolean> {
    try {
      console.log('=== 开始权限申请流程 ===');

      // 获取应用上下文
      let context = getContext();
      if (!context) {
        console.error('无法获取应用上下文');
        promptAction.showToast({
          message: '无法获取应用上下文，请重启应用',
          duration: 3000
        });
        return false;
      }

      let atManager = abilityAccessCtrl.createAtManager();
      console.log('权限管理器创建成功');

      // 先检查权限状态
      try {
        // 获取应用的tokenID
        const tokenID = context.applicationInfo.accessTokenId;
        const permissionStatus = await atManager.verifyAccessToken(tokenID, 'ohos.permission.MICROPHONE');
        console.log('麦克风权限状态:', permissionStatus);

        if (permissionStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          console.log('麦克风权限已授权');
          return true;
        } else if (permissionStatus === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
          console.log('麦克风权限已被拒绝');
        } else {
          console.log('麦克风权限状态未知:', permissionStatus);
        }
      } catch (verifyError) {
        console.error('权限状态检查失败:', verifyError);
      }

      // 申请权限
      console.log('开始申请麦克风权限...');
      const permissions: Permissions[] = ['ohos.permission.MICROPHONE'];

      // 显示权限申请提示
      promptAction.showToast({
        message: '正在申请麦克风权限，请在弹出的对话框中点击"允许"',
        duration: 2000
      });

      // 尝试申请权限（最多3次）
      for (let i = 0; i < 3; i++) {
        try {
          console.log(`第${i + 1}次尝试申请权限...`);

          // 设置超时机制
          const timeoutPromise = new Promise<never>((_, reject) => {
            setTimeout(() => reject(new Error('权限申请超时')), 10000); // 10秒超时
          });

          const permissionPromise = atManager.requestPermissionsFromUser(context, permissions);
          const result = await Promise.race([permissionPromise, timeoutPromise]);

          console.log(`第${i + 1}次权限申请结果:`, JSON.stringify(result));

          // 检查申请结果
          if (result && Array.isArray(result.authResults) && result.authResults.length > 0) {
            const granted = result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
            console.log('麦克风权限申请结果:', granted ? '成功' : '失败');

            if (granted) {
              promptAction.showToast({
                message: '麦克风权限已获得',
                duration: 1000
              });
              return true;
            } else {
              console.log('权限被拒绝，authResults:', result.authResults);

              // 根据拒绝原因提供不同的提示
              const deniedReason = result.authResults[0];
              if (deniedReason === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
                promptAction.showToast({
                  message: '麦克风权限被拒绝，请在设置中手动开启',
                  duration: 3000
                });
              } else {
                promptAction.showToast({
                  message: '麦克风权限申请失败，请重试',
                  duration: 3000
                });
              }
              return false;
            }
          } else {
            console.log('权限申请结果为空或格式错误:', result);
          }

          // 如果没有结果，等待一下再重试
          if (i < 2) {
            console.log('等待1秒后重试...');
            await new Promise<void>(resolve => setTimeout(resolve, 1000));
          }
        } catch (retryError) {
          console.error(`第${i + 1}次权限申请失败:`, retryError);
          const errorMessage = retryError instanceof Error ? retryError.message : '未知错误';
          console.error('错误详情:', errorMessage);

          // 如果是超时错误，提供特殊提示
          if (errorMessage.includes('超时')) {
            promptAction.showToast({
              message: '权限申请超时，请检查网络连接',
              duration: 2000
            });
          }

          if (i < 2) {
            console.log('等待1秒后重试...');
            await new Promise<void>(resolve => setTimeout(resolve, 1000));
          }
        }
      }

      // 如果多次尝试都失败，提供详细的错误信息
      console.error('所有权限申请尝试都失败了');
      promptAction.showToast({
        message: '麦克风权限申请失败，请检查系统设置或重启应用',
        duration: 4000
      });

      return false;
    } catch (error) {
      console.error('申请麦克风权限失败:', error);
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      console.error('错误详情:', errorMessage);

      promptAction.showToast({
        message: '权限申请失败: ' + errorMessage,
        duration: 4000
      });
      return false;
    }
  }

  // 检测是否为虚拟机环境
  private isVirtualMachine(): boolean {
    try {
      // 在ArkTS中，我们使用更简单的方法检测环境
      // 通过尝试获取一些真机特有的API来判断
      const context = getContext();

      // 检查是否有真实的麦克风设备
      // 在真机上，麦克风权限申请会成功，在模拟器上可能会失败
      // 这里我们默认返回false，表示真机环境
      return false;
    } catch (error) {
      console.log('设备检测失败，默认使用真机模式:', error);
      return false; // 默认使用真机模式
    }
  }



  private async startRecord() {
    try {
      console.log('开始录音流程...');

      // 检查麦克风权限
      if (!this.hasMicrophonePermission) {
        console.log('麦克风权限未授权，尝试申请权限...');

        // 显示权限申请提示
        promptAction.showToast({
          message: '正在申请麦克风权限...',
          duration: 1000
        });

        const granted = await this.requestMicrophonePermission();
        if (!granted) {
          console.error('麦克风权限申请失败，无法录音');
          // 显示更详细的提示信息
          promptAction.showToast({
            message: '麦克风权限被拒绝，请在设置中手动开启麦克风权限',
            duration: 4000
          });
          return;
        }
        this.hasMicrophonePermission = true;

        // 权限获得后，延迟一下再开始录音
        setTimeout(() => {
          this.startRecordingProcess();
        }, 1000);
        return;
      }

      // 如果已有权限，再次确认权限状态
      const currentPermission = await AudioCapturerManager.checkMicrophonePermission();
      if (!currentPermission) {
        console.log('权限状态发生变化，重新申请权限...');
        this.hasMicrophonePermission = false;
        this.startRecord();
        return;
      }

      // 如果已有权限，直接开始录音
      this.startRecordingProcess();
    } catch (error) {
      console.error('录音启动失败:', error);
      this.isRecording = false;
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      promptAction.showToast({
        message: '录音启动失败: ' + errorMessage,
        duration: 2000
      });
    }
  }

  // 新增：实际的录音开始流程
  private async startRecordingProcess(): Promise<void> {
    try {
      this.isRecording = true;
      this.recordDuration = 0;
      this.fileName = Date.now().toString();

      console.log('录音文件名:', this.fileName);

      // 检测环境并选择录音方式
      const isVM = this.isVirtualMachine();
      console.log('当前环境:', isVM ? '虚拟机' : '真机');

      if (isVM) {
        // 虚拟机环境：模拟录音
        console.log('虚拟机环境，使用模拟录音');
        this.simulateRecord();
      } else {
        // 真机环境：真实录音
        console.log('真机环境，使用真实录音');

        // 再次检查权限
        const hasPermission = await AudioCapturerManager.checkMicrophonePermission();
        if (!hasPermission) {
          console.error('录音前权限检查失败');
          this.isRecording = false;
          this.hasMicrophonePermission = false;
          promptAction.showToast({
            message: '麦克风权限未授权，请重新申请权限',
            duration: 2000
          });
          return;
        }

        const filePath = await AudioCapturerManager.startRecord(this.fileName);
        if (!filePath) {
          console.error('录音开始失败');
          this.isRecording = false;
          promptAction.showToast({
            message: '录音启动失败，请检查麦克风权限和设备状态',
            duration: 3000
          });
          return;
        }
        console.log('录音开始成功，文件路径:', filePath);
      }

      // 开始计时
      this.recordTimer = setInterval(() => {
        this.recordDuration += 1;
        console.log('录音时长:', this.recordDuration, '秒');
      }, 1000);

    } catch (error) {
      console.error('录音流程启动失败:', error);
      this.isRecording = false;
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      promptAction.showToast({
        message: '录音流程启动失败: ' + errorMessage,
        duration: 2000
      });
    }
  }

  // 模拟录音功能
  private simulateRecord() {
    // 模拟录音文件生成
    console.log('模拟录音文件生成:', this.fileName);
  }

  private async stopAndSendRecord() {
    try {
      console.log('停止录音并发送...');

      clearInterval(this.recordTimer);
      clearInterval(this.volumeTimer);
      this.isRecording = false;

      // 检查录音时长
      if (this.recordDuration < 1) {
        console.log('录音时长太短，取消发送');
        this.recordDuration = 0;
        this.isCancelRecord = false;
        return;
      }

      // 检查是否取消录音
      if (this.isCancelRecord) {
        console.log('用户取消录音');
        this.recordDuration = 0;
        this.isCancelRecord = false;
        return;
      }

      const isVM = this.isVirtualMachine();
      console.log('停止录音，环境:', isVM ? '虚拟机' : '真机');

      if (isVM) {
        // 虚拟机环境：模拟录音结束
        console.log('虚拟机环境，模拟录音结束');
        this.simulateVoiceRecognition();
      } else {
        // 真机环境：真实录音结束
        console.log('真机环境，停止真实录音');
        const stopSuccess = await AudioCapturerManager.stopRecord();
        if (!stopSuccess) {
          console.error('录音停止失败');
          promptAction.showToast({
            message: '录音停止失败',
            duration: 2000
          });
          return;
        }

        // 检查录音文件是否存在
        const filePath = AudioCapturerManager.getRecordFilePath();
        console.log('录音文件路径:', filePath);

        // 开始语音识别
        this.recognizeAudioFile(this.fileName);
      }

      this.recordDuration = 0;
      this.isCancelRecord = false;

    } catch (error) {
      console.error('停止录音失败:', error);
      this.recordDuration = 0;
      this.isCancelRecord = false;
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      promptAction.showToast({
        message: '录音处理失败: ' + errorMessage,
        duration: 2000
      });
    }
  }

  // 模拟语音识别
  private simulateVoiceRecognition() {
    // 模拟识别结果
    const mockText = '这是模拟的语音识别结果';
    console.log('模拟语音识别结果:', mockText);
    this.sendVoiceMessage(this.fileName, this.recordDuration, mockText);
  }

  private recognizeAudioFile(fileName: string) {
    console.log('开始语音识别，文件名:', fileName);

    // 显示识别中提示
    promptAction.showToast({
      message: '正在识别语音...',
      duration: 2000
    });

    SpeechRecognizerManager.init2((res) => {
      console.log('语音识别结果:', res);
      let text = res.result || '未识别到语音内容';

      if (text && text !== '未识别到语音内容' && !text.includes('失败')) {
        console.log('语音识别成功:', text);
        this.sendVoiceMessage(fileName, this.recordDuration, text);
      } else {
        console.log('语音识别失败或结果为空');
        promptAction.showToast({
          message: '语音识别失败，请重试',
          duration: 2000
        });
        this.sendVoiceMessage(fileName, this.recordDuration, '语音识别失败');
      }
    }, fileName);
  }

  private sendVoiceMessage(fileName: string, duration: number, text: string) {
    // 语音识别完成后，自动调用sendMessage进行AI对话
    if (text && text !== '未识别到语音内容') {
      // 将识别出的文本作为用户输入，调用sendMessage
      this.inputText = text; // 设置输入文本
      this.sendMessage(); // 调用AI对话
    } else {
      // 如果识别失败，显示语音消息
      const newMessage: ChatMessage = {
        id: this.chatData.length + 1,
        isMe: true,
        avatar: $r('app.media.splash'),
        content: '[语音] 未识别到语音内容',
        time: new Date().toLocaleTimeString().slice(0, 5),
        type: 'voice',
        duration: duration,
      };
      this.chatData = [...this.chatData, newMessage];
      this.scrollToBottom();
    }
  }
}