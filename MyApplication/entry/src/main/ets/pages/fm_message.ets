import router from '@ohos.router'
import { fetchWeather } from '../model/WeatherService';
import { ApiService } from '../service/apiservice';
import { Conversation, AiRole } from '../common/types';
import { getUserId } from '../common/constants';

class WeatherInfo {
  city: string = '加载中';
  temperature: string = '--°';
  icon: string = '❓';
  desc: string = '加载中';
}
class MessageItem {
  avatar: Resource = $r('app.media.splash');
  name: string = '';
  desc: string = '';
  time: string = '';
  followed: boolean = false;
  unread: number = 0;
  isOfficial?: boolean = false;
  isSystem?: boolean = false;
}
@Entry
@Component
export struct MessagePage {
  @State weatherInfo: WeatherInfo = new WeatherInfo();
  @State currentTime: string = '';
  @State currentDate: string = '';
  @State private conversations: Conversation[] = [];
  @State private aiRoleMap: Record<number, AiRole> = {};
  @State arcRotation: number = 0 // 圆弧旋转角度
  @State starTwinkle: number = 0 // 星星闪烁效果
  @State glowOpacity: number = 0.5 // 发光效果透明度
  @State textOpacity: number = 0.8 // 文字透明度
  @State nebulaOpacity: number = 0.3 // 星云透明度
  private timerId: number = -1;

  aboutToAppear() {
    this.startGalaxyAnimations()
    this.getWeatherByLocation();
    this.updateDateTime();
    this.loadConversations();
    this.timerId = setInterval(() => {
      this.updateDateTime();
    }, 1000);
  }

  private startGalaxyAnimations() {
    // 圆弧旋转动画
    setInterval(() => {
      this.arcRotation += 1.5
    }, 50)
    
    // 星星闪烁动画
    setInterval(() => {
      this.starTwinkle += 0.1
    }, 100)
    
    // 发光效果动画
    setInterval(() => {
      this.glowOpacity = this.glowOpacity === 0.5 ? 0.8 : 0.5
    }, 1200)
    
    // 文字透明度动画
    setInterval(() => {
      this.textOpacity = this.textOpacity === 0.8 ? 1.0 : 0.8
    }, 1800)
    
    // 星云透明度动画
    setInterval(() => {
      this.nebulaOpacity = this.nebulaOpacity === 0.3 ? 0.6 : 0.3
    }, 3000)
  }

  // 新增：页面显示时刷新对话列表
  onPageShow() {
    console.log('Message页面显示，刷新对话列表');
    this.loadConversations();
  }

  aboutToDisappear() {
    // 清理定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  updateDateTime() {
    const now = new Date();
    
    // 格式化时间 HH:MM
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    this.currentTime = `${hours}:${minutes}`;
    
    // 格式化日期和星期
    const year = now.getFullYear();
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const day = now.getDate().toString().padStart(2, '0');
    const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    const weekday = weekdays[now.getDay()];
    this.currentDate = `${year}年${month}月${day}日 ${weekday}`;
  }

  async getWeatherByLocation() {
    const data = await fetchWeather('101200101'); // 武汉
    console.log('fetchWeather返回:', JSON.stringify(data));
    if (data && data.status === 200 && data.data && data.cityInfo) {
      this.weatherInfo.city = data.cityInfo.city;
      this.weatherInfo.temperature = data.data.wendu + '°';
      this.weatherInfo.desc = data.data.forecast && data.data.forecast.length > 0 ? data.data.forecast[0].type : '';
      this.weatherInfo.icon = this.iconMap(this.weatherInfo.desc);
    } else {
      this.weatherInfo.city = '获取失败';
      this.weatherInfo.temperature = '--°';
      this.weatherInfo.desc = '天气获取失败';
      this.weatherInfo.icon = '❌';
    }
  }

  iconMap(desc: string): string {
    switch (desc) {
      case '晴': return '☀️';
      case '多云': return '🌤️';
      case '阴': return '☁️';
      case '小雨': return '🌧️';
      case '中雨': return '🌧️';
      case '大雨': return '⛈️';
      case '雷阵雨': return '⛈️';
      case '雪': return '❄️';
      case '雾': return '🌫️';
      default: return '❓';
    }
  }

