import router from '@ohos.router'
import { ApiService } from '../service/apiservice'
import http from '@ohos.net.http'

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
  @State private currentBgUrl: string = ''
  @State private lineRotation: number = 0
  @State private lineScale: number = 1.0
  @State private glowOpacity: number = 0.5
  @State private textOpacity: number = 0.8
  @State private arcRotation: number = 0

  private description: string = ''
  private styles: string[] = ['古风', '赛博', '卡通', '动漫', 'Q版']

  aboutToAppear() {
    const params = router.getParams() as RouteParams
    this.description = params.description || ''
    this.styles = params.styles || ['古风', '赛博', '卡通', '动漫', 'Q版']
    
    this.startAnimations()
    this.startGeneration()
  }

  private startAnimations() {
    // 圆弧旋转动画
    setInterval(() => {
      this.arcRotation += 3
    }, 50)
    
    // 线条缩放动画
    setInterval(() => {
      this.lineScale = this.lineScale === 1.0 ? 1.2 : 1.0
    }, 1000)
    
    // 发光效果动画
    setInterval(() => {
      this.glowOpacity = this.glowOpacity === 0.5 ? 0.8 : 0.5
    }, 800)
    
    // 文字透明度动画
    setInterval(() => {
      this.textOpacity = this.textOpacity === 0.8 ? 1.0 : 0.8
    }, 1200)
  }

  private async preloadImages(urls: string[]): Promise<void> {
    const promises = urls.map(url => {
      const httpRequest = http.createHttp();
      return httpRequest.request(url, {
        method: http.RequestMethod.GET,
        readTimeout: 10000,
        connectTimeout: 5000
      }).then(() => httpRequest.destroy())
        .catch(() => httpRequest.destroy());
    });
    await Promise.all(promises);
  }

  private async startGeneration() {
    this.isGenerating = true
    this.hasError = false
    this.generatedUrls = []
    this.successfulStyles = []
    this.progress = 0
    this.currentBgUrl = ''

    for (let i = 0; i < this.styles.length; i++) {
      const style = this.styles[i]
      this.currentStyle = style
      
      try {
        const imageUrl = await ApiService.generateFigure(this.description, style)
        if (imageUrl && imageUrl.trim() !== '' && !imageUrl.includes('生成图片时出现错误')) {
          this.generatedUrls.push(imageUrl)
          this.successfulStyles.push(style)
          this.currentBgUrl = imageUrl
          // 只有在成功生成图片后才增加进度
          this.progress = (this.successfulStyles.length / this.styles.length) * 100
        }
      } catch (error) {
        console.error(`生成${style}风格图片失败:`, error)
      }
    }

    await this.preloadImages(this.generatedUrls);

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
              .width(150 + index * 50)
              .height(150 + index * 50)
              .borderRadius((150 + index * 50) / 2)
              .border({ width: 1, color: `rgba(64, 64, 64, ${0.3 - index * 0.05})` })
              .position({ x: '50%', y: '50%' })
              .translate({ x: -(150 + index * 50) / 2, y: -(150 + index * 50) / 2 })
            
            // 旋转的圆弧点 - 改为白色系
            Column()
              .width(10)
              .height(10)
              .backgroundColor(`rgba(255, 255, 255, ${0.6 - index * 0.1})`)
              .borderRadius(5)
              .position({ x: '50%', y: '50%' })
              .translate({ 
                x: -5 + Math.cos((this.arcRotation + index * 90) * Math.PI / 180) * (75 + index * 25),
                y: -5 + Math.sin((this.arcRotation + index * 90) * Math.PI / 180) * (75 + index * 25)
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
        // 顶部间距
        Blank().height(100)
        
        // 中心动画区域
        Stack() {
          // 外圈发光效果 - 改为白色发光
          Column()
            .width(200)
            .height(200)
            .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.05})`)
            .borderRadius(100)
            .border({ width: 2, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.2})` })
          
          // 内圈
          Column()
            .width(160)
            .height(160)
            .backgroundColor('rgba(255, 255, 255, 0.03)')
            .borderRadius(80)
            .border({ width: 1, color: 'rgba(255, 255, 255, 0.08)' })
          
          // 中心图标
          Text('🎨')
            .fontSize(60)
            .fontColor('#fff')
            .opacity(this.textOpacity)
        }
        .margin({ bottom: 40 })
        
        // 标题区域
        Column() {
          Text('AI 创作中')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
            .opacity(this.textOpacity)
            .margin({ bottom: 8 })
          
          Text('正在为您生成独特的角色形象')
            .fontSize(16)
            .fontColor('rgba(255, 255, 255, 0.7)')
            .opacity(this.textOpacity)
            .margin({ bottom: 50 })
        }
        .alignItems(HorizontalAlign.Center)
        
        // 进度显示区域
        Column() {
          // 当前风格显示 - 改为白色
          if (this.isGenerating && this.currentStyle) {
            Text(`正在生成: ${this.currentStyle}风格`)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#ffffff')
              .margin({ bottom: 25 })
          }
          
          // 现代化进度条
          Stack() {
            // 背景条
            Column()
              .width('70%')
              .height(6)
              .backgroundColor('rgba(255, 255, 255, 0.1)')
              .borderRadius(3)
            
            // 进度条 - 改为白色，宽度需要相对于70%的容器计算
            Column()
              .width(`${this.progress * 0.7}%`)
              .height(6)
              .backgroundColor('#ffffff')
              .borderRadius(3)
          }
          .margin({ bottom: 15 })
          
          // 进度百分比 - 改为白色
          Text(`${Math.round(this.progress)}%`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')
            .margin({ bottom: 30 })
          
          // 成功计数
          if (this.successfulStyles.length > 0) {
            Row() {
              Text('✨')
                .fontSize(18)
                .margin({ right: 8 })
              Text(`已生成 ${this.successfulStyles.length} 张图片`)
                .fontSize(15)
                .fontColor('rgba(255, 255, 255, 0.9)')
            }
            .margin({ bottom: 30 })
          }
        }
        .alignItems(HorizontalAlign.Center)
        
        // 底部提示区域
        Column() {
          if (this.isGenerating) {
            Text('请稍候，AI正在精心创作您的专属角色...')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.6)')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 20 })
            
            // 动态加载点 - 改为白色
            Row() {
              ForEach([0, 1, 2], (index: number) => {
                Column()
                  .width(6)
                  .height(6)
                  .backgroundColor('#ffffff')
                  .borderRadius(3)
                  .margin({ right: 8 })
                  .opacity(0.5 + (index * 0.2))
              })
            }
          }
          
          // 错误处理
          if (this.hasError) {
            Column() {
              Text('❌ 生成失败')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ff6b6b')
                .margin({ bottom: 12 })
              
              Text('所有风格图片生成都失败了')
                .fontSize(14)
                .fontColor('rgba(255, 255, 255, 0.7)')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 25 })
              
              Button('重新生成')
                .width(150)
                .height(48)
                .backgroundColor('#ffffff')
                .fontColor('#000000')
                .fontWeight(FontWeight.Bold)
                .borderRadius(24)
                .onClick(() => this.startGeneration())
            }
            .alignItems(HorizontalAlign.Center)
          }
        }
        .alignItems(HorizontalAlign.Center)
        
        // 底部间距
        Blank().layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
} 