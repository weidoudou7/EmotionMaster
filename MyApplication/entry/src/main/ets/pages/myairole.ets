import { BusinessError } from '@kit.BasicServicesKit';
import { ApiService } from '../service/apiservice';
import { AiRole } from '../common/types';
import { getUserId } from '../common/constants';
import http from '@ohos.net.http'
import image from '@ohos.multimedia.image'
import { effectKit } from '@kit.ArkGraphics2D'

// 定义位置接口
interface Position {
  x: number;
  y: number;
}

@Entry
@Component
export struct MyAIRole {
  @State isLoading: boolean = false;
  @State aiRoles: AiRole[] = [];
  @State userAvatar: string = '';
  @State rotationAngle: number = 0; // 旋转角度
  @State isGathering: boolean = false; // 是否正在聚集
  @State isSpreading: boolean = false; // 是否正在扩散
  @State gatherProgress: number = 0; // 聚集进度 (0-1)
  @State spreadProgress: number = 0; // 扩散进度 (0-1)
  @State rolesOpacity: number = 1; // AI角色透明度 - 初始值设为1确保可见
  @State currentRoleIndex: number = 0; // 当前显示的角色组索引
  @State selectedRole: AiRole | null = null; // 当前选中的角色
  @State lastClickTime: number = 0; // 上次点击时间
  @State lastClickIndex: number = -1; // 上次点击的角色索引
  @State selectedIndex: number = -1; // 当前选中的角色索引
  @State hoverIndex: number = -1; // 当前悬停的角色索引
  @State currentRoleStartIndex: number = 0; // 当前显示的角色起始下标
  @State private arcRotation: number = 0
  @State private glowOpacity: number = 0.5
  @State private textOpacity: number = 0.8
  @State private lineScale: number = 1.0
  @State private mainColor: string = '#1a1a1a'
  @State private pixelMap: PixelMap | undefined = undefined

  // 预计算六个位置（圆形布局）
  private rolePositions: Position[] = [
    { x: 120, y: 0 },      // 0度 - 右侧
    { x: 60, y: 103.92 },  // 60度 - 右下
    { x: -60, y: 103.92 }, // 120度 - 左下
    { x: -120, y: 0 },     // 180度 - 左侧
    { x: -60, y: -103.92 }, // 240度 - 左上
    { x: 60, y: -103.92 }  // 300度 - 右上
  ];

  // 获取当前要显示的6个角色
  private getCurrentRoles(): AiRole[] {
    if (!this.aiRoles || this.aiRoles.length === 0) return [];
    const roles: AiRole[] = [];
    for (let i = 0; i < 6; i++) {
      const idx = (this.currentRoleStartIndex + i) % this.aiRoles.length;
      roles.push(this.aiRoles[idx]);
    }
    return roles;
  }

  aboutToAppear() {
    console.log('🚀 MyAIRole页面开始加载');
    this.loadAIRoles();
    this.loadUserInfo();
    this.startRotation();
    this.startAnimations();
    
    // 添加调试信息
    console.log('🔍 初始状态检查:');
    console.log('  - rolesOpacity:', this.rolesOpacity);
    console.log('  - isGathering:', this.isGathering);
    console.log('  - isSpreading:', this.isSpreading);
    console.log('  - aiRoles长度:', this.aiRoles ? this.aiRoles.length : 'undefined');
  }

  // 启动旋转动画
  private startRotation() {
    // 每50毫秒旋转1度，实现平滑的旋转效果
    setInterval(() => {
      if (!this.isGathering && !this.isSpreading) { // 只有在不聚集且不扩散时才旋转
        this.rotationAngle += 1;
        if (this.rotationAngle >= 360) {
          this.rotationAngle = 0;
        }
      }
    }, 50);
  }

  // 开始聚集动画
  private startGatheringAnimation() {
    if (this.isGathering || this.isSpreading) return; // 防止重复触发
    
    this.isGathering = true;
    this.gatherProgress = 0;
    this.rolesOpacity = 1;
    
    // 聚集动画：1秒内完成
    const duration = 1000; // 1秒
    const interval = 16; // 约60fps
    const steps = duration / interval;
    const progressStep = 1 / steps;
    
    const timer = setInterval(() => {
      this.gatherProgress += progressStep;
      
      if (this.gatherProgress >= 1) {
        this.gatherProgress = 1;
        this.rolesOpacity = 0;
        clearInterval(timer);
        
        // 聚集完成后开始扩散动画
        setTimeout(() => {
          this.startSpreadingAnimation();
        }, 300);
      } else {
        // 计算透明度：在聚集过程中逐渐变透明
        this.rolesOpacity = 1 - this.gatherProgress;
      }
    }, interval);
  }

