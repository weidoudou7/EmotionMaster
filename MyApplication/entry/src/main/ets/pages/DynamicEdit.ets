// DynamicEdit.ets
// 动态编辑页面

import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { CreateDynamicRequest } from '../common/types';
import { NetworkUtils, CommonUtils } from '../common/utils';
import { Config } from '../common/config';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';

interface SelectedImage {
  uri: string;
  name: string;
}

@Component
struct DynamicEdit {
  @State content: string = ''; // 动态内容
  @State selectedImages: SelectedImage[] = []; // 选中的图片（文件uri和文件名）
  @State isSubmitting: boolean = false; // 是否正在提交
  @State userUID: string = globalUserData.userUID;
  @State isNetworkConnected: boolean = true; // 网络连接状态

  // 页面生命周期
  aboutToAppear() {
    this.checkNetworkConnection();
  }

  // 检查网络连接
  async checkNetworkConnection(): Promise<void> {
    this.isNetworkConnected = await NetworkUtils.checkNetworkConnection();
  }

  // 选择图片（支持多选，最多9张）
  async selectImages(): Promise<void> {
    try {
      let photoPicker = new picker.PhotoViewPicker();
      let photoSelectOptions: picker.PhotoSelectOptions = {
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 9 - this.selectedImages.length
      };
      let photoViewPicker = await photoPicker.select(photoSelectOptions);
      if (photoViewPicker && photoViewPicker.photoUris && photoViewPicker.photoUris.length > 0) {
        for (let uri of photoViewPicker.photoUris) {
          // 获取文件名
          const name = uri.split('/').pop() || 'image.jpg';
          this.selectedImages.push({ uri, name });
        }
        promptAction.showToast({ message: `已添加${photoViewPicker.photoUris.length}张图片` });
      }
    } catch (error) {
      promptAction.showToast({ message: '选择图片失败' });
    }
  }

  // 移除图片
  removeImage(index: number) {
    this.selectedImages.splice(index, 1);
  }

  // 提交动态（FormData上传）
  async submitDynamic(): Promise<void> {
    if (CommonUtils.isEmpty(this.content)) {
      promptAction.showToast({ message: '请输入动态内容' });
      return;
    }
    if (this.isSubmitting) {
      return;
    }
    if (!this.isNetworkConnected) {
      NetworkUtils.showNetworkError();
      return;
    }
    try {
      this.isSubmitting = true;
      // 构建FormData
      const boundary = '----WebKitFormBoundary' + Math.random().toString(36).substr(2);
      let body = '';
      body += `--${boundary}\r\n`;
      body += `Content-Disposition: form-data; name=\"content\"\r\n\r\n${this.content.trim()}\r\n`;
      // 读取图片内容并拼接到body
      for (let i = 0; i < this.selectedImages.length; i++) {
        const img = this.selectedImages[i];
        const fd = await fs.open(img.uri, fs.OpenMode.READ_ONLY);
        const stat = await fs.stat(img.uri);
        const buffer = new Uint8Array(stat.size);
        await fs.read(fd.fd, buffer.buffer, { offset: 0 });
        await fs.close(fd);
        body += `--${boundary}\r\n`;
        body += `Content-Disposition: form-data; name=\"images\"; filename=\"${img.name}\"\r\n`;
        body += `Content-Type: image/jpeg\r\n\r\n`;
        let str = '';
        for (let j = 0; j < buffer.length; j++) {
          str += String.fromCharCode(buffer[j]);
        }
        body += str;
        body += '\r\n';
      }
      body += `--${boundary}--\r\n`;
      await ApiService.createDynamicForm(this.userUID, body, boundary);
      promptAction.showToast({ message: '动态发布成功' });
      let uiContext: UIContext = this.getUIContext();
      let router = uiContext.getRouter();
      router.back();
    } catch (error) {
      console.error('发布动态失败:', error);
      promptAction.showToast({ message: '发布动态失败' });
    } finally {
      this.isSubmitting = false;
    }
  }

