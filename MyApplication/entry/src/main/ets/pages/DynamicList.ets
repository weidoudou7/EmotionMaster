// DynamicList.ets
// 动态展示页面

import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { Dynamic, CreateDynamicRequest } from '../common/types';
import { NetworkUtils } from '../common/utils';
import { Config } from '../common/config';
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

  // 发布相关状态
  @State showPublishModal: boolean = false; // 是否显示发布弹窗
  @State publishContent: string = ''; // 发布内容
  @State publishImages: string[] = []; // 发布图片
  @State isLocalMode: boolean = false; // 是否为本地模式
  @State isPublishing: boolean = false; // 是否正在发布
  @State localDynamics: Dynamic[] = []; // 本地动态列表
  @State showImagePickerModal: boolean = false; // 是否显示图片选择弹窗

  // 头像查看器状态
  @State showAvatarViewer: boolean = false; // 显示头像查看器
  @State currentAvatarUrl: string = ''; // 当前查看的头像URL

  // 页面生命周期
  aboutToAppear() {
    this.checkNetworkConnection();
    this.loadDynamics();
    this.loadLocalDynamics().then(() => {
      console.log('本地动态加载完成');
    }).catch((error: string) => {
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
      
      // 按时间顺序排序（最新的在前）
      this.dynamics = dynamics.sort((a, b) => {
        const timeA = new Date(a.createTime).getTime();
        const timeB = new Date(b.createTime).getTime();
        return timeB - timeA;
      });
      
      // 保存最新动态到本地存储，供 yourpage 使用
      if (this.dynamics.length > 0) {
        await this.saveLatestDynamic(this.dynamics[0]);
      }
    } catch (error) {
      console.error('加载动态失败:', error);
      promptAction.showToast({ message: '加载动态失败' });
    } finally {
      this.isLoading = false;
    }
  }

  // 保存最新动态到本地存储
  async saveLatestDynamic(dynamic: Dynamic): Promise<void> {
    try {
      const context = getContext(this);
      const preferencesHelper = await preferences.getPreferences(context, 'userData');
      await preferencesHelper.put('latestDynamic', JSON.stringify(dynamic));
      await preferencesHelper.flush();
    } catch (error) {
      console.error('保存最新动态失败:', error);
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

  // 显示头像查看器
  showAvatarViewerDialog(avatarUrl: string) {
    this.currentAvatarUrl = avatarUrl;
    this.showAvatarViewer = true;
  }

  // 关闭头像查看器
  closeAvatarViewer() {
    this.showAvatarViewer = false;
    this.currentAvatarUrl = '';
  }

  // 发布动态
  async publishDynamic(): Promise<void> {
    console.log('🚀 开始发布动态...');
    console.log('🚀 发布内容:', this.publishContent);
    console.log('🚀 网络状态:', this.isNetworkConnected);
    
    if (this.publishContent.trim() === '') {
      promptAction.showToast({ message: '请输入动态内容' });
      return;
    }

    if (this.isPublishing) {
      console.log('⚠️ 正在发布中，跳过重复请求');
      return;
    }

    try {
      this.isPublishing = true;

      if (this.isNetworkConnected) {
        console.log('🌐 联网发布模式');
        // 联网发布
        const request: CreateDynamicRequest = {
          content: this.publishContent.trim(),
          images: this.publishImages,
          isPrivate: false
        };

        console.log('📤 发送请求:', JSON.stringify(request));
        const newDynamic = await ApiService.createDynamic(this.userUID, request);
        console.log('✅ 发布成功，返回数据:', JSON.stringify(newDynamic));
        
        // 添加到动态列表开头
        this.dynamics.unshift(newDynamic);
        console.log('📝 已添加到动态列表，当前列表长度:', this.dynamics.length);
        
        // 保存最新动态到本地存储
        await this.saveLatestDynamic(newDynamic);
        console.log('💾 已保存到本地存储');
        
        promptAction.showToast({ message: '发布成功' });
      } else {
        console.log('📱 本地发布模式');
        // 本地发布
        const localDynamic: Dynamic = {
          id: Date.now().toString(),
          userUID: this.userUID,
          content: this.publishContent.trim(),
          images: this.publishImages,
          likeCount: 0,
          commentCount: 0,
          isPrivate: false,
          createTime: new Date().toISOString(),
          updateTime: new Date().toISOString()
        };

        this.localDynamics.unshift(localDynamic);
        await this.saveLocalDynamics();
        console.log('📝 本地发布成功，当前本地动态数量:', this.localDynamics.length);
        
        promptAction.showToast({ message: '本地发布成功' });
      }

      // 清空发布内容
      this.publishContent = '';
      this.publishImages = [];
      this.showPublishModal = false;
      console.log('🧹 已清空发布内容');

      // 自动刷新页面
      console.log('🔄 开始刷新动态列表...');
      await this.refreshDynamics();
      console.log('✅ 动态发布流程完成');
      
    } catch (error) {
      console.error('❌ 发布动态失败:', error);
      console.error('❌ 错误详情:', JSON.stringify(error));
      promptAction.showToast({ message: `发布失败: ${error.message || '未知错误'}` });
    } finally {
      this.isPublishing = false;
      console.log('🏁 发布状态重置完成');
    }
  }

  // 选择图片
  async selectImages(): Promise<void> {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const photoSelectOptions: picker.PhotoSelectOptions = {
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 9 - this.publishImages.length
      };

      const photoView = await photoPicker.select(photoSelectOptions);
      const uris = photoView.photoUris;

      for (let i = 0; i < uris.length; i++) {
        const uri = uris[i];
        const fileName = `dynamic_${Date.now()}_${i}.jpg`;
        const destPath = `file:///data/storage/el2/base/haps/entry/files/${fileName}`;
        
        await fs.copyFile(uri, destPath);
        this.publishImages.push(destPath);
      }
    } catch (error) {
      console.error('选择图片失败:', error);
      promptAction.showToast({ message: '选择图片失败' });
    }
  }

  // 移除图片
  removeImage(index: number): void {
    this.publishImages.splice(index, 1);
  }

  // 格式化时间
  formatTime(timeString: string): string {
    const date = new Date(timeString);
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

  // 处理头像URL - 改为预览器样式
  getAvatarUrl(avatarUrl: string | undefined): Resource | string {
    if (!avatarUrl || avatarUrl === '/avatars/default.png') {
      return $r('app.media.image');
    }
    
    // 处理头像URL - 如果是相对路径，拼接完整URL
    if (avatarUrl && avatarUrl.startsWith('/')) {
      const baseUrl = Config.getApiBaseUrl().replace('/api', '');
      const fullUrl = baseUrl + avatarUrl;
      console.log('👤 [DynamicList] 处理后的头像URL:', fullUrl);
      return fullUrl;
    }
    
    return avatarUrl;
  }

  build() {
    Stack() {
      // 渐变背景 - 与 yourpage 保持一致
      Column() {
        Blank().width('100%').height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['#1a1a2e', 0.0], ['#16213e', 0.3], ['#0f3460', 0.7], ['#533483', 1.0]]
          })
      }
      .width('100%')
      .height('100%')
      
      // 装饰性背景元素 - 与 yourpage 保持一致
      Column() {
        // 顶部装饰元素
        Row() {
          Image($r('app.media.deroration_1'))
            .width(200)
            .height(200)
            .opacity(0.1)
            .position({ x: -100, y: -50 })
          Image($r('app.media.deroration_2'))
            .width(150)
            .height(150)
            .opacity(0.08)
            .position({ x: 300, y: -30 })
        }
        .width('100%')
        .height(60)
        
        Blank().layoutWeight(1)
        
        // 底部装饰元素
        Row() {
          Image($r('app.media.deroration_3'))
            .width(180)
            .height(180)
            .opacity(0.08)
            .position({ x: -80, y: 20 })
          Image($r('app.media.deroration_4'))
            .width(120)
            .height(120)
            .opacity(0.1)
            .position({ x: 320, y: 40 })
        }
        .width('100%')
        .height(80)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1)
      
      // 主体内容
      Column() {
        // 顶部导航栏
        Row() {
          // 返回按钮
          Button() {
            Image($r('app.media.return'))
              .width(24)
              .height(24)
              .fillColor('#fff')
          }
          .width(40)
          .height(40)
          .backgroundColor('rgba(128,128,128,0)')
          .borderRadius(20)
          .margin({ left: 16 })
          .onClick(() => {
            let uiContext: UIContext = this.getUIContext();
            let router = uiContext.getRouter();
            router.back();
          })
          
          // 页面标题
          Text('我的动态')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .margin({ right: 56 }) // 为返回按钮留出空间
          
          // 发布按钮
          Button() {
            Image($r('app.media.plus_icon'))
              .width(24)
              .height(24)
              .fillColor('#fff')
          }
          .width(40)
          .height(40)
          .backgroundColor('rgba(128,128,128,0.3)')
          .borderRadius(20)
          .margin({ right: 16 })
          .onClick(() => {
            this.showPublishModal = true;
          })
        }
        .width('100%')
        .height(60)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        
        // 动态列表
        Refresh({ refreshing: this.isRefreshing, offset: 120, friction: 100 }) {
          List() {
            if (this.isLoading) {
              // 加载状态
              ListItem() {
                Column() {
                  LoadingProgress()
                    .width(40)
                    .height(40)
                    .color('#fff')
                  Text('加载中...')
                    .fontSize(16)
                    .fontColor('rgba(255,255,255,0.8)')
                    .margin({ top: 16 })
                }
                .width('100%')
                .height(200)
                .justifyContent(FlexAlign.Center)
              }
            } else if (this.dynamics.length === 0 && this.localDynamics.length === 0) {
              // 空状态
              ListItem() {
                Column() {
                  Image($r('app.media.dynamic'))
                    .width(80)
                    .height(80)
                    .opacity(0.3)
                    .margin({ bottom: 16 })
                  Text('还没有动态')
                    .fontSize(16)
                    .fontColor('rgba(255,255,255,0.5)')
                    .textAlign(TextAlign.Center)
                  Text('点击右上角发布第一条动态吧')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.4)')
                    .textAlign(TextAlign.Center)
                    .margin({ top: 8 })
                }
                .width('100%')
                .height(300)
                .justifyContent(FlexAlign.Center)
              }
            } else {
              // 动态列表
              ForEach([...this.dynamics, ...this.localDynamics], (dynamic: Dynamic) => {
                ListItem() {
                  this.DynamicCard(dynamic)
                }
              })
            }
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(255,255,255,0.05)')
          .borderRadius(16)
          .margin({ left: 16, right: 16, bottom: 16 })
          .padding(16)
        }
        .onRefreshing(() => {
          this.refreshDynamics();
        })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .zIndex(2)
      
      // 发布弹窗
      if (this.showPublishModal) {
        this.PublishModal()
      }

      // 头像查看器 - 全屏显示头像
      if (this.showAvatarViewer) {
        Stack({ alignContent: Alignment.Center }) {
          // 半透明背景
          Column() {
            Blank()
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .opacity(0.9)
              .onClick(() => this.closeAvatarViewer())
          }
          .width('100%')
          .height('100%')

          // 头像查看器内容
          Column() {
            // 关闭按钮
            Row() {
              Button() {
                Image($r('app.media.return'))
                  .width(24)
                  .height(24)
                  .fillColor('#fff')
              }
              .width(40)
              .height(40)
              .backgroundColor('rgba(0,0,0,0.5)')
              .borderRadius(20)
              .onClick(() => this.closeAvatarViewer())
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
            .margin({ bottom: 20 })

            // 大尺寸头像显示
            Image(this.currentAvatarUrl)
              .width(300)
              .height(300)
              .borderRadius(150)
              .border({ width: 6, color: 'rgba(255,255,255,0.3)' })
              .objectFit(ImageFit.Cover)
              .margin({ bottom: 20 })

            // 操作按钮
            Row() {
              Button('查看用户')
                .width(120)
                .height(44)
                .backgroundColor('rgba(255,255,255,0.2)')
                .fontColor('#fff')
                .borderRadius(22)
                .onClick(() => {
                  this.closeAvatarViewer();
                  setTimeout(() => {
                    let uiContext: UIContext = this.getUIContext();
                    let router = uiContext.getRouter();
                    router.pushUrl({ url: 'pages/yourpage' });
                  }, 300);
                })
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('90%')
          .padding(24)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(999)
      }
    }
  }

  @Builder
  DynamicCard(dynamic: Dynamic) {
    Column() {
      // 用户信息 - 改为预览器样式显示头像
      Row() {
        // 头像显示 - 像预览器一样显示
        Stack() {
          // 头像图片 - 大尺寸显示
          Image(this.getAvatarUrl(dynamic.userAvatar))
            .width(50)
            .height(50)
            .borderRadius(25)
            .backgroundColor('rgba(255,255,255,0.1)')
            .border({ width: 2, color: 'rgba(255,255,255,0.3)' })
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              // 点击头像显示查看器
              const avatarUrl = this.getAvatarUrl(dynamic.userAvatar);
              if (typeof avatarUrl === 'string') {
                this.showAvatarViewerDialog(avatarUrl);
              }
            })
        }
        
        Column() {
          Text(dynamic.userName || globalUserData.userName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
          Text(this.formatTime(dynamic.createTime))
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.6)')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)
        
        // 删除按钮（仅对自己的动态显示）
        if (dynamic.userUID === this.userUID) {
          Button() {
            Image($r('app.media.menu_icon'))
              .width(16)
              .height(16)
              .fillColor('rgba(255,255,255,0.6)')
          }
          .width(32)
          .height(32)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(16)
          .onClick(() => {
            if (this.localDynamics.some(d => d.id === dynamic.id)) {
              this.deleteLocalDynamic(dynamic);
            } else {
              this.deleteDynamic(dynamic);
            }
          })
        }
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      // 动态内容
      Text(dynamic.content)
        .fontSize(16)
        .fontColor('#fff')
        .textAlign(TextAlign.Start)
        .width('100%')
        .margin({ bottom: 12 })
      
      // 图片展示
      if (dynamic.images && dynamic.images.length > 0) {
        Grid() {
          ForEach(dynamic.images, (image: string, index: number) => {
            GridItem() {
              Image(image)
                .width('100%')
                .height(120)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
        .margin({ bottom: 12 })
      }
      
      // 操作栏
      Row() {
        // 点赞按钮
        Row() {
          Text('❤️')
            .fontSize(16)
            .margin({ right: 4 })
          Text(dynamic.likeCount?.toString() || '0')
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.8)')
        }
        .onClick(() => {
          if (this.localDynamics.some(d => d.id === dynamic.id)) {
            // 本地动态不支持点赞
            promptAction.showToast({ message: '本地动态暂不支持点赞' });
          } else {
            this.likeDynamic(dynamic);
          }
        })
        
        // 评论按钮
        Row() {
          Text('💬')
            .fontSize(16)
            .margin({ right: 4 })
          Text(dynamic.commentCount?.toString() || '0')
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.8)')
        }
        .margin({ left: 20 })
        .onClick(() => {
          promptAction.showToast({ message: '评论功能开发中' });
        })
        
        // 分享按钮
        Row() {
          Text('📤')
            .fontSize(16)
        }
        .margin({ left: 20 })
        .onClick(() => {
          promptAction.showToast({ message: '分享功能开发中' });
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.05)')
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder
  PublishModal() {
    Stack({ alignContent: Alignment.Center }) {
      // 半透明背景
      Column() {
        Blank()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.6)
          .onClick(() => {
            this.showPublishModal = false;
          })
      }
      .width('100%')
      .height('100%')

      // 发布弹窗内容
      Column() {
        // 标题栏
        Row() {
          Text('发布动态')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
            .layoutWeight(1)
          
          Button() {
            Image($r('app.media.return'))
              .width(20)
              .height(20)
              .fillColor('#fff')
          }
          .width(32)
          .height(32)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(16)
          .onClick(() => {
            this.showPublishModal = false;
          })
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 内容输入框
        TextArea({
          text: this.publishContent,
          placeholder: '分享你的想法...'
        })
          .width('100%')
          .height(120)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(12)
          .padding(16)
          .fontSize(16)
          .fontColor('#fff')
          .placeholderColor('rgba(255,255,255,0.5)')
          .onChange((value: string) => {
            this.publishContent = value;
          })
          .margin({ bottom: 16 })

        // 图片选择区域
        if (this.publishImages.length > 0) {
          Grid() {
            ForEach(this.publishImages, (image: string, index: number) => {
              GridItem() {
                Stack() {
                  Image(image)
                    .width('100%')
                    .height(80)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)
                  
                  // 删除按钮
                  Button() {
                    Text('×')
                      .fontSize(16)
                      .fontColor('#fff')
                  }
                  .width(24)
                  .height(24)
                  .backgroundColor('rgba(0,0,0,0.6)')
                  .borderRadius(12)
                  .position({ x: '85%', y: '15%' })
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
          .margin({ bottom: 16 })
        }

        // 操作按钮
        Row() {
          Button() {
            Text('📷')
              .fontSize(16)
          }
          .width(44)
          .height(44)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(22)
          .onClick(() => {
            this.selectImages();
          })

          Button('发布')
            .width(100)
            .height(44)
            .backgroundColor(this.isPublishing ? 'rgba(255,255,255,0.3)' : 'rgba(255,255,255,0.2)')
            .fontColor('#fff')
            .borderRadius(22)
            .margin({ left: 'auto' })
            .onClick(() => {
              if (!this.isPublishing) {
                this.publishDynamic();
              }
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('90%')
      .backgroundColor('rgba(0,0,0,0.8)')
      .borderRadius(20)
      .padding(24)
      .backdropBlur(20)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(999)
  }
} 