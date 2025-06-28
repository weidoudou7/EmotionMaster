// DynamicList.ets
// 动态展示页面

import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { Dynamic, CreateDynamicRequest } from '../common/types';
import { NetworkUtils } from '../common/utils';
import promptAction from '@ohos.promptAction';
import { BottomNavBar } from './BottomNavBar';
import preferences from '@ohos.data.preferences';
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';

// 类型声明
interface ErrorWithCode {
  code?: number;
}

@Entry
@Component
struct DynamicList {
  @State dynamics: Dynamic[] = []; // 动态列表
  @State isLoading: boolean = false; // 加载状态
  @State isRefreshing: boolean = false; // 刷新状态
  @State userUID: string = globalUserData.userUID;
  @State showAllDynamics: boolean = false; // 是否显示所有动态（包括私密）
  @State isNetworkConnected: boolean = true; // 网络连接状态
  
  // 新增：发布相关状态
  @State showPublishModal: boolean = false; // 是否显示发布弹窗
  @State publishContent: string = ''; // 发布内容
  @State publishImages: string[] = []; // 发布图片
  @State isLocalMode: boolean = false; // 是否为本地模式
  @State isPublishing: boolean = false; // 是否正在发布
  @State localDynamics: Dynamic[] = []; // 本地动态列表

  // 页面生命周期
  aboutToAppear() {
    this.checkNetworkConnection();
    this.loadDynamics();
    this.loadLocalDynamics().then(() => {
      console.log('本地动态加载完成');
    }).catch((error:string) => {
      console.error('本地动态加载失败:', error);
    });
  }

  // 检查网络连接
  async checkNetworkConnection(): Promise<void> {
    this.isNetworkConnected = await NetworkUtils.checkNetworkConnection();
  }

  // 加载动态
  async loadDynamics(): Promise<void> {
    if (!this.isNetworkConnected) {
      return;
    }

    if (this.isLoading) return;
    
    try {
      this.isLoading = true;
      const dynamics = this.showAllDynamics 
        ? await ApiService.getUserDynamics(this.userUID)
        : await ApiService.getUserPublicDynamics(this.userUID);
      this.dynamics = dynamics;
    } catch (error) {
      console.error('加载动态失败:', error);
      promptAction.showToast({ message: '加载动态失败' });
    } finally {
      this.isLoading = false;
    }
  }

  // 加载本地动态
  async loadLocalDynamics(): Promise<void> {
    try {
      const context = getContext(this);
      const preferencesHelper = await preferences.getPreferences(context, 'localDynamics');
      const localDynamicsStr = await preferencesHelper.get('dynamics', '[]') as string;
      this.localDynamics = JSON.parse(localDynamicsStr);
    } catch (error) {
      console.error('加载本地动态失败:', error);
      this.localDynamics = [];
    }
  }

  // 保存本地动态
  async saveLocalDynamics(): Promise<void> {
    try {
      const context = getContext(this);
      const preferencesHelper = await preferences.getPreferences(context, 'localDynamics');
      await preferencesHelper.put('dynamics', JSON.stringify(this.localDynamics));
      await preferencesHelper.flush();
    } catch (error) {
      console.error('保存本地动态失败:', error);
    }
  }

  // 刷新动态
  async refreshDynamics(): Promise<void> {
    if (!this.isNetworkConnected) {
      this.isRefreshing = false;
      return;
    }

    if (this.isRefreshing) return;
    
    try {
      this.isRefreshing = true;
      await this.loadDynamics();
      promptAction.showToast({ message: '刷新成功' });
    } catch (error) {
      console.error('刷新动态失败:', error);
      promptAction.showToast({ message: '刷新失败' });
    } finally {
      this.isRefreshing = false;
    }
  }

  // 点赞动态
  async likeDynamic(dynamic: Dynamic): Promise<void> {
    if (!this.isNetworkConnected) {
      NetworkUtils.showNetworkError();
      return;
    }

    try {
      await ApiService.likeDynamic(dynamic.id);
      // 更新本地数据
      const index = this.dynamics.findIndex(d => d.id === dynamic.id);
      if (index !== -1) {
        this.dynamics[index].likeCount += 1;
      }
      promptAction.showToast({ message: '点赞成功' });
    } catch (error) {
      console.error('点赞失败:', error);
      promptAction.showToast({ message: '点赞失败' });
    }
  }

