import router from '@ohos.router'
import { ApiService } from '../service/apiservice'

interface RouteParams {
  description: string;
  styles: string[];
}

@Entry
@Component
export struct LoadingPage {
  @State private progress: number = 0
  @State private currentStyle: string = ''
  @State private generatedUrls: string[] = []
  @State private successfulStyles: string[] = []
  @State private isGenerating: boolean = true
  @State private hasError: boolean = false

  private description: string = ''
  private styles: string[] = ['古风', '赛博', '卡通', '动漫', 'Q版']

  aboutToAppear() {
    const params = router.getParams() as RouteParams
    this.description = params.description || ''
    this.styles = params.styles || ['古风', '赛博', '卡通', '动漫', 'Q版']
    
    this.startGeneration()
  }

  private async startGeneration() {
    this.isGenerating = true
    this.hasError = false
    this.generatedUrls = []
    this.successfulStyles = []
    this.progress = 0

    for (let i = 0; i < this.styles.length; i++) {
      const style = this.styles[i]
      this.currentStyle = style
      this.progress = ((i + 1) / this.styles.length) * 100
      
      try {
        const imageUrl = await ApiService.generateFigure(this.description, style)
        
        if (imageUrl && imageUrl.trim() !== '' && !imageUrl.includes('生成图片时出现错误')) {
          this.generatedUrls.push(imageUrl)
          this.successfulStyles.push(style)
        }
      } catch (error) {
        console.error(`生成${style}风格图片失败:`, error)
      }
    }

    this.isGenerating = false
    
    if (this.generatedUrls.length === 0) {
      this.hasError = true
      return
    }

    setTimeout(() => {
      router.replaceUrl({
        url: 'pages/FigureResult',
        params: {
          imageUrls: this.generatedUrls,
          styles: this.successfulStyles,
          description: this.description
        }
      })
    }, 1000)
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Button('<')
          .backgroundColor('transparent')
          .fontColor('#fff')
          .fontSize(24)
          .onClick(() => {
            if (!this.isGenerating) router.back()
          })
        Blank().width(10)
        Text('生成中...')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
        Blank()
      }
      .width('100%')
      .height(56)
      .backgroundColor('#222')
      .alignItems(VerticalAlign.Center)
      .padding({ left: 10 })

      // 加载内容
      Column() {
        // 旋转图标
        Stack() {
          Image($r('app.media.disc'))
            .width(100)
            .height(100)
            .opacity(0.8)
            .animation({
              duration: 2000,
              iterations: -1,
              curve: Curve.Linear
            })
            .rotate({ angle: 360, centerX: '50%', centerY: '50%' })
          
          Image($r('app.media.logo'))
            .width(50)
            .height(50)
            .borderRadius(25)
        }
        .margin({ top: 100, bottom: 40 })

        // 状态文本
        Text(this.isGenerating ? `正在生成${this.currentStyle}风格...` : '生成完成！')
          .fontSize(18)
          .fontColor('#fff')
          .margin({ bottom: 30 })

        // 进度条
        Row() {
          Column()
            .width(`${this.progress}%`)
            .height(6)
            .backgroundColor('#FFD700')
            .borderRadius(3)
        }
        .width('80%')
        .height(6)
        .backgroundColor('#333')
        .borderRadius(3)
        .margin({ bottom: 30 })

        // 成功数量
        if (this.successfulStyles.length > 0) {
          Text(`已生成 ${this.successfulStyles.length} 张图片`)
            .fontSize(14)
            .fontColor('#4CAF50')
            .margin({ bottom: 20 })
        }

        // 错误信息
        if (this.hasError) {
          Column() {
            Text('生成失败')
              .fontSize(16)
              .fontColor('#FF6B6B')
              .margin({ bottom: 8 })
            Text('所有风格图片生成都失败了，请稍后重试')
              .fontSize(14)
              .fontColor('#888')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 20 })
            
            Button('重新生成')
              .width(120)
              .height(40)
              .backgroundColor('#FFD700')
              .fontColor('#222')
              .borderRadius(20)
              .onClick(() => this.startGeneration())
          }
        }

        // 提示文本
        if (this.isGenerating) {
          Text('AI正在为您创作独特的形象，请耐心等待')
            .fontSize(14)
            .fontColor('#888')
            .textAlign(TextAlign.Center)
            .margin({ top: 40 })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#181818')
  }
} 