import router from '@ohos.router';

const TIME_OPTIONS: number[] = [1, 5, 10, 30];
const TIME_LABELS: string[] = ['1分钟', '5分钟', '10分钟', '30分钟'];

@Entry
@Component
struct FMMeditationPage {
  @State currentCard: number = 0
  @State cardOpacity: number = 1.0
  @State cardTranslateX: number = 0
  private themes: string[] = ['基础冥想', '呼吸觉察', '身体扫描', '睡前放松'];
  private themeDesc: string[] = [
    '适合新手的基础冥想，帮助你快速进入状态',
    '专注呼吸，缓解焦虑与压力',
    '关注身体感受，释放紧张',
    '助眠冥想，放松身心，安然入睡'
  ];
  private themeEmoji: string[] = ['🧘‍♂️', '🌬️', '🛌', '😴'];
  @State isPlaying: boolean = false;
  @State progress: number = 0.0;
  private timer: number = -1;
  @State duration: number = 300; // 默认5分钟
  private bgms: string[] = ['自然风', '海浪声', '钢琴曲', '无'];
  @State selectedBgm: number = 0;
  @State elapsedSeconds: number = 0;
  @State showCustomTimeDialog: boolean = false;
  @State customHour: string = '0';
  @State customMinute: string = '5';
  @State customSecond: string = '0';
  @State selectedTimeIndex: number = 1; // 默认5分钟

  aboutToDisappear() {
    this.stopPlay();
  }

  private startPlay() {
    this.isPlaying = true;
    this.timer = setInterval(() => {
      if (this.progress < this.duration) {
        this.progress += 1;
        this.elapsedSeconds++;
      } else {
        this.stopPlay();
      }
    }, 1000);
  }