  async loadConversations() {
    try {
      // 获取全局用户ID
      const userId = getUserId();
      
      // 检查用户ID是否有效
      if (userId === null) {
        console.warn('用户ID为空，无法加载对话列表');
        this.conversations = [];
        this.aiRoleMap = {};
        return;
      }
      
      console.log('使用用户ID加载对话列表:', userId);
      const conversations = await ApiService.getConversationsByUserId(userId);
      this.conversations = conversations;
      
      // 批量获取AI角色信息
      const aiRoleIds = Array.from(new Set(conversations.map(c => c.aiRoleId)));
      const aiRoleMap: Record<number, AiRole> = {};
      for (const id of aiRoleIds) {
        try {
          aiRoleMap[id] = await ApiService.getAiRoleById(id);
        } catch (e) {
          console.error('获取AI角色信息失败，角色ID:', id, e);
          // 失败则跳过
        }
      }
      this.aiRoleMap = aiRoleMap;
      
      console.log('成功加载对话列表，对话数量:', conversations.length);
    } catch (e) {
      console.error('加载会话失败', e);
      this.conversations = [];
      this.aiRoleMap = {};
    }
  }

  build(): void {
    Stack() {
      // 深色渐变背景 - 改为纯黑色主题
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#000000', 0.0], ['#0a0a0a', 0.5], ['#1a1a1a', 1.0]]
        })
      
      // 旋转的圆弧背景 - 改为黑色系装饰
      Stack() {
        // 多个同心圆弧轨道
        ForEach([0, 1, 2, 3], (index: number) => {
          Stack() {
            // 圆弧轨道 - 改为深灰色
            Column()
              .width(250 + index * 60)
              .height(250 + index * 60)
              .borderRadius((250 + index * 60) / 2)
              .border({ width: 1, color: `rgba(64, 64, 64, ${0.3 - index * 0.05})` })
              .position({ x: '50%', y: '50%' })
              .translate({ x: -(250 + index * 60) / 2, y: -(250 + index * 60) / 2 })
            
            // 旋转的圆弧点 - 改为白色系
            Column()
              .width(6)
              .height(6)
              .backgroundColor(`rgba(255, 255, 255, ${0.6 - index * 0.1})`)
              .borderRadius(3)
              .position({ x: '50%', y: '50%' })
              .translate({ 
                x: -3 + Math.cos((this.arcRotation + index * 90) * Math.PI / 180) * (125 + index * 30),
                y: -3 + Math.sin((this.arcRotation + index * 90) * Math.PI / 180) * (125 + index * 30)
              })
          }
        })
        
        // 外圈装饰点 - 改为银色系
        ForEach([0, 1, 2, 3, 4, 5], (index: number) => {
          Column()
            .width(6)
            .height(6)
            .backgroundColor(`rgba(192, 192, 192, ${0.4 - index * 0.05})`)
            .borderRadius(3)
            .position({ x: '50%', y: '50%' })
            .translate({ 
              x: -3 + Math.cos((this.arcRotation * 0.5 + index * 60) * Math.PI / 180) * 120,
              y: -3 + Math.sin((this.arcRotation * 0.5 + index * 60) * Math.PI / 180) * 120
            })
        })
      }
      .width('100%')
      .height('100%')
      
