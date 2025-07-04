import router from '@ohos.router';
import { ApiService } from '../service/apiservice';
import { AudioPlayerService, AudioPlayerState } from '../service/audioPlayer';
import promptAction from '@ohos.promptAction';
@Entry
@Component
struct MusicTestPage {
  @State musicId: string = '1824045033';
  @State musicUrl: string = '';
  @State isPlaying: boolean = false;
  @State currentTime: number = 0;
  @State duration: number = 0;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  
  private audioPlayerService: AudioPlayerService = new AudioPlayerService();

  aboutToAppear() {
    this.setupAudioCallbacks();
  }

  aboutToDisappear() {
    this.audioPlayerService.destroy();
  }

  setupAudioCallbacks() {
    this.audioPlayerService.setCallbacks({
      onStateChange: (state: AudioPlayerState) => {
        this.isPlaying = state === AudioPlayerState.PLAYING;
        console.log('播放状态变化:', state);
      },
      onProgressChange: (currentTime: number, duration: number) => {
        this.currentTime = Math.floor(currentTime);
        this.duration = Math.floor(duration);
      },
      onError: (error: string) => {
        this.errorMessage = error;
        this.isLoading = false;
        promptAction.showToast({ message: '播放错误: ' + error });
      },
      onComplete: () => {
        this.isPlaying = false;
        this.currentTime = 0;
        promptAction.showToast({ message: '播放完成' });
      }
    });
  }

  async getMusicUrl() {
    try {
      this.isLoading = true;
      this.errorMessage = '';
      
      console.log('获取音乐URL，ID:', this.musicId);
      const url = await ApiService.getMusicPlayUrl(this.musicId);
      this.musicUrl = url;
      
      console.log('获取到音乐URL:', url);
      promptAction.showToast({ message: '获取音乐URL成功' });
      
    } catch (error) {
      console.error('获取音乐URL失败:', error);
      this.errorMessage = error instanceof Error ? error.message : '未知错误';
      promptAction.showToast({ message: '获取音乐URL失败: ' + this.errorMessage });
    } finally {
      this.isLoading = false;
    }
  }

  async initAndPlay() {
    try {
      if (!this.musicUrl) {
        promptAction.showToast({ message: '请先获取音乐URL' });
        return;
      }

      this.isLoading = true;
      console.log('初始化播放器，URL:', this.musicUrl);
      
      await this.audioPlayerService.initPlayer(this.musicUrl);
      await this.audioPlayerService.play();
      
      promptAction.showToast({ message: '开始播放' });
      
    } catch (error) {
      console.error('播放失败:', error);
      this.errorMessage = error instanceof Error ? error.message : '未知错误';
      promptAction.showToast({ message: '播放失败: ' + this.errorMessage });
    } finally {
      this.isLoading = false;
    }
  }

  async togglePlay() {
    try {
      if (this.isPlaying) {
        await this.audioPlayerService.pause();
      } else {
        await this.audioPlayerService.play();
      }
    } catch (error) {
      console.error('播放控制失败:', error);
      promptAction.showToast({ message: '播放控制失败' });
    }
  }

  async stopPlay() {
    try {
      await this.audioPlayerService.stop();
    } catch (error) {
      console.error('停止播放失败:', error);
    }
  }

  formatTime(time: number): string {
    const m = Math.floor(time / 60);
    const s = Math.floor(time % 60);
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Button('‹ 返回')
          .fontSize(16)
          .fontColor('#fff')
          .backgroundColor('#333')
          .borderRadius(8)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => router.back())
        
        Text('音乐播放测试')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#2d2d2d')