  // 取消点赞动态
  async unlikeDynamic(dynamic: Dynamic): Promise<void> {
    if (!this.isNetworkConnected) {
      NetworkUtils.showNetworkError();
      return;
    }

    try {
      await ApiService.unlikeDynamic(dynamic.id);
      // 更新本地数据
      const index = this.dynamics.findIndex(d => d.id === dynamic.id);
      if (index !== -1 && this.dynamics[index].likeCount > 0) {
        this.dynamics[index].likeCount -= 1;
      }
      promptAction.showToast({ message: '取消点赞成功' });
    } catch (error) {
      console.error('取消点赞失败:', error);
      promptAction.showToast({ message: '取消点赞失败' });
    }
  }

  // 删除动态
  async deleteDynamic(dynamic: Dynamic): Promise<void> {
    if (!this.isNetworkConnected) {
      NetworkUtils.showNetworkError();
      return;
    }

    try {
      await ApiService.deleteDynamic(dynamic.id, this.userUID);
      // 从列表中移除
      this.dynamics = this.dynamics.filter(d => d.id !== dynamic.id);
      promptAction.showToast({ message: '删除成功' });
    } catch (error) {
      console.error('删除动态失败:', error);
      promptAction.showToast({ message: '删除失败' });
    }
  }

  // 删除本地动态
  async deleteLocalDynamic(dynamic: Dynamic): Promise<void> {
    this.localDynamics = this.localDynamics.filter(d => d.id !== dynamic.id);
    await this.saveLocalDynamics();
    promptAction.showToast({ message: '删除成功' });
  }

  // 发布动态
  async publishDynamic(): Promise<void> {
    if (this.publishContent.trim() === '') {
      promptAction.showToast({ message: '请输入动态内容' });
      return;
    }

    if (this.isPublishing) return;

    try {
      this.isPublishing = true;

      const newDynamic: Dynamic = {
        id: Date.now().toString(),
        userUID: this.userUID,
        content: this.publishContent,
        images: this.publishImages,
        likeCount: 0,
        commentCount: 0,
        isPrivate: false,
        createTime: new Date().toISOString(),
        updateTime: new Date().toISOString()
      };

      if (this.isLocalMode) {
        // 本地模式：直接添加到本地动态列表
        this.localDynamics = [newDynamic, ...this.localDynamics];
        await this.saveLocalDynamics();
        promptAction.showToast({ message: '本地发布成功' });
      } else {
        // 网络模式：发送到服务器
        if (!this.isNetworkConnected) {
          NetworkUtils.showNetworkError();
          return;
        }

        const dynamicData: CreateDynamicRequest = {
          content: this.publishContent,
          images: this.publishImages.length > 0 ? this.publishImages : undefined,
          isPrivate: false
        };

        const createdDynamic = await ApiService.createDynamic(this.userUID, dynamicData);
        this.dynamics = [createdDynamic, ...this.dynamics];
        promptAction.showToast({ message: '发布成功' });
      }

      // 清空发布内容并关闭弹窗
      this.publishContent = '';
      this.publishImages = [];
      this.showPublishModal = false;
    } catch (error) {
      console.error('发布动态失败:', error);
      promptAction.showToast({ message: '发布失败' });
    } finally {
      this.isPublishing = false;
    }
  }

