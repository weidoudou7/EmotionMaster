import router from '@ohos.router';
import { ApiService } from '../service/apiservice';
import { AudioPlayerService, AudioPlayerState, AudioPlayerCallbacks } from '../service/audioPlayer';
import promptAction from '@ohos.promptAction';
import { MusicDetailVO } from '../common/types';

interface SongInfo {
  title: string;
  artist: string;
  cover: Resource;
  duration: number;
  musicId: string;
}

interface MusicCloudParams {
  musicId?: string;
  musicTitle?: string;
  musicArtist?: string;
  musicDetail?: MusicDetailVO;
  songs?: MusicDetailVO[];
  currentIndex?: number;
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
  @State isRandomMode: boolean = true; // true为随机播放，false为单曲循环
  @State showVolumePanel: boolean = false;
  @State volume: number = 1;
  
  private rotateTimerId: number = -1;
  private audioPlayerService: AudioPlayerService = new AudioPlayerService();
  
  @State song: SongInfo = {
    title: '句号',
    artist: 'G.E.M.邓紫棋',
    cover: $r('app.media.splash'),
    duration: 235,
    musicId: '1824045033' // 默认音乐ID，实际应该从路由参数获取
  };

  @State songDetail: MusicDetailVO = {
    musicId: '',
    name: '',
    artist: '',
    duration: '00:00',
    coverUrl: ''
  };

  @State songs: MusicDetailVO[] = [];
  @State currentIndex: number = 0;

