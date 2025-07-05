import { BusinessError } from '@kit.BasicServicesKit';
import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { UserInfo, SearchUserResult } from '../common/types';
import promptAction from '@ohos.promptAction';
import { Config } from '../common/config';

@Entry
@Component
export struct SearchPage {
  @State searchText: string = ''; // 搜索文本
  @State isSearching: boolean = false; // 搜索状态
  @State searchResult: SearchUserResult | null = null; // 搜索结果
  @State hasSearched: boolean = false; // 是否已经搜索过

  // 页面生命周期
  aboutToAppear() {
    console.log('🚀 SearchPage 页面开始加载');
    console.log('🚀 当前API地址:', Config.getApiBaseUrl());
  }

  // 搜索功能
  async performSearch() {
    if (this.searchText.trim() === '') {
      promptAction.showToast({ message: '请输入UID以查询用户' });
      return;
    }
    
    this.isSearching = true;
    this.hasSearched = true;
    
    try {
      promptAction.showToast({ message: `正在搜索用户: ${this.searchText}` });
      
      const result = await ApiService.searchUser(this.searchText.trim());
      
      if (result) {
        // 处理头像URL拼接
        if (result.userAvatar && result.userAvatar.startsWith('/')) {
          const apiBaseUrl = Config.getApiBaseUrl();
          const serverBaseUrl = apiBaseUrl.replace('/api', ''); // 移除API路径
          
          // 检查并修正错误的路径
          let correctedAvatarUrl = result.userAvatar;
          if (result.userAvatar.startsWith('/images/')) {
            console.log('🔍 [SearchPage] 检测到错误的/images/路径，修正为/avatars/');
            correctedAvatarUrl = result.userAvatar.replace('/images/', '/avatars/');
          }
          
          const fullAvatarUrl = serverBaseUrl + correctedAvatarUrl;
          console.log('🔍 [SearchPage] 拼接后的完整头像URL:', fullAvatarUrl);
          result.userAvatar = fullAvatarUrl;
        }
        
        this.searchResult = result;
        promptAction.showToast({ message: `找到用户: ${result.userName}` });
      } else {
        this.searchResult = null;
        promptAction.showToast({ message: '未找到该用户' });
      }
    } catch (error) {
      console.error('搜索失败:', error);
      promptAction.showToast({ message: `搜索失败: ${error.message || '未知错误'}` });
      this.searchResult = null;
    } finally {
      this.isSearching = false;
    }
  }

  // 关注按钮点击事件
  onFollowClick() {
    promptAction.showToast({ message: '关注功能正在开发中' });
  }

  // 查看按钮点击事件
  onViewClick() {
    promptAction.showToast({ message: '查看功能正在开发中' });
  }

