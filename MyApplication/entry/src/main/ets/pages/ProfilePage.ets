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
  @State private isLoaded: boolean = false

  async aboutToAppear() {
    const params = router.getParams() as ProfilePageParams;
    this.figureImageUrl = params.figureImageUrl ?? '';
    this.figureType = params.figureType ?? '';
    this.figureName = params.figureName ?? '';
    this.description = params.description ?? '';
    this.createdAiRoleId = params.createdAiRoleId ?? 0;
    await this.extractMainColorFromImage(this.figureImageUrl)
    this.isLoaded = true // 主色和图片处理完成后再显示内容
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
    Column() {
      if (!this.isLoaded) {
        // 加载动画或提示
        Blank(24)
        Text('加载中...')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 32 })
      } else {
        // 上半部分：图片
        Image(this.figureImageUrl)
          .width('100%')
          .height('45%')
          .objectFit(ImageFit.Cover)

        // 下半部分：人物信息，背景始终为半透明白色
        Column() {
          Text(this.figureName)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })
          Text(this.figureType)
            .fontSize(18)
            .margin({ bottom: 8 })
          Text(this.description)
            .fontSize(16)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .height('55%')
        .padding(24)
        .backgroundColor('rgba(255,255,255,0.5)')
        .borderRadius(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.mainColor)
  }
}
