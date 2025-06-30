import { fetchWeather } from '../model/WeatherService';

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
  private messages: MessageItem[] = [
    (() => { let m = new MessageItem(); m.avatar = $r('app.media.splash'); m.name = '谢厌之'; m.desc = '（胃里一阵绞痛，额上渗出细汗，咬着牙说道）...'; m.time = '星期四'; m.followed = true; m.unread = 0; return m; })(),
    (() => { let m = new MessageItem(); m.avatar = $r('app.media.splash'); m.name = '能猜出你坦/推'; m.desc = '[系统消息]解锁"微笑"时刻，可在详情查看 去查看'; m.time = '星期四'; m.followed = false; m.unread = 0; return m; })(),
    (() => { let m = new MessageItem(); m.avatar = $r('app.media.splash'); m.name = '星若（AI助手）'; m.desc = '根据搜索材料，以下是武汉市2025年6月27日的...'; m.time = '星期四'; m.followed = false; m.unread = 0; m.isOfficial = true; return m; })(),
    (() => { let m = new MessageItem(); m.avatar = $r('app.media.splash'); m.name = '系统通知'; m.desc = '📻欢迎新人主播「武媛娘」入驻星野！'; m.time = '星期一'; m.followed = false; m.unread = 0; m.isSystem = true; return m; })(),
  ];
  private timerId: number = -1;

  aboutToAppear() {
    this.getWeatherByLocation();
    this.updateDateTime();
    // 启动定时器，每分钟更新一次时间
    this.timerId = setInterval(() => {
      this.updateDateTime();
    }, 1000); //
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

  build(): void {
    Column() {
      // 天气卡片部分
      Stack() {
        Column() {
          Row() {
            Text(this.weatherInfo.temperature)
              .fontSize(64)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .margin({ left: 24, top: 18, bottom: 8, right: 12 })
            Column() {
              Text(this.weatherInfo.city)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#fff')
                .margin({ bottom: 2 })
              Text(this.weatherInfo.desc)
                .fontSize(16)
                .fontColor('#fff')
                .margin({ bottom: 2 })
            }
            .margin({ top: 18 })
            Blank().width('1fr')
            Column() {
              Text(this.weatherInfo.icon)
                .fontSize(48)
                .margin({ top: 8, right: 24 })
            }
          }
          
          // 当前时间日期
          Column() {
            Text(this.currentTime)
              .fontSize(32)
              .fontColor('#fff')
              .fontWeight(FontWeight.Bold)
              .margin({ top: 16, bottom: 8 })
            Text(this.currentDate)
              .fontSize(16)
              .fontColor('#fff')
              .opacity(0.9)
              .margin({ bottom: 16 })
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height(200)
        .backgroundColor('#7ec6f5')
        .linearGradient({
          angle: 90,
          colors: [[0x7ec6f5, 1], [0x4a90e2, 1]]
        })
        .borderRadius(32)
        .margin({ left: 12, right: 12, top: 12, bottom: 18 })
        .shadow({ radius: 12, color: '#00000022', offsetX: 0, offsetY: 4 })
      }
      // 消息列表
      List() {
        ForEach(this.messages, (msg: MessageItem, idx: number) => {
          ListItem() {
            Row() {
              Image(msg.avatar)
                .width(48)
                .height(48)
                .borderRadius(24)
                .margin({ left: 16, right: 12 })
              Column({ space: 4 }) {
                Row() {
                  Text(msg.name)
                    .fontSize(16)
                    .fontColor(msg.isOfficial ? '#0D9FFB' : (msg.isSystem ? '#1976D2' : '#fff'))
                    .fontWeight(FontWeight.Bold)
                  if (msg.followed) {
                    Text('已关注')
                      .fontSize(12)
                      .fontColor('#888')
                      .margin({ left: 8 })
                  }
                  if (msg.isOfficial) {
                    Text('官方助手')
                      .fontSize(12)
                      .fontColor('#0D9FFB')
                      .backgroundColor('#222')
                      .margin({ left: 8 })
                      .borderRadius(6)
                      .padding({ left: 4, right: 4 })
                  }
                }
                Text(msg.desc)
                  .fontSize(13)
                  .fontColor('#bbb')
                  .maxLines(1)
                  .margin({ top: 2 })
              }
              .layoutWeight(1)
              Column() {
                Text(msg.time)
                  .fontSize(12)
                  .fontColor('#888')
                  .margin({ bottom: 8 })
                if (msg.unread > 0) {
                  Text(msg.unread.toString())
                    .fontSize(10)
                    .fontColor('#fff')
                    .backgroundColor('#FF5252')
                    .borderRadius(8)
                    .width(16)
                    .height(16)
                    .textAlign(TextAlign.Center)
                }
              }
              .alignItems(HorizontalAlign.End)
              .margin({ right: 16 })
            }
            .height(64)
            .backgroundColor('rgba(34,34,34,0)')
          }
        }, (msg: MessageItem) => msg.name + msg.time)
      }
      .width('100%')
      .backgroundColor('#181818')
      .layoutWeight(1)
      Blank().height(56)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#181818')
  }
} 