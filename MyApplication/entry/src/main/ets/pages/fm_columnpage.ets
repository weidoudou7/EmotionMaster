import router from '@ohos.router';

// 定义文章接口
interface Article {
  id: string;
  title: string;
  subtitle: string;
  author: string;
  publishTime: string;
  readTime: string;
  tags: string[];
  coverImage: Resource;
  content: string;
  icon?: string;
  iconColor?: string;
  bgColor?: string;
}

// 定义专栏接口
interface Column {
  id: string;
  name: string;
  description: string;
  coverImage: Resource;
  articleCount: number;
  followerCount: number;
  isFollowed: boolean;
  icon?: string;
  iconColor?: string;
  bgColor?: string;
}

// 定义专栏参数接口
interface ColumnParams {
  columnId?: string;
  columnName?: string;
  columnAuthor?: string;
  columnType?: string;
}

const params = router.getParams() as ColumnParams;

@Entry
@Component
struct ColumnPage {
  @State currentColumn: Column = {
    id: '1',
    name: '深度解析',
    description: '深度分析行业趋势，解读热点话题',
    coverImage: $r('app.media.background'),
    articleCount: 156,
    followerCount: 2847,
    isFollowed: false
  };

  @State articles: Article[] = [];

  @State currentTab: number = 0;
  private tabs: string[] = ['最新', '热门', '推荐'];

  // 心理科普专栏文章
  private depthArticles: Article[] = [
    {
      id: '1',
      title: '焦虑症的识别与自我调节方法',
      subtitle: '科学认识焦虑，掌握有效的缓解技巧',
      author: '临床心理学专家',
      publishTime: '2024-01-15',
      readTime: '10分钟',
      tags: ['焦虑症', '心理健康', '自我调节'],
      coverImage: $r('app.media.background'),
      content: '焦虑是现代人最常见的心理健康问题之一。本文将从心理学角度深入解析焦虑的成因、表现和科学的调节方法，帮助读者更好地应对焦虑情绪...',
      icon: '😰',
      iconColor: '#FF5722',
      bgColor: '#FFEBEE'
    },
    {
      id: '2',
      title: '抑郁症的早期识别与预防',
      subtitle: '了解抑郁信号，及时寻求专业帮助',
      author: '精神科医生',
      publishTime: '2024-01-14',
      readTime: '12分钟',
      tags: ['抑郁症', '早期识别', '预防干预'],
      coverImage: $r('app.media.background'),
      content: '抑郁症是一种常见的心理健康疾病，早期识别和干预至关重要。本文将详细介绍抑郁症的早期症状、风险因素和预防策略...',
      icon: '😔',
      iconColor: '#9C27B0',
      bgColor: '#F3E5F5'
    },
    {
      id: '3',
      title: '压力管理：从生理到心理的全面解析',
      subtitle: '科学理解压力，建立健康的应对机制',
      author: '健康心理学专家',
      publishTime: '2024-01-13',
      readTime: '15分钟',
      tags: ['压力管理', '生理心理', '健康生活'],
      coverImage: $r('app.media.background'),
      content: '压力是现代社会不可避免的一部分，但过度的压力会对身心健康造成严重影响。本文将从生理和心理两个维度，全面解析压力的影响机制和科学的管理方法...',
      icon: '💪',
      iconColor: '#2196F3',
      bgColor: '#E3F2FD'
    }
  ];

  // AI应用专栏文章
  private techArticles: Article[] = [
    {
      id: '1',
      title: 'AI心理咨询：技术与伦理的平衡',
      subtitle: '探讨AI在心理咨询中的应用前景与挑战',
      author: 'AI伦理专家',
      publishTime: '2024-01-15',
      readTime: '18分钟',
      tags: ['AI咨询', '伦理问题', '心理健康'],
      coverImage: $r('app.media.background'),
      content: 'AI技术在心理咨询领域的应用正在快速发展，但同时也带来了伦理和隐私保护等挑战。本文将深入探讨AI心理咨询的技术实现、应用场景和伦理考量...',
      icon: '🤖',
      iconColor: '#607D8B',
      bgColor: '#ECEFF1'
    },
    {
      id: '2',
      title: '机器学习在情绪识别中的应用',
      subtitle: '从语音到文字的智能情绪分析技术',
      author: '机器学习专家',
      publishTime: '2024-01-14',
      readTime: '15分钟',
      tags: ['机器学习', '情绪识别', 'AI技术'],
      coverImage: $r('app.media.background'),
      content: '情绪识别是AI心理健康应用的核心技术之一。本文将详细介绍机器学习在语音、文字、图像等多种模态情绪识别中的应用原理和技术实现...',
      icon: '📊',
      iconColor: '#FF9800',
      bgColor: '#FFF3E0'
    },
    {
      id: '3',
      title: '自然语言处理在心理健康对话系统中的应用',
      subtitle: '构建智能化的心理健康对话机器人',
      author: 'NLP研究员',
      publishTime: '2024-01-13',
      readTime: '12分钟',
      tags: ['NLP', '对话系统', '心理健康'],
      coverImage: $r('app.media.background'),
      content: '自然语言处理技术为心理健康对话系统提供了强大的技术支持。本文将探讨如何利用NLP技术构建智能化的心理健康对话机器人，提供个性化的心理支持...',
      icon: '💬',
      iconColor: '#4CAF50',
      bgColor: '#E8F5E8'
    }
  ];

