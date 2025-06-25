import router from '@ohos.router';

@Entry
@Component
struct EmailConfirmPage {
  @State email: string = ''
  @State code: string = ''
  @State agree: boolean = false

  build() {
    Column() {
      // 顶部返回按钮
      Row() {
        Image($r('app.media.return')) // 请替换为你的返回图标资源
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
        .fontColor(Color.Black)
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
        .type(InputType.Email)
        .fontSize(18)
        .fontColor(Color.Black)
        .backgroundColor('#F5F5F5')
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
          .type(InputType.Number)
          .fontSize(18)
          .fontColor(Color.Black)
          .backgroundColor('#F5F5F5')
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
          .fontColor('#fff')
          .backgroundColor('#14DCA0')
          .borderRadius(22)
          .margin({ left: 10 })
          .onClick(() => {
            // 这里调用后端发送验证码接口
            console.log('获取验证码');
          })
      }
      .width('90%')
      .margin({ bottom: 40 })

      // 确认登录按钮
      Button('确认登录')
        .width('90%')
        .height(50)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor('#14DCA0')
        .borderRadius(25)
        .margin({ bottom: 20 })
        .onClick(() => {
          // 登录逻辑
          console.log('确认登录');
        })

      // 用户协议勾选框
      Row() {
        Checkbox()
          .select(this.agree)
          .onChange((value: boolean) => {
            this.agree = value;
          })
          .margin({ right: 8 })
        Text('已阅读并同意')
          .fontSize(14)
          .fontColor('#888')
        Text('《用户协议》')
          .fontSize(14)
          .fontColor('#14DCA0')
          .onClick(() => {
            // 跳转到用户协议页面
          })
        Text('《隐私政策》')
          .fontSize(14)
          .fontColor('#14DCA0')
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
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
} 