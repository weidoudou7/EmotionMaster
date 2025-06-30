import router from '@ohos.router';

// 呼吸模式定义
interface BreathingPattern {
  id: string;
  name: string;
  description: string;
  inhaleTime: number;
  holdTime: number;
  exhaleTime: number;
  holdAfterExhale: number;
  emoji: string;
  color: string;
  bgColor: string;
}

const BREATHING_PATTERNS: BreathingPattern[] = [
  {
    id: '478',
    name: '4-7-8呼吸法',
    description: '经典放松呼吸，缓解焦虑',
    inhaleTime: 4,
    holdTime: 7,
    exhaleTime: 8,
    holdAfterExhale: 0,
    emoji: '🌬️',
    color: '#4CAF50',
    bgColor: '#E8F5E8'
  },
  {
    id: 'box',
    name: '方框呼吸',
    description: '平衡呼吸节奏，提升专注',
    inhaleTime: 4,
    holdTime: 4,
    exhaleTime: 4,
    holdAfterExhale: 4,
    emoji: '⬜',
    color: '#2196F3',
    bgColor: '#E3F2FD'
  },
  {
    id: 'belly',
    name: '腹式呼吸',
    description: '深度腹式呼吸，缓解压力',
    inhaleTime: 5,
    holdTime: 2,
    exhaleTime: 6,
    holdAfterExhale: 1,
    emoji: '🫁',
    color: '#FF9800',
    bgColor: '#FFF3E0'
  },
  {
    id: 'coherence',
    name: '和谐呼吸',
    description: '6秒呼吸节奏，平衡身心',
    inhaleTime: 6,
    holdTime: 0,
    exhaleTime: 6,
    holdAfterExhale: 0,
    emoji: '💫',
    color: '#9C27B0',
    bgColor: '#F3E5F5'
  }
];

@Entry
@Component
struct FMBreathingPage {
  @State currentPattern: BreathingPattern = BREATHING_PATTERNS[0];
  @State isPlaying: boolean = false;
  @State currentPhase: 'inhale' | 'hold' | 'exhale' | 'holdAfterExhale' = 'inhale';
  @State phaseProgress: number = 0;
  @State totalProgress: number = 0;
  @State elapsedSeconds: number = 0;
  @State selectedDuration: number = 300; // 5分钟
  @State selectedPatternIndex: number = 0;
  @State showPatternSelector: boolean = false;
  @State showSettings: boolean = false;
  @State breathCount: number = 0;
  @State circleScale: number = 1.0;
  @State circleOpacity: number = 0.8;
  @State phaseStartTime: number = 0;
  @State sessionStartTime: number = 0;
  @State pausedTime: number = 0;
  @State isPaused: boolean = false;
  @State savedCircleScale: number = 1.0;
  @State savedCircleOpacity: number = 0.8;
  @State textOpacity: number = 1.0;
  @State textTranslateY: number = 0;
  @State isTransitioning: boolean = false;
  
  private timer: number = -1;
  private phaseTimer: number = -1;
  private durationOptions: number[] = [60, 180, 300, 600, 900]; // 1,3,5,10,15分钟
  private durationLabels: string[] = ['1分钟', '3分钟', '5分钟', '10分钟', '15分钟'];

  aboutToDisappear() {
    this.stopBreathing();
  }

  private startBreathing() {
    if (this.isPaused) {
      // 恢复暂停的会话
      this.resumeBreathing();
    } else {
      // 开始新的会话
      this.isPlaying = true;
      this.breathCount = 0;
      this.elapsedSeconds = 0;
      this.totalProgress = 0;
      this.sessionStartTime = Date.now();
      // 重置文字动画状态
      this.textOpacity = 1.0;
      this.textTranslateY = 0;
      this.isTransitioning = false;
      this.startBreathingCycle();
    }
  }

