// infopage.ets
// 导入页面路由模块
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { OSSService } from '../service/ossService';
import { UserInfo } from '../common/types';
import { Config } from '../common/config';
import { BottomNavBar } from './BottomNavBar';

@Entry
@Component
export struct InfoPage {
  @State userAvatar: string = ''; // 用户头像 - 改为简单字符串类型
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
  @State imgDatas: string[] = []; // 选择的图片数据

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
    // 只用OSS返回的URL，不做任何拼接
    if (avatarUrl && avatarUrl !== '') {
      // 强制UI刷新：先清空再设置
      this.userAvatar = '';
      await this.sleep(100); // 短暂延迟
      this.userAvatar = avatarUrl;
      console.log('🖼️ [infopage] 头像更新成功:', avatarUrl);
    } else {
      this.userAvatar = '';
      console.log('🖼️ [infopage] 头像为空');
    }
  }

  // 简单的延迟函数
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // 获取头像URL（用于显示）
  getAvatarUrl(): string {
    return this.userAvatar || '';
  }

  // 显示头像查看器
  showAvatarViewerDialog() {
    this.showAvatarViewer = true;
  }

  // 关闭头像查看器
  closeAvatarViewer() {
    this.showAvatarViewer = false;
  }

  // 获取相册图片 - 简化的图片选择方法
  getAllImg() {
    let photoPicker = new picker.PhotoViewPicker();
    let options = new picker.PhotoSelectOptions();
    options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = 1; // 只选择一张图片作为头像

    photoPicker.select(options).then((result) => {
      this.imgDatas = result.photoUris;
      console.info('选中的图片 URI: ' + JSON.stringify(result.photoUris));
      
      if (result.photoUris && result.photoUris.length > 0) {
        // 上传选中的图片
        this.uploadSelectedImage(result.photoUris[0]);
      }
    }).catch((err: BusinessError) => {
      console.error('📸 [infopage] 选择图片失败:', err.message);
      promptAction.showToast({ message: '选择图片失败，请重试' });
    });
  }

  // 上传选中的图片
  private async uploadSelectedImage(imageUri: string) {
    try {
      this.isAvatarLoading = true;
      promptAction.showToast({ message: '正在上传头像...' });

      console.log('☁️ [infopage] 开始上传到OSS...');
      const ossService = OSSService.getInstance();
      const ossUrl = await ossService.uploadImageViaBackend(imageUri, this.userUID);
      
      if (ossUrl) {
        console.log('☁️ [infopage] 后端原始返回URL:', ossUrl);
        console.log('☁️ [infopage] OSS上传成功');
        console.log('☁️ [infopage] OSS URL:', ossUrl);
        // 直接赋值头像
        this.userAvatar = ossUrl;
        // 可选：同步到后端用户信息
        await ApiService.updateUserInfo(this.userUID, { userAvatar: ossUrl });
        promptAction.showToast({ message: '头像上传成功' });
      } else {
        console.error('☁️ [infopage] OSS上传失败，返回URL为空');
        promptAction.showToast({ message: '头像上传失败' });
      }
    } catch (error) {
      console.error('☁️ [infopage] 上传图片到OSS失败:', error);
      promptAction.showToast({ message: '头像上传失败，请重试' });
    } finally {
      this.isAvatarLoading = false;
    }
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
                if (this.userAvatar && this.userAvatar !== '') {
                  Image(this.userAvatar)
                    .width(200)
                    .height(200)
                    .objectFit(ImageFit.Cover)
                } else {
                  // 空白头像占位符
                  Column() {
                    Text('无头像')
                      .fontSize(16)
                      .fontColor('rgba(255,255,255,0.5)')
                  }
                  .width(200)
                  .height(200)
                  .borderRadius(100)
                  .border({ width: 4, color: 'rgba(255,255,255,0.3)', style: BorderStyle.Dashed })
                  .backgroundColor('rgba(255,255,255,0.05)')
                  .justifyContent(FlexAlign.Center)
                }
              }
              .width(200)
              .height(200)
              .margin({ bottom: 20 })

              // 头像操作按钮
              Row() {
                Button('查看大图')
                  .width(80)
                  .height(40)
                  .backgroundColor('rgba(255,255,255,0.1)')
                  .fontColor('#fff')
                  .borderRadius(20)
                  .fontSize(12)
                  .onClick(() => this.showAvatarViewerDialog())

                Button('上传头像')
                  .width(80)
                  .height(40)
                  .backgroundColor('rgba(255,255,255,0.15)')
                  .fontColor('#fff')
                  .borderRadius(20)
                  .margin({ left: 10 })
                  .fontSize(12)
                  .onClick(() => this.getAllImg())

                Button('生成新头像')
                  .width(80)
                  .height(40)
                  .backgroundColor('rgba(255,255,255,0.2)')
                  .fontColor('#fff')
                  .borderRadius(20)
                  .margin({ left: 10 })
                  .fontSize(12)
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

          // 头像图片
          if (this.userAvatar && this.userAvatar !== '') {
            Image(this.userAvatar)
              .width('80%')
              .height('80%')
              .objectFit(ImageFit.Contain)
              .borderRadius(20)
          }

          // 关闭按钮
          Button() {
            Text('×')
              .fontSize(32)
              .fontColor('#fff')
          }
          .width(50)
          .height(50)
          .backgroundColor('rgba(255,255,255,0.2)')
          .borderRadius(25)
          .position({ x: '85%', y: '10%' })
          .onClick(() => this.closeAvatarViewer())
        }
        .width('100%')
        .height('100%')
      }

      // 预览对话框
      if (this.showPreviewDialog) {
        Stack({ alignContent: Alignment.Center }) {
          // 半透明背景
          Column() {
            Blank()
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .opacity(0.8)
              .onClick(() => this.cancelPreviewAvatar())
          }
          .width('100%')
          .height('100%')

          // 预览内容
          Column() {
            Text('预览头像')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .margin({ bottom: 20 })

            if (this.previewImage) {
              Image(this.previewImage)
                .width(200)
                .height(200)
                .objectFit(ImageFit.Cover)
                .borderRadius(20)
                .margin({ bottom: 20 })
            }

            Row() {
              Button('取消')
                .width(80)
                .height(40)
                .backgroundColor('rgba(255,255,255,0.2)')
                .fontColor('#fff')
                .borderRadius(20)
                .onClick(() => this.cancelPreviewAvatar())

              Button('确认')
                .width(80)
                .height(40)
                .backgroundColor('#4CAF50')
                .fontColor('#fff')
                .borderRadius(20)
                .margin({ left: 20 })
                .onClick(() => this.confirmPreviewAvatar())
            }
          }
          .width('90%')
          .padding(30)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(20)
          .backdropBlur(20)
        }
        .width('100%')
        .height('100%')
      }

      // 名称编辑对话框
      if (this.showNameDialog) {
        Stack({ alignContent: Alignment.Center }) {
          Column() {
            Blank()
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .opacity(0.8)
              .onClick(() => this.cancelEditName())
          }
          .width('100%')
          .height('100%')

          Column() {
            Text('编辑用户名称')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .margin({ bottom: 20 })

            TextInput({ text: this.tempName, placeholder: '请输入用户名称' })
              .width('100%')
              .height(50)
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(10)
              .fontColor('#fff')
              .placeholderColor('rgba(255,255,255,0.5)')
              .placeholderFont({ size: 16 })
              .onChange((value: string) => {
                this.tempName = value;
              })
              .margin({ bottom: 20 })

            Row() {
              Button('取消')
                .width(80)
                .height(40)
                .backgroundColor('rgba(255,255,255,0.2)')
                .fontColor('#fff')
                .borderRadius(20)
                .onClick(() => this.cancelEditName())

              Button('确认')
                .width(80)
                .height(40)
                .backgroundColor('#4CAF50')
                .fontColor('#fff')
                .borderRadius(20)
                .margin({ left: 20 })
                .onClick(() => this.confirmEditName())
            }
          }
          .width('90%')
          .padding(30)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(20)
          .backdropBlur(20)
        }
        .width('100%')
        .height('100%')
      }

      // 签名编辑对话框
      if (this.showSignatureDialog) {
        Stack({ alignContent: Alignment.Center }) {
          Column() {
            Blank()
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .opacity(0.8)
              .onClick(() => this.cancelEditSignature())
          }
          .width('100%')
          .height('100%')

          Column() {
            Text('编辑个性签名')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .margin({ bottom: 20 })

            TextArea({ text: this.tempSignature, placeholder: '请输入个性签名' })
              .width('100%')
              .height(100)
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(10)
              .fontColor('#fff')
              .placeholderColor('rgba(255,255,255,0.5)')
              .placeholderFont({ size: 16 })
              .onChange((value: string) => {
                this.tempSignature = value;
              })
              .margin({ bottom: 20 })

            Row() {
              Button('取消')
                .width(80)
                .height(40)
                .backgroundColor('rgba(255,255,255,0.2)')
                .fontColor('#fff')
                .borderRadius(20)
                .onClick(() => this.cancelEditSignature())

              Button('确认')
                .width(80)
                .height(40)
                .backgroundColor('#4CAF50')
                .fontColor('#fff')
                .borderRadius(20)
                .margin({ left: 20 })
                .onClick(() => this.confirmEditSignature())
            }
          }
          .width('90%')
          .padding(30)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(20)
          .backdropBlur(20)
        }
        .width('100%')
        .height('100%')
      }

      // 性别选择对话框
      if (this.showGenderDialog) {
        Stack({ alignContent: Alignment.Center }) {
          Column() {
            Blank()
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .opacity(0.8)
              .onClick(() => this.cancelEditGender())
          }
          .width('100%')
          .height('100%')

          Column() {
            Text('选择性别')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .margin({ bottom: 20 })

            Column({ space: 10 }) {
              Button('男')
                .width('100%')
                .height(50)
                .backgroundColor(this.tempGender === '男' ? '#4CAF50' : 'rgba(255,255,255,0.1)')
                .fontColor('#fff')
                .borderRadius(10)
                .onClick(() => {
                  this.tempGender = '男';
                })

              Button('女')
                .width('100%')
                .height(50)
                .backgroundColor(this.tempGender === '女' ? '#4CAF50' : 'rgba(255,255,255,0.1)')
                .fontColor('#fff')
                .borderRadius(10)
                .onClick(() => {
                  this.tempGender = '女';
                })

              Button('其他')
                .width('100%')
                .height(50)
                .backgroundColor(this.tempGender === '其他' ? '#4CAF50' : 'rgba(255,255,255,0.1)')
                .fontColor('#fff')
                .borderRadius(10)
                .onClick(() => {
                  this.tempGender = '其他';
                })
            }
            .margin({ bottom: 20 })

            Row() {
              Button('取消')
                .width(80)
                .height(40)
                .backgroundColor('rgba(255,255,255,0.2)')
                .fontColor('#fff')
                .borderRadius(20)
                .onClick(() => this.cancelEditGender())

              Button('确认')
                .width(80)
                .height(40)
                .backgroundColor('#4CAF50')
                .fontColor('#fff')
                .borderRadius(20)
                .margin({ left: 20 })
                .onClick(() => this.confirmEditGender())
            }
          }
          .width('90%')
          .padding(30)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(20)
          .backdropBlur(20)
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
} 