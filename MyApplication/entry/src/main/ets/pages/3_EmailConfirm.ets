import http from '@ohos.net.http';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ApiService } from '../service/apiservice';
import { setUserId } from '../common/constants';
@Entry
@Component
struct EmailConfirmPage {
  @State email: string = ''
  @State code: string = ''
  @State agree: boolean = false

  async sendEmailCode() {
    // 检查邮箱是否为空
    if (!this.email) {
      promptAction.showToast({ message: '请先输入邮箱地址' });
      return;
    }

    try {
      let httpRequest = http.createHttp();
      const response = await httpRequest.request(
        'http://121.36.225.8:8081/auth/send-code',
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            email: this.email
          }
        }
      );

      if (response.responseCode === 200) {
        promptAction.showToast({ message: '验证码已发送到您的邮箱' });
      } else {
        promptAction.showToast({ message: '发送失败: ' + response.result.toString() });
      }
    } catch (err) {
      console.error('发送验证码异常:', err);
      promptAction.showToast({ message: '发送验证码失败，请重试' });
    }
  }

  async verifyEmailCode() {
    // 检查是否同意用户协议
    if (!this.agree) {
      promptAction.showToast({ message: '请先同意用户协议和隐私政策' });
      return;
    }

    // 检查邮箱和验证码是否为空
    if (!this.email || !this.code) {
      promptAction.showToast({ message: '请填写完整的邮箱和验证码' });
      return;
    }

    try {
      // 先验证邮箱验证码
      let httpRequest = http.createHttp();
      const response = await httpRequest.request(
        'http://121.36.225.8:8081/auth/verify-code',
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            email: this.email,
            verificationCode: this.code
          }
        }
      );

      if (response.responseCode === 200) {
        promptAction.showToast({ message: '验证码验证成功' });
        
        // 验证成功后，调用 createOrLoginUserByEmail 函数
        try {
          const userInfo = await ApiService.createOrLoginUserByEmail(this.email);
          console.log('用户创建或登录成功:', userInfo);
          
          // 直接从 userInfo 中获取用户ID
          if (userInfo.id) {
            console.log('从用户信息中获取到用户ID:', userInfo.id);
            setUserId(userInfo.id);
            console.log('用户ID已保存到常量中:', userInfo.id);
          } else {
            console.warn('用户信息中没有ID字段，尝试通过邮箱获取...');
            
            // 如果 userInfo 中没有 ID，则通过邮箱获取
            try {
              const userId = await ApiService.getUserIdByEmail(this.email);
              console.log('通过邮箱获取到用户ID:', userId);
              setUserId(userId);
              console.log('用户ID已保存到常量中:', userId);
            } catch (userIdError) {
              console.error('通过邮箱获取用户ID失败:', userIdError);
              console.error('错误详情:', JSON.stringify(userIdError));
              promptAction.showToast({ message: '登录成功，但获取用户ID失败，部分功能可能受限' });
            }
          }
          
          promptAction.showToast({ message: '登录成功，欢迎回来！' });
          
          // 跳转到主页面
          router.pushUrl({ url: 'pages/BottomNavBar' });
        } catch (userError) {
          console.error('用户创建或登录失败:', userError);
          console.error('错误详情:', JSON.stringify(userError));
          promptAction.showToast({ message: '用户登录失败，请重试' });
        }
      } else {
        promptAction.showToast({ message: '验证码验证失败: ' + response.result.toString() });
      }
    } catch (err) {
      console.error('验证码验证异常:', err);
      promptAction.showToast({ message: '验证码验证异常，请重试' });
    }
  }

  build() {
    Column() {
      // 顶部返回按钮
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
        Blank()
      }
      .width('100%')
      .padding({ left: 24, top: 20 })
      .margin({ bottom: 40 })

      // 标题
      Text('欢迎登录心屿')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 24 })
        .margin({ bottom: 8 })

      // 副标题
      Text('未注册的邮箱验证通过后自动注册')
        .fontSize(16)
        .fontColor('#888')
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 24 })
        .margin({ bottom: 40 })

      // 邮箱输入框
      TextInput({ placeholder: '请输入QQ邮箱' })
        .placeholderColor('#6e6e6e')
        .type(InputType.Email)
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor('#202021')
        .borderRadius(8)
        .width('90%')
        .height(56)
        .padding({ left: 15, right: 15 })
        .margin({ bottom: 20 })
        .onChange((value: string) => {
          this.email = value;
        })

      // 验证码输入框和获取验证码按钮
      Row() {
        TextInput({ placeholder: '请输入验证码' })
          .placeholderColor('#6e6e6e')
          .type(InputType.Number)
          .fontSize(18)
          .fontColor(Color.White)
          .backgroundColor('#202021')
          .borderRadius(8)
          .layoutWeight(1)
          .height(56)
          .padding({ left: 15 })
          .onChange((value: string) => {
            this.code = value;
          })
        Button('获取验证码')
          .width(120)
          .height(44)
          .fontSize(16)
          .fontColor('#121114')
          .backgroundColor('#ffda7f')
          .borderRadius(22)
          .margin({ left: 10 })
          .onClick(() => {
            this.sendEmailCode();
          })
      }
      .width('90%')
      .margin({ bottom: 40 })

      // 确认登录按钮
      Button('确认登录')
        .width('90%')
        .height(50)
        .fontSize(20)
        .fontColor('#121114')
        .backgroundColor('#ffda7f')
        .borderRadius(25)
        .margin({ bottom: 20 })
        .onClick(() => {
          this.verifyEmailCode();
        })

      // 用户协议勾选框
      Row() {
        Checkbox()
          .selectedColor('#ffda7f')
          .foregroundColor(Color.Black)
          .mark({
            strokeColor:Color.Black,
            size: 50
          })
          .select(this.agree)
          .onChange((value: boolean) => {
            this.agree = value;
          })
          .margin({ right: 8 })
        Text('已阅读并同意')
          .fontSize(14)
          .fontColor('#6e6e6e')
        Text('《用户协议》')
          .fontSize(14)
          .fontColor(Color.White)
          .onClick(() => {
            // 跳转到用户协议页面
          })
        Text('《隐私政策》')
          .fontSize(14)
          .fontColor(Color.White)
          .onClick(() => {
            // 跳转到隐私政策页面
          })
      }
      .width('90%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#121114')
    .justifyContent(FlexAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    .alignItems(HorizontalAlign.Center)
  }
} 