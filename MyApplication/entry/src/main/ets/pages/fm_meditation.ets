import router from '@ohos.router';

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
  private duration: number = 300; // 5分钟
  private bgms: string[] = ['自然风', '海浪声', '钢琴曲', '无'];
  @State selectedBgm: number = 0;

  aboutToDisappear() {
    this.stopPlay();
  }

  private startPlay() {
    this.isPlaying = true;
    this.stopPlay();
    this.timer = setInterval(() => {
      if (this.progress < 1.0) {
        this.progress += 1 / this.duration;
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

  // 切换卡片动画
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
      // 返回按钮（悬浮左上角）
      Row() {
        Button('<')
          .fontSize(20)
          .width(36)
          .height(36)
          .backgroundColor('#fff')
          .fontColor('#1976D2')
          .borderRadius(18)
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 2 })
          .onClick(() => router.back())
      }
      .position({ x: 12, y: 8 })

      // 顶部可切换冥想主题卡片
      Column() {
        Blank().height(15)
        Stack() {
          Stack() {
            // 卡片内容
            Column() {
              Row() {
                // 左侧切换按钮
                Button('‹')
                  .fontSize(24)
                  .fontColor('#1976D2')
                  .backgroundColor('#E3F2FD')
                  .borderRadius(20)
                  .width(40)
                  .height(40)
                  .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
                  .onClick(() => this.switchCard('left'))
                // 卡片内容
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
                .margin({ left: 16, right: 16 })
                // 右侧切换按钮
                Button('›')
                  .fontSize(24)
                  .fontColor('#1976D2')
                  .backgroundColor('#E3F2FD')
                  .borderRadius(20)
                  .width(40)
                  .height(40)
                  .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
                  .onClick(() => this.switchCard('right'))
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .backgroundColor('#E3F2FD')
            .borderRadius(16)
            .padding(20)
            .width('100%')
            .height(120)
            .opacity(this.cardOpacity)
            .translate({ x: this.cardTranslateX, y: 0 })
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.13)', offsetX: 0, offsetY: 4 })
          }
          // 指示点
          Row() {
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
            .layoutWeight(1)
          }
          .margin({ top: 12, bottom: 8 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
      }
      .width('100%')
      .height(200)
      .padding({ left: 0, right: 0, bottom: 0 })

      // 今日冥想统计
      Row() {
        Column() {
          Text('累计冥想')
            .fontColor('#888').fontSize(13)
          Text('32 分钟') // 可后续动态
            .fontColor('#1976D2').fontWeight(FontWeight.Bold).fontSize(18)
        }
        .margin({ right: 32 })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 渐变分割线
      Rect().width('100%').height(2).backgroundColor('#E3F2FD').margin({ bottom: 16 })

      // 冥想引导语区加插画
      Row() {
        Image($r('app.media.fmhome_softMusic'))
          .width(56).height(56).borderRadius(16).margin({ right: 12 })
        Column() {
          Text('请找一个安静舒适的位置，闭上眼睛，跟随引导语进行冥想。')
            .fontColor('#388E3C')
            .fontSize(15)
            .margin({ bottom: 2 })
          Text('放松身体，感受每一次呼吸。')
            .fontColor('#888')
            .fontSize(13)
        }
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 播放/暂停按钮与进度条
      Row() {
        Button(this.isPlaying ? '暂停' : '开始')
          .fontColor('#fff')
          .backgroundColor('#4CAF50')
          .borderRadius(24)
          .fontSize(20)
          .padding({ left: 40, right: 40, top: 14, bottom: 14 })
          .onClick(() => {
            if (this.isPlaying) {
              this.stopPlay();
            } else {
              this.startPlay();
            }
          })
        Text(Math.floor(this.progress * this.duration) + 's / ' + this.duration + 's')
          .fontColor('#888')
          .fontSize(14)
          .margin({ left: 18 })
      }
      .margin({ bottom: 8 })
      // 进度条
      Progress({ value: this.progress })
        .width('85%')
        .color('#4CAF50')
        .backgroundColor('#E0E0E0')
        .margin({ bottom: 24 })
        .borderRadius(8)

      // 背景音乐选择区美化
      Text('背景音乐')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1976D2')
        .margin({ bottom: 8 })
      Row() {
        ForEach(this.bgms, (bgm: string, idx: number) => {
          Row() {
            Text(
              bgm === '自然风' ? '🍃' : bgm === '海浪声' ? '🌊' : bgm === '钢琴曲' ? '🎹' : '🔇'
            ).fontSize(18).margin({ right: 4 })
            Text(bgm).fontSize(13)
              .fontColor(this.selectedBgm === idx ? '#fff' : '#1976D2')
          }

          .backgroundColor(this.selectedBgm === idx ? '#1976D2' : '#E3F2FD')
          .borderRadius(16)
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .margin({ right: 10 })
          .onClick(() => this.selectedBgm = idx)
        }, (bgm: string) => bgm)
      }
      .margin({ bottom: 24 })

      // 温馨提示区美化
      Row() {
        Text('💡').fontSize(18).margin({ right: 8 })
        Text('温馨提示：冥想过程中如有杂念，不必焦虑，轻轻将注意力带回呼吸即可。')
          .fontColor('#888')
          .fontSize(13)
      }
      .backgroundColor('#F5F7FA')
      .borderRadius(12)
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .margin({ bottom: 32 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 0 })
    .backgroundColor('#F8F9FB')
  }
} 
