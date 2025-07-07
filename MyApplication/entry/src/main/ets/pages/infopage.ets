// infopage.ets
// 导入页面路由模块
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';
import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { UserInfo } from '../common/types';
import { Config } from '../common/config';
import { BottomNavBar } from './BottomNavBar';

@Entry
@Component
export struct InfoPage {
  @State userAvatar: Resource | string = $r("app.media.image"); // 用户头像
  @State userName: string = globalUserData.userName; // 用户名称
  @State userUID: string = globalUserData.userUID; // 用户UID
  @State isPrivacyVisible: boolean = globalUserData.isPrivacyVisible; // 用户隐私是否可见
  @State showNameDialog: boolean = false; // 显示名称编辑对话框
  @State tempName: string = ''; // 临时存储编辑的名称
  @State showSignatureDialog: boolean = false; // 显示签名编辑对话框
  @State tempSignature: string = ''; // 临时存储编辑的签名
  @State showGenderDialog: boolean = false; // 显示性别选择对话框
  @State tempGender: string = ''; // 临时存储选择的性别
  @State isLoading: boolean = false; // 加载状态
  @State userInfo: UserInfo | null = null; // 用户详细信息
  @State avatarScale: number = 1.0; // 头像缩放动画
  @State showPreviewDialog: boolean = false; // 显示预览对话框
  @State previewImage: string = ''; // 预览图片
  @State previewSeed: number = 0; // 预览种子
  @State isGeneratingPreview: boolean = false; // 正在生成预览
  @State isAvatarLoading: boolean = false; // 头像加载状态
  @State showAvatarViewer: boolean = false; // 显示头像查看器

  // 页面生命周期
  aboutToAppear() {
    // 使用全局数据快速初始化
    this.userName = globalUserData.userName;
    this.userUID = globalUserData.userUID;
    this.isPrivacyVisible = globalUserData.isPrivacyVisible;
    
    // 异步加载详细信息
    this.loadUserInfoAsync();
  }

  // 异步加载用户信息（不阻塞页面显示）
  async loadUserInfoAsync() {
    try {
      console.log('👤 [infopage] 开始加载用户信息，用户UID:', this.userUID);
      
      const userInfo = await ApiService.getUserInfo(this.userUID);
      this.userInfo = userInfo;
      this.userName = userInfo.userName;
      this.isPrivacyVisible = userInfo.isPrivacyVisible;

      // 处理头像显示
      await this.updateAvatarDisplay(userInfo.userAvatar);
      
      console.log('👤 [infopage] 用户信息加载完成');
    } catch (error) {
      console.error('👤 [infopage] 加载用户信息失败:', error);
      // 不显示错误提示，避免影响用户体验
    }
  }

  // 更新头像显示
  async updateAvatarDisplay(avatarUrl: string | undefined) {
    console.log('🖼️ [infopage] 开始更新头像显示');
    console.log('🖼️ [infopage] 原始头像URL:', avatarUrl);
    
    if (avatarUrl && avatarUrl !== '/avatars/default.png' && avatarUrl !== '') {
      // 如果有后端头像，使用后端头像
      let processedAvatarUrl = avatarUrl;
      
      // 处理头像URL - 如果是相对路径，拼接完整URL
      if (avatarUrl.startsWith('/')) {
        const baseUrl = Config.getApiBaseUrl().replace('/api', '');
        processedAvatarUrl = baseUrl + avatarUrl;
        console.log('🖼️ [infopage] 处理后的头像URL:', processedAvatarUrl);
      }
      
      this.userAvatar = processedAvatarUrl;
      console.log('🖼️ [infopage] 头像更新成功');
    } else {
      // 使用默认头像
      this.userAvatar = $r("app.media.image");
      console.log('🖼️ [infopage] 使用默认头像');
    }
  }

  // 获取头像URL（用于显示）
  getAvatarUrl(): string {
    if (typeof this.userAvatar === 'string') {
      return this.userAvatar;
    }
    return '';
  }

  // 显示头像查看器
  showAvatarViewerDialog() {
    this.showAvatarViewer = true;
  }

  // 关闭头像查看器
  closeAvatarViewer() {
    this.showAvatarViewer = false;
  }

