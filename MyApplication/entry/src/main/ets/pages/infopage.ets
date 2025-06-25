// infopage.ets
// 导入页面路由模块
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import { globalUserData } from '../models/userdata';

@Entry
@Component
struct InfoPage {
  @State userAvatar: Resource = $r("app.media.image"); // 用户头像
  @State userName: string = globalUserData.userName; // 用户名称
  @State userUID: string = globalUserData.userUID; // 用户UID
  @State isPrivacyVisible: boolean = globalUserData.isPrivacyVisible; // 用户隐私是否可见
  @State showNameDialog: boolean = false; // 显示名称编辑对话框
  @State tempName: string = ''; // 临时存储编辑的名称

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
        // 这里可以处理选中的图片，暂时使用默认图片
        this.userAvatar = $r("app.media.image");
        globalUserData.updateUserAvatar('new_avatar_path');
        promptAction.showToast({ message: '头像更新成功' });
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
  confirmEditName() {
    if (this.tempName.trim() !== '') {
      this.userName = this.tempName.trim();
      globalUserData.updateUserName(this.userName);
      promptAction.showToast({ message: '用户名称更新成功' });
    }
    this.showNameDialog = false;
  }

  // 取消编辑用户名称
  cancelEditName() {
    this.showNameDialog = false;
  }

  // 切换隐私可见性
  togglePrivacy() {
    this.isPrivacyVisible = !this.isPrivacyVisible;
    globalUserData.togglePrivacy();
    promptAction.showToast({ 
      message: this.isPrivacyVisible ? '隐私已隐藏' : '隐私已可见' 
    });
  }
  build() {
    Stack() {
      Column() {
        // 页面标题
        Row() {
          Text('个人信息')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 20 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 20 })
        .justifyContent(FlexAlign.Start)

        // 用户信息列表
        List() {
          // 头像项
          ListItem() {
            Row() {
              Text('头像')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .width('30%')
              
              Image(this.userAvatar)
                .width(60)
                .height(60)
                .borderRadius(30)
                .margin({ left: 20 })
              
              Text('点击修改')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 'auto' })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 15, bottom: 15 })
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .onClick(() => this.selectAvatar())
          }

          // 用户名称项
          ListItem() {
            Row() {
              Text('用户名称')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .width('30%')
              
              Text(this.userName)
                .fontSize(16)
                .fontColor('#333333')
                .margin({ left: 20 })
              
              Text('点击修改')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 'auto' })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 15, bottom: 15 })
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .onClick(() => this.editUserName())
          }

          // 隐私可见性项
          ListItem() {
            Row() {
              Text('隐私可见性')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .width('30%')
              
              Text(this.isPrivacyVisible ? '隐藏' : '可见')
                .fontSize(16)
                .fontColor(this.isPrivacyVisible ? '#FF4D4F' : '#52C41A')
                .margin({ left: 20 })
              
              Toggle({ type: ToggleType.Switch, isOn: !this.isPrivacyVisible })
                .margin({ left: 'auto' })
                .onChange((isOn: boolean) => {
                  this.isPrivacyVisible = !isOn;
                  globalUserData.togglePrivacy();
                })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 15, bottom: 15 })
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .onClick(() => this.togglePrivacy())
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .margin({ top: 20 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 用户名称编辑对话框
      if (this.showNameDialog) {
        Column() {
          Column() {
            Text('编辑用户名称')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 20 })
            
            TextInput({ placeholder: '请输入用户名称', text: this.tempName })
              .width('100%')
              .height(50)
              .margin({ bottom: 20 })
              .onChange((value: string) => {
                this.tempName = value;
              })
            
            Row() {
              Button('取消')
                .width(100)
                .height(40)
                .backgroundColor('#F5F5F5')
                .fontColor('#666666')
                .onClick(() => this.cancelEditName())
              
              Button('确定')
                .width(100)
                .height(40)
                .margin({ left: 20 })
                .backgroundColor('#007DFF')
                .onClick(() => this.confirmEditName())
            }
          }
          .width('80%')
          .padding(30)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
      }
    }
  }
} 