  // 开始扩散动画
  private startSpreadingAnimation() {
    this.isGathering = false;
    this.isSpreading = true;
    this.spreadProgress = 0;
    this.rolesOpacity = 0;
    
    // 切换到下一组角色（如果有的话）
    if (this.aiRoles && this.aiRoles.length > 6) {
      this.currentRoleIndex = (this.currentRoleIndex + 6) % this.aiRoles.length;
    }
    
    // 扩散动画：1秒内完成
    const duration = 1000; // 1秒
    const interval = 16; // 约60fps
    const steps = duration / interval;
    const progressStep = 1 / steps;
    
    const timer = setInterval(() => {
      this.spreadProgress += progressStep;
      
      if (this.spreadProgress >= 1) {
        this.spreadProgress = 1;
        this.rolesOpacity = 1;
        clearInterval(timer);
        
        // 扩散完成后重置状态
        setTimeout(() => {
          this.isSpreading = false;
          this.spreadProgress = 0;
          this.gatherProgress = 0;
          this.rolesOpacity = 1; // 确保角色可见
          console.log('✅ 扩散动画完成，重置状态:');
          console.log('  - isSpreading:', this.isSpreading);
          console.log('  - rolesOpacity:', this.rolesOpacity);
        }, 500);
      } else {
        // 计算透明度：在扩散过程中逐渐变不透明
        this.rolesOpacity = this.spreadProgress;
      }
    }, interval);
  }

  // 计算旋转后的位置
  private getRotatedPosition(index: number): Position {
    const basePosition = this.rolePositions[index];
    const angleRad = (this.rotationAngle + index * 60) * Math.PI / 180;
    const radius = 120; // 旋转半径
    
    return {
      x: Math.cos(angleRad) * radius,
      y: Math.sin(angleRad) * radius
    };
  }

  // 计算聚集时的位置（向中心移动）
  private getGatheringPosition(index: number): Position {
    if (!this.isGathering) {
      return this.getRotatedPosition(index);
    }
    
    const startPos = this.getRotatedPosition(index);
    const centerPos: Position = { x: 0, y: 0 }; // 中心位置
    
    // 线性插值：从起始位置向中心移动
    return {
      x: startPos.x + (centerPos.x - startPos.x) * this.gatherProgress,
      y: startPos.y + (centerPos.y - startPos.y) * this.gatherProgress
    };
  }

  // 计算扩散时的位置（从中心向外移动）
  private getSpreadingPosition(index: number): Position {
    if (!this.isSpreading) {
      return this.getRotatedPosition(index);
    }
    
    const endPos = this.getRotatedPosition(index);
    const centerPos: Position = { x: 0, y: 0 }; // 中心位置
    
    // 线性插值：从中心位置向外移动
    return {
      x: centerPos.x + (endPos.x - centerPos.x) * this.spreadProgress,
      y: centerPos.y + (endPos.y - centerPos.y) * this.spreadProgress
    };
  }

  // 加载用户信息
  async loadUserInfo() {
    try {
      const userId = getUserId();
      if (userId) {
        // 这里可以调用API获取用户头像，暂时使用默认头像
        this.userAvatar = '';
        console.log('👤 用户头像已设置');
      }
    } catch (error) {
      console.error('❌ 加载用户信息失败:', error);
    }
  }

  // 加载AI角色数据
  async loadAIRoles() {
    this.isLoading = true;
    try {
      // 获取全局用户ID
      const userId = getUserId();
      console.log('🤖 开始加载用户AI角色，全局用户ID:', userId);
      
      if (userId === null || userId <= 0) {
        console.error('❌ 全局用户ID无效:', userId);
        console.error('❌ 请先登录获取用户ID');
        this.aiRoles = [];
        return;
      }

      console.log('🤖 使用全局用户ID:', userId);
      // 调用API获取用户的AI角色列表
      const roles = await ApiService.getUserAiRoles(userId);
      console.log('✅ 获取AI角色列表成功:', roles);
      console.log('✅ 角色数量:', roles ? roles.length : 0);
      console.log('✅ 角色详情:', JSON.stringify(roles, null, 2));
      this.aiRoles = roles || [];
      console.log('✅ 设置aiRoles后，数组长度:', this.aiRoles.length);
      // 自动选中第一个角色并提取主色
      if (this.aiRoles.length > 0) {
        this.selectedRole = this.aiRoles[0];
        this.selectedIndex = 0;
        await this.updateMainColorBySelectedRole();
      }
      
    } catch (error) {
      console.error('❌ 加载AI角色失败:', error);
      console.error('❌ 错误详情:', JSON.stringify(error));
      // 显示错误提示或使用默认数据
      this.aiRoles = [];
    } finally {
      this.isLoading = false;
      console.log('✅ 加载完成，isLoading:', this.isLoading, 'aiRoles长度:', this.aiRoles.length);
      
      // 确保角色在正常状态下可见
      if (!this.isGathering && !this.isSpreading) {
        this.rolesOpacity = 1;
        console.log('✅ 设置rolesOpacity为1，确保角色可见');
      }
      
      // 添加调试信息
      console.log('🔍 加载后状态检查:');
      console.log('  - rolesOpacity:', this.rolesOpacity);
      console.log('  - isGathering:', this.isGathering);
      console.log('  - isSpreading:', this.isSpreading);
      console.log('  - currentRoles长度:', this.getCurrentRoles() ? this.getCurrentRoles().length : 'undefined');
    }
  }