  // 生成预览头像
  async generatePreviewAvatar() {
    try {
      console.log('👁️ [infopage] 开始生成预览头像...');
      
      this.isGeneratingPreview = true;
      promptAction.showToast({ message: '正在生成预览头像...' });

      // 调用后端API生成预览头像
      const previewResponse = await ApiService.generatePreviewAvatar(this.userUID);
      
      if (previewResponse && previewResponse.previewImage) {
        console.log('👁️ [infopage] 预览头像生成成功');
        console.log('👁️ [infopage] 预览种子:', previewResponse.previewSeed);
        
        // 保存预览信息
        this.previewImage = previewResponse.previewImage;
        this.previewSeed = previewResponse.previewSeed;
        
        // 显示预览对话框
        this.showPreviewDialog = true;
        
        promptAction.showToast({ message: '预览头像生成成功' });
      } else {
        promptAction.showToast({ message: '预览头像生成失败' });
      }
    } catch (error) {
      console.error('👁️ [infopage] 生成预览头像失败:', error);
      promptAction.showToast({ message: '生成预览头像失败，请重试' });
    } finally {
      this.isGeneratingPreview = false;
    }
  }

  // 确认并保存预览头像
  async confirmPreviewAvatar() {
    try {
      console.log('💾 [infopage] 开始确认并保存预览头像...');
      console.log('💾 [infopage] 预览种子:', this.previewSeed);
      
      this.isAvatarLoading = true;
      promptAction.showToast({ message: '正在保存头像...' });

      // 调用后端API确认并保存头像
      const newAvatarUrl = await ApiService.confirmPreviewAvatar(this.userUID, this.previewSeed);
      
      if (newAvatarUrl) {
        console.log('💾 [infopage] 头像确认并保存成功，URL:', newAvatarUrl);
        
        // 更新本地显示
        await this.updateAvatarDisplay(newAvatarUrl);
        
        // 刷新用户信息
        await this.loadUserInfoAsync();
        
        // 关闭预览对话框
        this.showPreviewDialog = false;
        
        promptAction.showToast({ message: '头像保存成功' });
      } else {
        promptAction.showToast({ message: '头像保存失败' });
      }
    } catch (error) {
      console.error('💾 [infopage] 确认预览头像失败:', error);
      promptAction.showToast({ message: '头像保存失败，请重试' });
    } finally {
      this.isAvatarLoading = false;
    }
  }

  // 取消预览头像
  cancelPreviewAvatar() {
    console.log('❌ [infopage] 取消预览头像');
    this.showPreviewDialog = false;
    this.previewImage = '';
    this.previewSeed = 0;
  }

  // 编辑用户名称
  editUserName() {
    this.tempName = this.userName;
    this.showNameDialog = true;
  }

  // 确认编辑用户名称
  async confirmEditName() {
    if (this.tempName.trim() !== '') {
      try {
        this.isLoading = true;
        const updatedUser = await ApiService.updateUserInfo(this.userUID, {
          userName: this.tempName.trim()
        });
        this.userName = updatedUser.userName;
        promptAction.showToast({ message: '用户名称更新成功' });
      } catch (error) {
        console.error('更新用户名称失败:', error);
        promptAction.showToast({ message: '更新用户名称失败' });
      } finally {
        this.isLoading = false;
      }
    }
    this.showNameDialog = false;
  }

  // 取消编辑用户名称
  cancelEditName() {
    this.showNameDialog = false;
  }

  // 切换隐私可见性
  async togglePrivacy() {
    try {
      this.isLoading = true;
      const newPrivacyState = await ApiService.togglePrivacy(this.userUID);
      this.isPrivacyVisible = newPrivacyState;
      promptAction.showToast({
        message: this.isPrivacyVisible ? '隐私已隐藏' : '隐私已可见'
      });
    } catch (error) {
      console.error('切换隐私状态失败:', error);
      promptAction.showToast({ message: '切换隐私状态失败' });
    } finally {
      this.isLoading = false;
    }
  }

  // 编辑个性签名
  editSignature() {
    this.tempSignature = this.userInfo?.signature || '这个人很懒，什么都没留下~';
    this.showSignatureDialog = true;
  }