  private stopPlay() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    this.isPlaying = false;
  }

  private switchCard(direction: 'left' | 'right') {
    animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
      this.cardOpacity = 0;
      this.cardTranslateX = direction === 'left' ? -20 : 20;
    })
    setTimeout(() => {
      if (direction === 'left') {
        this.currentCard = (this.currentCard - 1 + this.themes.length) % this.themes.length;
      } else {
        this.currentCard = (this.currentCard + 1) % this.themes.length;
      }
      this.cardTranslateX = direction === 'left' ? 20 : -20;
      animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
        this.cardOpacity = 1.0;
        this.cardTranslateX = 0;
      })
    }, 200)
  }

  private setCard(idx: number) {
    if (idx === this.currentCard) return;
    const direction = idx > this.currentCard ? 'right' : 'left';
    this.switchCard(direction);
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.music_return'))
          .width(36)
          .height(36)
          //.shadow({ radius: 4, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 2 })
          .onClick(() => router.back())
        Text('冥想')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1976D2')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(36)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor('#fff')

      // 主要内容区域
      Scroll() {
        Column() {
          // 主题卡片区域
          Row() {
            Button('‹')
              .fontSize(24)
              .fontColor('#1976D2')
              .backgroundColor('#E3F2FD')
              .borderRadius(20)
              .width(40)
              .height(40)
              .margin({ left: 16, right: 0 })
              .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
              .onClick(() => this.switchCard('left'))
              .align(Alignment.Center)
            Column() {
              Row() {
                Text(this.themeEmoji[this.currentCard])
                  .fontSize(36)
                  .margin({ right: 12 })
                Column() {
                  Text(this.themes[this.currentCard])
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1976D2')
                  Text(this.themeDesc[this.currentCard])
                    .fontSize(15)
                    .fontColor('#1976D2')
                    .opacity(0.8)
                }
                .layoutWeight(1)
              }
              .margin({ bottom: 8 })
              Text('5分钟正念冥想，放松身心')
                .fontSize(13)
                .fontColor('#1976D2')
                .opacity(0.7)
                .textAlign(TextAlign.Start)
            }
            .layoutWeight(1)
            .margin({ left: 8, right: 8 })
            Button('›')
              .fontSize(24)
              .fontColor('#1976D2')
              .backgroundColor('#E3F2FD')
              .borderRadius(20)
              .width(40)
              .height(40)
              .margin({ left: 0, right: 16 })
              .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
              .onClick(() => this.switchCard('right'))
              .align(Alignment.Center)
          }
          .backgroundColor('#E3F2FD')
          .borderRadius(16)
          .padding(16)
          .width('92%')
          .height(110)
          .margin({ top: 4, bottom: 0 })
          .alignItems(VerticalAlign.Center)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.13)', offsetX: 0, offsetY: 4 })

          // 指示点
          Row() {
            ForEach(this.themes, (theme: string, idx: number) => {
              Blank()
                .width(idx === this.currentCard ? 24 : 8)
                .height(8)
                .backgroundColor(idx === this.currentCard ? '#1976D2' : '#eee')
                .borderRadius(4)
                .margin({ right: 4 })
                .animation({ duration: 300, curve: Curve.EaseInOut })
                .onClick(() => { if (idx !== this.currentCard) this.setCard(idx) })
            }, (theme: string) => theme)
          }
          .justifyContent(FlexAlign.Center)
          .margin({ top: 10, bottom: 18 })

          // 冥想时长选择区
          Row() {
            ForEach(TIME_OPTIONS, (opt: number, idx: number) => {
              Button(TIME_LABELS[idx])
                .fontColor(this.selectedTimeIndex === idx ? '#fff' : '#1976D2')
                .backgroundColor(this.selectedTimeIndex === idx ? '#1976D2' : '#E3F2FD')
                .borderRadius(16)
                .fontSize(14)
                .width(90)
                .height(36)
                .margin({ right: 10 })
                .onClick(() => {
                  this.selectedTimeIndex = idx;
                  if (opt === -1) {
                    this.showCustomTimeDialog = true;
                  } else {
                    this.duration = opt * 60;
                    this.progress = 0;
                    this.elapsedSeconds = 0;
                  }
                })
            }, (opt: number, idx: number) => idx.toString())
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 18 })

          // 引导区
          Column() {
            Text('请找一个安静舒适的位置，闭上眼睛，跟随引导语进行冥想。')
              .fontColor('#388E3C')
              .fontSize(16)
              .margin({ bottom: 2 })
              .textAlign(TextAlign.Center)
            Text('放松身体，感受每一次呼吸。')
              .fontColor('#888')
              .fontSize(14)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .margin({ bottom: 20 })
          .alignItems(HorizontalAlign.Center)

          // 播放区
          Column() {
            Button(this.isPlaying ? '暂停' : '开始冥想')
              .fontColor('#fff')
              .backgroundColor('#4CAF50')
              .borderRadius(28)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .width('90%')
              .height(60)
              .margin({ bottom: 18, top: 4 })
              .onClick(() => {
                if (this.isPlaying) {
                  this.stopPlay();
                } else {
                  this.startPlay();
                }
              })
            Row() {
              Text(this.formatTime(this.elapsedSeconds))
                .fontColor('#1976D2')
                .fontSize(16)
                .margin({ right: 10 })
              Progress({ value: this.progress*100 / this.duration })
                .width('60%')
                .color('#4CAF50')
                .backgroundColor('#E0E0E0')
                .borderRadius(8)
              Text(this.formatTime(this.duration))
                .fontColor('#888')
                .fontSize(16)
                .margin({ left: 10 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 8, bottom: 8 })
          }
          .width('100%')
          .margin({ bottom: 24 })

          // 统计区
          Row() {
            Column() {
              Text('累计冥想')
                .fontColor('#888').fontSize(13)
              Text(`${Math.floor(this.elapsedSeconds / 60)} 分钟`)
                .fontColor('#1976D2').fontWeight(FontWeight.Bold).fontSize(20)
            }
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 18 })

          // 温馨提示区
          Row() {
            Text('💡').fontSize(18).margin({ right: 8 })
            Text('温馨提示：冥想过程中如有杂念，不必焦虑，轻轻将注意力带回呼吸即可。')
              .fontColor('#888')
              .fontSize(13)
          }
          .backgroundColor('#F5F7FA')
          .borderRadius(12)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .margin({ bottom: 36 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .backgroundColor('#F8F9FB')
    }
    .width('100%')
    .height('100%')
  }

  private formatTime(seconds: number): string {
    const min = Math.floor(seconds / 60);
    const sec = seconds % 60;
    return `${min}:${sec.toString().padStart(2, '0')}`;
  }
}