  // 行业动态专栏文章
  private observeArticles: Article[] = [
    {
      id: '1',
      title: '2024年心理健康行业投资趋势报告',
      subtitle: '资本视角下的心理健康市场发展机遇',
      author: '投资分析师',
      publishTime: '2024-01-15',
      readTime: '20分钟',
      tags: ['投资趋势', '市场分析', '心理健康'],
      coverImage: $r('app.media.background'),
      content: '心理健康行业正成为投资热点，本文将从资本视角分析2024年心理健康市场的投资趋势、热门赛道和未来发展机遇...',
      icon: '💰',
      iconColor: '#4CAF50',
      bgColor: '#E8F5E8'
    },
    {
      id: '2',
      title: '全球心理健康政策法规最新动态',
      subtitle: '各国心理健康政策对比与趋势分析',
      author: '政策研究专家',
      publishTime: '2024-01-14',
      readTime: '16分钟',
      tags: ['政策法规', '全球趋势', '心理健康'],
      coverImage: $r('app.media.background'),
      content: '各国政府越来越重视心理健康问题，纷纷出台相关政策法规。本文将对比分析全球主要国家的心理健康政策，探讨政策趋势对行业发展的影响...',
      icon: '📋',
      iconColor: '#2196F3',
      bgColor: '#E3F2FD'
    },
    {
      id: '3',
      title: '心理健康服务标准化与质量监管',
      subtitle: '建立行业标准，保障服务质量',
      author: '行业监管专家',
      publishTime: '2024-01-13',
      readTime: '14分钟',
      tags: ['标准化', '质量监管', '行业规范'],
      coverImage: $r('app.media.background'),
      content: '随着心理健康服务的普及，标准化和质量监管成为行业发展的重要议题。本文将探讨如何建立心理健康服务的行业标准和质量监管体系...',
      icon: '🏛️',
      iconColor: '#9C27B0',
      bgColor: '#F3E5F5'
    }
  ];

  aboutToAppear() {
    // 根据传入的参数初始化专栏内容
    this.initializeColumn();
  }

  // 初始化专栏内容
  initializeColumn() {
    const columnType = params.columnType || 'depth';
    
    switch(columnType) {
      case 'depth':
        this.currentColumn = {
          id: '1',
          name: '心理科普',
          description: 'AI心理健康知识深度解析，科学认识心理健康问题',
          coverImage: $r('app.media.background'),
          articleCount: 156,
          followerCount: 2847,
          isFollowed: false,
          icon: '🧠',
          iconColor: '#1976D2',
          bgColor: '#E3F2FD'
        };
        this.articles = this.depthArticles;
        break;
      case 'tech':
        this.currentColumn = {
          id: '2',
          name: 'AI应用',
          description: 'AI技术在心理健康领域的应用与创新',
          coverImage: $r('app.media.background'),
          articleCount: 89,
          followerCount: 1567,
          isFollowed: false,
          icon: '🤖',
          iconColor: '#4CAF50',
          bgColor: '#E8F5E8'
        };
        this.articles = this.techArticles;
        break;
      case 'observe':
        this.currentColumn = {
          id: '3',
          name: '行业动态',
          description: '心理健康行业最新趋势与政策动态观察',
          coverImage: $r('app.media.background'),
          articleCount: 203,
          followerCount: 3921,
          isFollowed: false,
          icon: '📈',
          iconColor: '#FF9800',
          bgColor: '#FFF3E0'
        };
        this.articles = this.observeArticles;
        break;
      default:
        this.currentColumn = {
          id: '1',
          name: '心理科普',
          description: 'AI心理健康知识深度解析',
          coverImage: $r('app.media.background'),
          articleCount: 156,
          followerCount: 2847,
          isFollowed: false,
          icon: '🧠',
          iconColor: '#1976D2',
          bgColor: '#E3F2FD'
        };
        this.articles = this.depthArticles;
    }
  }

  // 切换关注状态
  toggleFollow() {
    this.currentColumn.isFollowed = !this.currentColumn.isFollowed;
    if (this.currentColumn.isFollowed) {
      this.currentColumn.followerCount++;
    } else {
      this.currentColumn.followerCount--;
    }
  }