  // 确认编辑个性签名
  async confirmEditSignature() {
    if (this.tempSignature.trim() !== '') {
      try {
        this.isLoading = true;
        const updatedUser = await ApiService.updateUserInfo(this.userUID, {
          signature: this.tempSignature.trim()
        });
        // 更新本地用户信息
        if (this.userInfo) {
          this.userInfo.signature = updatedUser.signature;
        }
        promptAction.showToast({ message: '个性签名更新成功' });
      } catch (error) {
        console.error('更新个性签名失败:', error);
        promptAction.showToast({ message: '更新个性签名失败' });
      } finally {
        this.isLoading = false;
      }
    }
    this.showSignatureDialog = false;
  }

  // 取消编辑个性签名
  cancelEditSignature() {
    this.showSignatureDialog = false;
  }

  // 编辑性别
  editGender() {
    this.tempGender = this.userInfo?.gender || '未设置';
    this.showGenderDialog = true;
  }

  // 确认编辑性别
  async confirmEditGender() {
    if (this.tempGender !== '未设置') {
      try {
        this.isLoading = true;
        const updatedUser = await ApiService.updateUserInfo(this.userUID, {
          gender: this.tempGender
        });
        // 更新本地用户信息
        if (this.userInfo) {
          this.userInfo.gender = updatedUser.gender;
        }
        promptAction.showToast({ message: '性别更新成功' });
      } catch (error) {
        console.error('更新性别失败:', error);
        promptAction.showToast({ message: '更新性别失败' });
      } finally {
        this.isLoading = false;
      }
    }
    this.showGenderDialog = false;
  }

  // 取消编辑性别
  cancelEditGender() {
    this.showGenderDialog = false;
  }

