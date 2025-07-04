import router from '@ohos.router';
import http from '@ohos.net.http';
import { Config } from '../common/config';
import image from '@ohos.multimedia.image';
import effectKit from '@ohos.effectKit';


interface FeaturedPerson {

   id: number | null;
   userId: number | null;
   roleName: string;
   roleDescription: string;
   roleType: string;
   roleAuthor: string;
   viewCount: number;
   avatarUrl: string;
   isTemplate: boolean;
   createdAt: string; // ISO字符串
}

// interface ApiResponse<T> {
//   success: boolean;
//   message: string;
//   data: T;
//   timestamp: number;
// }

@Entry
@Component
export struct FeaturedList {
  @State private selectedIndex: number = 0;
  private lastClickTime: number = 0;
  private lastClickIndex: number = -1;
  @State private isLoading: boolean = false;
  @State private errorMessage: string = '';

  @State private persons: FeaturedPerson[] = [];
  @State private mainColors: number[] = [];

  aboutToAppear() {
    this.fetchFeaturedPersons();
  }

  async fetchFeaturedPersons() {
    this.isLoading = true;
    this.errorMessage = '';
    //this.persons = [];//清空现有数据

    try {
      console.log("开始请求特色人物数据...");
      let httpRequest = http.createHttp();
      const response = await httpRequest.request(
        Config.getApiBaseUrl()+"/featured-people/all",
        {
          method: http.RequestMethod.GET,
          readTimeout: 60000,
          header: {
            "Content-Type": "application/json"
          },
          connectTimeout: 30000 // 30秒连接超时
        }
      );

      // 日志1：打印完整响应状态和原始结果
      console.log("响应状态码:", response.responseCode);
      console.log("原始响应结果:", response.result); // 关键：确认返回的是否是数组字符串

      if (response.responseCode === 200 && typeof response.result === 'string') {
        // 显式指定类型，解决any报错
        const result = JSON.parse(response.result) as FeaturedPerson[];
        console.log("75");
        //console.log(result.data.toString())
        this.persons = result; // 直接使用数组

      } else {
        this.errorMessage = "请求失败，状态码: " + response.responseCode;
      }
    } catch (error) {
      this.errorMessage = "加载出错: " + (error as Error).message;
    } finally {
      this.isLoading = false;
    }
  }

  // 获取图片buffer，需根据实际图片资源类型实现
  async getImageBuffer(imageUrl: string): Promise<Uint8Array> {
    // 这里仅为示例，实际请根据你的图片加载方式实现
    // 假设图片是网络图片，可以用http请求获取ArrayBuffer再转Uint8Array
    let httpRequest = http.createHttp();
    const response = await httpRequest.request(imageUrl, { method: http.RequestMethod.GET });
    if (response.result instanceof ArrayBuffer) {
      return new Uint8Array(response.result);
    }
    return new Uint8Array();
  }

  async getMainColorFromImage(imageUrl: string, index: number) {
    const buffer: Uint8Array = await this.getImageBuffer(imageUrl);
    const imageSource = image.createImageSource(buffer);
    const pixelMap = await imageSource.createPixelMap();
    effectKit.createColorPicker(pixelMap, (err, colorPicker) => {
      if (!err) {
        const color = colorPicker.getMainColorSync();
        // 转为0xAARRGGBB格式
        const colorInt = (color.alpha << 24) | (color.red << 16) | (color.green << 8) | color.blue;
        this.mainColors[index] = colorInt;
      }
    });
  }

  build() {
    Column() {
      Row(){}.height(5);
      Grid() {
        ForEach(this.persons, (item: FeaturedPerson, index: number) => {
          GridItem() {
            Stack() {
              // 图片
              Image(item.avatarUrl)
                .width('100%')
                .aspectRatio(0.9)
                .borderRadius(12)
                .objectFit(ImageFit.Cover)
                .onAppear(() => {
                  this.getMainColorFromImage(item.avatarUrl, index);
                })
              // 内容区
              Column() {
                Text(item.roleName)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#fff')
                  .margin({ top: 2, bottom: 2 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(item.roleDescription)
                  .fontSize(13)
                  .fontColor(Color.White)
                  .maxLines(2)
                  .margin({ bottom: 2 })
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                // Row() {
                  // 作者头像
                  // Image(item.authorAvatar)
                  //   .width(20)
                  //   .height(20)
                  //   .borderRadius(10)
                  // Text('@' + item.roleAuthor)
                  //   .fontSize(12)
                  //   .fontColor('#aaa')
                  //   .margin({ left: 4, right: 8 })
                  // 浏览量
                  // Image($r('app.media.message_icon'))
                  //   .width(14)
                  //   .height(14)
                  // Text(item.viewCount.toString())
                  //   .fontSize(12)
                  //   .fontColor('#aaa')
                  //   .margin({ left: 2 })
                // }
                // .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .linearGradient({
                direction: GradientDirection.Bottom,
                repeating: false,
                colors: [
                  [0x80000000, 0.0],
                  [this.mainColors[index], 1.0]
                ]
              })
              //.padding({ left: 8, right: 8, top: 8, bottom: 8 })
              //.position({ y: '100%' })
              .translate({ y: 63})
            }
            .backgroundColor('#232323')
            .borderRadius(16)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 2 })
            .margin({ bottom: 4 })
            .onClick(() => {
              const currentTime = Date.now();
              
              // 检查是否是双击（300ms内的两次点击）
              if (currentTime - this.lastClickTime < 300 && this.lastClickIndex === index) {
                // 双击事件 - 跳转到聊天页面
                router.pushUrl({
                  url: 'pages/chat',
                  params: {
                    figureImageUrl: item.avatarUrl,
                    figureType: item.roleType,
                    figureName: item.roleName,
                    isFromCreateFigure: true,
                    description: item.roleDescription,
                    createdAiRoleId:item.id
                  }
                });
                // 重置状态
                this.lastClickTime = 0;
                this.lastClickIndex = -1;
              } else {
                // 单击事件 - 选择卡片
                this.selectedIndex = index;
                this.lastClickTime = currentTime;
                this.lastClickIndex = index;
              }
            })
          }
        }, (item: FeaturedPerson) => item.id?item.id.toString():"1")
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(16)
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#181818')
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    .padding({ left: 12, right: 12 })
  }
}

