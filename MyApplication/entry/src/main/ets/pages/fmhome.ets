import router from '@ohos.router';

// 定义专栏项接口
interface SectionItem {
  title: string;
  subtitle: string;
  tag: string;
  author: string;
  image?: Resource; // 添加可选的图片字段
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
struct FMHomePage {
  @State activeTab: number = 0
  private tabs: string[] = ['精选', '音乐', '专栏', '工具'];
  private scrollController: Scroller = new Scroller()

  // 情绪卡片相关状态
  @State currentEmotionIndex: number = 0
  @State emotionCardOpacity: number = 1.0
  @State emotionCardTranslateX: number = 0
  @State isAutoPlaying: boolean = true // 自动播放状态
  private autoPlayTimer: number = -1 // 自动播放定时器

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
      backgroundColor: '#E3F2FD',
      textColor: '#1976D2',
      description: '点击记录今天的心情，让AI更好地了解你'
    },
    {
      id: 2,
      title: '压力指数',
      subtitle: '了解你的压力水平',
      emoji: '😰',
      backgroundColor: '#FFF3E0',
      textColor: '#F57C00',
      description: '快速评估当前压力状态，获取缓解建议'
    },
    {
      id: 3,
      title: '正念练习',
      subtitle: '5分钟放松身心',
      emoji: '🧘‍♀️',
      backgroundColor: '#E8F5E8',
      textColor: '#388E3C',
      description: '通过正念冥想，找回内心的平静'
    }
  ];

  // 定义各分类的数据
  private selectedItems: SectionItem[] = [
    { title: 'Vol.01 《热门推荐》', subtitle: '精选内容推荐', tag: '热门', author: '推荐官' },
    { title: 'Vol.02 《今日精选》', subtitle: '今日最佳内容', tag: '精选', author: '编辑' },
    { title: 'Vol.03 《热门话题》', subtitle: '热门话题讨论', tag: '话题', author: '话题君' }
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
    { title: 'Vol.01 《深度解析》', subtitle: '深度文章分析', tag: '深度', author: '分析师' },
    { title: 'Vol.02 《技术分享》', subtitle: '技术经验分享', tag: '技术', author: '技术员' },
    { title: 'Vol.03 《行业观察》', subtitle: '行业趋势观察', tag: '观察', author: '观察者' }
  ];


  // AI今日推荐内容（可扩展为动态AI推荐）
  private aiRecommend: AIRecommend = {
    title: 'AI今日推荐：正念冥想5分钟',
    desc: '放松身心，缓解压力，开启美好一天',
    tag: 'AI推荐'
  };
  // 工具区内容 - 仅包含冥想练习、呼吸训练、压力评估
  private toolList: ToolItem[] = [
    { 
      title: '冥想练习', 
      desc: '正念冥想，放松身心', 
      color: '#4CAF50',
      bgColor: '#E8F5E8',
      route: 'pages/fm_meditation'
    },
    { 
      title: '呼吸训练', 
      desc: '科学呼吸，缓解焦虑', 
      color: '#00BCD4',
      bgColor: '#E0F2F1',
      route: 'pages/taskspage'
    },
    { 
      title: '压力评估', 
      desc: '评估压力指数，科学调节', 
      color: '#FF9800',
      bgColor: '#FFF3E0',
      route: 'pages/taskspage'
    }
  ];

  // 切换情绪卡片的方法
  private switchEmotionCard(direction: 'left' | 'right') {
    // 手动切换时暂停自动轮播
    this.stopAutoPlay()
    
    // 先淡出
    animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
      this.emotionCardOpacity = 0;
      this.emotionCardTranslateX = direction === 'left' ? -20 : 20;
    })
    
    setTimeout(() => {
      // 更新索引
      if (direction === 'left') {
        this.currentEmotionIndex = (this.currentEmotionIndex - 1 + this.emotionCards.length) % this.emotionCards.length;
      } else {
        this.currentEmotionIndex = (this.currentEmotionIndex + 1) % this.emotionCards.length;
      }
      
      // 重置位置
      this.emotionCardTranslateX = direction === 'left' ? 20 : -20;
      
      // 再淡入
      animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
        this.emotionCardOpacity = 1.0;
        this.emotionCardTranslateX = 0;
      })
    }, 200)
  }

  // 开始自动轮播
  private startAutoPlay() {
    this.stopAutoPlay() // 先停止之前的定时器
    this.isAutoPlaying = true
    this.autoPlayTimer = setInterval(() => {
      this.switchEmotionCard('right')
    }, 4000) // 每4秒切换一次
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
    // 页面出现时开始自动轮播
    this.startAutoPlay()
  }

  aboutToDisappear() {
    // 页面消失时停止自动轮播
    this.stopAutoPlay()
  }

  build() {
    Column() {
      // 顶部AI温馨问候
      Row() {
        Text(this.greetings[this.greetingIndex])
          .fontSize(18)
          .fontColor('#0D9FFB')
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16, top: 12, bottom: 8 })
          .layoutWeight(1)
          .opacity(this.greetingAnimOpacity)
          .translate({ x: 0, y: this.greetingAnimTranslateY })
        Text('换一句')
          .fontSize(15)
          .fontColor('#888')
          .margin({ right: 16 })
          .onClick(() => {
            let newIndex = this.greetingIndex
            while (newIndex === this.greetingIndex) {
              newIndex = Math.floor(Math.random() * this.greetings.length)
            }
            // 先淡出和下移
            animateTo({ duration: 180, curve: Curve.EaseOut }, () => {
              this.greetingAnimOpacity = 0;
              this.greetingAnimTranslateY = 20;
            })
            setTimeout(() => {
              this.greetingIndex = newIndex;
              // 再淡入和上移
              animateTo({ duration: 220, curve: Curve.EaseIn }, () => {
                this.greetingAnimOpacity = 1.0;
                this.greetingAnimTranslateY = 0;
              })
            }, 180)
          })
      }
      .width('100%')
      // 顶部搜索栏
      Row() {
        TextInput({ placeholder: '系统' })
          .width('90%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .fontColor('#222')
          .borderRadius(20)
          .padding({ left: 20 })
      }
      .width('100%')
      .padding({ top: 4, bottom: 8 })

      // 分类Tab - 均匀分布
      Row() {
        ForEach(this.tabs, (tab: string, idx: number) => {
          Column() {
            Text(tab)
              .fontSize(16)
              .fontColor(this.activeTab === idx ? '#222' : '#bbb')
              .fontWeight(this.activeTab === idx ? FontWeight.Bold : FontWeight.Normal)
            if (this.activeTab === idx) {
              Blank().height(2).width(24).backgroundColor('#0D9FFB').margin({ top: 2 })
            }
          }
          .onClick(() => { 
            this.activeTab = idx
            this.scrollToSection(idx)
          })
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }, (tab: string) => tab)
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })

      // 内容区域 - 垂直滚动
      Scroll(this.scrollController) {
        Column() {
          // Banner - 情绪卡片轮播
          Column() {
            Blank().height(15)
            // 情绪卡片轮播区域
            Stack() {
              // 当前情绪卡片
              Column() {
                Row() {
                  // 左侧切换按钮
                  Button('‹')
                    .fontSize(24)
                    .fontColor(this.emotionCards[this.currentEmotionIndex].textColor)
                    .backgroundColor(this.emotionCards[this.currentEmotionIndex].backgroundColor)
                    .borderRadius(20)
                    .width(40)
                    .height(40)
                    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
                    .onClick(() => this.switchEmotionCard('left'))
                  
                  // 情绪卡片内容
                  Column() {
                    Row() {
                      Text(this.emotionCards[this.currentEmotionIndex].emoji)
                        .fontSize(32)
                        .margin({ right: 12 })
                      Column() {
                        Text(this.emotionCards[this.currentEmotionIndex].title)
                          .fontSize(18)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(this.emotionCards[this.currentEmotionIndex].textColor)
                        Text(this.emotionCards[this.currentEmotionIndex].subtitle)
                          .fontSize(14)
                          .fontColor(this.emotionCards[this.currentEmotionIndex].textColor)
                          .opacity(0.8)
                      }
                      .layoutWeight(1)
                    }
                    .margin({ bottom: 8 })
                    Text(this.emotionCards[this.currentEmotionIndex].description)
                      .fontSize(13)
                      .fontColor(this.emotionCards[this.currentEmotionIndex].textColor)
                      .opacity(0.7)
                      .textAlign(TextAlign.Start)
                  }
                  .layoutWeight(1)
                  .margin({ left: 16, right: 16 })
                  
                  // 右侧切换按钮
                  Button('›')
                    .fontSize(24)
                    .fontColor(this.emotionCards[this.currentEmotionIndex].textColor)
                    .backgroundColor(this.emotionCards[this.currentEmotionIndex].backgroundColor)
                    .borderRadius(20)
                    .width(40)
                    .height(40)
                    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
                    .onClick(() => this.switchEmotionCard('right'))
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
              }
              .backgroundColor(this.emotionCards[this.currentEmotionIndex].backgroundColor)
              .borderRadius(16)
              .padding(20)
              .width('100%')
              .height(120)
              .opacity(this.emotionCardOpacity)
              .translate({ x: this.emotionCardTranslateX, y: 0 })
              .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
              .onClick(() => {
                // 根据当前情绪卡片执行相应操作
                switch(this.currentEmotionIndex) {
                  case 0:
                    // 跳转到情绪记录页面
                    console.log('跳转到情绪记录页面')
                    break
                  case 1:
                    // 跳转到压力测试页面
                    console.log('跳转到压力测试页面')
                    break
                  case 2:
                    // 跳转到正念练习页面
                    console.log('跳转到正念练习页面')
                    break
                }
              })
            }
            .width('100%')
            
            // 指示点和控制按钮
            Row() {
              // 指示点
              Row() {
                ForEach(this.emotionCards, (card: EmotionCard, idx: number) => {
                  Blank()
                    .width(idx === this.currentEmotionIndex ? 24 : 8)
                    .height(8)
                    .backgroundColor(idx === this.currentEmotionIndex ? '#0D9FFB' : '#eee')
                    .borderRadius(4)
                    .margin({ right: 4 })
                    .animation({
                      duration: 300,
                      curve: Curve.EaseInOut
                    })
                    .onClick(() => {
                      if (idx !== this.currentEmotionIndex) {
                        const direction = idx > this.currentEmotionIndex ? 'right' : 'left'
                        this.switchEmotionCard(direction)
                      }
                    })
                }, (card: EmotionCard) => card.id.toString())
              }
              .layoutWeight(1)
              
              // 播放/暂停按钮
              Button(this.isAutoPlaying ? '⏸️' : '▶️')
                .fontSize(16)
                .fontColor('#666')
                .backgroundColor('rgba(255,255,255,0.8)')
                .borderRadius(12)
                .width(24)
                .height(24)
                .margin({ right: 8 })
                .onClick(() => this.toggleAutoPlay())
            }
            .margin({ top: 12, bottom: 8 })
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .height(200) // 固定高度
          .padding({ left: 16, right: 16, bottom: 0 })

          // AI今日推荐卡片
          Column() {
            Row() {
              Text(this.aiRecommend.tag)
                .fontColor('#fff')
                .fontSize(12)
                .backgroundColor('#0D9FFB')
                .borderRadius(8)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .margin({ right: 8 })
              Text(this.aiRecommend.title)
                .fontColor('#222')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
            }
            .margin({ bottom: 4 })
            Text(this.aiRecommend.desc)
              .fontColor('#888')
              .fontSize(14)
              .margin({ bottom: 8 })
            Row() {
              Button('和AI聊聊')
                .fontColor('#fff')
                .backgroundColor('#0D9FFB')
                .borderRadius(16)
                .fontSize(15)
                .padding({ left: 18, right: 18, top: 6, bottom: 6 })
                .onClick(() => {
                  // TODO: 跳转到AI陪聊页面
                })
            }
          }
          .backgroundColor('#E3F2FD')
          .borderRadius(16)
          .padding(16)
          .margin({ top: 8, bottom: 20 })

          // 精选区
          this.BuildSection('精选推荐', this.selectedItems)
          // 音频区
          this.BuildSection('音乐电台', this.musicItems)
          // 专栏区
          this.BuildSection('专栏文章', this.columnItems)
          // 工具区
          Column() {
            Text('心理健康工具')
              .fontColor('#0D9FFB')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16, top: 24 })
            // 工具区纵向列表展示
            ForEach(this.toolList, (tool: ToolItem, idx: number) => {
              Row() {
                // 工具图标区域
                Row() {
                  Text(this.getToolIcon(tool.title))
                    .fontSize(24)
                    .fontColor(tool.color)
                }
                .width(48)
                .height(48)
                .backgroundColor(tool.bgColor)
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
                .margin({ right: 12 })
                // 工具信息
                Column() {
                  Text(tool.title)
                    .fontColor('#222')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(tool.desc)
                    .fontColor('#888')
                    .fontSize(13)
                    .margin({ top: 2 })
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
              .backgroundColor('#fff')
              .borderRadius(16)
              .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                console.log('点击了工具:', tool.title)
                if (tool.route) {
                  router.pushUrl({
                    url: tool.route,
                    params: {
                      toolName: tool.title,
                      toolType: this.getToolType(tool.title)
                    }
                  })
                }
              })
            }, (tool: ToolItem) => tool.title)
          }
          .width('100%')
          .margin({ bottom: 40 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 80 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }

  // 滚动到指定专栏的方法（定值累加法）
  scrollToSection(index: number) {
    let offset = this.searchBarHeight + this.tabBarHeight + this.bannerHeight;
    for (let i = 0; i < index; i++) {
      offset += this.sectionHeights[i] + this.sectionSpacing;
    }
    offset -= this.targetOffset;
    this.scrollController.scrollTo({ xOffset: 0, yOffset: offset });
  }

  @Builder
  BuildSection(title: string, items: SectionItem[]) {
    Column() {
      Text(title)
        .fontColor('#0D9FFB')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16, top: 24 })
      ForEach(items, (item: SectionItem, idx: number) => {
        Row() {
          // 如果有图片就显示图片，否则显示默认占位符
          if (item.image) {
            Image(item.image)
              .width(56)
              .height(56)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          } else {
            Blank().width(56).height(56).backgroundColor('#E3F2FD').borderRadius(8)
          }
          Column() {
            Text(item.title)
              .fontColor('#222')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(item.subtitle)
              .fontColor('#888')
              .fontSize(13)
              .margin({ top: 2 })
            Row() {
              Text('《' + item.tag + '》')
                .fontColor('#0D9FFB')
                .fontSize(12)
                .backgroundColor('#E3F2FD')
                .borderRadius(6)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              Text(item.author)
                .fontColor('#888')
                .fontSize(12)
                .margin({ left: 8 })
            }
            .margin({ top: 4 })
          }
          .margin({ left: 12 })
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
        .onClick(() => {
          console.log('点击了:', item.title)
          // 如果是音乐电台模块，跳转到音乐播放界面
          if (title === '音乐电台') {
            let musicType = 'fashion'; // 默认流行音乐
            if (item.tag === '古典') {
              musicType = 'classic';
            } else if (item.tag === '轻音') {
              musicType = 'soft';
            }
            
            router.pushUrl({
              url: 'pages/fm_musicBegin',
              params: {
                musicId: (idx + 1).toString(),
                musicTitle: item.title,
                musicArtist: item.author,
                musicType: musicType
              }
            });
          }
          // 如果是专栏文章模块，跳转到专栏页面
          else if (title === '专栏文章') {
            let columnType = 'depth'; // 默认深度解析
            if (item.tag === '技术') {
              columnType = 'tech';
            } else if (item.tag === '观察') {
              columnType = 'observe';
            }
            
            router.pushUrl({
              url: 'pages/fm_columnpage',
              params: {
                columnId: (idx + 1).toString(),
                columnName: item.title,
                columnAuthor: item.author,
                columnType: columnType
              }
            });
          }
        })
      }, (item: SectionItem) => item.title)
    }
    .width('100%')
    .margin({ bottom: 40 })
  }

  // 获取工具图标的方法
  private getToolIcon(title: string): string {
    switch (title) {
      case '冥想练习':
        return '🧘‍♀️'
      case '呼吸训练':
        return '💨'
      case '压力评估':
        return '📊'
      default:
        return '🔧'
    }
  }

  // 获取工具类型的方法
  private getToolType(title: string): string {
    switch (title) {
      case '冥想练习':
        return 'meditation'
      case '呼吸训练':
        return 'breathing'
      case '压力评估':
        return 'assessment'
      default:
        return 'tool'
    }
  }
} 