  // 添加图片
  async addImage(): Promise<void> {
    if (this.publishImages.length >= 9) {
      promptAction.showToast({ message: '最多只能添加9张图片' });
      return;
    }
    
    console.log('=== 开始图片选择流程 ===');
    console.log('当前已选择图片数量:', this.publishImages.length);
    promptAction.showToast({ message: '正在打开图片选择器...' });
    
    try {
      console.log('步骤1: 创建图片选择器实例');
      // 创建图片选择器
      const photoPicker = new picker.PhotoViewPicker();
      console.log('✓ 图片选择器创建成功');
      
      console.log('步骤2: 配置选择器选项');
      // 配置选择器选项
      const photoSelectOptions: picker.PhotoSelectOptions = {
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 9 - this.publishImages.length
      };
      console.log('✓ 选择器选项配置完成:', JSON.stringify(photoSelectOptions));
      
      console.log('步骤3: 启动图片选择器');
      // 启动图片选择器
      console.log('正在调用 photoPicker.select()...');
      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      console.log('✓ 图片选择器返回结果:', photoSelectResult);
      
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        console.log(`✓ 选择了${photoSelectResult.photoUris.length}张图片`);
        promptAction.showToast({ message: `正在处理${photoSelectResult.photoUris.length}张图片...` });
        
        // 处理选中的图片
        for (let i = 0; i < photoSelectResult.photoUris.length; i++) {
          const uri = photoSelectResult.photoUris[i];
          try {
            console.log(`处理第${i + 1}张图片，URI:`, uri);
            const base64Image = await this.uriToBase64(uri);
            if (base64Image) {
              this.publishImages.push(base64Image);
              console.log(`✓ 第${i + 1}张图片处理成功，已添加到列表`);
            } else {
              console.log(`✗ 第${i + 1}张图片处理失败，base64为空`);
            }
          } catch (error) {
            console.error(`✗ 处理第${i + 1}张图片失败:`, error);
            promptAction.showToast({ message: `处理第${i + 1}张图片失败，跳过该图片` });
          }
        }
        
        promptAction.showToast({ message: `已添加${photoSelectResult.photoUris.length}张图片` });
      } else {
        console.log('✗ 没有选择图片或选择被取消');
        console.log('photoSelectResult:', photoSelectResult);
        promptAction.showToast({ message: '未选择图片' });
      }
    } catch (error) {
      console.error('=== 图片选择器启动失败 ===');
      console.error('错误类型:', typeof error);
      console.error('错误对象:', error);
      console.error('错误消息:', error.message);
      console.error('错误堆栈:', error.stack);
      
      const err: ErrorWithCode = error as ErrorWithCode;
      
      if (err.code !== undefined) {
        console.log('错误代码:', err.code);
        if (err.code === 201) {
          promptAction.showToast({ message: '用户取消了图片选择' });
        } else if (err.code === 2018203) {
          promptAction.showToast({ message: '权限不足，请在设置中授予相册访问权限' });
        } else {
          promptAction.showToast({ message: `选择图片失败，错误代码: ${err.code}` });
        }
      } else {
        console.error('未知错误，没有错误代码');
        promptAction.showToast({ message: '选择图片失败，请检查权限设置' });
      }
    }
    
