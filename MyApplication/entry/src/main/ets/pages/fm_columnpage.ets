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

  @State currentColumnType: string = 'depth';

  // 深度解析专栏文章
  private depthArticles: Article[] = [
    {
      id: '1',
      title: '心理健康在现代社会的重要性',
      subtitle: '探讨现代人面临的心理挑战及应对策略',
      author: '心理学专家',
      publishTime: '2024-01-15',
      readTime: '8分钟',
      tags: ['心理健康', '现代生活', '压力管理'],
      coverImage: $r('app.media.background'),
      content: '在现代快节奏的生活中，心理健康问题日益突出。本文将从多个角度分析现代人面临的心理挑战，并提供实用的应对策略...',
    },
    {
      id: '2',
      title: '正念冥想的科学依据与实践方法',
      subtitle: '基于神经科学研究的冥想指南',
      author: '神经科学研究员',
      publishTime: '2024-01-14',
      readTime: '12分钟',
      tags: ['正念冥想', '神经科学', '心理健康'],
      coverImage: $r('app.media.background'),
      content: '正念冥想作为一种古老的心理练习方法，在现代神经科学研究中得到了越来越多的验证。本文将详细介绍其科学依据...',
    },
    {
      id: '3',
      title: '情绪管理的艺术：从认知到行动',
      subtitle: '如何更好地理解和控制自己的情绪',
      author: '情绪管理专家',
      publishTime: '2024-01-13',
      readTime: '10分钟',
      tags: ['情绪管理', '认知行为', '自我提升'],
      coverImage: $r('app.media.background'),
      content: '情绪管理是每个人都需要掌握的重要技能。本文将从认知行为的角度，介绍如何更好地理解和控制自己的情绪...',
    }
  ];

  // 技术分享专栏文章
  private techArticles: Article[] = [
    {
      id: '1',
      title: '鸿蒙开发实战：从零开始构建心理健康应用',
      subtitle: '详细讲解鸿蒙应用开发流程和最佳实践',
      author: '鸿蒙开发专家',
      publishTime: '2024-01-15',
      readTime: '15分钟',
      tags: ['鸿蒙开发', 'ArkTS', '应用开发'],
      coverImage: $r('app.media.background'),
      content: '本文将从零开始，详细介绍如何使用鸿蒙HarmonyOS开发一个心理健康应用。包括项目搭建、UI设计、数据管理等核心内容...',
    },
    {
      id: '2',
      title: 'ArkTS状态管理最佳实践',
      subtitle: '深入理解鸿蒙应用的状态管理机制',
      author: '前端架构师',
      publishTime: '2024-01-14',
      readTime: '12分钟',
      tags: ['ArkTS', '状态管理', '架构设计'],
      coverImage: $r('app.media.background'),
      content: '状态管理是应用开发中的核心概念。本文将深入探讨ArkTS中的状态管理机制，包括@State、@Link、@Prop等装饰器的使用...',
    },
    {
      id: '3',
      title: '鸿蒙UI组件库设计与实现',
      subtitle: '如何构建可复用的UI组件库',
      author: 'UI工程师',
      publishTime: '2024-01-13',
      readTime: '10分钟',
      tags: ['UI设计', '组件库', '鸿蒙开发'],
      coverImage: $r('app.media.background'),
      content: '优秀的UI组件库能够大大提高开发效率。本文将分享如何设计一个高质量的鸿蒙UI组件库，包括组件设计原则、实现技巧等...',
    }
  ];

  // 行业观察专栏文章
  private observeArticles: Article[] = [
    {
      id: '1',
      title: '2024年心理健康行业发展趋势分析',
      subtitle: '深度解读心理健康市场的新机遇与挑战',
      author: '行业分析师',
      publishTime: '2024-01-15',
      readTime: '18分钟',
      tags: ['行业分析', '市场趋势', '心理健康'],
      coverImage: $r('app.media.background'),
      content: '随着人们对心理健康的重视程度不断提升，心理健康行业正在经历前所未有的发展机遇。本文将从多个维度分析2024年的行业趋势...',
    },
    {
      id: '2',
      title: 'AI技术在心理健康领域的应用前景',
      subtitle: '探索人工智能如何改变心理健康服务',
      author: 'AI研究员',
      publishTime: '2024-01-14',
      readTime: '14分钟',
      tags: ['人工智能', '心理健康', '技术创新'],
      coverImage: $r('app.media.background'),
      content: '人工智能技术正在各个领域发挥重要作用，心理健康领域也不例外。本文将探讨AI在心理咨询、情绪识别、个性化治疗等方面的应用...',
    },
    {
      id: '3',
      title: '数字化心理健康服务的商业模式创新',
      subtitle: '从传统咨询到数字化服务的转型之路',
      author: '商业模式专家',
      publishTime: '2024-01-13',
      readTime: '16分钟',
      tags: ['商业模式', '数字化转型', '心理健康服务'],
      coverImage: $r('app.media.background'),
      content: '数字化正在重塑心理健康服务的商业模式。本文将分析传统心理健康服务向数字化转型的路径，以及新的商业机会...',
    }
  ];

  aboutToAppear() {
    // 根据传入的参数初始化专栏内容
    this.initializeColumn();
  }

  // 初始化专栏内容
  initializeColumn() {
    const columnType = params.columnType || 'depth';
    this.currentColumnType = columnType;
    switch(columnType) {
      case 'depth':
        this.currentColumn = {
          id: '1',
          name: '深度解析',
          description: '深度分析行业趋势，解读热点话题，提供专业见解',
          coverImage: $r('app.media.background'),
          articleCount: 156,
          followerCount: 2847,
          isFollowed: false
        };
        this.articles = this.depthArticles;
        break;
      case 'tech':
        this.currentColumn = {
          id: '2',
          name: '技术分享',
          description: '分享鸿蒙开发技术，探讨前沿技术趋势',
          coverImage: $r('app.media.background'),
          articleCount: 89,
          followerCount: 1567,
          isFollowed: false
        };
        this.articles = this.techArticles;
        break;
      case 'observe':
        this.currentColumn = {
          id: '3',
          name: '行业观察',
          description: '观察行业动态，分析市场趋势，洞察未来发展',
          coverImage: $r('app.media.background'),
          articleCount: 203,
          followerCount: 3921,
          isFollowed: false
        };
        this.articles = this.observeArticles;
        break;
      default:
        this.currentColumn = {
          id: '1',
          name: '深度解析',
          description: '深度分析行业趋势，解读热点话题',
          coverImage: $r('app.media.background'),
          articleCount: 156,
          followerCount: 2847,
          isFollowed: false
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
      // 顶部导航栏
      Row() {
        Button('‹')
          .fontSize(24)
          .fontColor('#333')
          .backgroundColor('transparent')
          .onClick(() => router.back())

        Column() {
          Text(this.currentColumn.name)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
          Text(`${this.currentColumn.articleCount}篇文章 · ${this.currentColumn.followerCount}人关注`)
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .margin({ left: 16, right: 16 })

        Button(this.currentColumn.isFollowed ? '已关注' : '关注')
          .fontSize(14)
          .fontColor(this.currentColumn.isFollowed ? '#999' : '#fff')
          .backgroundColor(this.currentColumn.isFollowed ? '#f5f5f5' : '#0D9FFB')
          .borderRadius(16)
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .onClick(() => this.toggleFollow())
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')
      .border({ width: { bottom: 1 }, color: '#f0f0f0' })

      // 专栏介绍
      Row() {
        Image(this.currentColumn.coverImage)
          .width(60)
          .height(60)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        Column() {
          Text(this.currentColumn.description)
            .fontSize(14)
            .fontColor('#666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#fff')
      .margin({ bottom: 8 })

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
            this.ArticleCard(article, this.currentColumnType)
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

        Image(article.coverImage)
          .width(80)
          .height(80)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .margin({ left: 12 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .margin({ bottom: 8 })
    .onClick(() => {
      this.goToArticleDetail(article, this.currentColumnType);
      console.log("进入了:"+article.title+",类别为："+this.currentColumnType)
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