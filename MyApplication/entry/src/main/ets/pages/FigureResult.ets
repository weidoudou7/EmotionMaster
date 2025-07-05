import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import http from '@ohos.net.http'
import { ApiService } from '../service/apiservice'
import { globalUserData } from '../models/userdata'
import { getUserId } from '../common/constants'

// 定义路由参数接口
interface RouteParams {
  imageUrls?: string[];
  styles?: string[];
  description?: string;
}

interface ChatParams {
  figureImageUrl?: string;
  figureType?: string;
  figureName?: string;
  isFromCreateFigure?: boolean;
  description?: string;
  createdAiRoleId?: number;
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
          .onClick(() => this.handleComplete())
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
   * 处理完成按钮点击事件
   */
  private async handleComplete(): Promise<void> {
    try {
      const selectedImageUrl = this.imageUrls[this.selectedIndex];
      const selectedStyle = this.styles[this.selectedIndex] || '自定义角色';
      const selectedDescription = this.description || selectedStyle || '一个有趣的角色';
      
      // 显示生成名称中提示
      this.showToast('正在生成角色名称...');

      // 调用AI生成角色名称
      let generatedRoleName: string;
      try {
        generatedRoleName = await ApiService.generateRoleName(selectedDescription);
        console.log('AI生成的角色名称:', generatedRoleName);
      } catch (nameError) {
        console.error('生成角色名称失败，使用默认名称:', nameError);
        generatedRoleName = selectedStyle; // 使用风格作为默认名称
      }

      // 显示保存中提示
      this.showToast('正在保存AI角色...');


      // 调用API保存AI角色到数据库
      const newAiRole = await ApiService.createAiRole({
        userId: getUserId() || undefined, // 如果全局用户ID为空，则不传递
        roleName: generatedRoleName,
        roleDescription: selectedDescription,
        roleType: selectedStyle,
        roleAuthor: globalUserData.userName || '用户',
        avatarUrl: selectedImageUrl,
        isTemplate: false
      });

      console.log('AI角色保存成功:', newAiRole);
      console.log('新角色ID:', newAiRole.id);

      // 显示成功提示
      this.showToast('AI角色保存成功！');

      // 跳转到聊天页面
      router.pushUrl({
        url: 'pages/chat',
        params: {
          figureImageUrl: selectedImageUrl,
          figureType: selectedStyle,
          figureName: generatedRoleName, // 使用生成的角色名称
          isFromCreateFigure: true,
          description: selectedDescription,
          createdAiRoleId: newAiRole.id
        }
      });

    } catch (error) {
      console.error('保存AI角色失败:', error);
      
      // 显示错误提示
      let errorMessage = '保存AI角色失败，请稍后重试';
      if (error instanceof Error) {
        errorMessage = error.message;
      }
      
      this.showToast(errorMessage);

      // 即使保存失败，也跳转到聊天页面
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
          description: selectedDescription,
          createdAiRoleId: 0
        }
      });
    }
  }

  /**
   * 安全显示Toast的方法
   */
  private showToast(message: string): void {
    try {
      setTimeout(() => {
        try {
          promptAction.showToast({
            message: message,
            duration: 2000
          });
        } catch (toastError) {
          console.error('Toast显示失败:', toastError);
        }
      }, 0);
    } catch (error) {
      console.error('showToast调用失败:', error);
    }
  }
} 