      // 主要内容
      Column() {
        // 音乐ID输入
        Row() {
          Text('音乐ID:')
            .fontSize(16)
            .fontColor('#333')
            .width(80)
          
          TextInput({ text: this.musicId })
            .width('100%')
            .height(40)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
            .padding({ left: 12, right: 12 })
            .onChange((value: string) => {
              this.musicId = value;
            })
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 获取音乐URL按钮
        Button('获取音乐URL')
          .width('100%')
          .height(50)
          .backgroundColor('#0D9FFB')
          .fontColor('#fff')
          .borderRadius(8)
          .margin({ bottom: 16 })
          .onClick(() => this.getMusicUrl())

        // 音乐URL显示
        if (this.musicUrl) {
          Column() {
            Text('音乐URL:')
              .fontSize(14)
              .fontColor('#666')
              .margin({ bottom: 8 })
            Text(this.musicUrl)
              .fontSize(12)
              .fontColor('#333')
              .backgroundColor('#f9f9f9')
              .borderRadius(8)
              .padding(12)
              .width('100%')
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .margin({ bottom: 20 })
        }

        // 播放控制按钮
        Row() {
          Button('初始化并播放')
            .layoutWeight(1)
            .height(50)
            .backgroundColor('#4CAF50')
            .fontColor('#fff')
            .borderRadius(8)
            .margin({ right: 8 })
            .onClick(() => this.initAndPlay())
          
          Button(this.isPlaying ? '暂停' : '播放')
            .layoutWeight(1)
            .height(50)
            .backgroundColor(this.isPlaying ? '#FF9800' : '#2196F3')
            .fontColor('#fff')
            .borderRadius(8)
            .margin({ left: 8 })
            .onClick(() => this.togglePlay())
        }
        .width('100%')
        .margin({ bottom: 16 })

        Button('停止播放')
          .width('100%')
          .height(50)
          .backgroundColor('#F44336')
          .fontColor('#fff')
          .borderRadius(8)
          .margin({ bottom: 20 })
          .onClick(() => this.stopPlay())

        // 播放进度
        Column() {
          Text('播放进度:')
            .fontSize(16)
            .fontColor('#333')
            .margin({ bottom: 8 })
          
          Row() {
            Text(this.formatTime(this.currentTime))
              .fontSize(14)
              .fontColor('#666')
              .width(50)
              .textAlign(TextAlign.Center)
            
            Slider({
              value: this.currentTime,
              min: 0,
              max: this.duration,
              step: 1
            })
              .width('100%')
              .layoutWeight(1)
              .margin({ left: 12, right: 12 })
            
            Text(this.formatTime(this.duration))
              .fontSize(14)
              .fontColor('#666')
              .width(50)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 状态信息
        Column() {
          Text('状态信息:')
            .fontSize(16)
            .fontColor('#333')
            .margin({ bottom: 8 })
          
          Text('播放状态: ' + (this.isPlaying ? '播放中' : '已停止'))
            .fontSize(14)
            .fontColor(this.isPlaying ? '#4CAF50' : '#666')
            .margin({ bottom: 4 })
          
          Text('加载状态: ' + (this.isLoading ? '加载中...' : '已完成'))
            .fontSize(14)
            .fontColor(this.isLoading ? '#FF9800' : '#666')
            .margin({ bottom: 4 })
          
          if (this.errorMessage) {
            Text('错误信息: ' + this.errorMessage)
              .fontSize(14)
              .fontColor('#F44336')
              .margin({ bottom: 4 })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#f9f9f9')
        .borderRadius(8)

        // 测试音乐ID列表
        Column() {
          Text('测试音乐ID:')
            .fontSize(16)
            .fontColor('#333')
            .margin({ bottom: 8 })
          
          Row() {
            Button('句号')
              .layoutWeight(1)
              .height(40)
              .backgroundColor('#E3F2FD')
              .fontColor('#1976D2')
              .borderRadius(8)
              .margin({ right: 8 })
              .onClick(() => {
                this.musicId = '1824045033';
              })
            
            Button('稻香')
              .layoutWeight(1)
              .height(40)
              .backgroundColor('#E3F2FD')
              .fontColor('#1976D2')
              .borderRadius(8)
              .margin({ left: 8 })
              .onClick(() => {
                this.musicId = '185924';
              })
          }
          .width('100%')
          .margin({ bottom: 8 })
          
          Row() {
            Button('青花瓷')
              .layoutWeight(1)
              .height(40)
              .backgroundColor('#E3F2FD')
              .fontColor('#1976D2')
              .borderRadius(8)
              .margin({ right: 8 })
              .onClick(() => {
                this.musicId = '185924';
              })
            
            Button('夜曲')
              .layoutWeight(1)
              .height(40)
              .backgroundColor('#E3F2FD')
              .fontColor('#1976D2')
              .borderRadius(8)
              .margin({ left: 8 })
              .onClick(() => {
                this.musicId = '185924';
              })
          }
          .width('100%')
        }
        .width('100%')
        .margin({ top: 20 })
      }
      .layoutWeight(1)
      .padding(16)
      .backgroundColor('#fff')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
} 