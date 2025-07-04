import http from '@ohos.net.http';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
@Entry
@Component
struct EmailConfirmPage {
  @State email: string = ''
  @State code: string = ''
  @State agree: boolean = false
  @State canSendCode: boolean = true
  @State countdown: number = 0

  sendEmailCode() {
    if (!this.canSendCode) {
      return;
    }
    
    let httpRequest = http.createHttp();
    httpRequest.request(
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
    ).then((response) => {
      if (response.responseCode === 200) {
        promptAction.showToast({ message: response.result.toString() });
        // 开始倒计时
        this.canSendCode = false;
        this.countdown = 60;
        this.startCountdown();
      } else {
        promptAction.showToast({ message: '发送失败: ' + response.result.toString() });
      }
    }).catch((err:Error) => {
      promptAction.showToast({ message: '请求异常: ' + JSON.stringify(err) });
    });
  }

  startCountdown() {
    if (this.countdown > 0) {
      setTimeout(() => {
        this.countdown--;
        this.startCountdown();
      }, 1000);
    } else {
      this.canSendCode = true;
    }
  }

  verifyEmailCode() {
    // 检查用户是否勾选协议
    if (!this.agree) {
      promptAction.showToast({ message: '请先阅读并同意用户协议和隐私政策' });
      return;
    }
    
    let httpRequest = http.createHttp();
    httpRequest.request(
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
    ).then((response) => {
      promptAction.showToast({ message: JSON.stringify(response) });
      if (response.responseCode === 200) {
        promptAction.showToast({ message: response.result.toString() });
        // 跳转到主页面
        router.push({ url: 'pages/BottomNavBar' });
      } else {
        promptAction.showToast({ message: '验证失败: ' + response.result.toString() });
      }
    }).catch((err:Error) => {
      promptAction.showToast({ message: '请求异常: ' + JSON.stringify(err) });
    });
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
        Button(this.canSendCode ? '获取验证码' : `${this.countdown}s`)
          .width(120)
          .height(44)
          .fontSize(16)
          .fontColor(this.canSendCode ? '#121114' : '#666')
          .backgroundColor(this.canSendCode ? '#ffda7f' : '#333')
          .borderRadius(22)
          .margin({ left: 10 })
          .enabled(this.canSendCode)
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