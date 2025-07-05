import router from '@ohos.router';
import { MusicDetailVO } from '../common/types';
import { ApiService } from '../service/apiservice';

// 定义专栏项接口
interface SectionItem {
  title: string;
  subtitle: string;
  tag: string;
  author: string;
  image?: Resource; // 添加可选的图片字段
  icon?: string; // 添加可选的图标字段
  iconColor?: string; // 添加图标颜色字段
  bgColor?: string; // 添加背景颜色字段
}

interface ToolItem {
  icon?: string;
  title: string;
  desc: string;
  color: string;
  bgColor: string;
  route?: string;
}

interface AIRecommend {
  title: string;
  desc: string;
  tag: string;
}

// 定义情绪卡片接口
interface EmotionCard {
  id: number;
  title: string;
  subtitle: string;
  emoji: string;
  backgroundColor: string;
  textColor: string;
  description: string;
}

@Entry
@Component
export struct FMHomePage {
  @State activeTab: number = 0
  private tabs: string[] = ['精选', '音乐', '专栏', '工具'];
  private scrollController: Scroller = new Scroller()

  // 情绪卡片相关状态
  @State currentEmotionIndex: number = 0
  @State emotionCardOpacity: number = 1.0
  @State emotionCardTranslateX: number = 0
  @State isAutoPlaying: boolean = true // 自动播放状态
  private autoPlayTimer: number = -1 // 自动播放定时器

  // 银河系动画状态
  @State arcRotation: number = 0 // 圆弧旋转角度
  @State starTwinkle: number = 0 // 星星闪烁效果
  @State glowOpacity: number = 0.5 // 发光效果透明度
  @State textOpacity: number = 0.8 // 文字透明度
  @State nebulaOpacity: number = 0.3 // 星云透明度

  // 专栏理论高度（标题+内容+间距），可根据实际页面微调
  private sectionHeights: number[] = [320, 420, 420, 320]; // 仅示例，需根据实际内容微调
  private sectionSpacing: number = 40;
  private bannerHeight: number = 215; // Banner总高度 (200+15)
  private searchBarHeight: number = 64; // 搜索栏总高度 (16+8+40)
  private tabBarHeight: number = 68; // 标签栏总高度 (8+60)
  private targetOffset: number = 15; // tab下方15像素

  // 预定义温馨问候语
  private greetings: string[] = [
    '早安，今天也要照顾好自己哦！',
    '无论遇到什么，AI都陪着你。',
    '给自己一个微笑，新的一天会更好。',
    '你很棒，别忘了肯定自己。',
    '累了就休息一下，健康最重要。',
    '每一天都值得被温柔以待。',
    '情绪有波动很正常，慢慢来。',
    '相信自己，你能度过难关。',
    '别忘了喝水，照顾好身体。',
    '你不是一个人，AI一直在。',
    '给自己一点耐心，一切都会好起来。',
    '世界很大，也有属于你的温暖。',
    '今天也要好好吃饭哦！',
    '遇到烦恼可以和我聊聊。',
    '你的感受很重要，值得被倾听。'
  ];
  @State greetingIndex: number = Math.floor(Math.random() * 15);
  @State greetingAnimOpacity: number = 1.0;
  @State greetingAnimTranslateY: number = 0;

  // 定义三种情绪卡片
  private emotionCards: EmotionCard[] = [
    {
      id: 1,
      title: '今日心情',
      subtitle: '记录你的情绪状态',
      emoji: '😊',
      backgroundColor: 'rgba(255, 255, 255, 0.1)',
      textColor: '#ffffff',
      description: '点击记录今天的心情，让AI更好地了解你'
    },
    {
      id: 2,
      title: '压力指数',
      subtitle: '了解你的压力水平',
      emoji: '😰',
      backgroundColor: 'rgba(255, 255, 255, 0.1)',
      textColor: '#ffffff',
      description: '快速评估当前压力状态，获取缓解建议'
    },
    {
      id: 3,
      title: '正念练习',
      subtitle: '5分钟放松身心',
      emoji: '🧘‍♀️',
      backgroundColor: 'rgba(255, 255, 255, 0.1)',
      textColor: '#ffffff',
      description: '通过正念冥想，找回内心的平静'
    }
  ];

