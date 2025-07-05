// infopage.ets
// 导入页面路由模块
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import { globalUserData } from '../models/userdata';
import { ApiService } from '../service/apiservice';
import { UserInfo } from '../common/types';
import { BottomNavBar } from './BottomNavBar';
import { Config } from '../common/config';

interface AvatarResponse {
  data?: string;
}

@Entry
@Component
export struct InfoPage {
  @State userAvatar: Resource | string = $r("app.media.image"); // 用户头像
  @State selectedImageUri: string = ''; // 选择的图片URI
  @State selectedImageName: string = '';
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
      const userInfo = await ApiService.getUserInfo(this.userUID);
      this.userInfo = userInfo;
      this.userName = userInfo.userName;
      this.isPrivacyVisible = userInfo.isPrivacyVisible;

      // 处理头像显示
      if (userInfo.userAvatar && userInfo.userAvatar !== '/avatars/default.png') {
        // 如果有后端头像，使用后端头像
        this.userAvatar = userInfo.userAvatar;
        this.selectedImageUri = ''; // 清空本地选择的图片
      } else {
        // 使用默认头像
        this.userAvatar = $r("app.media.image");
        this.selectedImageUri = ''; // 清空本地选择的图片
      }
    } catch (error) {
      console.error('加载用户信息失败:', error);
      // 不显示错误提示，避免影响用户体验
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
        this.selectedImageUri = photoViewPicker.photoUris[0];
        this.selectedImageName = this.selectedImageUri.split('/').pop() || 'avatar.jpg';
        promptAction.showToast({ message: '已选择头像' });
      }
    } catch (error) {
      promptAction.showToast({ message: '选择头像失败' });
    }
  }

  // 头像上传（Base64方式）
  async uploadAvatar() {
    if (!this.selectedImageUri) {
      promptAction.showToast({ message: '请先选择头像' });
      return;
    }
    try {
      this.isLoading = true;
      // 读取图片并转为Base64
      const base64Data = await this.uriToBase64(this.selectedImageUri);
      const result = await ApiService.uploadAvatarBase64(this.userUID, base64Data);
      // 解析后端返回的新头像URL
      let avatarUrl: string = '';
      try {
        const resObj: AvatarResponse = typeof result === 'string' ? JSON.parse(result) : result;
        avatarUrl = resObj?.data || '';
      } catch (e) {
        avatarUrl = '';
      }
      // 如果是相对路径，拼接服务器地址
      if (avatarUrl && avatarUrl.startsWith('/')) {
        avatarUrl = Config.getApiBaseUrl().replace(/\/$/, '') + avatarUrl;
      }
      if (avatarUrl) {
        this.userAvatar = avatarUrl;
      }
      promptAction.showToast({ message: '头像上传成功' });
      this.selectedImageUri = '';
      this.selectedImageName = '';
      this.loadUserInfoAsync();
    } catch (error) {
      console.error('[头像上传Base64] error:', error);
      promptAction.showToast({ message: '头像上传失败' });
    } finally {
      this.isLoading = false;
    }
  }

  // 将图片URI转换为base64格式
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

  // 测试本地图片处理功能
  async testLocalImageProcessing() {
    try {
      console.log('开始测试本地图片处理...');

      // 创建一个测试图片URI（这里使用一个示例URI）
      const testUri = 'file:///data/storage/el2/base/haps/entry/files/test.jpg';

      // 测试图片转换
      const base64Data = await this.uriToBase64(testUri);
      if (base64Data) {
        console.log('测试图片转换成功，大小:', base64Data.length, '字符');
        promptAction.showToast({ message: '本地图片处理测试成功' });
      } else {
        console.log('测试图片转换失败');
        promptAction.showToast({ message: '本地图片处理测试失败' });
      }
    } catch (error) {
      console.error('测试本地图片处理失败:', error);
      promptAction.showToast({ message: '测试失败: ' + (error instanceof Error ? error.message : '未知错误') });
    }
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
                // 根据是否有选择的图片来决定显示方式
                if (this.selectedImageUri) {
                  // 显示本地选择的图片
                  Image(this.selectedImageUri)
                    .width(120)
                    .height(120)
                    .borderRadius(60)
                    .border({ width: 3, color: 'rgba(255,255,255,0.3)' })
                    .scale({ x: this.avatarScale, y: this.avatarScale })
                    .animation({
                      duration: 120,
                      curve: Curve.EaseInOut
                    })
                } else {
                  // 显示默认头像或后端头像
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
                }
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
              // 点击头像选择新图片
              .onClick(() => {
                this.avatarScale = 0.95;
                setTimeout(() => {
                  this.avatarScale = 1.0;
                  this.selectAvatar();
                }, 120);
              })
              // 新增：头像下方显示"保存头像"按钮
              if (this.selectedImageUri) {
                Button('保存头像')
                  .width(120)
                  .height(36)
                  .fontSize(16)
                  .fontColor('#fff')
                  .backgroundColor('#2980B9')
                  .borderRadius(18)
                  .margin({ top: 12 })
                  .onClick(() => {
                    this.uploadAvatar();
                  })
              }
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