  // 格式化时间
  formatTime(timeString: string): string {
    try {
      const date = new Date(timeString);
      return date.toLocaleDateString();
    } catch (error) {
      return '未知时间';
    }
  }

  private startAnimations() {
    // 圆弧旋转动画
    setInterval(() => {
      this.arcRotation += 2
    }, 50)
    
    // 线条缩放动画
    setInterval(() => {
      this.lineScale = this.lineScale === 1.0 ? 1.1 : 1.0
    }, 1200)
    
    // 发光效果动画
    setInterval(() => {
      this.glowOpacity = this.glowOpacity === 0.5 ? 0.8 : 0.5
    }, 1000)
    
    // 文字透明度动画
    setInterval(() => {
      this.textOpacity = this.textOpacity === 0.8 ? 1.0 : 0.8
    }, 1500)
  }

  // 选中角色时提取主色
  private async updateMainColorBySelectedRole() {
    if (this.selectedRole && this.selectedRole.avatarUrl) {
      await this.extractMainColorFromImage(this.selectedRole.avatarUrl)
    } else {
      this.mainColor = '#1a1a1a'
    }
  }

  async extractMainColorFromImage(url: string) {
    const httpRequest = http.createHttp()
    try {
      const response = await httpRequest.request(url, { method: http.RequestMethod.GET })
      if (response.responseCode === 200 && response.result) {
        let imageData: ArrayBuffer
        if (response.result instanceof ArrayBuffer) {
          imageData = response.result
        } else {
          this.mainColor = '#cccccc'
          return
        }
        const imageSource = image.createImageSource(imageData)
        const pixelMap = await imageSource.createPixelMap()
        this.pixelMap = pixelMap
        effectKit.createColorPicker(pixelMap, (err: Error | null, colorPicker: effectKit.ColorPicker | null) => {
          if (!err && colorPicker) {
            const color = colorPicker.getMainColorSync()
            const alpha = color.alpha.toString(16).padStart(2, '0')
            const red = color.red.toString(16).padStart(2, '0')
            const green = color.green.toString(16).padStart(2, '0')
            const blue = color.blue.toString(16).padStart(2, '0')
            this.mainColor = `#${alpha}${red}${green}${blue}`
          }
        })
      }
    } catch (error) {
      this.mainColor = '#cccccc'
    } finally {
      httpRequest.destroy()
    }
  }

  build() {
    Stack() {
      // 深色渐变背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#000000', 0.0], ['#0a0a0a', 0.5], ['#1a1a1a', 1.0]]
        })
      
      // 旋转的圆弧背景装饰
      Stack() {
        // 多个同心圆弧轨道
        ForEach([0, 1, 2, 3], (index: number) => {
          Stack() {
            // 圆弧轨道
            Column()
              .width(200 + index * 60)
              .height(200 + index * 60)
              .borderRadius((200 + index * 60) / 2)
              .border({ width: 1, color: `rgba(64, 64, 64, ${0.3 - index * 0.05})` })
              .position({ x: '50%', y: '50%' })
              .translate({ x: -(200 + index * 60) / 2, y: -(200 + index * 60) / 2 })
            
            // 旋转的圆弧点
            Column()
              .width(8)
              .height(8)
              .backgroundColor(`rgba(255, 255, 255, ${0.6 - index * 0.1})`)
              .borderRadius(4)
              .position({ x: '50%', y: '50%' })
              .translate({ 
                x: -4 + Math.cos((this.arcRotation + index * 90) * Math.PI / 180) * (100 + index * 30),
                y: -4 + Math.sin((this.arcRotation + index * 90) * Math.PI / 180) * (100 + index * 30)
              })
          }
        })
        
        // 外圈装饰点
        ForEach([0, 1, 2, 3, 4, 5, 6, 7], (index: number) => {
          Column()
            .width(4)
            .height(4)
            .backgroundColor(`rgba(192, 192, 192, ${0.4 - index * 0.03})`)
            .borderRadius(2)
            .position({ x: '50%', y: '50%' })
            .translate({ 
              x: -2 + Math.cos((this.arcRotation * 0.5 + index * 45) * Math.PI / 180) * 160,
              y: -2 + Math.sin((this.arcRotation * 0.5 + index * 45) * Math.PI / 180) * 160
            })
        })
      }
      .width('100%')
      .height('100%')
      