  // 定义各分类的数据
  private selectedItems: SectionItem[] = [
    { 
      title: 'AI个性化推荐', 
      subtitle: '基于你的情绪状态智能推荐', 
      tag: 'AI推荐', 
      author: 'AI助手',
      icon: '🤖',
      iconColor: '#ffffff',
      bgColor: 'rgba(255, 255, 255, 0.05)'
    },
    { 
      title: '今日心理健康工具', 
      subtitle: '精选心理健康练习和技巧', 
      tag: '工具', 
      author: '心理专家',
      icon: '🧰',
      iconColor: '#ffffff',
      bgColor: 'rgba(255, 255, 255, 0.05)'
    },
    { 
      title: '情绪管理课程', 
      subtitle: '系统学习情绪管理技能', 
      tag: '课程', 
      author: '情绪专家',
      icon: '📚',
      iconColor: '#ffffff',
      bgColor: 'rgba(255, 255, 255, 0.05)'
    },
  ];

  private musicItems: SectionItem[] = [
    { 
      title: 'Vol.01 《流行音乐》', 
      subtitle: '最新流行歌曲', 
      tag: '流行', 
      author: '音乐人',
      image: $r('app.media.fmhome_fashionMusic')
    },
    { 
      title: 'Vol.02 《古典音乐》', 
      subtitle: '经典古典作品', 
      tag: '古典', 
      author: '古典乐',
      image: $r('app.media.fmhome_classicMusic')
    },
    { 
      title: 'Vol.03 《轻音乐》', 
      subtitle: '轻松舒缓音乐', 
      tag: '轻音', 
      author: '轻音乐',
      image: $r('app.media.fmhome_softMusic')
    }
  ];

  private columnItems: SectionItem[] = [
    { 
      title: 'Vol.01 《深度解析》', 
      subtitle: '深度文章分析', 
      tag: '深度', 
      author: '分析师',
      icon: '🔍',
      iconColor: '#ffffff',
      bgColor: 'rgba(255, 255, 255, 0.05)'
    },
    { 
      title: 'Vol.02 《技术分享》', 
      subtitle: '技术经验分享', 
      tag: '技术', 
      author: '技术员',
      icon: '💻',
      iconColor: '#ffffff',
      bgColor: 'rgba(255, 255, 255, 0.05)'
    },
    { 
      title: 'Vol.03 《行业观察》', 
      subtitle: '行业趋势观察', 
      tag: '观察', 
      author: '观察者',
      icon: '📊',
      iconColor: '#ffffff',
      bgColor: 'rgba(255, 255, 255, 0.05)'
    }
  ];

  private toolItems: ToolItem[] = [
    {
      icon: '🎵',
      title: '音乐治疗',
      desc: '通过音乐缓解压力',
      color: '#ffffff',
      bgColor: 'rgba(255, 255, 255, 0.05)',
      route: 'pages/fm_musicBegin'
    },
    {
      icon: '🧘‍♀️',
      title: '冥想练习',
      desc: '正念冥想指导',
      color: '#ffffff',
      bgColor: 'rgba(255, 255, 255, 0.05)',
      route: 'pages/fm_meditation'
    },
    {
      icon: '📝',
      title: '情绪日记',
      desc: '记录每日情绪',
      color: '#ffffff',
      bgColor: 'rgba(255, 255, 255, 0.05)',
      route: 'pages/fm_message'
    },
    {
      icon: '💬',
      title: 'AI对话',
      desc: '与AI倾诉心事',
      color: '#ffffff',
      bgColor: 'rgba(255, 255, 255, 0.05)',
      route: 'pages/chat'
    }
  ];