    console.log('=== 图片选择流程结束 ===');
  }

  // 将图片URI转换为base64格式
  async uriToBase64(uri: string): Promise<string> {
    try {
      // ArkTS fs无readFile/readAll，需用open/read/close
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
      return `data:${mimeType};base64,${base64}`;
    } catch (error) {
      console.error('转换图片失败:', error);
      return '';
    }
  }

  // ArrayBuffer转base64的辅助方法
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

  // 移除图片
  removeImage(index: number): void {
    this.publishImages.splice(index, 1);
  }

  // 格式化时间
  formatTime(timeStr: string): string {
    const date = new Date(timeStr);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    
    const minutes = Math.floor(diff / (1000 * 60));
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    
    if (minutes < 1) return '刚刚';
    if (minutes < 60) return `${minutes}分钟前`;
    if (hours < 24) return `${hours}小时前`;
    if (days < 7) return `${days}天前`;
    
    return date.toLocaleDateString();
  }

  // 动态卡片组件
  @Builder
  DynamicCard(dynamic: Dynamic, isLocal: boolean = false) {
    Column() {
      // 动态头部
      Row() {
        Image(globalUserData.userAvatar || $r("app.media.image"))
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 12 })
        
        Column() {
          Text(globalUserData.userName)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
          
          Row() {
            Text(this.formatTime(dynamic.createTime))
              .fontSize(12)
              .fontColor('#999')
            if (isLocal) {
              Text(' [本地]')
                .fontSize(12)
                .fontColor('#2980B9')
                .margin({ left: 4 })
            }
          }
          .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
        
        // 删除按钮（仅对自己的动态显示）
        if (dynamic.userUID === this.userUID) {
          Button('删除')
            .fontSize(12)
            .fontColor('#ff6b6b')
            .backgroundColor('transparent')
            .onClick(() => {
              if (isLocal) {
                this.deleteLocalDynamic(dynamic);
              } else {
                this.deleteDynamic(dynamic);
              }
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })

      // 动态内容
      if (dynamic.content) {
        Text(dynamic.content)
          .fontSize(15)
          .fontColor('#333')
          .textAlign(TextAlign.Start)
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }

      // 动态图片
      if (dynamic.images && dynamic.images.length > 0) {
        Column() {
          if (dynamic.images.length === 1) {
            // 单张图片
            Image(dynamic.images[0])
              .width('100%')
              .height(200)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          } else {
            // 多张图片网格
            Grid() {
              ForEach(dynamic.images, (image: string, index: number) => {
                GridItem() {
                  Image(image)
                    .width('100%')
                    .height(100)
                    .borderRadius(4)
                    .objectFit(ImageFit.Cover)
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .columnsGap(4)
            .rowsGap(4)
            .width('100%')
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })
      }

      // 动态底部操作栏
      Row() {
        // 点赞按钮
        Row() {
          Image(dynamic.likeCount > 0 ? $r("app.media.return") : $r("app.media.return"))
            .width(20)
            .height(20)
            .fillColor(dynamic.likeCount > 0 ? '#ff6b6b' : '#999')
            .margin({ right: 4 })
          
          Text(dynamic.likeCount.toString())
            .fontSize(14)
            .fontColor(dynamic.likeCount > 0 ? '#ff6b6b' : '#999')
        }
        .onClick(() => {
          if (!isLocal) {
            if (dynamic.likeCount > 0) {
              this.unlikeDynamic(dynamic);
            } else {
              this.likeDynamic(dynamic);
            }
          } else {
            promptAction.showToast({ message: '本地动态暂不支持点赞' });
          }
        })

        Blank()

        // 评论按钮
        Row() {
          Image($r("app.media.return"))
            .width(20)
            .height(20)
            .fillColor('#999')
            .margin({ right: 4 })
          
          Text(dynamic.commentCount.toString())
            .fontSize(14)
            .fontColor('#999')
        }
        .onClick(() => {
          promptAction.showToast({ message: '评论功能开发中...' });
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .backgroundColor('#fff')
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
  }

  // 发布弹窗组件
  @Builder
  PublishModal() {
    if (this.showPublishModal) {
      Column() {
        // 弹窗头部
        Row() {
          Button('取消')
            .fontSize(16)
            .fontColor('#666')
            .backgroundColor('transparent')
            .onClick(() => {
              this.showPublishModal = false;
              this.publishContent = '';
              this.publishImages = [];
            })
          
          Blank()
          
          Text('发布动态')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
          
          Blank()
          
          Button('发布')
            .fontSize(16)
            .fontColor(this.publishContent.trim() ? '#2980B9' : '#ccc')
            .backgroundColor('transparent')
            .enabled(this.publishContent.trim().length > 0 && !this.isPublishing)
            .onClick(() => {
              this.publishDynamic();
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#fff')
        .border({ width: { bottom: 1 }, color: '#f0f0f0' })

        // 模式切换
        Row() {
          Button('网络模式')
            .fontSize(14)
            .fontColor(this.isLocalMode ? '#999' : '#2980B9')
            .backgroundColor(this.isLocalMode ? 'transparent' : 'rgba(41, 128, 185, 0.1)')
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8 })
            .onClick(() => {
              this.isLocalMode = false;
            })
          
          Button('本地模式')
            .fontSize(14)
            .fontColor(this.isLocalMode ? '#2980B9' : '#999')
            .backgroundColor(this.isLocalMode ? 'rgba(41, 128, 185, 0.1)' : 'transparent')
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8 })
            .onClick(() => {
              this.isLocalMode = true;
            })

          // 图片添加按钮
          Button() {
            Row() {
              Image($r('app.media.ic_add_circle'))
                .width(16)
                .height(16)
              Text('添加图片')
                .fontSize(14)
                .fontColor('#2980B9')
                .margin({ left: 4 })
            }
          }
          .backgroundColor('rgba(41, 128, 185, 0.1)')
          .borderRadius(16)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .onClick(async () => {
            await this.addImage();
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#fff')

        // 内容输入区域
        Column() {
          TextInput({
            text: this.publishContent,
            placeholder: '分享你的想法...'
          })
            .type(InputType.Normal)
            .placeholderColor('#999')
            .fontColor('#333')
            .fontSize(16)
            .width('100%')
            .height(120)
            .backgroundColor('transparent')
            .borderWidth(0)
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            .onChange((text: string) => {
              this.publishContent = text;
            })

          // 图片预览区域
          if (this.publishImages.length > 0) {
            Column() {
              Text('已选择的图片')
                .fontSize(14)
                .fontColor('#666')
                .margin({ bottom: 8, left: 16 })
                .textAlign(TextAlign.Start)
              
              Grid() {
                ForEach(this.publishImages, (image: string, index: number) => {
                  GridItem() {
                    Stack() {
                      Image(image)
                        .width('100%')
                        .height(80)
                        .borderRadius(8)
                        .objectFit(ImageFit.Cover)
                        .backgroundColor('#f0f0f0')
                      
                      // 删除按钮
                      Button('×')
                        .fontSize(16)
                        .fontColor('#fff')
                        .backgroundColor('rgba(0,0,0,0.6)')
                        .borderRadius(10)
                        .width(20)
                        .height(20)
                        .position({ x: '85%', y: '5%' })
                        .onClick(() => {
                          this.removeImage(index);
                        })
                    }
                  }
                })
              }
              .columnsTemplate('1fr 1fr 1fr')
              .columnsGap(8)
              .rowsGap(8)
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 16 })
            }
            .width('100%')
          }

          // 底部工具栏
          Row() {
            if (this.isPublishing) {
              LoadingProgress()
                .width(20)
                .height(20)
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 16 })
          .justifyContent(FlexAlign.Center)
        }
        .backgroundColor('#fff')
        .layoutWeight(1)
      }
      .width('100%')
      .height('60%')
      .backgroundColor('#fff')
      .borderRadius({ topLeft: 20, topRight: 20 })
      .position({ x: 0, y: '40%' })
      .zIndex(1000)
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })
    }
  }

  // 构建页面
  @Builder
  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Button('返回')
            .fontSize(16)
            .fontColor('#666')
            .backgroundColor('transparent')
            .onClick(() => {
              let uiContext: UIContext = this.getUIContext();
              let router = uiContext.getRouter();
              router.back();
            })
          
          Blank()
          
          Text('我的动态')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
          
          Blank()
          
          Button('发布')
            .fontSize(16)
            .fontColor('#2980B9')
            .backgroundColor('transparent')
            .onClick(() => {
              this.showPublishModal = true;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#fff')
        .border({ width: { bottom: 1 }, color: '#f0f0f0' })

        // 主要内容区域
        if (this.isNetworkConnected) {
          Refresh({ refreshing: this.isRefreshing, offset: 120, friction: 100 }) {
            List() {
              if (this.isLoading && this.dynamics.length === 0 && this.localDynamics.length === 0) {
                // 加载状态
                ListItem() {
                  Column() {
                    LoadingProgress()
                      .width(50)
                      .height(50)
                    Text('加载中...')
                      .fontSize(16)
                      .fontColor('#666')
                      .margin({ top: 10 })
                  }
                  .width('100%')
                  .height(200)
                  .justifyContent(FlexAlign.Center)
                }
              } else if (this.dynamics.length === 0 && this.localDynamics.length === 0) {
                // 空状态
                ListItem() {
                  Column() {
                    Text('暂无动态')
                      .fontSize(16)
                      .fontColor('#999')
                      .margin({ bottom: 8 })
                    Text('发布你的第一条动态吧！')
                      .fontSize(14)
                      .fontColor('#ccc')
                  }
                  .width('100%')
                  .height(200)
                  .justifyContent(FlexAlign.Center)
                }
              } else {
                // 本地动态列表
                if (this.localDynamics.length > 0) {
                  ListItem() {
                    Text('本地动态')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#2980B9')
                      .margin({ left: 16, top: 16, bottom: 8 })
                  }
                  
                  ForEach(this.localDynamics, (dynamic: Dynamic) => {
                    ListItem() {
                      this.DynamicCard(dynamic, true)
                    }
                  })
                }

                // 网络动态列表
                if (this.dynamics.length > 0) {
                  if (this.localDynamics.length > 0) {
                    ListItem() {
                      Text('网络动态')
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333')
                        .margin({ left: 16, top: 16, bottom: 8 })
                    }
                  }
                  
                  ForEach(this.dynamics, (dynamic: Dynamic) => {
                    ListItem() {
                      this.DynamicCard(dynamic, false)
                    }
                  })
                }
              }
            }
            .width('100%')
            .height('100%')
            .backgroundColor('#f5f5f5')
            .padding({ left: 16, right: 16, top: 8 })
          }
          .onRefreshing(() => {
            this.refreshDynamics();
          })
          .width('100%')
          .layoutWeight(1)
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

      // 发布弹窗
      this.PublishModal()

      // 底部导航栏
      BottomNavBar({ navIndex: 'dynamic' })
    }
  }
} 