  aboutToAppear() {
    const params = router.getParams() as MusicCloudParams;
    if (params?.songs && params?.currentIndex !== undefined) {
      this.songs = params.songs;
      this.currentIndex = params.currentIndex;
      this.setSongByIndex(this.currentIndex);
    } else {
      if (params?.musicId) {
        this.song.musicId = params.musicId;
      }
      if (params?.musicTitle) {
        this.song.title = params.musicTitle;
      }
      if (params?.musicArtist) {
        this.song.artist = params.musicArtist;
      }
      if (params?.musicDetail) {
        this.songDetail = params.musicDetail;
      } else {
        this.fetchSongDetail();
      }
    }
    this.setupAudioCallbacks();
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
      
      onComplete: async () => {
        console.log('音频播放完成');
        this.isPlaying = false;
        this.currentTime = 0;
        this.stopRotate();
        if (this.isRandomMode) {
          await this.randomPlay();
        } else {
          await this.setSongByIndex(this.currentIndex); // 单曲循环
        }
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
    } catch (error) {
      console.error('初始化音频播放器失败:', error);
      this.isLoading = false;
      this.errorMessage = error instanceof Error ? error.message : '未知错误';
      // 不再弹toast
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
    if (typeof time !== 'number' || isNaN(time) || time < 0) {
      return '--:--';
    }
    const m = Math.floor(time / 60);
    const s = Math.floor(time % 60);
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }

  async fetchSongDetail() {
    try {
      const detail = await ApiService.getMusicDetail(this.song.musicId);
      this.songDetail = detail;
    } catch (e) {
      // 不再弹toast
    }
  }

  async setSongByIndex(index: number) {
    const song = this.songs[index];
    if (song) {
      this.songDetail = song;
      this.song.musicId = song.musicId;
      this.song.title = song.name;
      this.song.artist = song.artist;
      this.currentTime = 0;
      this.isInitialized = false;
      await this.initAudioPlayer();
      await this.audioPlayerService.play(); // 自动播放
    }
  }

  previousSong() {
    if (this.songs.length === 0) return;
    this.currentIndex = (this.currentIndex - 1 + this.songs.length) % this.songs.length;
    this.setSongByIndex(this.currentIndex);
  }

  nextSong() {
    if (this.songs.length === 0) return;
    this.currentIndex = (this.currentIndex + 1) % this.songs.length;
    this.setSongByIndex(this.currentIndex);
  }

  // 随机播放方法
  private async randomPlay() {
    if (this.songs.length <= 1) return;
    let nextIndex = this.currentIndex;
    while (nextIndex === this.currentIndex && this.songs.length > 1) {
      nextIndex = Math.floor(Math.random() * this.songs.length);
    }
    this.currentIndex = nextIndex;
    await this.setSongByIndex(this.currentIndex); // 自动播放
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
          .margin({left:5})
        // 中间内容
        Column() {
          Text(this.songDetail.name || this.song.title)
            .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#fff').textAlign(TextAlign.Center)
          Text(this.songDetail.artist || this.song.artist)
            .fontSize(14).fontColor('#ccc').textAlign(TextAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)
        .width('80%')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .position({ y: 0 })
      .margin({top:20})

      // 黑胶转盘+专辑封面
      Stack() {
        // 黑胶盘
        Image($r('app.media.music_record'))
          .width(300).height(300)
          .objectFit(ImageFit.Cover)
          .rotate({ angle: this.rotateAngle })

        // 专辑封面
        Image(this.songDetail.coverUrl || this.song.cover)
          .width(200).height(200).borderRadius(100)
          .objectFit(ImageFit.Cover)
          .rotate({ angle: this.rotateAngle })

        // 加载状态指示
        /*if (this.isLoading) {
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
        }*/

        // 错误状态指示
        /*if (this.errorMessage && !this.isLoading) {
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
        }*/
      }

      // 底部控制区
      Column() {
        // 进度条区域
        Row() {
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
          
          Text(this.songDetail.duration)
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
          // 随机/单曲循环切换按钮
          Image(this.isRandomMode ? $r('app.media.music_random') : $r('app.media.repeat'))
            .width(32)
            .height(32)
            .onClick(() => {
              this.isRandomMode = !this.isRandomMode;
            })
          Image($r('app.media.music_last'))
            .width(28).height(28).margin({ left: 30 })
            .onClick(() => this.previousSong())
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
          Image($r('app.media.music_next'))
            .width(28).height(28).margin({ right: 30 })
            .onClick(() => this.nextSong())
          Image($r('app.media.music_list')).width(28).height(28).margin({ left: 16 })
            .onClick(() => {
              this.showVolumePanel = true;
            })
        }
        .width('100%').justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
      }
      .width('100%').position({ y: 600 })

      // 音量调节弹窗
      if (this.showVolumePanel) {
        Stack() {
          // 半透明遮罩，点击关闭
          Column() {}
            .width('100%').height('100%')
            .backgroundColor('rgba(0,0,0,0.3)')
            .onClick(() => { this.showVolumePanel = false })
          // 音量面板
          Column() {
            Text('音量调节')
              .fontSize(18).fontColor('#fff').margin({ bottom: 12 })
            Row() {
              Slider({
                value: this.volume,
                min: 0,
                max: 1,
                step: 0.01
              })
                .width(200)
                .selectedColor('#ffda7f')
                .onChange((value: number) => {
                  this.volume = value;
                  this.audioPlayerService.setVolume(this.volume);
                })
              Text(Math.round(this.volume * 100) + '%')
                .fontSize(16).fontColor('#fff').margin({ left: 12 })
            }
            Button('关闭')
              .width(100).height(36)
              .fontSize(16)
              .fontColor('#121114')
              .backgroundColor('#ffda7f')
              .borderRadius(18)
              .margin({ top: 16 })
              .onClick(() => { this.showVolumePanel = false })
          }
          .width(280).backgroundColor('#232323').borderRadius(16)
          .padding({ top: 24, bottom: 24, left: 24, right: 24 })
          .position({ x: '50%', y: '60%' })
          .translate({ x: -140, y: -80 })
        }
        .width('100%').height('100%').position({ x: 0, y: 0 })
      }
    }
    .width('100%').height('100%').backgroundColor('#232323')
  }
} 