  build() {
    Stack() {
      // 渐变背景
      Column() {
        Blank().width('100%').height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['#1a1a2e', 0.0], ['#16213e', 0.5], ['#0f3460', 1.0]]
          })
      }
      .width('100%')
      .height('100%')

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(50).height(50)
          Text('处理中...').fontSize(16).fontColor('#fff').margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 主体内容
        Scroll() {
          Column() {
            // 页面标题区域
            Row() {
              Button() {
                Image($r('app.media.return'))
                  .width(24)
                  .height(24)
                  .fillColor('#fff')
              }
              .width(40)
              .height(40)
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(20)
              .margin({ right: 16 })
              .onClick(() => {
                let uiContext: UIContext = this.getUIContext();
                let router = uiContext.getRouter();
                router.back();
              })

              Text('个人信息')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#fff')
            }
            .width('90%')
            .padding({ top: 20, bottom: 20 })
            .justifyContent(FlexAlign.Start)
            .margin({ bottom: 20 })

            // 头像卡片 - 改为头像查看器样式
            Column() {
              // 头像显示区域 - 像预览器一样显示
              Stack() {
                // 头像图片 - 大尺寸显示
                Image(this.userAvatar)
                  .width(200)
                  .height(200)
                  .borderRadius(100)
                  .border({ width: 4, color: 'rgba(255,255,255,0.3)' })
                  .scale({ x: this.avatarScale, y: this.avatarScale })
                  .animation({
                    duration: 120,
                    curve: Curve.EaseInOut
                  })
                  .objectFit(ImageFit.Cover)
                  .onClick(() => {
                    this.avatarScale = 0.95;
                    setTimeout(() => {
                      this.avatarScale = 1.0;
                      this.showAvatarViewerDialog();
                    }, 120);
                  })

                // 加载状态遮罩
                if (this.isAvatarLoading) {
                  Column() {
                    LoadingProgress().width(40).height(40)
                  }
                  .width(200)
                  .height(200)
                  .borderRadius(100)
                  .backgroundColor('rgba(0,0,0,0.5)')
                  .justifyContent(FlexAlign.Center)
                }

                // 刷新按钮 - 悬浮在头像上
                if (!this.isGeneratingPreview && !this.isAvatarLoading) {
                  Button() {
                    Image($r('app.media.return'))
                      .width(24)
                      .height(24)
                      .fillColor('#fff')
                  }
                  .width(48)
                  .height(48)
                  .backgroundColor('rgba(0,0,0,0.7)')
                  .borderRadius(24)
                  .border({ width: 2, color: '#fff' })
                  .position({ x: '85%', y: '85%' })
                  .translate({ x: -24, y: -24 })
                  .onClick(() => {
                    this.generatePreviewAvatar();
                  })
                }
              }
              .width(200)
              .height(200)
              .margin({ bottom: 20 })

              // 头像操作按钮
              Row() {
                Button('查看大图')
                  .width(100)
                  .height(40)
                  .backgroundColor('rgba(255,255,255,0.1)')
                  .fontColor('#fff')
                  .borderRadius(20)
                  .onClick(() => this.showAvatarViewerDialog())

                Button('生成新头像')
                  .width(100)
                  .height(40)
                  .backgroundColor('rgba(255,255,255,0.2)')
                  .fontColor('#fff')
                  .borderRadius(20)
                  .margin({ left: 20 })
                  .onClick(() => this.generatePreviewAvatar())
              }
              .justifyContent(FlexAlign.Center)
            }
            .width('90%')
            .padding(24)
            .backgroundColor('rgba(255,255,255,0.1)')
            .borderRadius(20)
            .margin({ bottom: 20 })

            // 用户信息卡片列表
            Column({ space: 16 }) {
              // 用户名称项
              Row() {
                Column() {
                  Text('用户名称')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#fff')
                    .margin({ bottom: 4 })
                  Text(this.userName)
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.7)')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Image($r('app.media.selectNext'))
                  .width(20)
                  .height(20)
                  .fillColor('rgba(255,255,255,0.6)')
              }
              .width('100%')
              .padding(20)
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(16)
              .onClick(() => this.editUserName())

              // 性别项
              Row() {
                Column() {
                  Text('性别')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#fff')
                    .margin({ bottom: 4 })
                  Text(this.userInfo?.gender || '未设置')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.7)')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Image($r('app.media.selectNext'))
                  .width(20)
                  .height(20)
                  .fillColor('rgba(255,255,255,0.6)')
              }
              .width('100%')
              .padding(20)
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(16)
              .onClick(() => this.editGender())

              // 个性签名项
              Row() {
                Column() {
                  Text('个性签名')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#fff')
                    .margin({ bottom: 4 })
                  Text(this.userInfo?.signature || '这个人很懒，什么都没留下~')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.7)')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Image($r('app.media.selectNext'))
                  .width(20)
                  .height(20)
                  .fillColor('rgba(255,255,255,0.6)')
              }
              .width('100%')
              .padding(20)
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(16)
              .onClick(() => this.editSignature())

              // 隐私设置项
              Row() {
                Column() {
                  Text('隐私设置')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#fff')
                    .margin({ bottom: 4 })
                  Text(this.isPrivacyVisible ? '隐私可见' : '隐私隐藏')
                    .fontSize(14)
                    .fontColor(this.isPrivacyVisible ? 'rgba(255,255,255,0.7)' : 'rgba(255,107,107,0.8)')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Toggle({ type: ToggleType.Switch, isOn: !this.isPrivacyVisible })
                  .selectedColor('#4CAF50')
                  .switchPointColor('#fff')
                  .onChange((isOn: boolean) => {
                    this.togglePrivacy();
                  })
              }
              .width('100%')
              .padding(20)
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(16)
            }
            .width('90%')
            .margin({ bottom: 40 })
          }
          .width('100%')
          .padding({ top: 10 })
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
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
            Image(this.userAvatar)
              .width(300)
              .height(300)
              .borderRadius(150)
              .border({ width: 6, color: 'rgba(255,255,255,0.3)' })
              .objectFit(ImageFit.Cover)
              .margin({ bottom: 20 })

            // 操作按钮
            Row() {
              Button('生成新头像')
                .width(120)
                .height(44)
                .backgroundColor('rgba(255,255,255,0.2)')
                .fontColor('#fff')
                .borderRadius(22)
                .onClick(() => {
                  this.closeAvatarViewer();
                  setTimeout(() => {
                    this.generatePreviewAvatar();
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

      // 个性签名编辑弹窗
      if (this.showSignatureDialog) {
        Stack({ alignContent: Alignment.Center }) {
          // 半透明背景
          Column() {
            Blank()
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .opacity(0.6)
              .onClick(() => this.cancelEditSignature())
          }
          .width('100%')
          .height('100%')

          // 弹窗内容
          Column() {
            // 标题
            Text('编辑个性签名')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .margin({ bottom: 20 })

            // 输入框
            TextInput({
              text: this.tempSignature,
              placeholder: '请输入个性签名...'
            })
              .width('100%')
              .height(120)
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(12)
              .padding(16)
              .fontSize(16)
              .fontColor('#fff')
              .placeholderColor('rgba(255,255,255,0.5)')
              .textAlign(TextAlign.Start)
              .onChange((value: string) => {
                this.tempSignature = value;
              })
              .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
                this.confirmEditSignature();
              })

            // 按钮区域
            Row() {
              Button('取消')
                .width(100)
                .height(44)
                .backgroundColor('rgba(255,255,255,0.1)')
                .fontColor('#fff')
                .borderRadius(22)
                .onClick(() => this.cancelEditSignature())

              Button('确定')
                .width(100)
                .height(44)
                .backgroundColor('rgba(255,255,255,0.2)')
                .fontColor('#fff')
                .borderRadius(22)
                .margin({ left: 20 })
                .onClick(() => this.confirmEditSignature())
            }
            .margin({ top: 20 })
            .justifyContent(FlexAlign.Center)
          }
          .width('85%')
          .padding(24)
          .backgroundColor('rgba(0,0,0,0.8)')
          .borderRadius(20)
          .backdropBlur(20)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(999)
      }

      // 名称编辑弹窗
      if (this.showNameDialog) {
        Stack({ alignContent: Alignment.Center }) {
          // 半透明背景
          Column() {
            Blank()
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .opacity(0.6)
              .onClick(() => this.cancelEditName())
          }
          .width('100%')
          .height('100%')

          // 弹窗内容
          Column() {
            // 标题
            Text('编辑用户名称')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .margin({ bottom: 20 })

            // 输入框
            TextInput({
              text: this.tempName,
              placeholder: '请输入用户名称...'
            })
              .width('100%')
              .height(50)
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(12)
              .padding(16)
              .fontSize(16)
              .fontColor('#fff')
              .placeholderColor('rgba(255,255,255,0.5)')
              .textAlign(TextAlign.Start)
              .onChange((value: string) => {
                this.tempName = value;
              })
              .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
                this.confirmEditName();
              })

            // 按钮区域
            Row() {
              Button('取消')
                .width(100)
                .height(44)
                .backgroundColor('rgba(255,255,255,0.1)')
                .fontColor('#fff')
                .borderRadius(22)
                .onClick(() => this.cancelEditName())

              Button('确定')
                .width(100)
                .height(44)
                .backgroundColor('rgba(255,255,255,0.2)')
                .fontColor('#fff')
                .borderRadius(22)
                .margin({ left: 20 })
                .onClick(() => this.confirmEditName())
            }
            .margin({ top: 20 })
            .justifyContent(FlexAlign.Center)
          }
          .width('85%')
          .padding(24)
          .backgroundColor('rgba(0,0,0,0.8)')
          .borderRadius(20)
          .backdropBlur(20)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(999)
      }

      // 性别选择弹窗
      if (this.showGenderDialog) {
        Stack({ alignContent: Alignment.Center }) {
          // 半透明背景
          Column() {
            Blank()
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .opacity(0.6)
              .onClick(() => this.cancelEditGender())
          }
          .width('100%')
          .height('100%')

          // 弹窗内容
          Column() {
            // 标题
            Text('选择性别')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .margin({ bottom: 20 })

            // 性别选项
            Column({ space: 12 }) {
              // 男
              Row() {
                Text('男')
                  .fontSize(16)
                  .fontColor(this.tempGender === '男' ? '#fff' : 'rgba(255,255,255,0.7)')
                  .fontWeight(this.tempGender === '男' ? FontWeight.Bold : FontWeight.Normal)

                if (this.tempGender === '男') {
                  Image($r('app.media.selectNext'))
                    .width(20)
                    .height(20)
                    .fillColor('#fff')
                    .margin({ left: 'auto' })
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor(this.tempGender === '男' ? 'rgba(255,255,255,0.2)' : 'rgba(255,255,255,0.1)')
              .borderRadius(12)
              .onClick(() => {
                this.tempGender = '男';
              })

              // 女
              Row() {
                Text('女')
                  .fontSize(16)
                  .fontColor(this.tempGender === '女' ? '#fff' : 'rgba(255,255,255,0.7)')
                  .fontWeight(this.tempGender === '女' ? FontWeight.Bold : FontWeight.Normal)

                if (this.tempGender === '女') {
                  Image($r('app.media.selectNext'))
                    .width(20)
                    .height(20)
                    .fillColor('#fff')
                    .margin({ left: 'auto' })
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor(this.tempGender === '女' ? 'rgba(255,255,255,0.2)' : 'rgba(255,255,255,0.1)')
              .borderRadius(12)
              .onClick(() => {
                this.tempGender = '女';
              })

              // 其他
              Row() {
                Text('其他')
                  .fontSize(16)
                  .fontColor(this.tempGender === '其他' ? '#fff' : 'rgba(255,255,255,0.7)')
                  .fontWeight(this.tempGender === '其他' ? FontWeight.Bold : FontWeight.Normal)

                if (this.tempGender === '其他') {
                  Image($r('app.media.selectNext'))
                    .width(20)
                    .height(20)
                    .fillColor('#fff')
                    .margin({ left: 'auto' })
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor(this.tempGender === '其他' ? 'rgba(255,255,255,0.2)' : 'rgba(255,255,255,0.1)')
              .borderRadius(12)
              .onClick(() => {
                this.tempGender = '其他';
              })
            }
            .margin({ bottom: 20 })

            // 按钮区域
            Row() {
              Button('取消')
                .width(100)
                .height(44)
                .backgroundColor('rgba(255,255,255,0.1)')
                .fontColor('#fff')
                .borderRadius(22)
                .onClick(() => this.cancelEditGender())

              Button('确定')
                .width(100)
                .height(44)
                .backgroundColor('rgba(255,255,255,0.2)')
                .fontColor('#fff')
                .borderRadius(22)
                .margin({ left: 20 })
                .onClick(() => this.confirmEditGender())
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('85%')
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

      // 头像预览弹窗 - 重写的预览对话框
      if (this.showPreviewDialog) {
        Stack({ alignContent: Alignment.Center }) {
          // 半透明背景
          Column() {
            Blank()
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .opacity(0.6)
              .onClick(() => this.cancelPreviewAvatar())
          }
          .width('100%')
          .height('100%')

          // 弹窗内容
          Column() {
            // 标题
            Text('预览新头像')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .margin({ bottom: 20 })

            // 预览头像显示区域
            Stack() {
              if (this.previewImage) {
                Image(this.previewImage)
                  .width(200)
                  .height(200)
                  .borderRadius(100)
                  .border({ width: 4, color: 'rgba(255,255,255,0.3)' })
                  .objectFit(ImageFit.Cover)
              } else {
                Column() {
                  LoadingProgress().width(50).height(50)
                  Text('正在生成预览...').fontSize(16).fontColor('#fff').margin({ top: 10 })
                }
                .width(200)
                .height(200)
                .justifyContent(FlexAlign.Center)
              }
            }
            .margin({ bottom: 20 })

            // 提示文字
            Text('这是您的新头像预览，确认后将保存到您的账户')
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.7)')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 20 })

            // 按钮区域
            Row() {
              Button('重新生成')
                .width(100)
                .height(44)
                .backgroundColor('rgba(255,255,255,0.1)')
                .fontColor('#fff')
                .borderRadius(22)
                .onClick(() => {
                  this.showPreviewDialog = false;
                  setTimeout(() => {
                    this.generatePreviewAvatar();
                  }, 300);
                })

              Button('确认使用')
                .width(100)
                .height(44)
                .backgroundColor('rgba(255,255,255,0.2)')
                .fontColor('#fff')
                .borderRadius(22)
                .margin({ left: 20 })
                .onClick(() => this.confirmPreviewAvatar())
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('85%')
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
  }
} 