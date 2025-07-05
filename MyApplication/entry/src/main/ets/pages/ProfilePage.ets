import router from '@ohos.router'
import http from '@ohos.net.http'
import image from '@ohos.multimedia.image'
import { effectKit } from '@kit.ArkGraphics2D'

interface ProfilePageParams {
  figureImageUrl?: string;
  figureType?: string;
  figureName?: string;
  description?: string;
  createdAiRoleId?: number;
}

@Entry
@Component
struct ProfilePage {
  @State private figureImageUrl: string = ''
  @State private figureType: string = ''
  @State private figureName: string = ''
  @State private description: string = ''
  @State private createdAiRoleId: number = 0
  @State private mainColor: string = '#ffffff'
  @State private pixelMap: PixelMap | undefined = undefined

  async aboutToAppear() {
    const params = router.getParams() as ProfilePageParams;
    this.figureImageUrl = params.figureImageUrl ?? '';
    this.figureType = params.figureType ?? '';
    this.figureName = params.figureName ?? '';
    this.description = params.description ?? '';
    this.createdAiRoleId = params.createdAiRoleId ?? 0;
    await this.extractMainColorFromImage(this.figureImageUrl)
  }

  async extractMainColorFromImage(url: string) {
    const httpRequest = http.createHttp()
    try {
      const response = await httpRequest.request(url, { method: http.RequestMethod.GET })
      if (response.responseCode === 200 && response.result) {
        // 确保 response.result 是 ArrayBuffer 类型
        let imageData: ArrayBuffer
        if (response.result instanceof ArrayBuffer) {
          imageData = response.result
        } else {
          // 如果不是 ArrayBuffer，跳过颜色提取
          console.warn('Response result is not ArrayBuffer, skipping color extraction')
          this.mainColor = '#cccccc'
          return
        }
        
        const imageSource = image.createImageSource(imageData)
        const pixelMap = await imageSource.createPixelMap()
        this.pixelMap = pixelMap
        effectKit.createColorPicker(pixelMap, (err: Error | null, colorPicker: effectKit.ColorPicker | null) => {
          if (!err && colorPicker) {
            const color = colorPicker.getMainColorSync()
            const alpha = color.alpha.toString(16).padStart(2, '0')
            const red = color.red.toString(16).padStart(2, '0')
            const green = color.green.toString(16).padStart(2, '0')
            const blue = color.blue.toString(16).padStart(2, '0')
            this.mainColor = `#${alpha}${red}${green}${blue}`
          }
        })
      }
    } catch (error) {
      console.error('主色提取失败', error)
      this.mainColor = '#cccccc'
    } finally {
      httpRequest.destroy()
    }
  }

  build() {
    Column({ space: 0 }) {
      // 上半部分：图片
      Image(this.figureImageUrl)
        .width('100%')
        .height('45%')
        .objectFit(ImageFit.Cover)
        .borderRadius(20)
      
      // 下半部分：信息
      Column({ space: 12 }) {
        Text(this.figureName)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16 })
        Text(`角色类型: ${this.figureType}`)
          .fontSize(14)
          .fontColor('#888')
        Text(this.description)
          .fontSize(16)
          .margin({ top: 8, bottom: 16 })
        // 按钮区
        Row({ space: 16 }) {
          Button('设置壁纸')
          Button('设置关系')
          Button('设置对话模型')
        }
        Button('清空历史对话')
          .backgroundColor('#eee')
          .fontColor('#333')
          .margin({ top: 16 })
      }
      .padding(20)
      .backgroundColor('#f7f7f7')
      .borderRadius({ topLeft: 24, topRight: 24 })
      .offset({ y: -24 }) // 让下半部分稍微覆盖图片
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.mainColor)
  }
}
