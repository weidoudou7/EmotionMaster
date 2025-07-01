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

  aboutToAppear(): void {
    const params = router.getParams() as RouteParams
    this.imageUrls = params.imageUrls || []
    this.styles = params.styles || []
    this.description = params.description || ''
    console.log('接收到的图片URLs:', this.imageUrls)
    console.log('接收到的风格:', this.styles)
    console.log('接收到的描述:', this.description)
  }

  build(): void {
    Stack() {
      // 背景大图
      if (this.imageUrls[this.selectedIndex]) {
        Image(this.imageUrls[this.selectedIndex])
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .opacity(0.3)
      }
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
          ForEach(this.imageUrls, (url: string, idx: number): void => {
            ListItem() {
              Column() {
                Image(url)
                  .width(70)
                  .height(90)
                  .borderRadius(12)
                  .objectFit(ImageFit.Cover)
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
} 