  private allMusicIds: string[] = ['1824045033', '202369', '447926071', '436346833', '33471531','186345','2499704738','2491811886','1832581073','5043882','2600797312','2708984802'];
  @State randomSongs: MusicDetailVO[] = [];
  private musicDetailCache: Record<string, MusicDetailVO> = {};

  // 切换情绪卡片的方法
  private switchEmotionCard(direction: 'left' | 'right') {
    // 手动切换时暂停自动轮播
    this.stopAutoPlay()
    
    // 先淡出并移动
    animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.emotionCardOpacity = 0;
      this.emotionCardTranslateX = direction === 'left' ? -30 : 30;
    })
    
    setTimeout(() => {
      // 更新索引
      if (direction === 'left') {
        this.currentEmotionIndex = (this.currentEmotionIndex - 1 + this.emotionCards.length) % this.emotionCards.length;
      } else {
        this.currentEmotionIndex = (this.currentEmotionIndex + 1) % this.emotionCards.length;
      }
      
      // 重置位置
      this.emotionCardTranslateX = direction === 'left' ? 30 : -30;
      
      // 再淡入并回到中心
      animateTo({ duration: 300, curve: Curve.EaseIn }, () => {
        this.emotionCardOpacity = 1.0;
        this.emotionCardTranslateX = 0;
      })
    }, 300)
  }

  // 开始自动轮播
  private startAutoPlay() {
    this.stopAutoPlay() // 先停止之前的定时器
    this.isAutoPlaying = true
    this.autoPlayTimer = setInterval(() => {
      this.switchEmotionCard('right')
    }, 3000) // 每3秒切换一次，更频繁
  }

  // 停止自动轮播
  private stopAutoPlay() {
    if (this.autoPlayTimer !== -1) {
      clearInterval(this.autoPlayTimer)
      this.autoPlayTimer = -1
    }
    this.isAutoPlaying = false
  }

  // 切换自动播放状态
  private toggleAutoPlay() {
    if (this.isAutoPlaying) {
      this.stopAutoPlay()
    } else {
      this.startAutoPlay()
    }
  }

  // 页面生命周期
  aboutToAppear() {
    this.startGalaxyAnimations()
    this.startAutoPlay()
    this.startGreetingAnimation()
    this.fetchRandomSongs();
  }

  aboutToDisappear() {
    // 页面消失时停止自动轮播
    this.stopAutoPlay()
  }

  // 延迟函数，ms为毫秒
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async fetchRandomSongs() {
    // 随机打乱并取前3个id
    const ids = [...this.allMusicIds].sort(() => Math.random() - 0.5).slice(0, 3);
    const songs: MusicDetailVO[] = [];
    for (let id of ids) {
      try {
        let detail: MusicDetailVO;
        if (this.musicDetailCache[id]) {
          detail = this.musicDetailCache[id];
        } else {
          detail = await ApiService.getMusicDetail(id);
          detail.musicId = id;
          this.musicDetailCache[id] = detail;
          // 每次请求后等待1秒，防止超过1QPS
          await this.delay(1000);
        }
        songs.push(detail);
      } catch (e) {
        // 错误处理
      }
    }
    this.randomSongs = songs;
  }

  build() {
    Stack() {
      // 深色渐变背景 - 改为纯黑色主题
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#000000', 0.0], ['#0a0a0a', 0.5], ['#1a1a1a', 1.0]]
        })
      
      // 旋转的圆弧背景 - 改为黑色系装饰
      Stack() {
        // 多个同心圆弧轨道
        ForEach([0, 1, 2, 3], (index: number) => {
          Stack() {
            // 圆弧轨道 - 改为深灰色
            Column()
              .width(250 + index * 60)
              .height(250 + index * 60)
              .borderRadius((250 + index * 60) / 2)
              .border({ width: 1, color: `rgba(64, 64, 64, ${0.3 - index * 0.05})` })
              .position({ x: '50%', y: '50%' })
              .translate({ x: -(250 + index * 60) / 2, y: -(250 + index * 60) / 2 })
            
            // 旋转的圆弧点 - 改为白色系
            Column()
              .width(6)
              .height(6)
              .backgroundColor(`rgba(255, 255, 255, ${0.6 - index * 0.1})`)
              .borderRadius(3)
              .position({ x: '50%', y: '50%' })
              .translate({ 
                x: -3 + Math.cos((this.arcRotation + index * 90) * Math.PI / 180) * (125 + index * 30),
                y: -3 + Math.sin((this.arcRotation + index * 90) * Math.PI / 180) * (125 + index * 30)
              })
          }
        })
        
        // 外圈装饰点 - 改为银色系
        ForEach([0, 1, 2, 3, 4, 5], (index: number) => {
          Column()
            .width(6)
            .height(6)
            .backgroundColor(`rgba(192, 192, 192, ${0.4 - index * 0.05})`)
            .borderRadius(3)
            .position({ x: '50%', y: '50%' })
            .translate({ 
              x: -3 + Math.cos((this.arcRotation * 0.5 + index * 60) * Math.PI / 180) * 120,
              y: -3 + Math.sin((this.arcRotation * 0.5 + index * 60) * Math.PI / 180) * 120
            })
        })
      }
      .width('100%')
      .height('100%')
      
      // 主要内容区域
      Column() {
        // 顶部问候语
        Stack() {
          // 问候语卡片背景发光效果
          Column()
            .width('100%')
            .height('auto')
            .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.03})`)
            .borderRadius(16)
            .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
          
          Text(this.greetings[this.greetingIndex])
            .fontSize(16)
            .fontColor('#ffffff')
            .opacity(this.greetingAnimOpacity)
            .translate({ y: this.greetingAnimTranslateY })
            .animation({
              duration: 500,
              curve: Curve.EaseInOut
            })
            .textAlign(TextAlign.Center)
            .padding({ top: 20, bottom: 20, left: 20, right: 20 })
        }
        .width('100%')
        .backgroundColor('rgba(255, 255, 255, 0.03)')
        .borderRadius(16)
        .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
        .margin({ top: 20, left: 16, right: 16, bottom: 16 })
        .shadow({ radius: 12, color: '#00000030', offsetX: 0, offsetY: 4 })

        // 情绪卡片区域
        Stack() {
          // 情绪卡片背景发光效果
          Column()
            .width('100%')
            .height('auto')
            .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
            .borderRadius(20)
            .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
          
          Column() {
            Text('今日心情')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ffffff')
              .opacity(this.textOpacity)
              .margin({ top: 16, bottom: 12 })
            
            // 情绪卡片 - 逐一展示
            Stack() {
              // 当前显示的情绪卡片
              Column() {
                Text(this.emotionCards[this.currentEmotionIndex].emoji)
                  .fontSize(32)
                  .margin({ bottom: 8 })
                Text(this.emotionCards[this.currentEmotionIndex].title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff')
                  .opacity(this.textOpacity)
                  .margin({ bottom: 4 })
                Text(this.emotionCards[this.currentEmotionIndex].subtitle)
                  .fontSize(12)
                  .fontColor('rgba(255, 255, 255, 0.7)')
                  .opacity(this.textOpacity)
              }
              .width('100%')
              .backgroundColor('rgba(255, 255, 255, 0.1)')
              .borderRadius(12)
              .padding({ top: 16, bottom: 16 })
              .border({ width: 1, color: 'rgba(255, 255, 255, 0.2)' })
              .opacity(this.emotionCardOpacity)
              .translate({ x: this.emotionCardTranslateX })
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
              .onClick(() => this.switchEmotionCard('right'))
              
              // 指示器
              Row() {
                ForEach(this.emotionCards, (card: EmotionCard, index: number) => {
                  Column()
                    .width(6)
                    .height(6)
                    .backgroundColor(this.currentEmotionIndex === index ? '#ffffff' : 'rgba(255, 255, 255, 0.3)')
                    .borderRadius(3)
                    .margin({ right: 4 })
                })
              }
              .position({ x: '50%', y: '100%' })
              .translate({ x: -15, y: 8 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 16 })
          }
          .width('100%')
          .backgroundColor('rgba(255, 255, 255, 0.03)')
          .borderRadius(20)
          .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
          .margin({ left: 16, right: 16, bottom: 16 })
          .shadow({ radius: 12, color: '#00000030', offsetX: 0, offsetY: 4 })
        }

        // 标签栏
        Row() {
          ForEach(this.tabs, (tab: string, index: number) => {
            Text(tab)
              .fontSize(16)
              .fontWeight(this.activeTab === index ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.activeTab === index ? '#ffffff' : 'rgba(255, 255, 255, 0.6)')
              .opacity(this.textOpacity)
              .padding({ left: 20, right: 20, top: 12, bottom: 12 })
              .backgroundColor(this.activeTab === index ? 'rgba(255, 255, 255, 0.1)' : 'transparent')
              .borderRadius(20)
              .onClick(() => {
                this.activeTab = index;
              })
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .padding({ left: 16, right: 16, bottom: 16 })

        // 内容区域
        Column() {
          if (this.activeTab === 0) {
            // 精选内容
            this.buildSelectedContent()
          } else if (this.activeTab === 1) {
            // 音乐内容
            this.buildMusicContent()
          } else if (this.activeTab === 2) {
            // 专栏内容
            this.buildColumnContent()
          } else if (this.activeTab === 3) {
            // 工具内容
            this.buildToolContent()
          }
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  // 构建精选内容
  @Builder
  buildSelectedContent() {
    List() {
      ForEach(this.selectedItems, (item: SectionItem) => {
        ListItem() {
          Stack() {
            // 卡片背景发光效果
            Column()
              .width('100%')
              .height('auto')
              .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
              .borderRadius(16)
              .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
            
            Row() {
              if (item.icon) {
                Text(item.icon)
                  .fontSize(24)
                  .fontColor(item.iconColor)
                  .margin({ right: 12 })
              }
              Column() {
                Text(item.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff')
                  .opacity(this.textOpacity)
                  .margin({ bottom: 4 })
                Text(item.subtitle)
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.7)')
                  .opacity(this.textOpacity)
                  .margin({ bottom: 8 })
                Row() {
                  Text(item.tag)
                    .fontSize(12)
                    .fontColor('#ffffff')
                    .backgroundColor('rgba(255, 255, 255, 0.1)')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(8)
                    .margin({ right: 8 })
                  Text(`@${item.author}`)
                    .fontSize(12)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                }
              }
              .layoutWeight(1)
            }
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          }
          .width('100%')
          .backgroundColor('rgba(255, 255, 255, 0.03)')
          .borderRadius(16)
          .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
          .margin({ left: 16, right: 16, bottom: 12 })
          .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 2 })
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
  }

  // 构建音乐内容
  @Builder
  buildMusicContent() {
    List() {
      ForEach(this.musicItems, (item: SectionItem) => {
        ListItem() {
          Stack() {
            // 卡片背景发光效果
            Column()
              .width('100%')
              .height('auto')
              .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
              .borderRadius(16)
              .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
            
            Row() {
              if (item.image) {
                Image(item.image)
                  .width(80)
                  .height(80)
                  .borderRadius(12)
                  .margin({ right: 12 })
              }
              Column() {
                Text(item.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff')
                  .opacity(this.textOpacity)
                  .margin({ bottom: 4 })
                Text(item.subtitle)
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.7)')
                  .opacity(this.textOpacity)
                  .margin({ bottom: 8 })
                Row() {
                  Text(item.tag)
                    .fontSize(12)
                    .fontColor('#ffffff')
                    .backgroundColor('rgba(255, 255, 255, 0.1)')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(8)
                    .margin({ right: 8 })
                  Text(`@${item.author}`)
                    .fontSize(12)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                }
              }
              .layoutWeight(1)
            }
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          }
          .width('100%')
          .backgroundColor('rgba(255, 255, 255, 0.03)')
          .borderRadius(16)
          .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
          .margin({ left: 16, right: 16, bottom: 12 })
          .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 2 })
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
  }

  // 构建专栏内容
  @Builder
  buildColumnContent() {
    List() {
      ForEach(this.columnItems, (item: SectionItem) => {
        ListItem() {
          Stack() {
            // 卡片背景发光效果
            Column()
              .width('100%')
              .height('auto')
              .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
              .borderRadius(16)
              .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
            
            Row() {
              if (item.icon) {
                Text(item.icon)
                  .fontSize(24)
                  .fontColor(item.iconColor)
                  .margin({ right: 12 })
              }
              Column() {
                Text(item.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff')
                  .opacity(this.textOpacity)
                  .margin({ bottom: 4 })
                Text(item.subtitle)
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.7)')
                  .opacity(this.textOpacity)
                  .margin({ bottom: 8 })
                Row() {
                  Text(item.tag)
                    .fontSize(12)
                    .fontColor('#ffffff')
                    .backgroundColor('rgba(255, 255, 255, 0.1)')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(8)
                    .margin({ right: 8 })
                  Text(`@${item.author}`)
                    .fontSize(12)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                }
              }
              .layoutWeight(1)
            }
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          }
          .width('100%')
          .backgroundColor('rgba(255, 255, 255, 0.03)')
          .borderRadius(16)
          .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
          .margin({ left: 16, right: 16, bottom: 12 })
          .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 2 })
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
  }

  // 构建工具内容
  @Builder
  buildToolContent() {
    Grid() {
      ForEach(this.toolItems, (item: ToolItem) => {
        GridItem() {
          Stack() {
            // 工具卡片背景发光效果
            Column()
              .width('100%')
              .height('auto')
              .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
              .borderRadius(16)
              .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
            
            Column() {
              Text(item.icon)
                .fontSize(32)
                .fontColor(item.color)
                .margin({ bottom: 8 })
              Text(item.title)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff')
                .opacity(this.textOpacity)
                .margin({ bottom: 4 })
              Text(item.desc)
                .fontSize(12)
                .fontColor('rgba(255, 255, 255, 0.7)')
                .opacity(this.textOpacity)
                .textAlign(TextAlign.Center)
            }
            .padding({ top: 16, bottom: 16 })
          }
          .width('100%')
          .backgroundColor('rgba(255, 255, 255, 0.03)')
          .borderRadius(16)
          .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
          .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 2 })
          .onClick(() => this.onToolItemClick(item))
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(12)
    .rowsGap(12)
    .width('100%')
    .padding({ left: 16, right: 16 })
    .layoutWeight(1)
  }

  // 工具项点击处理
  private onToolItemClick(item: ToolItem) {
    if (item.route) {
      router.pushUrl({ url: item.route });
    }
  }

  // 银河系动画
  private startGalaxyAnimations() {
    // 圆弧旋转动画
    setInterval(() => {
      this.arcRotation += 1.5
    }, 50)
    
    // 星星闪烁动画
    setInterval(() => {
      this.starTwinkle += 0.1
    }, 100)
    
    // 发光效果动画
    setInterval(() => {
      this.glowOpacity = this.glowOpacity === 0.5 ? 0.8 : 0.5
    }, 1200)
    
    // 文字透明度动画
    setInterval(() => {
      this.textOpacity = this.textOpacity === 0.8 ? 1.0 : 0.8
    }, 1800)
    
    // 星云透明度动画
    setInterval(() => {
      this.nebulaOpacity = this.nebulaOpacity === 0.3 ? 0.6 : 0.3
    }, 3000)
  }

  // 问候语动画
  private startGreetingAnimation() {
    setInterval(() => {
      this.greetingAnimOpacity = 0;
      this.greetingAnimTranslateY = -20;
      
      setTimeout(() => {
        this.greetingIndex = Math.floor(Math.random() * this.greetings.length);
        this.greetingAnimOpacity = 1;
        this.greetingAnimTranslateY = 0;
      }, 500);
    }, 8000);
  }
} 