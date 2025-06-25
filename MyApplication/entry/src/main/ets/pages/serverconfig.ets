// serverconfig.ets
// 服务器配置测试页面
import { ApiService } from '../service/apiservice';
import { Config } from '../common/config';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct ServerConfigPage {
  @State serverStatus: string = '未知';
  @State isTesting: boolean = false;
  @State currentConfig: string = '';

  aboutToAppear() {
    this.currentConfig = ApiService.getEnvironmentInfo();
  }

  // 测试服务器连接
  async testServerConnection() {
    try {
      this.isTesting = true;
      this.serverStatus = '测试中...';
      
      const isHealthy = await ApiService.healthCheck();
      
      if (isHealthy) {
        this.serverStatus = '连接成功 ✅';
        promptAction.showToast({ message: '服务器连接正常' });
      } else {
        this.serverStatus = '连接失败 ❌';
        promptAction.showToast({ message: '服务器连接失败' });
      }
    } catch (error) {
      console.error('服务器连接测试失败:', error);
      this.serverStatus = '连接失败 ❌';
      promptAction.showToast({ message: '服务器连接失败: ' + error.message });
    } finally {
      this.isTesting = false;
    }
  }

  // 测试用户API
  async testUserAPI() {
    try {
      this.isTesting = true;
      promptAction.showToast({ message: '测试用户API...' });
      
      const userInfo = await ApiService.getUserInfo('100000000');
      promptAction.showToast({ message: `用户信息获取成功: ${userInfo.userName}` });
    } catch (error) {
      console.error('用户API测试失败:', error);
      promptAction.showToast({ message: '用户API测试失败: ' + error.message });
    } finally {
      this.isTesting = false;
    }
  }

  build() {
    Column() {
      // 标题
      Text('服务器配置')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 30 })

      // 当前配置信息
      Column() {
        Text('当前配置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 10 })
        
        Text(this.currentConfig)
          .fontSize(14)
          .fontColor('#666')
          .textAlign(TextAlign.Center)
          .backgroundColor('#F5F5F5')
          .padding(10)
          .borderRadius(8)
      }
      .width('90%')
      .margin({ bottom: 30 })

      // 服务器状态
      Column() {
        Text('服务器状态')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 10 })
        
        Text(this.serverStatus)
          .fontSize(16)
          .fontColor(this.serverStatus.includes('成功') ? '#52C41A' : '#FF4D4F')
          .backgroundColor('#F5F5F5')
          .padding(10)
          .borderRadius(8)
      }
      .width('90%')
      .margin({ bottom: 30 })

      // 测试按钮
      Column() {
        Button('测试服务器连接')
          .width(200)
          .height(40)
          .backgroundColor('#1890FF')
          .fontColor('#FFFFFF')
          .margin({ bottom: 15 })
          .onClick(() => this.testServerConnection())
          .enabled(!this.isTesting)

        Button('测试用户API')
          .width(200)
          .height(40)
          .backgroundColor('#52C41A')
          .fontColor('#FFFFFF')
          .margin({ bottom: 15 })
          .onClick(() => this.testUserAPI())
          .enabled(!this.isTesting)

        Button('返回主页')
          .width(200)
          .height(40)
          .backgroundColor('#666666')
          .fontColor('#FFFFFF')
          .onClick(() => {
            let uiContext: UIContext = this.getUIContext();
            let router = uiContext.getRouter();
            router.back();
          })
      }
      .width('100%')

      // 配置说明
      Column() {
        Text('配置说明')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 30, bottom: 10 })
        
        Text('1. 修改 config.ets 中的 CURRENT_ENV 切换环境')
          .fontSize(12)
          .fontColor('#666')
          .margin({ bottom: 5 })
        
        Text('2. 修改对应环境的 API_BASE_URL')
          .fontSize(12)
          .fontColor('#666')
          .margin({ bottom: 5 })
        
        Text('3. 确保后端服务正在运行')
          .fontSize(12)
          .fontColor('#666')
          .margin({ bottom: 5 })
        
        Text('4. 检查网络连接和防火墙设置')
          .fontSize(12)
          .fontColor('#666')
      }
      .width('90%')
      .margin({ top: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .padding(20)
  }
} 