      // 主要内容区域
      Column() {
        // 顶部导航栏
        Row() {
          // 返回按钮
          Button('←')
            .width(44)
            .height(44)
            .backgroundColor('rgba(255, 255, 255, 0.1)')
            .borderRadius(22)
            .fontColor('#ffffff')
            .fontSize(18)
            .onClick(() => {
              let uiContext: UIContext = this.getUIContext();
              let router = uiContext.getRouter();
              router.back();
            })
            
          // 标题
          Text('我的AI角色')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .opacity(this.textOpacity)
          
          // 创建按钮
          Button('+')
            .width(44)
            .height(44)
            .backgroundColor('rgba(255, 255, 255, 0.1)')
            .borderRadius(22)
            .fontColor('#ffffff')
            .fontSize(20)
            .onClick(() => {
              let uiContext: UIContext = this.getUIContext();
              let router = uiContext.getRouter();
              router.pushUrl({ url: 'pages/CreateFigure' });
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 20 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        // 内容区域
        Column() {
          if (this.isLoading) {
            // 加载状态 - 按照LoadingPage风格
            Column() {
              // 中心动画区域
              Stack() {
                // 外圈发光效果
                Column()
                  .width(180)
                  .height(180)
                  .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.05})`)
                  .borderRadius(90)
                  .border({ width: 2, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.2})` })
                
                // 内圈
                Column()
                  .width(140)
                  .height(140)
                  .backgroundColor('rgba(255, 255, 255, 0.03)')
                  .borderRadius(70)
                  .border({ width: 1, color: 'rgba(255, 255, 255, 0.08)' })
                
                // 中心图标
                Text('🤖')
                  .fontSize(50)
                  .fontColor('#fff')
                  .opacity(this.textOpacity)
              }
              .margin({ bottom: 30 })
              
              Text('加载中...')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#ffffff')
                .opacity(this.textOpacity)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else if (this.aiRoles.length === 0) {
            // 空状态 - 按照LoadingPage风格
            Column() {
              // 中心动画区域
              Stack() {
                // 外圈发光效果
                Column()
                  .width(180)
                  .height(180)
                  .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.05})`)
                  .borderRadius(90)
                  .border({ width: 2, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.2})` })
                
                // 内圈
                Column()
                  .width(140)
                  .height(140)
                  .backgroundColor('rgba(255, 255, 255, 0.03)')
                  .borderRadius(70)
                  .border({ width: 1, color: 'rgba(255, 255, 255, 0.08)' })
                
                // 中心图标
                Text('🤖')
                  .fontSize(50)
                  .fontColor('#fff')
                  .opacity(this.textOpacity)
              }
              .margin({ bottom: 30 })
              
              Text('还没有AI角色')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff')
                .opacity(this.textOpacity)
                .margin({ bottom: 12 })
              
              Text('创建一个AI角色开始对话吧')
                .fontSize(16)
                .fontColor('rgba(255, 255, 255, 0.7)')
                .opacity(this.textOpacity)
                .margin({ bottom: 40 })
                .textAlign(TextAlign.Center)
              
              // 创建按钮 - 现代化设计
              Button('创建AI角色')
                .width(180)
                .height(48)
                .backgroundColor('rgba(255, 255, 255, 0.1)')
                .borderRadius(24)
                .fontColor('#ffffff')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .border({ width: 1, color: 'rgba(255, 255, 255, 0.2)' })
                .onClick(() => {
                  let uiContext: UIContext = this.getUIContext();
                  let router = uiContext.getRouter();
                  router.pushUrl({ url: 'pages/CreateFigure' });
                })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            // 圆形布局：中心用户头像，周围六个AI角色
            Stack() {
              // 背景圆形轨道 - 现代化设计
              Column()
                .width(320)
                .height(320)
                .borderRadius(160)
                .border({ width: 2, color: 'rgba(255, 255, 255, 0.1)' })
                .backgroundColor('rgba(255, 255, 255, 0.02)')
              
              // 中心用户头像（可点击）
              Stack() {
                if (this.userAvatar && this.userAvatar.trim() !== '') {
                  Image(this.userAvatar)
                    .width(80)
                    .height(80)
                    .borderRadius(40)
                    .objectFit(ImageFit.Cover)
                } else {
                  Text('👤')
                    .fontSize(36)
                    .fontColor('#ffffff')
                }
                
                // 发光效果
                Circle()
                  .width(100)
                  .height(100)
                  .fill('rgba(255, 255, 255, 0.05)')
                  .stroke(`rgba(255, 255, 255, ${this.glowOpacity * 0.3})`)
                  .strokeWidth(2)
                  .position({ x: -10, y: -10 })
                  .animation({
                    duration: 2000,
                    curve: Curve.EaseInOut,
                    iterations: -1,
                    playMode: PlayMode.Alternate
                  })
                  .scale({ x: this.lineScale, y: this.lineScale })
                  .opacity(0.8)
              }
              .width(80)
              .height(80)
              .backgroundColor('rgba(255, 255, 255, 0.05)')
              .borderRadius(40)
              .border({ width: 2, color: 'rgba(255, 255, 255, 0.2)' })
              .shadow({ radius: 10, color: '#00000040', offsetX: 0, offsetY: 5 })
              .position({ x: '50%', y: '50%' })
              .translate({ x: -40, y: -40 })
              .onClick(() => {
                if (this.aiRoles && this.aiRoles.length > 0) {
                  this.currentRoleStartIndex = (this.currentRoleStartIndex + 6) % this.aiRoles.length;
                }
              })
              
              // 周围六个AI角色圆圈
              ForEach([0, 1, 2, 3, 4, 5], (index: number) => {
                if (this.getCurrentRoles().length > 0) {
                  Stack() {
                    // AI角色头像
                    if (this.getCurrentRoles()[index] && this.getCurrentRoles()[index].avatarUrl && this.getCurrentRoles()[index].avatarUrl.trim() !== '') {
                      Image(this.getCurrentRoles()[index].avatarUrl)
                        .width(60)
                        .height(60)
                        .borderRadius(30)
                        .objectFit(ImageFit.Cover)
                    } else {
                      Text('🤖')
                        .fontSize(24)
                        .fontColor('#ffffff')
                    }
                    
                    // 选中状态指示器
                    if (this.selectedIndex === index) {
                      Circle()
                        .width(80)
                        .height(80)
                        .fill('rgba(255, 255, 255, 0.1)')
                        .stroke(`rgba(255, 255, 255, ${this.glowOpacity * 0.6})`)
                        .strokeWidth(2)
                        .position({ x: -10, y: -10 })
                        .animation({
                          duration: 2000,
                          curve: Curve.EaseInOut,
                          iterations: -1,
                          playMode: PlayMode.Alternate
                        })
                        .scale({ x: 1.0, y: 1.0 })
                        .opacity(0.8)
                    }
                    
                    // 悬停效果指示器
                    if (this.hoverIndex === index && this.selectedIndex !== index) {
                      Circle()
                        .width(75)
                        .height(75)
                        .fill('rgba(255, 255, 255, 0.05)')
                        .stroke('rgba(255, 255, 255, 0.3)')
                        .strokeWidth(1)
                        .position({ x: -7.5, y: -7.5 })
                        .animation({
                          duration: 1000,
                          curve: Curve.EaseInOut,
                          iterations: -1,
                          playMode: PlayMode.Alternate
                        })
                        .scale({ x: 1.0, y: 1.0 })
                        .opacity(0.6)
                    }
                  }
                  .width(60)
                  .height(60)
                  .backgroundColor(this.selectedIndex === index ? 'rgba(255, 255, 255, 0.15)' : 'rgba(255, 255, 255, 0.05)')
                  .borderRadius(30)
                  .border({ 
                    width: this.selectedIndex === index ? 3 : 1, 
                    color: this.selectedIndex === index ? `rgba(255, 255, 255, ${this.glowOpacity * 0.8})` : 'rgba(255, 255, 255, 0.2)' 
                  })
                  .shadow({ 
                    radius: this.selectedIndex === index ? 15 : 8, 
                    color: this.selectedIndex === index ? '#ffffff50' : '#00000030', 
                    offsetX: 0, 
                    offsetY: this.selectedIndex === index ? 8 : 3 
                  })
                  .position({ x: '50%', y: '50%' })
                  .translate({ 
                    x: this.isSpreading ? this.getSpreadingPosition(index).x - 30 : this.getGatheringPosition(index).x - 30, 
                    y: this.isSpreading ? this.getSpreadingPosition(index).y - 30 : this.getGatheringPosition(index).y - 30
                  })
                  .opacity(this.rolesOpacity)
                  .scale({ 
                    x: this.selectedIndex === index ? 1.1 : (this.hoverIndex === index ? 1.05 : 1.0), 
                    y: this.selectedIndex === index ? 1.1 : (this.hoverIndex === index ? 1.05 : 1.0) 
                  })
                  .animation({
                    duration: 200,
                    curve: Curve.EaseInOut
                  })
                  .onClick(() => {
                    const currentTime = Date.now();
                    const timeDiff = currentTime - this.lastClickTime;
                    const isSameRole = this.lastClickIndex === index;
                    if (timeDiff < 300 && isSameRole) {
                      const selectedRole = this.getCurrentRoles()[index];
                      let uiContext: UIContext = this.getUIContext();
                      let router = uiContext.getRouter();
                      router.pushUrl({ 
                        url: 'pages/chat',
                        params: {
                          figureImageUrl: selectedRole.avatarUrl || '',
                          figureName: selectedRole.roleName || '',
                          figureType: selectedRole.roleType || '',
                          description: selectedRole.roleDescription || '',
                          isFromCreateFigure: true,
                          createdAiRoleId: selectedRole.id || 0
                        }
                      });
                      this.lastClickTime = 0;
                      this.lastClickIndex = -1;
                    } else {
                      this.selectedRole = this.getCurrentRoles()[index];
                      this.selectedIndex = index;
                      this.lastClickTime = currentTime;
                      this.lastClickIndex = index;
                    }
                  })
                  .onHover((isHovered: boolean) => {
                    if (!this.isGathering && !this.isSpreading) {
                      this.hoverIndex = isHovered ? index : -1;
                    }
                  })
                }
              })
            }
            .width(320)
            .height(320)
            .margin({ top: 20, bottom: 30 })
            
            // AI角色详细信息展示
            Column() {
              if (this.selectedRole) {
                // 显示选中角色的详细信息
                Column() {
                  Text('角色详情')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#ffffff')
                    .opacity(this.textOpacity)
                    .margin({ bottom: 25 })
                    .textAlign(TextAlign.Center)
                  
                  // 角色详细信息卡片 - 现代化设计
                  Column() {
                    // 角色头像和基本信息
                    Row() {
                      // 角色头像
                      Stack() {
                        if (this.selectedRole.avatarUrl && this.selectedRole.avatarUrl.trim() !== '') {
                          Image(this.selectedRole.avatarUrl)
                            .width(90)
                            .height(90)
                            .borderRadius(45)
                            .objectFit(ImageFit.Cover)
                        } else {
                          Text('🤖')
                            .fontSize(40)
                            .fontColor('#ffffff')
                            .width(90)
                            .height(90)
                            .textAlign(TextAlign.Center)
                            .backgroundColor('rgba(255, 255, 255, 0.1)')
                            .borderRadius(45)
                        }
                        
                        // 头像发光效果
                        Circle()
                          .width(110)
                          .height(110)
                          .fill('rgba(255, 255, 255, 0.05)')
                          .stroke(`rgba(255, 255, 255, ${this.glowOpacity * 0.3})`)
                          .strokeWidth(2)
                          .position({ x: -10, y: -10 })
                          .animation({
                            duration: 3000,
                            curve: Curve.EaseInOut,
                            iterations: -1,
                            playMode: PlayMode.Alternate
                          })
                          .scale({ x: 1.0, y: 1.0 })
                          .opacity(0.6)
                      }
                      .width(90)
                      .height(90)
                      .borderRadius(45)
                      .border({ width: 2, color: 'rgba(255, 255, 255, 0.2)' })
                      .shadow({ radius: 8, color: '#00000040', offsetX: 0, offsetY: 4 })
                      
                      // 角色基本信息
                      Column() {
                        Text(this.selectedRole.roleName || '未命名角色')
                          .fontSize(24)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#ffffff')
                          .opacity(this.textOpacity)
                          .margin({ bottom: 10 })
                          .textAlign(TextAlign.Start)
                        
                        if (this.selectedRole.roleType && this.selectedRole.roleType.trim() !== '') {
                          Text(this.selectedRole.roleType)
                            .fontSize(16)
                            .fontColor('rgba(255,255,255,0.8)')
                            .backgroundColor('rgba(255, 255, 255, 0.15)')
                            .borderRadius(20)
                            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                            .alignSelf(ItemAlign.Start)
                            .margin({ bottom: 10 })
                            .animation({
                              duration: 500,
                              curve: Curve.EaseInOut
                            })
                            .scale({ x: 1.0, y: 1.0 })
                        }
                        
                        if (this.selectedRole.createdAt) {
                          Text('创建时间: ' + this.formatTime(this.selectedRole.createdAt))
                            .fontSize(14)
                            .fontColor('rgba(255,255,255,0.6)')
                            .textAlign(TextAlign.Start)
                        }
                      }
                      .layoutWeight(1)
                      .justifyContent(FlexAlign.Start)
                      .margin({ left: 20 })
                    }
                    .width('100%')
                    .margin({ bottom: 25 })
                    
                    // 角色描述
                    if (this.selectedRole.roleDescription && this.selectedRole.roleDescription.trim() !== '') {
                      Text('角色描述:')
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#ffffff')
                        .opacity(this.textOpacity)
                        .margin({ bottom: 10 })
                        .textAlign(TextAlign.Start)
                      
                      Text(this.selectedRole.roleDescription)
                        .fontSize(16)
                        .fontColor('rgba(255,255,255,0.8)')
                        .textAlign(TextAlign.Start)
                        .margin({ bottom: 25 })
                        .maxLines(5)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    
                    // 操作按钮 - 现代化设计
                    Row() {
                      Button('开始聊天')
                        .width('48%')
                        .height(50)
                        .backgroundColor('rgba(255, 255, 255, 0.15)')
                        .borderRadius(25)
                        .fontSize(16)
                        .fontColor('#ffffff')
                        .fontWeight(FontWeight.Medium)
                        .border({ width: 1, color: 'rgba(255, 255, 255, 0.2)' })
                        .onClick(() => {
                          console.log('开始与角色聊天:', this.selectedRole?.roleName);
                          console.log('传递的角色信息:', {
                            figureImageUrl: this.selectedRole?.avatarUrl,
                            figureName: this.selectedRole?.roleName,
                            figureType: this.selectedRole?.roleType,
                            description: this.selectedRole?.roleDescription,
                            isFromCreateFigure: true,
                            createdAiRoleId: this.selectedRole?.id
                          });
                          
                          let uiContext: UIContext = this.getUIContext();
                          let router = uiContext.getRouter();
                          router.pushUrl({ 
                            url: 'pages/chat',
                            params: {
                              figureImageUrl: this.selectedRole?.avatarUrl || '',
                              figureName: this.selectedRole?.roleName || '',
                              figureType: this.selectedRole?.roleType || '',
                              description: this.selectedRole?.roleDescription || '',
                              isFromCreateFigure: true,
                              createdAiRoleId: this.selectedRole?.id || 0
                            }
                          });
                        })
                        .animation({
                          duration: 200,
                          curve: Curve.EaseInOut
                        })
                        .scale({ x: 1.0, y: 1.0 })
                      
                      Button('取消选择')
                        .width('48%')
                        .height(50)
                        .backgroundColor('rgba(255, 255, 255, 0.08)')
                        .borderRadius(25)
                        .fontSize(16)
                        .fontColor('#ffffff')
                        .fontWeight(FontWeight.Medium)
                        .border({ width: 1, color: 'rgba(255, 255, 255, 0.15)' })
                        .margin({ left: '4%' })
                        .onClick(() => {
                          this.selectedRole = null;
                          this.selectedIndex = -1;
                          console.log('取消选择角色');
                        })
                        .animation({
                          duration: 200,
                          curve: Curve.EaseInOut
                        })
                        .scale({ x: 1.0, y: 1.0 })
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                  }
                  .width('100%')
                  .padding({ left: 25, right: 25, top: 25, bottom: 25 })
                  .backgroundColor('rgba(255, 255, 255, 0.08)')
                  .borderRadius(20)
                  .border({ width: 1, color: 'rgba(255, 255, 255, 0.15)' })
                  .shadow({ radius: 15, color: '#00000050', offsetX: 0, offsetY: 8 })
                  .margin({ left: 20, right: 20 })
                  .animation({
                    duration: 500,
                    curve: Curve.EaseInOut
                  })
                  .scale({ x: 1.0, y: 1.0 })
                  .opacity(1)
                }
              } else {
                // 显示所有角色列表 - 现代化设计
                Column() {
                  Text('我的AI角色')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#ffffff')
                    .opacity(this.textOpacity)
                    .margin({ bottom: 15 })
                    .textAlign(TextAlign.Center)
                  
                  Text('点击上方角色查看详情，双击进入聊天')
                    .fontSize(16)
                    .fontColor('rgba(255,255,255,0.7)')
                    .opacity(this.textOpacity)
                    .margin({ bottom: 25 })
                    .textAlign(TextAlign.Center)
                  
                  ForEach(this.aiRoles, (role: AiRole, index: number) => {
                    Column() {
                      // 角色卡片 - 现代化设计
                      Row() {
                        // 角色头像
                        Stack() {
                          if (role.avatarUrl && role.avatarUrl.trim() !== '') {
                            Image(role.avatarUrl)
                              .width(70)
                              .height(70)
                              .borderRadius(35)
                              .objectFit(ImageFit.Cover)
                          } else {
                            Text('🤖')
                              .fontSize(32)
                              .fontColor('#ffffff')
                              .width(70)
                              .height(70)
                              .textAlign(TextAlign.Center)
                              .backgroundColor('rgba(255, 255, 255, 0.1)')
                              .borderRadius(35)
                          }
                        }
                        .width(70)
                        .height(70)
                        .borderRadius(35)
                        .border({ width: 2, color: 'rgba(255, 255, 255, 0.2)' })
                        .shadow({ radius: 6, color: '#00000030', offsetX: 0, offsetY: 3 })
                        
                        // 角色信息
                        Column() {
                          Text(role.roleName || '未命名角色')
                            .fontSize(20)
                            .fontWeight(FontWeight.Bold)
                            .fontColor('#ffffff')
                            .opacity(this.textOpacity)
                            .margin({ bottom: 8 })
                            .textAlign(TextAlign.Start)
                          
                          Text(role.roleDescription || '暂无描述')
                            .fontSize(16)
                            .fontColor('rgba(255,255,255,0.8)')
                            .textAlign(TextAlign.Start)
                            .maxLines(3)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ bottom: 10 })
                          
                          // 角色标签
                          if (role.roleType && role.roleType.trim() !== '') {
                            Text(role.roleType)
                              .fontSize(14)
                              .fontColor('rgba(255,255,255,0.7)')
                              .backgroundColor('rgba(255, 255, 255, 0.1)')
                              .borderRadius(16)
                              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                              .alignSelf(ItemAlign.Start)
                          }
                        }
                        .layoutWeight(1)
                        .justifyContent(FlexAlign.Start)
                        .margin({ left: 18 })
                        
                        // 操作按钮
                        Column() {
                          Button('聊天')
                            .width(70)
                            .height(36)
                            .backgroundColor('rgba(255, 255, 255, 0.15)')
                            .borderRadius(18)
                            .fontSize(14)
                            .fontColor('#ffffff')
                            .fontWeight(FontWeight.Medium)
                            .margin({ bottom: 10 })
                            .onClick(() => {
                              console.log('选择角色进行聊天:', role.roleName);
                              console.log('传递的角色信息:', {
                                figureImageUrl: role.avatarUrl,
                                figureName: role.roleName,
                                figureType: role.roleType,
                                description: role.roleDescription,
                                isFromCreateFigure: true,
                                createdAiRoleId: role.id
                              });
                              
                              let uiContext: UIContext = this.getUIContext();
                              let router = uiContext.getRouter();
                              router.pushUrl({ 
                                url: 'pages/chat',
                                params: {
                                  figureImageUrl: role.avatarUrl || '',
                                  figureName: role.roleName || '',
                                  figureType: role.roleType || '',
                                  description: role.roleDescription || '',
                                  isFromCreateFigure: true,
                                  createdAiRoleId: role.id || 0
                                }
                              });
                            })
                            .animation({
                              duration: 200,
                              curve: Curve.EaseInOut
                            })
                            .scale({ x: 1.0, y: 1.0 })
                          
                          // 创建时间
                          if (role.createdAt) {
                            Text(this.formatTime(role.createdAt))
                              .fontSize(12)
                              .fontColor('rgba(255,255,255,0.5)')
                              .textAlign(TextAlign.Center)
                          }
                        }
                        .alignItems(HorizontalAlign.Center)
                      }
                      .width('100%')
                      .padding({ left: 20, right: 20, top: 20, bottom: 20 })
                      .backgroundColor('rgba(255, 255, 255, 0.08)')
                      .borderRadius(16)
                      .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
                      .shadow({ radius: 10, color: '#00000040', offsetX: 0, offsetY: 5 })
                      .margin({ left: 20, right: 20, bottom: 15 })
                      .animation({
                        duration: 300 + index * 100,
                        curve: Curve.EaseInOut
                      })
                      .scale({ x: 1.0, y: 1.0 })
                      .opacity(1)
                    }
                  })
                }
                .width('100%')
                .padding({ left: 20, right: 20 })
              }
            }
            .width('100%')
            .layoutWeight(1)
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.mainColor)
  }
}
