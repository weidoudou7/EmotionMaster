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
  private timerId: number = -1;

  aboutToAppear() {
    this.getWeatherByLocation();
    this.updateDateTime();
    this.loadConversations();
    this.timerId = setInterval(() => {
      this.updateDateTime();
    }, 1000);
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
    Column() {
      // 天气卡片部分
      Stack() {
        Column() {
          Row() {
            Text(this.weatherInfo.temperature)
              .fontSize(48)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .margin({ left: 16, top: 10, bottom: 4, right: 8 })
            Column() {
              Text(this.weatherInfo.city)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#fff')
                .margin({ bottom: 1 })
              Text(this.weatherInfo.desc)
                .fontSize(13)
                .fontColor('#fff')
                .margin({ bottom: 1 })
            }
            .margin({ top: 10 })
            Blank().layoutWeight(1)
            Column() {
              Text(this.weatherInfo.icon)
                .fontSize(32)
                .margin({ top: 4, right: 12 })
            }
          }
          
          // 当前时间日期
          Column() {
            Text(this.currentTime)
              .fontSize(20)
              .fontColor('#fff')
              .fontWeight(FontWeight.Bold)
              .margin({ top: 8, bottom: 4 })
            Text(this.currentDate)
              .fontSize(12)
              .fontColor('#fff')
              .opacity(0.9)
              .margin({ bottom: 8 })
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height(140)
        .backgroundColor('rgba(34,34,34,0.7)')
        .borderRadius(24)
        .margin({ left: 8, right: 8, top: 8, bottom: 12 })
        .shadow({ radius: 8, color: '#00000022', offsetX: 0, offsetY: 2 })
      }
      // 消息列表
      if (this.conversations.length > 0) {
        List() {
          ForEach(this.conversations, (conv: Conversation, idx: number) => {
            ListItem() {
              Row() {
                Image(this.aiRoleMap[conv.aiRoleId]?.avatarUrl)
                  .width(48)
                  .height(48)
                  .borderRadius(24)
                  .margin({ left: 16, right: 12 })
                Column({ space: 4 }) {
                  Text(conv.title)
                    .fontSize(16)
                    .fontColor('#fff')
                    .fontWeight(FontWeight.Bold)
                  Text('') // 可扩展为摘要
                    .fontSize(13)
                    .fontColor('#bbb')
                    .maxLines(1)
                    .margin({ top: 2 })
                }
                .layoutWeight(1)
                Column() {
                  Text(conv.lastActive ? conv.lastActive.replace('T', ' ').slice(0, 16) : '')
                    .fontSize(12)
                    .fontColor('#888')
                    .margin({ bottom: 8 })
                }
                .alignItems(HorizontalAlign.End)
                .margin({ right: 16 })
              }
              .height(64)
              .backgroundColor('rgba(34,34,34,0)')
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
          }, (conv: Conversation) => conv.id.toString())
        }
        .width('100%')
        .backgroundColor('#181818')
        .layoutWeight(1)
      } else {
        // 空状态显示
        Column() {
          Image($r('app.media.splash'))
            .width(120)
            .height(120)
            .margin({ top: 100, bottom: 20 })
            .opacity(0.5)
          Text('暂无对话记录')
            .fontSize(16)
            .fontColor('#888')
            .margin({ bottom: 8 })
          Text('开始与AI角色聊天，创建你的第一个对话吧！')
            .fontSize(14)
            .fontColor('#666')
            .textAlign(TextAlign.Center)
            .margin({ left: 40, right: 40 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#181818')
      }
      Blank().height(56)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#181818')
  }
} 