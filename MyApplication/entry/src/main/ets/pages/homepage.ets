// homepage.ets - 超级动态页面
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
  @State arcRotation: number = 0 // 圆弧旋转角度
  @State starTwinkle: number = 0 // 星星闪烁效果
  @State glowOpacity: number = 0.5 // 发光效果透明度
  @State textOpacity: number = 0.8 // 文字透明度
  @State nebulaOpacity: number = 0.3 // 星云透明度
  private pageSize: number = 10 // 每页数量

  aboutToAppear() {
    console.log('🏠 HomePage 开始加载')
    this.startGalaxyAnimations()
    this.loadDynamics(true)
  }

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
    console.log('📝 导航到发布页面')
    // TODO: 实现导航逻辑
  }

  // 导航到个人页面
  navigateToProfile() {
    console.log('👤 导航到个人页面')
    // TODO: 实现导航逻辑
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
    Stack() {
      // 动态卡片背景发光效果
      Column()
        .width('100%')
        .height('auto')
        .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
        .borderRadius(20)
        .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
      
      Column() {
        // 用户信息行
        Row() {
          Image(dynamic.userAvatar || '/common/media/default.png')
            .width(40)
            .height(40)
            .borderRadius(20)
            .border({ width: 2, color: 'rgba(255, 255, 255, 0.2)' })
            .margin({ right: 12 })
          
          Column() {
            Text(dynamic.userName || '匿名用户')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#ffffff')
              .opacity(this.textOpacity)
            
            Text(this.formatTime(dynamic.createTime))
              .fontSize(12)
              .fontColor('rgba(255, 255, 255, 0.6)')
              .opacity(this.textOpacity)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          
          // 更多按钮
          Button('⋯')
            .fontSize(20)
            .fontColor('rgba(255, 255, 255, 0.7)')
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
            .fontColor('rgba(255, 255, 255, 0.9)')
            .lineHeight(22)
            .textAlign(TextAlign.Start)
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 8 })
            .opacity(this.textOpacity)
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
                .fontColor('#ffffff')
                .backgroundColor('rgba(255, 255, 255, 0.1)')
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
              .fontColor('rgba(255, 255, 255, 0.7)')
          }
          .onClick(() => {
            console.log('点赞动态:', dynamic.id)
          })
          
          // 评论按钮
          Row() {
            Text('💬')
              .fontSize(16)
              .margin({ right: 4 })
            Text(dynamic.commentCount?.toString() || '0')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.7)')
          }
          .margin({ left: 24 })
          .onClick(() => {
            console.log('评论动态:', dynamic.id)
          })
          
          // 分享按钮
          Row() {
            Text('📤')
              .fontSize(16)
              .margin({ right: 4 })
            Text('分享')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.7)')
          }
          .margin({ left: 24 })
          .onClick(() => {
            console.log('分享动态:', dynamic.id)
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .backgroundColor('rgba(255, 255, 255, 0.03)')
      .borderRadius(20)
      .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
      .margin({ bottom: 16 })
      .shadow({ radius: 12, color: '#00000030', offsetX: 0, offsetY: 4 })
    }
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
        // 顶部导航栏
        Stack() {
          // 导航栏背景发光效果
          Column()
            .width('100%')
            .height(80)
            .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.03})`)
            .borderRadius(0)
            .border({ width: { bottom: 1 }, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
          
          Row() {
            Text('动态广场')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ffffff')
              .opacity(this.textOpacity)
            
            Blank()
            
            // 发布按钮
            Button('发布')
              .fontSize(14)
              .fontColor('#000000')
              .backgroundColor('#ffffff')
              .borderRadius(20)
              .padding({ left: 20, right: 20, top: 8, bottom: 8 })
              .onClick(() => {
                this.navigateToPublish()
              })
            
            // 个人中心按钮
            Button() {
              Image(globalUserData.userAvatar || '/common/media/default.png')
                .width(36)
                .height(36)
                .borderRadius(18)
            }
            .backgroundColor('rgba(255, 255, 255, 0.1)')
            .border({ width: 1, color: 'rgba(255, 255, 255, 0.2)' })
            .borderRadius(18)
            .margin({ left: 12 })
            .onClick(() => {
              this.navigateToProfile()
            })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        }
        
        // 动态列表区域
        Column() {
          // 下拉刷新区域
          if (this.isRefreshing) {
            Row() {
              LoadingProgress()
                .width(20)
                .height(20)
                .color('#ffffff')
                .margin({ right: 8 })
              Text('刷新中...')
                .fontSize(14)
                .fontColor('rgba(255, 255, 255, 0.7)')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding({ top: 20, bottom: 20 })
          } else {
            // 刷新按钮
            Button('🔄 刷新动态')
              .fontSize(14)
              .fontColor('#ffffff')
              .backgroundColor('rgba(255, 255, 255, 0.1)')
              .border({ width: 1, color: 'rgba(255, 255, 255, 0.2)' })
              .borderRadius(20)
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .margin({ top: 16, bottom: 16 })
              .onClick(() => {
                this.onRefresh()
              })
          }
          
          // 动态列表
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
                    .color('#ffffff')
                    .margin({ right: 8 })
                  Text('加载中...')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.7)')
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
                  .fontColor('rgba(255, 255, 255, 0.5)')
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding({ top: 20, bottom: 20 })
              }
            }
            
            // 空状态
            if (!this.isLoading && this.dynamics.length === 0 && !this.errorMessage) {
              ListItem() {
                Column() {
                  // 发光圆圈
                  Stack() {
                    Column()
                      .width(140)
                      .height(140)
                      .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.05})`)
                      .borderRadius(70)
                      .border({ width: 2, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.2})` })
                    
                    Text('📝')
                      .fontSize(70)
                      .fontColor('#ffffff')
                      .opacity(this.textOpacity)
                  }
                  .margin({ top: 100, bottom: 24 })
                  
                  Text('暂无动态')
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#ffffff')
                    .opacity(this.textOpacity)
                    .margin({ bottom: 12 })
                  
                  Text('快来发布第一条动态吧！')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.7)')
                    .textAlign(TextAlign.Center)
                    .opacity(this.textOpacity)
                    .margin({ left: 40, right: 40 })
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
                    .fontColor('#ff6b6b')
                    .margin({ bottom: 16 })
                  
                  Text('加载失败')
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#ff6b6b')
                    .margin({ bottom: 8 })
                  
                  Text(this.errorMessage)
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.7)')
                    .textAlign(TextAlign.Center)
                    .margin({ bottom: 24 })
                  
                  Button('重试')
                    .fontSize(14)
                    .fontColor('#000000')
                    .backgroundColor('#ffffff')
                    .borderRadius(20)
                    .padding({ left: 32, right: 32, top: 12, bottom: 12 })
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
          .layoutWeight(1)
          .padding({ left: 20, right: 20 })
          .onReachEnd(() => {
            this.onLoadMore()
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}