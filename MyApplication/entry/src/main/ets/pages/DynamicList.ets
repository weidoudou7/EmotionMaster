// DynamicList.ets
// 动态展示页面

import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { Dynamic } from '../common/types';
import { NetworkUtils, CommonUtils } from '../common/utils';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct DynamicList {
  @State dynamics: Dynamic[] = []; // 动态列表
  @State isLoading: boolean = false; // 加载状态
  @State isRefreshing: boolean = false; // 刷新状态
  @State userUID: string = globalUserData.userUID;
  @State showAllDynamics: boolean = false; // 是否显示所有动态（包括私密）
  @State isNetworkConnected: boolean = true; // 网络连接状态

  // 页面生命周期
  aboutToAppear() {
    this.checkNetworkConnection();
    this.loadDynamics();
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
  DynamicCard(dynamic: Dynamic) {
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
              this.deleteDynamic(dynamic);
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
          if (dynamic.likeCount > 0) {
            this.unlikeDynamic(dynamic);
          } else {
            this.likeDynamic(dynamic);
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

  // 构建页面
  @Builder
  build() {
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
          .enabled(this.isNetworkConnected)
          .onClick(() => {
            let uiContext: UIContext = this.getUIContext();
            let router = uiContext.getRouter();
            router.pushUrl({ url: 'pages/DynamicEdit' });
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
            if (this.isLoading && this.dynamics.length === 0) {
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
            } else if (this.dynamics.length === 0) {
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
              // 动态列表
              ForEach(this.dynamics, (dynamic: Dynamic) => {
                ListItem() {
                  this.DynamicCard(dynamic)
                }
              })
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
  }
} 