  private pauseBreathing() {
    // 停止计时器
    if (this.phaseTimer !== -1) {
      clearInterval(this.phaseTimer);
      this.phaseTimer = -1;
    }
    
    // 保存当前动画状态
    this.savedCircleScale = this.circleScale;
    this.savedCircleOpacity = this.circleOpacity;
    
    this.isPlaying = false;
    this.isPaused = true;
    this.pausedTime = Date.now();
  }

  private resumeBreathing() {
    if (!this.isPaused) return;
    
    const pauseDuration = Date.now() - this.pausedTime;
    // 调整开始时间以补偿暂停的时间
    this.sessionStartTime += pauseDuration;
    this.phaseStartTime += pauseDuration;
    
    // 恢复动画状态
    this.circleScale = this.savedCircleScale;
    this.circleOpacity = this.savedCircleOpacity;
    
    this.isPlaying = true;
    this.isPaused = false;
    this.animatePhase();
  }

  private stopBreathing() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    if (this.phaseTimer !== -1) {
      clearInterval(this.phaseTimer);
      this.phaseTimer = -1;
    }
    this.isPlaying = false;
    this.isPaused = false;
    this.currentPhase = 'inhale';
    this.phaseProgress = 0;
    this.circleScale = 1.0;
    this.circleOpacity = 0.8;
    this.savedCircleScale = 1.0;
    this.savedCircleOpacity = 0.8;
    this.elapsedSeconds = 0;
    this.totalProgress = 0;
    this.breathCount = 0;
    // 重置文字动画状态
    this.textOpacity = 1.0;
    this.textTranslateY = 0;
    this.isTransitioning = false;
  }

  private startBreathingCycle() {
    this.currentPhase = 'inhale';
    this.phaseProgress = 0;
    this.phaseStartTime = Date.now();
    this.animatePhase();
  }

  private animatePhase() {
    const pattern = this.currentPattern;
    let phaseDuration = 0;
    
    switch (this.currentPhase) {
      case 'inhale':
        phaseDuration = pattern.inhaleTime;
        break;
      case 'hold':
        phaseDuration = pattern.holdTime;
        break;
      case 'exhale':
        phaseDuration = pattern.exhaleTime;
        break;
      case 'holdAfterExhale':
        phaseDuration = pattern.holdAfterExhale;
        break;
    }

    if (phaseDuration === 0) {
      this.nextPhase();
      return;
    }

    // 动画效果 - 防止动画回调干扰阶段切换
    if (this.isPlaying) {
      if (this.currentPhase === 'inhale') {
        // 吸气动画：从小到大的圆圈
        animateTo({ duration: phaseDuration * 1000, curve: Curve.EaseInOut }, () => {
          // 动画完成后的状态 - 但不触发阶段切换
          if (this.isPlaying && this.currentPhase === 'inhale') {
            this.circleScale = 1.8;
            this.circleOpacity = 1.0;
          }
        });
      } else if (this.currentPhase === 'exhale') {
        // 呼气动画：从大到小的圆圈
        animateTo({ duration: phaseDuration * 1000, curve: Curve.EaseInOut }, () => {
          // 动画完成后的状态 - 但不触发阶段切换
          if (this.isPlaying && this.currentPhase === 'exhale') {
            this.circleScale = 1.0;
            this.circleOpacity = 0.8;
          }
        });
      } else if (this.currentPhase === 'hold') {
        // 屏息状态：保持吸气完成的状态
        this.circleScale = 1.8;
        this.circleOpacity = 1.0;
      } else if (this.currentPhase === 'holdAfterExhale') {
        // 呼气后屏息状态：保持呼气完成的状态
        this.circleScale = 1.0;
        this.circleOpacity = 0.8;
      }
    }

    // 使用更精确的计时器，独立于动画
    this.phaseTimer = setInterval(() => {
      if (!this.isPlaying) {
        return; // 如果暂停了，不更新时间
      }
      
      const currentTime = Date.now();
      const phaseElapsed = Math.floor((currentTime - this.phaseStartTime) / 1000);
      const sessionElapsed = Math.floor((currentTime - this.sessionStartTime) / 1000);
      
      // 使用实际经过的时间作为进度，不进行限制
      this.phaseProgress = phaseElapsed;
      this.elapsedSeconds = sessionElapsed;
      
      // 确保阶段完全结束后才切换，使用严格的时间比较
      if (phaseElapsed >= phaseDuration) {
        clearInterval(this.phaseTimer);
        this.phaseTimer = -1;
        if (this.isPlaying) {
          // 确保当前阶段确实应该结束
          const actualPhaseDuration = this.getPhaseTime();
          if (phaseElapsed >= actualPhaseDuration) {
            this.nextPhase();
          }
        }
      }
    }, 100); // 更频繁的更新以获得更精确的计时
  }

  private nextPhase() {
    if (!this.isPlaying) {
      return; // 如果暂停了，不进入下一阶段
    }
    
    const pattern = this.currentPattern;
    
    switch (this.currentPhase) {
      case 'inhale':
        if (pattern.holdTime > 0) {
          this.currentPhase = 'hold';
        } else if (pattern.exhaleTime > 0) {
          this.currentPhase = 'exhale';
        } else {
          this.completeBreath();
        }
        break;
      case 'hold':
        if (pattern.exhaleTime > 0) {
          this.currentPhase = 'exhale';
        } else {
          this.completeBreath();
        }
        break;
      case 'exhale':
        if (pattern.holdAfterExhale > 0) {
          this.currentPhase = 'holdAfterExhale';
        } else {
          this.completeBreath();
        }
        break;
      case 'holdAfterExhale':
        this.completeBreath();
        break;
    }
    
    // 触发文字切换动画
    this.animateTextTransition();
    
    // 重置阶段进度和时间
    this.phaseProgress = 0;
    this.phaseStartTime = Date.now();
    
    // 延迟一帧再开始下一个阶段的动画，确保状态完全更新
    setTimeout(() => {
      if (this.isPlaying) {
        this.animatePhase();
      }
    }, 10);
  }

  private completeBreath() {
    if (!this.isPlaying) {
      return; // 如果暂停了，不完成呼吸周期
    }
    
    this.breathCount++;
    this.totalProgress = (this.elapsedSeconds / this.selectedDuration) * 100;
    
    if (this.elapsedSeconds >= this.selectedDuration) {
      this.stopBreathing();
      return;
    }
    
    // 开始新的呼吸周期
    this.currentPhase = 'inhale';
    this.phaseProgress = 0;
    this.phaseStartTime = Date.now();
    
    // 延迟一帧再开始新的呼吸周期，确保状态完全重置
    setTimeout(() => {
      if (this.isPlaying) {
        this.animatePhase();
      }
    }, 10);
  }

  private getPhaseText(): string {
    switch (this.currentPhase) {
      case 'inhale':
        return '吸气';
      case 'hold':
        return '屏息';
      case 'exhale':
        return '呼气';
      case 'holdAfterExhale':
        return '屏息';
      default:
        return '';
    }
  }

  private getPhaseTime(): number {
    const pattern = this.currentPattern;
    switch (this.currentPhase) {
      case 'inhale':
        return pattern.inhaleTime;
      case 'hold':
        return pattern.holdTime;
      case 'exhale':
        return pattern.exhaleTime;
      case 'holdAfterExhale':
        return pattern.holdAfterExhale;
      default:
        return 0;
    }
  }

  private getRemainingTime(): number {
    const phaseTime = this.getPhaseTime();
    const remaining = phaseTime - this.phaseProgress;
    return Math.max(0, remaining);
  }

  private animateTextTransition() {
    this.isTransitioning = true;
    
    // 当前文字向下淡出
    animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
      this.textOpacity = 0;
      this.textTranslateY = 20;
    });
    
    // 延迟后新文字向上淡入
    setTimeout(() => {
      if (this.isPlaying) {
        animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
          this.textOpacity = 1;
          this.textTranslateY = 0;
        });
        
        // 动画完成后重置状态
        setTimeout(() => {
          this.isTransitioning = false;
        }, 300);
      }
    }, 300);
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Button('‹')
          .fontSize(22)
          .fontColor('#1976D2')
          .backgroundColor('#fff')
          .borderRadius(18)
          .width(36)
          .height(36)
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 2 })
          .onClick(() => router.back())
        Text('呼吸训练')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1976D2')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Button('⚙️')
          .fontSize(18)
          .fontColor('#1976D2')
          .backgroundColor('#fff')
          .borderRadius(18)
          .width(36)
          .height(36)
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 2 })
          .onClick(() => this.showSettings = true)
      }
      .width('100%')
      .padding({ top: 16, left: 12, right: 12, bottom: 16 })

      // 可滚动内容区域
      Scroll() {
        Column() {
          // 呼吸模式选择器
          if (!this.isPlaying) {
            Column() {
              Text('选择呼吸模式')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .margin({ bottom: 12 })
              
              ForEach(BREATHING_PATTERNS, (pattern: BreathingPattern, idx: number) => {
                Row() {
                  Text(pattern.emoji)
                    .fontSize(24)
                    .margin({ right: 12 })
                  Column() {
                    Text(pattern.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333')
                    Text(pattern.description)
                      .fontSize(13)
                      .fontColor('#666')
                      .margin({ top: 2 })
                    Text(`${pattern.inhaleTime}-${pattern.holdTime}-${pattern.exhaleTime}${pattern.holdAfterExhale > 0 ? '-' + pattern.holdAfterExhale : ''}`)
                      .fontSize(12)
                      .fontColor(pattern.color)
                      .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(16)
                .backgroundColor(this.selectedPatternIndex === idx ? pattern.bgColor : '#f8f9fa')
                .borderRadius(12)
                .margin({ bottom: 8 })
                .onClick(() => {
                  this.selectedPatternIndex = idx;
                  this.currentPattern = pattern;
                })
              }, (pattern: BreathingPattern) => pattern.id)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .margin({ bottom: 20 })

            // 时长选择
            Column() {
              Text('训练时长')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .margin({ bottom: 12 })
              
              // 第一行：1、3、5分钟
              Row() {
                ForEach([0, 1, 2], (idx: number) => {
                  Button(this.durationLabels[idx])
                    .fontColor(this.selectedDuration === this.durationOptions[idx] ? '#fff' : '#1976D2')
                    .backgroundColor(this.selectedDuration === this.durationOptions[idx] ? '#1976D2' : '#E3F2FD')
                    .borderRadius(16)
                    .fontSize(14)
                    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.selectedDuration = this.durationOptions[idx];
                    })
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .margin({ bottom: 8 })
              
              // 第二行：10、15分钟
              Row() {
                ForEach([3, 4], (idx: number) => {
                  Button(this.durationLabels[idx])
                    .fontColor(this.selectedDuration === this.durationOptions[idx] ? '#fff' : '#1976D2')
                    .backgroundColor(this.selectedDuration === this.durationOptions[idx] ? '#1976D2' : '#E3F2FD')
                    .borderRadius(16)
                    .fontSize(14)
                    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.selectedDuration = this.durationOptions[idx];
                    })
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .margin({ bottom: 24 })
          }

          // 呼吸动画区域
          Column() {
            Stack() {
              // 背景圆圈
              Circle()
                .width(280)
                .height(280)
                .fill(this.currentPattern.bgColor)
                .opacity(0.3)
              
              // 动态呼吸圆圈
              Circle()
                .width(200)
                .height(200)
                .fill(this.currentPattern.color)
                .opacity(this.circleOpacity)
                .scale({ x: this.circleScale, y: this.circleScale })
              
              // 中心文字
              Column() {
                if (this.isPlaying) {
                  Text(this.getPhaseText())
                    .fontSize(32)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#fff')
                    .margin({ bottom: 8 })
                    .opacity(this.textOpacity)
                    .translate({ y: this.textTranslateY })
                  Text(`${Math.max(0, this.getRemainingTime())}s`)
                    .fontSize(18)
                    .fontColor('#fff')
                    .opacity(0.9)
                } else if (this.isPaused) {
                  Text('⏸️')
                    .fontSize(48)
                    .margin({ bottom: 8 })
                  Text('已暂停')
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333')
                } else {
                  Text(this.currentPattern.emoji)
                    .fontSize(48)
                    .margin({ bottom: 8 })
                  Text('准备开始')
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333')
                }
              }
            }
            .width('100%')
            .height(320)
            .margin({ bottom: 24 })

            // 控制按钮
            Row() {
              Button(this.isPlaying ? '暂停' : (this.isPaused ? '继续' : '开始'))
                .fontColor('#fff')
                .backgroundColor(this.isPlaying ? '#FF5722' : '#4CAF50')
                .borderRadius(24)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .padding({ left: 40, right: 40, top: 12, bottom: 12 })
                .margin({ right: 12 })
                .onClick(() => {
                  if (this.isPlaying) {
                    this.pauseBreathing();
                  } else {
                    this.startBreathing();
                  }
                })
              
              if (this.isPlaying || this.isPaused) {
                Button('停止')
                  .fontColor('#fff')
                  .backgroundColor('#666')
                  .borderRadius(24)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .padding({ left: 40, right: 40, top: 12, bottom: 12 })
                  .onClick(() => {
                    this.stopBreathing();
                  })
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 20 })

            // 进度信息
            if (this.isPlaying || this.isPaused) {
              Column() {
                Row() {
                  Text(`呼吸次数: ${this.breathCount}`)
                    .fontSize(14)
                    .fontColor('#666')
                  Text(`剩余时间: ${Math.max(0, Math.floor((this.selectedDuration - this.elapsedSeconds) / 60))}:${Math.max(0, (this.selectedDuration - this.elapsedSeconds) % 60).toString().padStart(2, '0')}`)
                    .fontSize(14)
                    .fontColor('#666')
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ bottom: 8 })
                
                Progress({ value: this.totalProgress })
                  .color(this.currentPattern.color)
                  .backgroundColor('#E0E0E0')
                  .width('100%')
                  .height(6)
                  .borderRadius(3)
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
              .margin({ bottom: 20 })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // 设置弹窗
      if (this.showSettings) {
        Stack() {
          Column()
            .backgroundColor('rgba(0,0,0,0.5)')
            .width('100%')
            .height('100%')
            .onClick(() => this.showSettings = false)
          
          Column() {
            Text('设置')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })
            
            Row() {
              Text('引导语音')
                .fontSize(16)
                .fontColor('#333')
              Toggle({ type: ToggleType.Switch, isOn: true })
                .margin({ left: 16 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 12 })
            
            Row() {
              Text('背景音乐')
                .fontSize(16)
                .fontColor('#333')
              Toggle({ type: ToggleType.Switch, isOn: false })
                .margin({ left: 16 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 12 })
            
            Row() {
              Text('振动提醒')
                .fontSize(16)
                .fontColor('#333')
              Toggle({ type: ToggleType.Switch, isOn: true })
                .margin({ left: 16 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 20 })
            
            Button('确定')
              .fontColor('#fff')
              .backgroundColor('#1976D2')
              .borderRadius(12)
              .width('100%')
              .onClick(() => this.showSettings = false)
          }
          .width('80%')
          .backgroundColor('#fff')
          .borderRadius(16)
          .padding(24)
          .alignSelf(ItemAlign.Center)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FB')
  }
} 