      // 主要内容区域
      Column() {
        // 天气卡片部分
        Stack() {
          // 天气卡片背景发光效果
          Column()
            .width('100%')
            .height(160)
            .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.05})`)
            .borderRadius(24)
            .border({ width: 2, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.2})` })
          
          Column() {
            // 上半部分：温度、城市、天气描述和图标
            Row() {
              // 左侧：温度
              Text(this.weatherInfo.temperature)
                .fontSize(42)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff')
                .opacity(this.textOpacity)
                .margin({ left: 20, top: 16, bottom: 0, right: 0 })
              
              // 中间：城市和天气描述
              Column() {
                Text(this.weatherInfo.city)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff')
                  .opacity(this.textOpacity)
                  .margin({ bottom: 4 })
                Text(this.weatherInfo.desc)
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.9)')
                  .opacity(this.textOpacity)
                  .margin({ bottom: 0 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 16, top: 16, bottom: 0, right: 0 })
              
              // 右侧：天气图标
              Blank().layoutWeight(1)
              Text(this.weatherInfo.icon)
                .fontSize(36)
                .fontColor('#ffffff')
                .opacity(this.textOpacity)
                .margin({ right: 20, top: 16, bottom: 0 })
            }
            .width('100%')
            .height(60)
            
            // 下半部分：时间日期
            Column() {
              Text(this.currentTime)
                .fontSize(24)
                .fontColor('#ffffff')
                .fontWeight(FontWeight.Bold)
                .opacity(this.textOpacity)
                .margin({ top: 8, bottom: 4 })
              Text(this.currentDate)
                .fontSize(13)
                .fontColor('rgba(255, 255, 255, 0.8)')
                .opacity(this.textOpacity)
                .margin({ bottom: 16 })
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
          }
          .width('100%')
          .height(160)
          .backgroundColor('rgba(255, 255, 255, 0.03)')
          .borderRadius(24)
          .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
          .margin({ left: 12, right: 12, top: 12, bottom: 16 })
          .shadow({ radius: 16, color: '#00000040', offsetX: 0, offsetY: 6 })
        }
        
        // 消息列表
        if (this.conversations.length > 0) {
          List() {
            ForEach(this.conversations, (conv: Conversation, idx: number) => {
              ListItem() {
                Stack() {
                  // 消息卡片背景发光
                  Column()
                    .width('100%')
                    .height(80)
                    .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
                    .borderRadius(16)
                    .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
                  
                  Row() {
                    Image(this.aiRoleMap[conv.aiRoleId]?.avatarUrl)
                      .width(48)
                      .height(48)
                      .borderRadius(24)
                      .border({ width: 2, color: 'rgba(255, 255, 255, 0.2)' })
                      .margin({ left: 16, right: 12 })
                    Column({ space: 4 }) {
                      Text(conv.title)
                        .fontSize(16)
                        .fontColor('#ffffff')
                        .fontWeight(FontWeight.Bold)
                        .opacity(this.textOpacity)
                      Text('') // 可扩展为摘要
                        .fontSize(13)
                        .fontColor('rgba(255, 255, 255, 0.7)')
                        .maxLines(1)
                        .margin({ top: 2 })
                    }
                    .layoutWeight(1)
                    Column() {
                      Text(conv.lastActive ? conv.lastActive.replace('T', ' ').slice(0, 16) : '')
                        .fontSize(12)
                        .fontColor('rgba(255, 255, 255, 0.6)')
                        .margin({ bottom: 8 })
                    }
                    .alignItems(HorizontalAlign.End)
                    .margin({ right: 16 })
                  }
                  .width('100%')
                  .height(80)
                  .backgroundColor('rgba(255, 255, 255, 0.03)')
                  .borderRadius(16)
                  .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
                  .margin({ left: 12, right: 12, bottom: 8 })
                  .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 2 })
                }
                .onClick(() => {
                  const aiRole = this.aiRoleMap[conv.aiRoleId];
                  console.log('角色ID:', aiRole.id);
                  router.pushUrl({
                    url: 'pages/chat',
                    params: {
                      figureImageUrl: aiRole?.avatarUrl ,
                      figureType: aiRole?.roleType ,
                      figureName: aiRole?.roleName ,
                      isFromCreateFigure: false,
                      description: aiRole?.roleDescription ,
                      createdAiRoleId: aiRole?.id
                    }
                  });
                })
              }
            }, (conv: Conversation) => conv.id.toString())
          }
          .width('100%')
          .layoutWeight(1)
        } else {
          // 空状态显示
          Column() {
            // 发光圆圈
            Stack() {
              Column()
                .width(140)
                .height(140)
                .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.05})`)
                .borderRadius(70)
                .border({ width: 2, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.2})` })
              
              Text('💬')
                .fontSize(70)
                .fontColor('#ffffff')
                .opacity(this.textOpacity)
            }
            .margin({ top: 100, bottom: 24 })
            
            Text('暂无对话记录')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#ffffff')
              .opacity(this.textOpacity)
              .margin({ bottom: 12 })
            
            Text('开始与AI角色聊天，创建你的第一个对话吧！')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.7)')
              .textAlign(TextAlign.Center)
              .opacity(this.textOpacity)
              .margin({ left: 40, right: 40 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        Blank().height(56)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
} 