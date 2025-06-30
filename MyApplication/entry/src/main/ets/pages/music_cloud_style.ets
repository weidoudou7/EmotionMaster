import router from '@ohos.router';
import { ApiService } from '../service/apiservice';
import { AudioPlayerService, AudioPlayerState, AudioPlayerCallbacks } from '../service/audioPlayer';
import promptAction from '@ohos.promptAction';

interface SongInfo {
  title: string;
  artist: string;
  cover: Resource;
  duration: number;
  musicId: string;
}

@Entry
@Component
struct CloudMusicPlayer {
  @State isPlaying: boolean = false;
  @State rotateAngle: number = 0;
  @State needleAngle: number = -30;
  @State currentTime: number = 0;
  @State duration: number = 235;
  @State isLoading: boolean = false;
  @State isInitialized: boolean = false;
  @State errorMessage: string = '';
  
  private rotateTimerId: number = -1;
  private audioPlayerService: AudioPlayerService = new AudioPlayerService();
  
  @State song: SongInfo = {
    title: '句号',
    artist: 'G.E.M.邓紫棋',
    cover: $r('app.media.splash'),
    duration: 235,
    musicId: '1824045033' // 默认音乐ID，实际应该从路由参数获取
  };

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>;
    if (params?.musicId) {
      this.song.musicId = params.musicId;
    }
    if (params?.musicTitle) {
      this.song.title = params.musicTitle;
    }
    if (params?.musicArtist) {
      this.song.artist = params.musicArtist;
    }
    
    // 设置音频播放器回调
    this.setupAudioCallbacks();
    