  build() {
    Stack() {
      // 渐变背景 - 与yourpage保持一致
      Column() {
        Blank().width('100%').height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['#1a1a2e', 0.0], ['#16213e', 0.3], ['#0f3460', 0.7], ['#533483', 1.0]]
          })
      }
      .width('100%')
      .height('100%')
      
      // 装饰性背景元素 - 与yourpage保持一致
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
          Text('查找')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .margin({ right: 56 }) // 为返回按钮留出空间
        }
        .width('100%')
        .height(60)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        
        // 搜索栏
        Column() {
          Row() {
            // 搜索输入框
            TextInput({ placeholder: '请输入UID以查询用户', text: this.searchText })
              .width('85%')
              .height(48)
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(24)
              .padding({ left: 20, right: 20 })
              .fontSize(16)
              .fontColor('#fff')
              .placeholderColor('rgba(255,255,255,0.5)')
              .onChange((value: string) => {
                this.searchText = value;
              })
              .onSubmit(() => {
                this.performSearch();
              })
            
            // 搜索按钮
            Button() {
              if (this.isSearching) {
                LoadingProgress()
                  .width(20)
                  .height(20)
                  .color('#fff')
              } else {
                Text('→')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#fff')
              }
            }
            .width(48)
            .height(48)
            .backgroundColor('rgba(128,128,128,0.3)')
            .borderRadius(24)
            .margin({ left: 12 })
            .onClick(() => {
              this.performSearch();
            })
          }
          .width('90%')
          
          // 提示文字
          Text('请输入UID以查询用户')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.6)')
            .textAlign(TextAlign.Start)
            .margin({ top: 8, left: '5%' })
        }
        .margin({ top: 20, bottom: 20 })
        
        // 搜索结果显示区域
        Column() {
          if (this.isSearching) {
            // 搜索中状态
            Column() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#fff')
              Text('搜索中...')
                .fontSize(16)
                .fontColor('rgba(255,255,255,0.8)')
                .margin({ top: 16 })
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
          } else if (this.hasSearched) {
            // 搜索结果
            if (this.searchResult) {
              // 找到用户
              Column() {
                Text('搜索结果')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#fff')
                  .margin({ bottom: 16 })
                
                // 用户卡片
                Row() {
                  // 左侧：头像+用户名+UID 垂直排列
                  Column() {
                    // 头像
                    Image(this.searchResult.userAvatar || $r('app.media.image'))
                      .width(60)
                      .height(60)
                      .borderRadius(30)
                      .backgroundColor('rgba(255,255,255,0.1)')
                      .border({ width: 2, color: 'rgba(255,255,255,0.3)' })
                      .margin({ bottom: 8 })
                    
                    // 用户名
                    Text(this.searchResult.userName)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#fff')
                      .textAlign(TextAlign.Center)
                      .margin({ bottom: 4 })
                    
                    // UID
                    Text(`UID: ${this.searchResult.userUID}`)
                      .fontSize(12)
                      .fontColor('rgba(255,255,255,0.6)')
                      .textAlign(TextAlign.Center)
                  }
                  .alignItems(HorizontalAlign.Center)
                  .layoutWeight(1)
                  
                  // 右侧：按钮垂直排列
                  Column() {
                    Button('关注')
                      .width(60)
                      .height(32)
                      .fontSize(12)
                      .backgroundColor('rgba(128,128,128,0.3)')
                      .fontColor('#fff')
                      .borderRadius(16)
                      .margin({ bottom: 8 })
                      .onClick(() => {
                        this.onFollowClick();
                      })
                    
                    Button('查看')
                      .width(60)
                      .height(32)
                      .fontSize(12)
                      .backgroundColor('rgba(128,128,128,0.3)')
                      .fontColor('#fff')
                      .borderRadius(16)
                      .onClick(() => {
                        this.onViewClick();
                      })
                  }
                  .alignItems(HorizontalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                }
                .width('100%')
                .padding(16)
                .backgroundColor('rgba(255,255,255,0.08)')
                .borderRadius(16)
                .border({ width: 1, color: 'rgba(255,255,255,0.1)' })
              }
              .width('90%')
            } else {
              // 未找到用户
              Column() {
                Image($r('app.media.menu_icon'))
                  .width(80)
                  .height(80)
                  .opacity(0.3)
                  .margin({ bottom: 16 })
                Text('未找到该用户')
                  .fontSize(16)
                  .fontColor('rgba(255,255,255,0.5)')
                  .textAlign(TextAlign.Center)
                Text('请检查UID是否正确')
                  .fontSize(14)
                  .fontColor('rgba(255,255,255,0.4)')
                  .textAlign(TextAlign.Center)
                  .margin({ top: 8 })
              }
              .width('100%')
              .height(200)
              .justifyContent(FlexAlign.Center)
            }
          } else {
            // 默认状态
            Column() {
              Image($r('app.media.menu_icon'))
                .width(80)
                .height(80)
                .opacity(0.3)
                .margin({ bottom: 16 })
              Text('输入UID开始搜索')
                .fontSize(16)
                .fontColor('rgba(255,255,255,0.5)')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('90%')
        .layoutWeight(1)
        .backgroundColor('rgba(255,255,255,0.05)')
        .borderRadius(16)
        .padding(20)
        
        // 底部空白
        Blank()
          .height(40)
      }
      .width('100%')
      .height('100%')
      .zIndex(2)
    }
  }
} 