  // 跳转到文章详情页
  goToArticleDetail(article: Article, columnType: string) {
    router.pushUrl({
      url: 'pages/fm_articleDetail',
      params: {
        articleId: article.id,
        articleTitle: article.title,
        articleType: columnType
      }
    });
  }

  build() {
    Column() {
      // 返回按钮（绝对定位悬浮最上方）
      Stack() {
        // 返回按钮
        Image($r('app.media.music_return'))
          .width(36)
          .height(36)
          .fillColor(Color.White)
          //.shadow({ radius: 4, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 2 })
          .position({ x: 16, y: 16 })
          .onClick(() => router.back())
        // 卡片内容整体下移
        Column() {
          // 如果有图标就显示图标，否则显示封面图片
          if (this.currentColumn.icon) {
            Row() {
              Text(this.currentColumn.icon)
                .fontSize(32)
                .fontColor(this.currentColumn.iconColor || '#666')
            }
            .width(60)
            .height(60)
            .backgroundColor(this.currentColumn.bgColor || '#F5F5F5')
            .borderRadius(8)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .margin({ bottom: 12, top: 12 })
          } else {
            Image(this.currentColumn.coverImage)
              .width(60)
              .height(60)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
              .margin({ bottom: 12, top: 12 })
          }
          Text(this.currentColumn.name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1976D2')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 4 })
          Text(this.currentColumn.description)
            .fontSize(14)
            .fontColor('#666')
            .maxLines(2)
            .textAlign(TextAlign.Center)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })
          Button(this.currentColumn.isFollowed ? '已关注' : '关注')
            .fontSize(14)
            .fontColor(this.currentColumn.isFollowed ? '#999' : '#fff')
            .backgroundColor(this.currentColumn.isFollowed ? '#f5f5f5' : '#0D9FFB')
            .borderRadius(16)
            .padding({ left: 24, right: 24, top: 8, bottom: 8 })
            .margin({ top: 4 })
            .onClick(() => this.toggleFollow())
        }
        .width('100%')
        .padding(20)
        .backgroundColor(this.currentColumn.bgColor || '#E3F2FD')
        .borderRadius(16)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.10)', offsetX: 0, offsetY: 4 })
        .margin({ top: 65, left: 16, right: 16, bottom: 8 })
      }
      .width('100%')
      // 标签栏
      Row() {
        ForEach(this.tabs, (tab: string, idx: number) => {
          Text(tab)
            .fontSize(16)
            .fontColor(this.currentTab === idx ? '#0D9FFB' : '#666')
            .fontWeight(this.currentTab === idx ? FontWeight.Medium : FontWeight.Normal)
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .onClick(() => {
              this.currentTab = idx;
            })
        }, (tab: string) => tab)
      }
      .width('100%')
      .backgroundColor('#fff')
      .border({ width: { bottom: 1 }, color: '#f0f0f0' })

      // 文章列表
      List() {
        ForEach(this.articles, (article: Article) => {
          ListItem() {
            this.ArticleCard(article, params.columnType || 'depth')
          }
        }, (article: Article) => article.id)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#f8f8f8')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f8f8')
  }

  @Builder
  ArticleCard(article: Article, columnType: string) {
    Column() {
      // 文章内容
      Row() {
        Column() {
          Text(article.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          Text(article.subtitle)
            .fontSize(14)
            .fontColor('#666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          // 作者和发布时间信息
          Row() {
            Text(article.author)
              .fontSize(12)
              .fontColor('#999')
            Text(` · ${article.publishTime} · ${article.readTime}`)
              .fontSize(12)
              .fontColor('#999')
          }
          .margin({ bottom: 8 })

          // 标签
          Row() {
            ForEach(article.tags, (tag: string) => {
              Text(tag)
                .fontSize(12)
                .fontColor('#0D9FFB')
                .backgroundColor('#E3F2FD')
                .borderRadius(12)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .margin({ right: 6 })
            }, (tag: string) => tag)
          }
        }
        .layoutWeight(1)

        // 如果有图标就显示图标，否则显示封面图片
        if (article.icon) {
          Row() {
            Text(article.icon)
              .fontSize(28)
              .fontColor(article.iconColor || '#666')
          }
          .width(80)
          .height(80)
          .backgroundColor(article.bgColor || '#F5F5F5')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({ left: 12 })
        } else {
          Image(article.coverImage)
            .width(80)
            .height(80)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
            .margin({ left: 12 })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .margin({ bottom: 8 })
    .onClick(() => {
      this.goToArticleDetail(article, columnType);
      console.log("进入了:"+article.title)
    })
  }

  @Builder
  BuildSection(title: string, items: Article[], columnType: string) {
    Column() {
      Text(title)
        .fontColor('#0D9FFB')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16, top: 24 })
      ForEach(items, (item: Article, idx: number) => {
        Row() {
          this.ArticleCard(item, columnType)
        }
      }, (item: Article) => item.id)
    }
    .width('100%')
    .margin({ bottom: 40 })
  }
} 