  // 构建页面
  @Builder
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('取消')
          .fontSize(16)
          .fontColor('#666')
          .backgroundColor('transparent')
          .onClick(() => {
            let uiContext: UIContext = this.getUIContext();
            let router = uiContext.getRouter();
            router.back();
          })
        
        Blank()
        
        Text('发布动态')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
        
        Blank()
        
        Button('发布')
          .fontSize(16)
          .fontColor(this.content.trim() ? '#2980B9' : '#ccc')
          .backgroundColor('transparent')
          .onClick(() => {
            this.submitDynamic();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')
      .border({ width: { bottom: 1 }, color: '#f0f0f0' })

      // 主要内容区域
      if (this.isNetworkConnected) {
        Scroll() {
          Column() {
            // 文字输入区域
            TextArea({ placeholder: '分享你的心情...', text: this.content })
              .width('100%')
              .height(120)
              .fontSize(16)
              .backgroundColor('#fff')
              .padding(16)
              .onChange((value: string) => {
                this.content = value;
              })

            // 图片选择区域
            if (this.selectedImages.length > 0) {
              Column() {
                Text('已选择的图片')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ bottom: 8 })
                
                Grid() {
                  ForEach(this.selectedImages, (image: SelectedImage, index: number) => {
                    GridItem() {
                      Stack() {
                        Image(image.uri)
                          .width('100%')
                          .height(80)
                          .borderRadius(8)
                          .objectFit(ImageFit.Cover)
                        
                        // 删除按钮
                        Button('×')
                          .width(24)
                          .height(24)
                          .fontSize(16)
                          .fontColor('#fff')
                          .backgroundColor('rgba(0,0,0,0.5)')
                          .borderRadius(12)
                          .position({ x: '85%', y: '5%' })
                          .onClick(() => {
                            this.removeImage(index);
                          })
                      }
                      .width('100%')
                      .height(80)
                    }
                  })
                }
                .columnsTemplate('1fr 1fr 1fr')
                .columnsGap(8)
                .rowsGap(8)
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#fff')
              .margin({ top: 8 })
            }

            // 添加图片按钮
            if (this.selectedImages.length < 9) {
              Button() {
                Column() {
                  Text('+')
                    .fontSize(24)
                    .fontColor('#999')
                  Text('添加图片')
                    .fontSize(12)
                    .fontColor('#999')
                    .margin({ top: 4 })
                }
              }
              .width('100%')
              .height(80)
              .backgroundColor('#f8f8f8')
              .borderRadius(8)
              .border({ width: 1, style: BorderStyle.Dashed, color: '#ddd' })
              .margin({ top: 8 })
              .onClick(() => {
                this.selectImages();
              })
            }

            // 测试按钮（仅用于开发测试）
            if (Config.isDebug()) {
              Button('测试网络断开')
                .width('100%')
                .height(40)
                .fontSize(14)
                .fontColor('#fff')
                .backgroundColor('#ff6b6b')
                .borderRadius(8)
                .margin({ top: 8 })
                .onClick(() => {
                  this.isNetworkConnected = false;
                  promptAction.showToast({ message: '已模拟网络断开' });
                })
            }

            // 底部提示
            Text('动态发布后将无法修改，请仔细检查内容')
              .fontSize(12)
              .fontColor('#999')
              .textAlign(TextAlign.Center)
              .margin({ top: 20, bottom: 20 })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#f5f5f5')
      } else {
        // 网络断开连接显示
        Column() {
          Image($r('app.media.disconnection'))
            .width(200)
            .height(200)
            .margin({ top: 100, bottom: 20 })
          
          Text('网络连接失败')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#666')
            .margin({ bottom: 8 })
          
          Text('请检查网络设置后重试')
            .fontSize(14)
            .fontColor('#999')
            .margin({ bottom: 30 })
          
          Button('重新连接')
            .width(120)
            .height(40)
            .fontSize(16)
            .fontColor('#fff')
            .backgroundColor('#2980B9')
            .borderRadius(20)
            .onClick(() => {
              this.checkNetworkConnection();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#f5f5f5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
} 