// infopage.ets
// 导入页面路由模块
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { UserInfo } from '../common/types';
import { BottomNavBar } from './BottomNavBar';

@Entry
@Component
export struct InfoPage {
  @State userAvatar: Resource = $r("app.media.image"); // 用户头像
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
  @State userInfo: UserInfo | null = null; // 用户信息
  @State avatarScale: number = 1.0; // 头像缩放动画

  // 页面生命周期
  aboutToAppear() {
    this.loadUserInfo();
  }

  // 加载用户信息
  async loadUserInfo() {
    try {
      this.isLoading = true;
      const userInfo = await ApiService.getUserInfo(this.userUID);
      this.userInfo = userInfo;
      this.userName = userInfo.userName;
      this.userUID = userInfo.userUID;
      this.isPrivacyVisible = userInfo.isPrivacyVisible;
      // 如果有头像URL，更新头像显示
      if (userInfo.userAvatar && userInfo.userAvatar !== '/avatars/default.png') {
        // 注意：这里需要处理字符串到Resource的转换
        // 暂时保持使用默认图片，实际项目中需要根据URL加载图片
        this.userAvatar = $r("app.media.image");
      }
    } catch (error) {
      console.error('加载用户信息失败:', error);
      promptAction.showToast({ message: '加载用户信息失败' });
    } finally {
      this.isLoading = false;
    }
  }

  // 头像选择器
  async selectAvatar() {
    try {
      let photoPicker = new picker.PhotoViewPicker();
      let photoSelectOptions: picker.PhotoSelectOptions = {
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      };
      let photoViewPicker = await photoPicker.select(photoSelectOptions);
      if (photoViewPicker && photoViewPicker.photoUris && photoViewPicker.photoUris.length > 0) {
        // 这里应该上传到后端，暂时使用默认图片
        this.userAvatar = $r("app.media.image");
        promptAction.showToast({ message: '头像更新成功' });

        // 更新后端用户信息
        await ApiService.updateUserInfo(this.userUID, {
          userAvatar: this.userAvatar.toString()
        });
      }
    } catch (error) {
      console.error('选择头像失败:', error);
      promptAction.showToast({ message: '选择头像失败' });
    }
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

            // 头像卡片
            Column() {
              Stack({ alignContent: Alignment.BottomEnd }) {
                Image(this.userAvatar)
                  .width(120)
                  .height(120)
                  .borderRadius(60)
                  .border({ width: 3, color: 'rgba(255,255,255,0.3)' })
                  .scale({ x: this.avatarScale, y: this.avatarScale })
                  .animation({
                    duration: 120,
                    curve: Curve.EaseInOut
                  })

                // 相机图标
                Image($r('app.media.camera'))
                  .width(32)
                  .height(32)
                  .backgroundColor('rgba(255,255,255,0.9)')
                  .borderRadius(16)
                  .border({ width: 2, color: '#fff' })
                  .margin({ right: 8, bottom: 8 })
              }
              .width(120)
              .height(120)
            }
            .width('90%')
            .padding(24)
            .backgroundColor('rgba(255,255,255,0.1)')
            .borderRadius(20)
            .margin({ bottom: 20 })
            .onClick(() => {
              this.avatarScale = 0.95;
              setTimeout(() => {
                this.avatarScale = 1.0;
                this.selectAvatar();
              }, 120);
            })

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
    }
  }
} 