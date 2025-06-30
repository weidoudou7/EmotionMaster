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
  @State private loadingStates: boolean[] = [true, true, true, true, true]
  @State private errorStates: boolean[] = [false, false, false, false, false]
  @State private retryCounts: number[] = [0, 0, 0, 0, 0]
  @State private selectedIndex: number = 0

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as RouteParams
    this.imageUrls = params.imageUrls || []
    this.styles = params.styles || []
    this.description = params.description || ''
    
    console.log('接收到的图片URLs:', this.imageUrls)
    console.log('接收到的风格:', this.styles)
    console.log('接收到的描述:', this.description)
    
    // 如果没有图片URL，添加一个测试URL
    if (this.imageUrls.length === 0 || !this.imageUrls[0]) {
      this.imageUrls = [
        'https://image.pollinations.ai/prompt/beautiful%20woman%20portrait?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux'
      ]
      this.styles = ['测试']
      console.log('使用测试图片URL:', this.imageUrls[0])
    }
  }

  build(): void {
    Stack() {
      // 背景大图（模糊/半透明）
      if (this.imageUrls[this.selectedIndex]) {
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
          Image(this.imageUrls[this.selectedIndex])
            .width('90%')
            .height(320)
            .borderRadius(18)
            .backgroundColor('#232323')
            .margin({ top: 8, bottom: 8 })
            .objectFit(ImageFit.Cover)
        }

        // 横向可选图片栏
        List({ space: 12, initialIndex: this.selectedIndex }) {
          ForEach(this.imageUrls, (url: string, idx: number) => {
            ListItem() {
              Column() {
                Image(url)
                  .width(70)
                  .height(90)
                  .borderRadius(12)
                  .objectFit(ImageFit.Cover)
                  .border({ width: this.selectedIndex === idx ? 3 : 0, color: '#FFD700' })
                  .onClick(() => this.selectedIndex = idx)
                if (this.styles[idx]) {
                  Text(this.styles[idx])
                    .fontSize(12)
                    .fontColor(this.selectedIndex === idx ? '#FFD700' : '#fff')
                    .margin({ top: 4 })
                }
              }
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
          .onClick(() => {
            // 跳转到chat页面，传递选定的人物信息
            const selectedImageUrl = this.imageUrls[this.selectedIndex];
            const selectedStyle = this.styles[this.selectedIndex] || '自定义角色';
            // 使用人物形象描述栏中的描述词，如果没有则使用风格作为备选
            const selectedDescription = this.description || selectedStyle || '一个有趣的角色';
            
            console.log('=== FigureResult跳转到Chat的参数 ===');
            console.log('selectedIndex:', this.selectedIndex);
            console.log('selectedImageUrl:', selectedImageUrl);
            console.log('selectedStyle:', selectedStyle);
            console.log('this.description (人物形象描述):', this.description);
            console.log('selectedDescription (最终传递给chat的描述词):', selectedDescription);
            console.log('====================================');
            
            router.pushUrl({
              url: 'pages/chat',
              params: {
                figureImageUrl: selectedImageUrl, // 选定的图片作为背景和头像
                figureType: selectedStyle, // 选定的人物类型
                figureName: selectedStyle, // 人物名称
                isFromCreateFigure: true,
                description: selectedDescription // 使用人物形象描述栏中的描述词
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
  }

  /**
   * 重试图片加载
   */
  private retryImageLoad(index: number, style: string): void {
    if (this.retryCounts[index] >= 3) {
      promptAction.showToast({ 
        message: `${style}风格图片重试次数已达上限`,
        duration: 2000
      })
      return
    }
    
    this.retryCounts[index]++
    this.loadingStates[index] = true
    this.errorStates[index] = false
    
    console.log(`重试加载${style}风格图片 (${this.retryCounts[index]}/3):`, this.imageUrls[index])
    
    promptAction.showToast({ 
      message: `正在重试加载${style}风格图片...`,
      duration: 1500
    })
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