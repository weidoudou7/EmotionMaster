// homepage.ets - 超级动态页面
import { BottomNavBar } from './BottomNavBar';
import { ApiService } from '../service/apiservice';
import { globalUserData } from '../models/userdata';
import { Dynamic } from '../models/aidata';

@Entry
@Component
export struct HomePage {
  @State dynamics: Dynamic[] = [] // 动态列表
  @State isLoading: boolean = false // 加载状态
  @State isRefreshing: boolean = false // 刷新状态
  @State currentPage: number = 1 // 当前页码
  @State hasMore: boolean = true // 是否还有更多数据
  @State errorMessage: string = '' // 错误信息
  private pageSize: number = 10 // 每页数量

  aboutToAppear() {
    this.loadDynamics(true)
  }

  // 加载动态数据
  async loadDynamics(isRefresh: boolean = false) {
    if (this.isLoading) return

    try {
      this.isLoading = true
      this.errorMessage = ''

      if (isRefresh) {
        this.currentPage = 1
        this.hasMore = true
      }

      console.log('🔄 开始加载动态，页码:', this.currentPage)
      
      const newDynamics = await ApiService.getAllPublicDynamics(this.currentPage, this.pageSize)
      console.log('✅ 获取到动态数据:', newDynamics.length, '条')

      if (isRefresh) {
        this.dynamics = newDynamics
      } else {
        this.dynamics = [...this.dynamics, ...newDynamics]
      }

      // 判断是否还有更多数据
      this.hasMore = newDynamics.length === this.pageSize
      
      if (!isRefresh && this.hasMore) {
        this.currentPage++
      }

      console.log('📊 当前动态总数:', this.dynamics.length, '是否还有更多:', this.hasMore)
    } catch (error) {
      console.error('❌ 加载动态失败:', error)
      this.errorMessage = error instanceof Error ? error.message : '加载失败'
    } finally {
      this.isLoading = false
      this.isRefreshing = false
    }
  }

  // 下拉刷新
  onRefresh() {
    console.log('🔄 触发下拉刷新')
    this.isRefreshing = true
    this.loadDynamics(true)
  }

  // 上拉加载更多
  onLoadMore() {
    if (this.hasMore && !this.isLoading) {
      console.log('📥 触发上拉加载更多')
      this.loadDynamics(false)
    }
  }

  // 导航到发布动态页面
  navigateToPublish() {
    let uiContext: UIContext = this.getUIContext();
    let router = uiContext.getRouter();
    router.pushUrl({ url: 'pages/DynamicList' });
  }

  // 导航到个人页面
  navigateToProfile() {
    let uiContext: UIContext = this.getUIContext();
    let router = uiContext.getRouter();
    router.pushUrl({ url: 'pages/yourpage' });
  }

  // 格式化时间
  formatTime(timeString: string): string {
    if (!timeString) return ''
    
    try {
      const date = new Date(timeString)
      const now = new Date()
      const diff = now.getTime() - date.getTime()
      
      const minutes = Math.floor(diff / (1000 * 60))
      const hours = Math.floor(diff / (1000 * 60 * 60))
      const days = Math.floor(diff / (1000 * 60 * 60 * 24))
      
      if (minutes < 1) return '刚刚'
      if (minutes < 60) return `${minutes}分钟前`
      if (hours < 24) return `${hours}小时前`
      if (days < 7) return `${days}天前`
      
      return date.toLocaleDateString()
    } catch (error) {
      return timeString
    }
  }

  // 动态卡片组件
  @Builder
  DynamicCard(dynamic: Dynamic) {
    Column() {
      // 用户信息行
      Row() {
        Image(dynamic.userAvatar || '/common/media/default.png')
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 12 })
        
        Column() {
          Text(dynamic.userName || '匿名用户')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          Text(this.formatTime(dynamic.createTime))
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        // 更多按钮
        Button('⋯')
          .fontSize(20)
          .fontColor('#999999')
          .backgroundColor(Color.Transparent)
          .width(32)
          .height(32)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      
      // 动态内容
      if (dynamic.content) {
        Text(dynamic.content)
          .fontSize(15)
          .fontColor('#333333')
          .lineHeight(22)
          .textAlign(TextAlign.Start)
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 8 })
      }
      
