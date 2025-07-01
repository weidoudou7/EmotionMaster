import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import http from '@ohos.net.http'

// 定义路由参数接口
interface RouteParams {
  imageUrls?: string[];
  styles?: string[];
  description?: string;
}

@Entry
@Component
struct FigureResultPage {
  @State private imageUrls: string[] = []
  @State private styles: string[] = []
  @State private description: string = ''
  @State private selectedIndex: number = 0
  @State private imageLoadingStates: boolean[] = []
  @State private imageErrorStates: boolean[] = []
  @State private preloadedImages: Map<string, string> = new Map()

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as RouteParams
    this.imageUrls = params.imageUrls || []
    this.styles = params.styles || []
    this.description = params.description || ''
    
    console.log('接收到的图片URLs:', this.imageUrls)
    console.log('接收到的风格:', this.styles)
    console.log('接收到的描述:', this.description)
    
    // 初始化加载状态
    this.imageLoadingStates = new Array(this.imageUrls.length).fill(true)
    this.imageErrorStates = new Array(this.imageUrls.length).fill(false)
    
    // 预加载所有图片
    this.preloadImages()
  }

  private async preloadImages() {
    console.log(`开始预加载 ${this.imageUrls.length} 张图片`)
    
    // 改为串行加载，避免并发请求问题
    for (let i = 0; i < this.imageUrls.length; i++) {
      const url = this.imageUrls[i]
      if (url && url.trim() !== '' && !url.includes('生成图片时出现错误')) {
        await this.preloadImage(url, i)
        // 添加延迟，避免请求过于频繁
        if (i < this.imageUrls.length - 1) {
          await this.delay(500)
        }
      } else {
        this.imageLoadingStates[i] = false
        this.imageErrorStates[i] = true
        console.error(`图片 ${i} URL无效:`, url)
      }
    }
    
    console.log('所有图片预加载完成')
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  private async preloadImage(url: string, index: number) {
    try {
      console.log(`开始预加载图片 ${index}:`, url.substring(0, 100) + '...')
      
      // 使用HTTP请求预加载图片
      const httpRequest = http.createHttp()
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        header: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        },
        readTimeout: 30000, // 增加超时时间到30秒
        connectTimeout: 15000 // 增加连接超时时间
      }

      const response = await httpRequest.request(url, requestOptions)
      httpRequest.destroy()

      if (response.responseCode === 200) {
        // 图片加载成功
        this.imageLoadingStates[index] = false
        this.imageErrorStates[index] = false
        this.preloadedImages.set(url, 'loaded')
        console.log(`图片 ${index} 预加载成功`)
      } else {
        // 图片加载失败
        this.imageLoadingStates[index] = false
        this.imageErrorStates[index] = true
        console.error(`图片 ${index} 预加载失败: HTTP ${response.responseCode}`)
      }
    } catch (error) {
      // 图片加载异常
      this.imageLoadingStates[index] = false
      this.imageErrorStates[index] = true
      console.error(`图片 ${index} 预加载异常:`, error)
      
      // 如果是网络错误，尝试重试一次
      if (error && typeof error === 'object' && error.hasOwnProperty('code')) {
        console.log(`图片 ${index} 网络错误，尝试重试...`)
        await this.delay(1000)
        await this.retryPreloadImage(url, index)
      }
    }
  }

  private async retryPreloadImage(url: string, index: number) {
    try {
      const httpRequest = http.createHttp()
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        header: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        },
        readTimeout: 20000,
        connectTimeout: 10000
      }

      const response = await httpRequest.request(url, requestOptions)
      httpRequest.destroy()

      if (response.responseCode === 200) {
        this.imageLoadingStates[index] = false
        this.imageErrorStates[index] = false
        this.preloadedImages.set(url, 'loaded')
        console.log(`图片 ${index} 重试预加载成功`)
      }
    } catch (retryError) {
      console.error(`图片 ${index} 重试预加载失败:`, retryError)
    }
  }

  build(): void {
    Stack() {
      // 背景大图（模糊/半透明）
      if (this.imageUrls[this.selectedIndex] && !this.imageLoadingStates[this.selectedIndex] && !this.imageErrorStates[this.selectedIndex]) {
        Image(this.imageUrls[this.selectedIndex])
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .opacity(0.3)
      }

      // 主内容
      Column() {
        // 顶部栏
        Row() {
          Button('<')
            .backgroundColor('transparent')
            .fontColor('#fff')
            .fontSize(24)
            .onClick(() => router.back())
          Blank().width(10)
          Text('生成结果')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
          Blank()
        }
        .width('100%')
        .height(56)
        .backgroundColor('rgba(34,34,34,0.7)')
        .alignItems(VerticalAlign.Center)
        .padding({ left: 10 })

        // 描述信息
        if (this.description) {
          Column() {
            Text('形象描述')
              .fontSize(16)
              .fontColor('#fff')
              .margin({ bottom: 8 })
            Text(this.description)
              .fontSize(14)
              .fontColor('#ccc')
              .textAlign(TextAlign.Start)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('90%')
          .margin({ top: 16, bottom: 16 })
          .alignSelf(ItemAlign.Center)
          .backgroundColor('rgba(35,35,35,0.7)')
          .borderRadius(16)
          .padding(16)
        }

        // 主图展示
        if (this.imageUrls[this.selectedIndex]) {
          if (this.imageLoadingStates[this.selectedIndex]) {
            // 加载中状态
            Column() {
              Image($r('app.media.disc'))
                .width(60)
                .height(60)
                .opacity(0.6)
                .animation({
                  duration: 1000,
                  iterations: -1,
                  curve: Curve.Linear
                })
                .rotate({ angle: 360, centerX: '50%', centerY: '50%' })
              Text('图片加载中...')
                .fontSize(14)
                .fontColor('#888')
                .margin({ top: 8 })
            }
            .width('90%')
            .height(320)
            .backgroundColor('#232323')
            .borderRadius(18)
            .margin({ top: 8, bottom: 8 })
            .justifyContent(FlexAlign.Center)
          } else if (this.imageErrorStates[this.selectedIndex]) {
            // 加载失败状态
            Column() {
              Image($r('app.media.image'))
                .width(60)
                .height(60)
                .opacity(0.5)
              Text('图片加载失败')
                .fontSize(14)
                .fontColor('#FF6B6B')
                .margin({ top: 8 })
            }
            .width('90%')
            .height(320)
            .backgroundColor('#232323')
            .borderRadius(18)
            .margin({ top: 8, bottom: 8 })
            .justifyContent(FlexAlign.Center)
          } else {
            // 图片显示
            Image(this.imageUrls[this.selectedIndex])
              .width('90%')
              .height(320)
              .borderRadius(18)
              .backgroundColor('#232323')
              .margin({ top: 8, bottom: 8 })
              .objectFit(ImageFit.Cover)
          }
        }

        // 横向可选图片栏
        List({ space: 12, initialIndex: this.selectedIndex }) {
          ForEach(this.imageUrls, (url: string, idx: number) => {
            ListItem() {
              Column() {
                if (this.imageLoadingStates[idx]) {
                  // 加载中
                  Column() {
                    Image($r('app.media.disc'))
                      .width(30)
                      .height(30)
                      .opacity(0.6)
                      .animation({
                        duration: 1000,
                        iterations: -1,
                        curve: Curve.Linear
                      })
                      .rotate({ angle: 360, centerX: '50%', centerY: '50%' })
                  }
                  .width(70)
                  .height(90)
                  .backgroundColor('#232323')
                  .borderRadius(12)
                  .justifyContent(FlexAlign.Center)
                } else if (this.imageErrorStates[idx]) {
                  // 加载失败
                  Column() {
                    Image($r('app.media.image'))
                      .width(30)
                      .height(30)
                      .opacity(0.5)
                    Text('失败')
                      .fontSize(10)
                      .fontColor('#FF6B6B')
                  }
                  .width(70)
                  .height(90)
                  .backgroundColor('#232323')
                  .borderRadius(12)
                  .justifyContent(FlexAlign.Center)
                } else {
                  // 图片显示
                  Image(url)
                    .width(70)
                    .height(90)
                    .borderRadius(12)
                    .objectFit(ImageFit.Cover)
                }
                
                if (this.styles[idx]) {
                  Text(this.styles[idx])
                    .fontSize(12)
                    .fontColor(this.selectedIndex === idx ? '#FFD700' : '#fff')
                    .margin({ top: 4 })
                }
              }
              .onClick(() => this.selectedIndex = idx)
            }
          })
        }
        .height(110)
        .margin({ top: 12, bottom: 12 })
        .listDirection(Axis.Horizontal)

        // 完成按钮
        Button('完成')
          .width('80%')
          .height(48)
          .fontSize(18)
          .backgroundColor('#FFD700')
          .fontColor('#222')
          .borderRadius(24)
          .alignSelf(ItemAlign.Center)
          .margin({ top: 20, bottom: 20 })
          .enabled(!this.imageLoadingStates[this.selectedIndex] && !this.imageErrorStates[this.selectedIndex])
          .onClick(() => {
            const selectedImageUrl = this.imageUrls[this.selectedIndex];
            const selectedStyle = this.styles[this.selectedIndex] || '自定义角色';
            const selectedDescription = this.description || selectedStyle || '一个有趣的角色';
            
            router.pushUrl({
              url: 'pages/chat',
              params: {
                figureImageUrl: selectedImageUrl,
                figureType: selectedStyle,
                figureName: selectedStyle,
                isFromCreateFigure: true,
                description: selectedDescription
              }
            });
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.End)
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#181818')
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  }

  /**
   * 重试图片加载
   */
  private retryImageLoad(index: number, style: string): void {
    const url = this.imageUrls[index]
    if (!url) {
      promptAction.showToast({ 
        message: '无效的图片URL',
        duration: 2000
      })
      return
    }
    
    // 重新预加载图片
    this.imageLoadingStates[index] = true
    this.imageErrorStates[index] = false
    
    console.log(`重试加载${style}风格图片:`, url)
    
    promptAction.showToast({ 
      message: `正在重试加载${style}风格图片...`,
      duration: 1500
    })
    
    // 重新预加载
    this.preloadImage(url, index)
  }

  /**
   * 保存图片
   */
  private saveImage(imageUrl: string, style: string): void {
    try {
      promptAction.showToast({ 
        message: `${style}风格图片保存功能开发中`,
        duration: 2000
      })
    } catch (toastError) {
      console.error('Toast显示失败:', toastError)
    }
  }

  /**
   * 分享图片
   */
  private shareImage(imageUrl: string, style: string): void {
    try {
      promptAction.showToast({ 
        message: `${style}风格图片分享功能开发中`,
        duration: 2000
      })
    } catch (toastError) {
      console.error('Toast显示失败:', toastError)
    }
  }

  /**
   * 重试生成
   */
  private retryGenerate(index: number, style: string): void {
    try {
      promptAction.showToast({ 
        message: `重新生成${style}风格图片功能开发中`,
        duration: 2000
      })
    } catch (toastError) {
      console.error('Toast显示失败:', toastError)
    }
  }

  /**
   * 测试图片URL
   */
  private testImageUrl(imageUrl: string, style: string): void {
    try {
      console.log(`开始测试${style}风格图片URL:`, imageUrl)
      
      // 使用HTTP请求测试URL
      const httpRequest = http.createHttp()
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        header: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        },
        readTimeout: 10000,
        connectTimeout: 5000
      }

      httpRequest.request(imageUrl, requestOptions)
        .then((response) => {
          console.log(`${style}风格图片URL测试结果:`, response.responseCode)
          httpRequest.destroy()
          
          if (response.responseCode === 200) {
            promptAction.showToast({ 
              message: `${style}风格图片URL可访问`,
              duration: 2000
            })
          } else {
            promptAction.showToast({ 
              message: `${style}风格图片URL不可访问 (${response.responseCode})`,
              duration: 3000
            })
          }
        })
        .catch(() => {
          console.error(`${style}风格图片URL测试失败:`)
          httpRequest.destroy()
          promptAction.showToast({ 
            message: `${style}风格图片URL测试失败`,
            duration: 3000
          })
        })
    } catch {
      console.error('URL测试功能失败')
      promptAction.showToast({ 
        message: 'URL测试功能失败',
        duration: 2000
      })
    }
  }
} 