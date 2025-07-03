import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import picker from '@ohos.file.picker'
import fs from '@ohos.file.fs'
import { ApiService } from '../service/apiservice'
import { AiRole } from '../common/types'

interface ArtStyle {
  name: string;
  image: Resource;
  selected: boolean;
}

interface FigureTypeImages {
  name: string;
  images: string[];
}

@Entry
@Component
export struct CreateFigurePage {
  @State private styleTags: string[] = ['精选', '动漫', '可爱', '写实', '创意', '国风']
  @State private selectedTags: Set<string> = new Set(['精选'])
  @State private desc: string = ''
  @State private isGenerating: boolean = false
  @State private isGeneratingFigure: boolean = false
  @State private selectedFigureType: number = 0
  @State private selectedImageIndex: number = 0
  @State private lastClickTime: number = 0
  @State private lastClickIndex: number = -1
  @State private selectedImageUri: string = ''
  @State private hasSelectedImage: boolean = false
  @State private selectedImageBase64: string = ''

  // 动态AI角色数据
  @State private featuredRoles: Record<string, AiRole[]> = {}
  @State private isLoadingRoles: boolean = true

  // 预定义的五种风格
  private readonly figureStyles: string[] = ['古风', '赛博', '卡通', '动漫', 'Q版']
  private readonly figureTypes: string[] = ['动漫', '可爱', '科幻', '写实']

  private readonly figureTypeDescriptions: Record<string, string> = {
    '动漫': '你是一个可爱的动漫角色，有着大大的眼睛和柔和的性格。你喜欢动漫文化，性格活泼开朗，说话时经常使用可爱的语气词。你擅长讨论动漫、游戏、二次元文化等话题，总是充满活力和正能量。',
    '可爱': '你是一个超级可爱的角色，性格温柔善良，说话声音甜美。你喜欢一切可爱的事物，比如小动物、甜点、粉色系物品等。你总是用温柔的语气说话，经常使用"呢"、"呀"、"啦"等可爱的语气词。',
    '科幻': '你是一个来自未来的科幻角色，拥有先进的科技知识和独特的未来视角。你对科技、太空、人工智能等话题非常了解，说话时经常提到未来的概念和科技产品。你性格理性冷静，但也很友善。',
    '写实': '你是一个真实可信的角色，性格成熟稳重，说话直接明了。你有着丰富的人生经验和智慧，擅长倾听和给出实用的建议。你说话时语气平和，逻辑清晰，是一个值得信赖的朋友。'
  }

  aboutToAppear() {
    this.setDescriptionForType(this.figureTypes[this.selectedFigureType]);
    this.loadFeaturedRoles();

    // 调试：打印 getFeatured4Types 返回内容
    ApiService.getFeatured4Types().then((result: Record<string, AiRole[]>) => {
      console.log('【调试】getFeatured4Types 返回:', JSON.stringify(result));
      // 逐个打印每个类型的第一个角色的 avatarUrl
      for (const type of this.figureTypes) {
        if (result[type] && result[type].length > 0) {
          console.log(`【调试】${type} 第一个角色 avatarUrl:`, result[type][0].avatarUrl);
        } else {
          console.log(`【调试】${type} 没有角色数据`);
        }
      }
    }).catch((e: Error) => {
      console.error('getFeatured4Types 调用失败:', e);
    });
  }

  private async loadFeaturedRoles() {
    this.isLoadingRoles = true;
    try {
      this.featuredRoles = await ApiService.getFeatured4Types();
    } catch (e) {
      this.featuredRoles = {};
    }
    this.isLoadingRoles = false;
  }