      // 图片内容
      if (dynamic.images && dynamic.images.length > 0) {
        Grid() {
          ForEach(dynamic.images, (image: string, index: number) => {
            GridItem() {
              Image(image)
                .width('100%')
                .height(120)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(4)
        .rowsGap(4)
        .padding({ left: 16, right: 16, bottom: 8 })
      }
      
      // 话题标签
      if (dynamic.topicTags && dynamic.topicTags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(dynamic.topicTags, (tag: string) => {
            Text(`#${tag}`)
              .fontSize(12)
              .fontColor('#0D9FFB')
              .backgroundColor('#F0F8FF')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
              .margin({ right: 8, bottom: 4 })
          })
        }
        .padding({ left: 16, right: 16, bottom: 8 })
      }
      
      // 操作按钮行
      Row() {
        // 点赞按钮
        Row() {
          Text('❤️')
            .fontSize(16)
            .margin({ right: 4 })
          Text(dynamic.likeCount?.toString() || '0')
            .fontSize(14)
            .fontColor('#666666')
        }
        .onClick(() => {
          // TODO: 实现点赞功能
          console.log('点赞动态:', dynamic.id)
        })
        
        // 评论按钮
        Row() {
          Text('💬')
            .fontSize(16)
            .margin({ right: 4 })
          Text(dynamic.commentCount?.toString() || '0')
            .fontSize(14)
            .fontColor('#666666')
        }
        .margin({ left: 24 })
        .onClick(() => {
          // TODO: 实现评论功能
          console.log('评论动态:', dynamic.id)
        })
        
        // 分享按钮
        Row() {
          Text('📤')
            .fontSize(16)
            .margin({ right: 4 })
          Text('分享')
            .fontSize(14)
            .fontColor('#666666')
        }
        .margin({ left: 24 })
        .onClick(() => {
          // TODO: 实现分享功能
          console.log('分享动态:', dynamic.id)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })
      .justifyContent(FlexAlign.Start)
    }
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Text('动态广场')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Blank()
          
          // 发布按钮
          Button('发布')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#0D9FFB')
            .borderRadius(16)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .onClick(() => {
              this.navigateToPublish()
            })
          
          // 个人中心按钮
          Button() {
            Image(globalUserData.userAvatar || '/common/media/default.png')
              .width(32)
              .height(32)
              .borderRadius(16)
          }
          .backgroundColor(Color.Transparent)
          .margin({ left: 12 })
          .onClick(() => {
            this.navigateToProfile()
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor(Color.White)
        .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 1 })
        
        // 动态列表
        Refresh({ refreshing: $$this.isRefreshing, offset: 120, friction: 100 }) {
          List() {
            // 动态卡片
            ForEach(this.dynamics, (dynamic: Dynamic) => {
              ListItem() {
                this.DynamicCard(dynamic)
              }
            })
            
            // 加载更多指示器
            if (this.isLoading && this.dynamics.length > 0) {
              ListItem() {
                Row() {
                  LoadingProgress()
                    .width(20)
                    .height(20)
                    .margin({ right: 8 })
                  Text('加载中...')
                    .fontSize(14)
                    .fontColor('#999999')
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding({ top: 20, bottom: 20 })
              }
            }
            
            // 没有更多数据提示
            if (!this.hasMore && this.dynamics.length > 0) {
              ListItem() {
                Text('没有更多动态了')
                  .fontSize(14)
                  .fontColor('#999999')
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding({ top: 20, bottom: 20 })
              }
            }
            
            // 空状态
            if (!this.isLoading && this.dynamics.length === 0 && !this.errorMessage) {
              ListItem() {
                Column() {
                  Text('📝')
                    .fontSize(80)
                    .margin({ bottom: 16 })
                  Text('暂无动态')
                    .fontSize(16)
                    .fontColor('#999999')
                  Text('快来发布第一条动态吧！')
                    .fontSize(14)
                    .fontColor('#CCCCCC')
                    .margin({ top: 8 })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding({ top: 100, bottom: 100 })
              }
            }
            
            // 错误状态
            if (this.errorMessage) {
              ListItem() {
                Column() {
                  Text('❌')
                    .fontSize(80)
                    .margin({ bottom: 16 })
                  Text('加载失败')
                    .fontSize(16)
                    .fontColor('#FF4D4F')
                  Text(this.errorMessage)
                    .fontSize(14)
                    .fontColor('#999999')
                    .margin({ top: 8 })
                  Button('重试')
                    .fontSize(14)
                    .fontColor(Color.White)
                    .backgroundColor('#0D9FFB')
                    .borderRadius(16)
                    .padding({ left: 24, right: 24, top: 8, bottom: 8 })
                    .margin({ top: 16 })
                    .onClick(() => {
                      this.loadDynamics(true)
                    })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding({ top: 100, bottom: 100 })
              }
            }
          }
          .width('100%')
          .height('100%')
          .padding({ left: 16, right: 16 })
          .onReachEnd(() => {
            this.onLoadMore()
          })
        }
        .onRefreshing(() => {
          this.onRefresh()
        })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
      
      // 底部导航栏
      BottomNavBar({ currentIndex: 0 })
    }
  }
}