    // 初始化音频播放器
    this.initAudioPlayer();
  }

  aboutToDisappear() {
    // 页面销毁时释放资源
    this.audioPlayerService.destroy();
    this.stopRotate();
  }

  // 设置音频播放器回调
  setupAudioCallbacks() {
    const callbacks: AudioPlayerCallbacks = {
      onStateChange: (state: AudioPlayerState) => {
        console.log('音频播放器状态变化:', state);
        this.isPlaying = state === AudioPlayerState.PLAYING;
        
        if (this.isPlaying) {
          this.needleAngle = 0;
          this.startRotate();
        } else {
          this.needleAngle = -30;
          this.stopRotate();
        }
      },
      
      onProgressChange: (currentTime: number, duration: number) => {
        this.currentTime = Math.floor(currentTime);
        this.duration = Math.floor(duration);
      },
      
      onError: (error: string) => {
        console.error('音频播放错误:', error);
        this.errorMessage = error;
        this.isLoading = false;
        promptAction.showToast({ 
          message: '播放失败: ' + error,
          duration: 3000
        });
      },
      
      onComplete: () => {
        console.log('音频播放完成');
        this.isPlaying = false;
        this.currentTime = 0;
        this.stopRotate();
        promptAction.showToast({ 
          message: '播放完成',
          duration: 2000
        });
      }
    };
    
    this.audioPlayerService.setCallbacks(callbacks);
  }

  // 初始化音频播放器
  async initAudioPlayer() {
    try {
      this.isLoading = true;
      this.errorMessage = '';
      
      console.log('开始初始化音频播放器，音乐ID:', this.song.musicId);
      
      // 调用API获取音乐播放URL
      const musicUrl = await ApiService.getMusicPlayUrl(this.song.musicId);
      console.log('获取到音乐URL:', musicUrl);
      
      // 初始化音频播放器
      await this.audioPlayerService.initPlayer(musicUrl);
      
      this.isInitialized = true;
      this.isLoading = false;
      
      promptAction.showToast({ 
        message: '音乐加载成功',
        duration: 2000
      });
      
    } catch (error) {
      console.error('初始化音频播放器失败:', error);
      this.isLoading = false;
      this.errorMessage = error instanceof Error ? error.message : '未知错误';
      
      promptAction.showToast({ 
        message: '音乐加载失败: ' + this.errorMessage,
        duration: 3000
      });
    }
  }

  // 播放/暂停切换
  async togglePlay() {
    try {
      if (!this.isInitialized) {
        await this.initAudioPlayer();
        return;
      }
      
      if (this.isPlaying) {
        await this.audioPlayerService.pause();
      } else {
        await this.audioPlayerService.play();
      }
    } catch (error) {
      console.error('播放控制失败:', error);
      promptAction.showToast({ 
        message: '播放控制失败: ' + (error instanceof Error ? error.message : '未知错误'),
        duration: 3000
      });
    }
  }

  // 停止播放
  async stopPlay() {
    try {
      await this.audioPlayerService.stop();
    } catch (error) {
      console.error('停止播放失败:', error);
    }
  }

  // 跳转到指定位置
  async seekToPosition(position: number) {
    try {
      await this.audioPlayerService.seek(position);
    } catch (error) {
      console.error('跳转失败:', error);
    }
  }

  startRotate() {
    if (!this.isPlaying) return;
    
    this.stopRotate();
    
    this.rotateTimerId = setInterval((): void => {
      if (this.isPlaying) {
        this.rotateAngle += 1;
      } else {
        this.stopRotate();
      }
    }, 30);
  }

  stopRotate() {
    if (this.rotateTimerId !== -1) {
      clearInterval(this.rotateTimerId);
      this.rotateTimerId = -1;
    }
  }

  formatTime(time: number): string {
    const m = Math.floor(time / 60);
    const s = Math.floor(time % 60);
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }

  build() {
    Stack() {
      // 背景渐变
      Column() {
        Blank()
      }
      .width('100%').height('100%')
      .backgroundColor(Color.Brown)
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])

      // 顶部信息栏
      Row() {
        // 左侧返回按钮
        Image($r('app.media.music_return'))
          .width(40).height(40)
          .onClick(() => router.back())

        // 中间内容
        Column() {
          Text(this.song.title)
            .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#fff').textAlign(TextAlign.Center)
          Text(this.song.artist)
            .fontSize(14).fontColor('#ccc').textAlign(TextAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)
        .width('80%')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .position({ y: 0 })

      // 黑胶转盘+专辑封面
      Stack() {
        // 黑胶盘
        Image($r('app.media.music_record'))
          .width(300).height(300)
          .objectFit(ImageFit.Cover)
          .rotate({ angle: this.rotateAngle })

        // 专辑封面
        Image(this.song.cover)
          .width(200).height(200).borderRadius(100)
          .objectFit(ImageFit.Cover)
          .rotate({ angle: this.rotateAngle })

        // 加载状态指示
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(60).height(60)
              .color('#fff')
            Text('加载中...')
              .fontSize(14).fontColor('#fff')
              .margin({ top: 8 })
          }
          .position({ x: '50%', y: '50%' })
          .translate({ x: -30, y: -40 })
        }

        // 错误状态指示
        if (this.errorMessage && !this.isLoading) {
          Column() {
            Text('⚠️')
              .fontSize(48).fontColor('#ff6b6b')
            Text('加载失败')
              .fontSize(14).fontColor('#ff6b6b')
              .margin({ top: 8 })
            Button('重试')
              .fontSize(12).fontColor('#fff')
              .backgroundColor('#ff6b6b')
              .borderRadius(12)
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .margin({ top: 8 })
              .onClick(() => this.initAudioPlayer())
          }
          .position({ x: '50%', y: '50%' })
          .translate({ x: -40, y: -60 })
        }
      }

      // 底部控制区
      Column() {
        // 进度条区域
        Row() {
          Text(this.formatTime(this.currentTime))
            .fontSize(12)
            .fontColor('#fff')
            .width(40)
            .textAlign(TextAlign.Center)
          
          Slider({
            value: this.currentTime,
            min: 0,
            max: this.duration,
            step: 1
          })
            .width('60%')
            .margin({ left: 12, right: 12 })
            .selectedColor('#fff')
            .onChange((value: number) => {
              this.seekToPosition(value);
            })
          
          Text(this.formatTime(this.duration))
            .fontSize(12)
            .fontColor('#fff')
            .width(40)
            .textAlign(TextAlign.Center)
        }
        .width('90%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .margin({bottom:20})

        // 播放控制按钮区
        Row() {
          Image($r('app.media.music_random')).width(28).height(28).margin({ right: 16 })
          Image($r('app.media.music_last')).width(28).height(28).margin({ left: 30 })
          
          if (this.isPlaying) {
            Image($r('app.media.music_stop'))
              .width(30)
              .margin({ left: 30, right: 30 })
              .onClick(() => this.togglePlay())
          } else {
            Image($r('app.media.music_go'))
              .width(30)
              .margin({ left: 30, right: 30 })
              .onClick(() => this.togglePlay())
          }

          Image($r('app.media.music_next')).width(28).height(28).margin({ right: 30 })
          Image($r('app.media.music_list')).width(28).height(28).margin({ left: 16 })
        }
        .width('100%').justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
      }
      .width('100%').position({ y: 600 })
    }
    .width('100%').height('100%').backgroundColor('#232323')
  }
} 