  build(): void {
    Column() {
      // 顶部栏
      Row() {
        Button('<')
          .backgroundColor('transparent')
          .fontColor('#fff')
          .fontSize(24)
          .onClick(() => router.back())
        Blank().width(10)
        Text('创建形象')
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

      // 形象参考图
      Column() {
        Text('形象参考图')
          .fontSize(16)
          .fontColor('#fff')
          .margin({ bottom: 8 })
        Column() {
          if (this.hasSelectedImage) {
            // 显示选择的图片
            Column() {
              Image(this.selectedImageBase64 || this.selectedImageUri)
                .width(120)
                .height(120)
                .borderRadius(12)
                .objectFit(ImageFit.Cover)
              Row() {
                Button('重新选择')
                  .fontSize(12)
                  .fontColor('#FFD700')
                  .backgroundColor('transparent')
                  .onClick(() => this.selectReferenceImage())
                Button('清除')
                  .fontSize(12)
                  .fontColor('#ff6b6b')
                  .backgroundColor('transparent')
                  .onClick(() => {
                    this.selectedImageUri = '';
                    this.selectedImageBase64 = '';
                    this.hasSelectedImage = false;
                  })
              }
              .margin({ top: 8 })
              .justifyContent(FlexAlign.Center)
            }
          } else {
            // 显示选择按钮
            Column() {
              Button('+')
                .width(60).height(60)
                .fontSize(36)
                .fontColor('#888')
                .backgroundColor('#222')
                .borderRadius(16)
                .onClick(() => this.selectReferenceImage())
              Text('(可选) 将基于上传的参考图生成基础形象')
                .fontSize(12)
                .fontColor('#888')
                .margin({ top: 8 })
            }
          }
        }
        .width('100%')
        .backgroundColor('#232323')
        .borderRadius(16)
        .padding(20)
      }
      .width('90%')
      .margin({ top: 18, bottom: 18 })
      .alignSelf(ItemAlign.Center)

      // 形象描述
      Column() {
        Row() {
          Text('形象描述')
            .fontSize(16)
            .fontColor('#fff')
          Blank()
          Button(this.isGenerating ? '生成中...' : '自动生成')
            .fontSize(13)
            .fontColor('#FFD700')
            .backgroundColor('transparent')
            .enabled(!this.isGenerating)
            .onClick(() => this.generateDescription())
        }
        .margin({ bottom: 8 })
        Column() {
          TextInput({ text: this.desc, placeholder: '（可选）添加形象的详细描述，如五官、动作、服饰、背景等' })
            .fontSize(14)
            .fontColor('#fff')
            .backgroundColor('#232323')
            .borderRadius(12)
            .height(60)
            .onChange((v: string) => {
              this.desc = v
            })
        }
        .width('100%')
        .backgroundColor('#232323')
        .borderRadius(16)
        .padding(20)
      }
      .width('90%')
      .margin({ bottom: 18 })
      .alignSelf(ItemAlign.Center)

      // 选择形象类型
      Text('选择形象类型')
        .fontSize(15)
        .fontColor('#fff')
        .alignSelf(ItemAlign.Start)
        .margin({ left: 20, bottom: 8 })

      List({ space: 12, initialIndex: this.selectedFigureType }) {
        ForEach(this.figureTypes, (type: string, idx: number) => {
          ListItem() {
            Button(type)
              .fontSize(15)
              .fontColor(this.selectedFigureType === idx ? '#FFD700' : '#fff')
              .backgroundColor(this.selectedFigureType === idx ? '#232323' : 'transparent')
              .borderRadius(16)
              .onClick(() => {
                this.selectedFigureType = idx;
                this.selectedImageIndex = 0;
                // 新增：自动设置对应类型的描述词
                this.setDescriptionForType(type);
              })
              .width(80)
              .height(36)
          }
        })
      }
      .height(48)
      .margin({ left: 20, right: 20, top: 12, bottom: 8 })
      .listDirection(Axis.Horizontal)

      // 新增：动态AI角色展示
      if (this.isLoadingRoles) {
        Text('AI角色加载中...')
      }

      // 横向滑动9张图片
      List({ space: 12 }) {
        ForEach(this.featuredRoles[this.figureTypes[this.selectedFigureType]] ?? [], (role: AiRole, idx: number) => {
          ListItem() {
            // 双击事件处理
            Column() {
              Image(role.avatarUrl).width(100).height(100).borderRadius(12)
              Text(role.roleName).fontSize(12).maxLines(1)
            }
            .onClick(() => {
              const currentTime = Date.now();
              if (currentTime - this.lastClickTime < 300 && this.lastClickIndex === idx) {
                // 双击，跳转到chat页面
                router.pushUrl({
                  url: 'pages/chat',
                  params: {
                    figureImageUrl: role.avatarUrl,
                    figureType: role.roleType,
                    figureName: role.roleName,
                    isFromCreateFigure: true,
                    description: role.roleDescription,
                    createdAiRoleId:role.id
                  }
                });
                this.lastClickTime = 0;
                this.lastClickIndex = -1;
              } else {
                // 单击，记录时间和索引
                this.lastClickTime = currentTime;
                this.lastClickIndex = idx;
              }
            })
          }
        }, )
      }
      .height(110)
      .margin({ left: 20, right: 20, bottom: 18 })
      .listDirection(Axis.Horizontal)

      // 生成形象按钮
      Button(this.isGeneratingFigure ? '生成中...' : '生成形象')
        .width('90%')
        .height(48)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(this.isGeneratingFigure ? '#666' : '#FFD700')
        .fontColor('#222')
        .borderRadius(24)
        .alignSelf(ItemAlign.Center)
        .enabled(!this.isGeneratingFigure)
        .onClick(() => this.generateFigure())

      Blank().height(30)
    }
    .width('100%')
    .backgroundColor('#181818')
    .height('100%')
  }

  /**
   * 生成形象描述
   */
  private generateDescription(): void {
    if (this.isGenerating) {
      return
    }

    this.isGenerating = true

    // 使用setTimeout确保UI更新在正确的上下文中执行
    setTimeout(() => {
      this.generateDescriptionAsync()
    }, 0)
  }

  /**
   * 异步生成描述
   */
  private async generateDescriptionAsync(): Promise<void> {
    try {
      console.log('开始生成描述，用户输入:', this.desc);

      // 调用后端API生成描述
      const generatedDesc = await ApiService.generateDescription(this.desc)

      console.log('成功生成描述:', generatedDesc);

      // 使用setTimeout确保UI更新在正确的上下文中执行
      setTimeout(() => {
        try {
          // 将生成的描述设置到输入框
          this.desc = generatedDesc
          this.isGenerating = false

          // 使用setTimeout确保toast在正确的上下文中显示
          setTimeout(() => {
            try {
              promptAction.showToast({
                message: '描述生成成功！',
                duration: 2000
              })
            } catch (toastError) {
              console.error('Toast显示失败:', toastError)
            }
          }, 100)
        } catch (uiError) {
          console.error('UI更新失败:', uiError)
        }
      }, 0)

    } catch (error) {
      console.error('生成描述失败:', error);
      console.error('错误类型:', typeof error);
      console.error('错误详情:', JSON.stringify(error));

      // 使用setTimeout确保UI更新在正确的上下文中执行
      setTimeout(() => {
        try {
          this.isGenerating = false

          let errorMessage = '生成描述失败，请稍后重试';
          if (error instanceof Error) {
            errorMessage = error.message;
          }

          // 使用setTimeout确保toast在正确的上下文中显示
          setTimeout(() => {
            try {
              promptAction.showToast({
                message: errorMessage,
                duration: 3000
              })
            } catch (toastError) {
              console.error('Toast显示失败:', toastError)
            }
          }, 100)
        } catch (uiError) {
          console.error('UI错误处理失败:', uiError)
        }
      }, 0)
    }
  }

  /**
   * 生成形象
   */
  private generateFigure(): void {
    if (this.isGeneratingFigure) {
      return
    }

    if (!this.desc.trim()) {
      try {
        promptAction.showToast({
          message: '请先输入形象描述',
          duration: 2000
        })
      } catch (toastError) {
        console.error('Toast显示失败:', toastError)
      }
      return
    }

    // 跳转到加载页面
    router.pushUrl({
      url: 'pages/LoadingPage',
      params: {
        description: this.desc,
        styles: this.figureStyles,
        referenceImageUri: this.hasSelectedImage ? this.selectedImageUri : '',
        referenceImageBase64: this.hasSelectedImage ? this.selectedImageBase64 : ''
      }
    })
  }

  /**
   * 选择参考图片
   */
  async selectReferenceImage() {
    try {
      console.log('开始选择参考图片...');
      let photoPicker = new picker.PhotoViewPicker();
      let photoSelectOptions: picker.PhotoSelectOptions = {
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      };

      console.log('打开图片选择器...');
      let photoViewPicker = await photoPicker.select(photoSelectOptions);

      if (photoViewPicker && photoViewPicker.photoUris && photoViewPicker.photoUris.length > 0) {
        console.log('用户选择了图片:', photoViewPicker.photoUris[0]);
        this.selectedImageUri = photoViewPicker.photoUris[0];

        // 显示加载状态
        promptAction.showToast({ message: '正在处理图片...' });

        // 本地处理图片，转换为base64格式用于显示
        const base64Data = await this.uriToBase64(this.selectedImageUri);
        if (base64Data) {
          console.log('图片处理成功，大小:', base64Data.length, '字符');

          // 更新状态
          this.hasSelectedImage = true;
          this.selectedImageBase64 = base64Data;

          promptAction.showToast({ message: '参考图片选择成功' });
        } else {
          promptAction.showToast({ message: '图片处理失败' });
        }
      } else {
        console.log('用户取消了图片选择');
      }
    } catch (error) {
      console.error('选择参考图片失败:', error);
      // 检查错误对象是否有code属性
      if (error && typeof error === 'object') {
        const errorObj = error as Record<string, number>;
        const errorCode = errorObj.code;
        if (errorCode === 201) {
          promptAction.showToast({ message: '用户取消了图片选择' });
        } else if (errorCode === 2018203) {
          promptAction.showToast({ message: '权限不足，请在设置中授予相册访问权限' });
        } else if (errorCode !== undefined) {
          promptAction.showToast({ message: `选择图片失败，错误代码: ${errorCode}` });
        } else {
          promptAction.showToast({ message: '选择参考图片失败' });
        }
      } else {
        promptAction.showToast({ message: '选择参考图片失败' });
      }
    }
  }

  /**
   * 将图片URI转换为base64格式
   */
  async uriToBase64(uri: string): Promise<string> {
    try {
      console.log('开始转换图片为base64:', uri);
      // 打开文件
      const fd = await fs.open(uri, fs.OpenMode.READ_ONLY);
      const stat = await fs.stat(uri);
      const buffer = new ArrayBuffer(stat.size);
      await fs.read(fd.fd, buffer, { offset: 0 });
      await fs.close(fd);

      // 转换为base64
      const base64 = this.arrayBufferToBase64(buffer);

      // 获取mimeType
      const extension = uri.split('.').pop()?.toLowerCase() || 'jpeg';
      let mimeType = 'image/jpeg';
      if (extension === 'png') mimeType = 'image/png';
      else if (extension === 'gif') mimeType = 'image/gif';
      else if (extension === 'webp') mimeType = 'image/webp';

      const result = `data:${mimeType};base64,${base64}`;
      console.log('图片转换完成，大小:', stat.size, '字节');
      return result;
    } catch (error) {
      console.error('转换图片失败:', error);
      return '';
    }
  }

  /**
   * ArrayBuffer转base64的辅助方法
   */
  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const uint8Array = new Uint8Array(buffer);
    const base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    let result = '';

    for (let i = 0; i < uint8Array.length; i += 3) {
      const byte1 = uint8Array[i];
      const byte2 = i + 1 < uint8Array.length ? uint8Array[i + 1] : 0;
      const byte3 = i + 2 < uint8Array.length ? uint8Array[i + 2] : 0;

      const chunk1 = byte1 >> 2;
      const chunk2 = ((byte1 & 3) << 4) | (byte2 >> 4);
      const chunk3 = ((byte2 & 15) << 2) | (byte3 >> 6);
      const chunk4 = byte3 & 63;

      result += base64Chars.charAt(chunk1);
      result += base64Chars.charAt(chunk2);
      result += i + 1 < uint8Array.length ? base64Chars.charAt(chunk3) : '=';
      result += i + 2 < uint8Array.length ? base64Chars.charAt(chunk4) : '=';
    }

    return result;
  }

  /**
   * 新增：自动设置对应类型的描述词
   */
  private setDescriptionForType(type: string): void {
    const description = this.figureTypeDescriptions[type] || '';
    this.desc = description;
    console.log(`已设置${type}类型的描述词:`, description);
  }
} 