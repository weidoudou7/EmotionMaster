import router from '@ohos.router';
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';

// 音乐信息接口
interface MusicInfo {
  id: string;
  title: string;
  artist: string;
  album: string;
  duration: number; // 总时长（秒）
  coverImage: Resource;
  audioUrl: string;
  lyrics?: string[];
}

// 播放列表项接口
interface PlaylistItem {
  id: string;
  title: string;
  artist: string;
  duration: number;
  isPlaying: boolean;
}

@Entry
@Component
struct FMMusicBegin {
  @State currentMusic: MusicInfo | null = null;
  @State isPlaying: boolean = false;
  @State currentTime: number = 0; // 当前播放时间（秒）
  @State volume: number = 0.7; // 音量 0-1
  @State showPlaylist: boolean = false;
  @State repeatMode: 'none' | 'one' | 'all' = 'none'; // 播放模式
  @State shuffleMode: boolean = false; // 随机播放
  @State showLyrics: boolean = false; // 是否显示歌词
  @State currentLyricIndex: number = 0; // 当前歌词索引
  
  // 从路由参数获取音乐信息
  @State musicId: string = '';
  @State musicTitle: string = '';
  @State musicArtist: string = '';
  @State musicCover: Resource = $r('app.media.fmhome_fashionMusic');

  // 模拟播放列表
  private playlist: PlaylistItem[] = [
    { id: '1', title: '夜曲', artist: '周杰伦', duration: 240, isPlaying: false },
    { id: '2', title: '稻香', artist: '周杰伦', duration: 210, isPlaying: false },
    { id: '3', title: '青花瓷', artist: '周杰伦', duration: 235, isPlaying: false },
    { id: '4', title: '菊花台', artist: '周杰伦', duration: 245, isPlaying: false },
    { id: '5', title: '发如雪', artist: '周杰伦', duration: 230, isPlaying: false }
  ];

  // 模拟歌词
  private lyrics: string[] = [
    '夜曲 - 周杰伦',
    '',
    '为你弹奏萧邦的夜曲',
    '纪念我死去的爱情',
    '而我为你隐姓埋名',
    '在月光下弹琴',
    '',
    '对你心跳的感应',
    '还是如此温热亲近',
    '怀念你那鲜红的唇印',
    '',
    '那些断翅的蜻蜓',
    '散落在这森林',
    '而我的眼睛',
    '没有丝毫同情',
    '',
    '失去你泪水混浊不清',
    '失去你我连笑容都有阴影',
    '风在长满青苔的屋顶',
    '嘲笑我的伤心',
    '',
    '像一口没有水的枯井',
    '我用凄美的字型',
    '描绘后悔莫及的那爱情'
  ];

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>;
    this.musicId = params?.musicId || '1';
    this.musicTitle = params?.musicTitle || '夜曲';
    this.musicArtist = params?.musicArtist || '周杰伦';
    
    // 根据音乐类型设置封面
    const musicType = params?.musicType || 'fashion';
    switch(musicType) {
      case 'fashion':
        this.musicCover = $r('app.media.fmhome_fashionMusic');
        break;
      case 'classic':
        this.musicCover = $r('app.media.fmhome_classicMusic');
        break;
      case 'soft':
        this.musicCover = $r('app.media.fmhome_softMusic');
        break;
    }

    // 初始化当前音乐信息
    this.currentMusic = {
      id: this.musicId,
      title: this.musicTitle,
      artist: this.musicArtist,
      album: '专辑名称',
      duration: 240,
      coverImage: this.musicCover,
      audioUrl: '',
      lyrics: this.lyrics
    } as MusicInfo;

    // 更新播放列表状态
    this.updatePlaylistStatus();
  }

  // 更新播放列表状态
  updatePlaylistStatus() {
    this.playlist = this.playlist.map(item => {
      return {
        id: item.id,
        title: item.title,
        artist: item.artist,
        duration: item.duration,
        isPlaying: item.id === this.musicId
      } as PlaylistItem;
    });
  }

  // 播放/暂停
  togglePlay() {
    this.isPlaying = !this.isPlaying;
    if (this.isPlaying) {
      this.startPlayback();
    } else {
      this.pausePlayback();
    }
  }

  // 开始播放
  startPlayback() {
    // 模拟播放进度更新
    this.simulatePlayback();
  }

  // 暂停播放
  pausePlayback() {
    // 实际项目中这里会暂停音频播放
    console.log('暂停播放');
  }

  // 模拟播放进度
  simulatePlayback() {
    if (this.isPlaying && this.currentTime < (this.currentMusic?.duration || 0)) {
      setTimeout(() => {
        this.currentTime += 1;
        this.updateLyricIndex();
        this.simulatePlayback();
      }, 1000);
    }
  }

  // 更新歌词索引
  updateLyricIndex() {
    if (this.currentMusic?.lyrics) {
      // 简单的歌词同步逻辑
      const progress = this.currentTime / (this.currentMusic.duration || 1);
      const newIndex = Math.floor(progress * this.currentMusic.lyrics.length);
      if (newIndex !== this.currentLyricIndex && newIndex < this.currentMusic.lyrics.length) {
        this.currentLyricIndex = newIndex;
      }
    }
  }

  // 格式化时间
  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // 切换播放模式
  toggleRepeatMode() {
    switch(this.repeatMode) {
      case 'none':
        this.repeatMode = 'one';
        break;
      case 'one':
        this.repeatMode = 'all';
        break;
      case 'all':
        this.repeatMode = 'none';
        break;
    }
  }

  // 切换随机播放
  toggleShuffle() {
    this.shuffleMode = !this.shuffleMode;
  }

  // 上一首
  previousTrack() {
    const currentIndex = this.playlist.findIndex(item => item.id === this.musicId);
    if (currentIndex > 0) {
      const prevTrack = this.playlist[currentIndex - 1];
      this.musicId = prevTrack.id;
      this.musicTitle = prevTrack.title;
      this.musicArtist = prevTrack.artist;
      this.currentTime = 0;
      this.updatePlaylistStatus();
    }
  }

  // 下一首
  nextTrack() {
    const currentIndex = this.playlist.findIndex(item => item.id === this.musicId);
    if (currentIndex < this.playlist.length - 1) {
      const nextTrack = this.playlist[currentIndex + 1];
      this.musicId = nextTrack.id;
      this.musicTitle = nextTrack.title;
      this.musicArtist = nextTrack.artist;
      this.currentTime = 0;
      this.updatePlaylistStatus();
    }
  }

  build() {
    Stack() {
      // 背景渐变
      Column() {
        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#2d2d2d')

      Column() {
        // 顶部导航栏
        Row() {
          Button('‹')
            .fontSize(24)
            .fontColor('#fff')
            .backgroundColor('rgba(255,255,255,0.1)')
            .borderRadius(20)
            .width(40)
            .height(40)
            .onClick(() => router.back())

          Column() {
            Text(this.musicTitle)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#fff')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.musicArtist)
              .fontSize(14)
              .fontColor('#ccc')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .margin({ left: 16, right: 16 })

          Button('⋮')
            .fontSize(20)
            .fontColor('#fff')
            .backgroundColor('rgba(255,255,255,0.1)')
            .borderRadius(20)
            .width(40)
            .height(40)
            .onClick(() => {
              this.showPlaylist = !this.showPlaylist;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 16 })

        // 主要内容区域
        Column() {
          // 专辑封面
          Stack() {
            Image(this.musicCover)
              .width(280)
              .height(280)
              .borderRadius(20)
              .objectFit(ImageFit.Cover)
              .shadow({ radius: 20, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 10 })

            // 播放状态指示
            if (this.isPlaying) {
              Column() {
                Text('♪')
                  .fontSize(48)
                  .fontColor('#fff')
                  .backgroundColor('rgba(0,0,0,0.5)')
                  .borderRadius(24)
                  .width(48)
                  .height(48)
                  .textAlign(TextAlign.Center)
              }
              .position({ x: '50%', y: '50%' })
              .translate({ x: -24, y: -24 })
            }
          }
          .margin({ top: 40, bottom: 40 })

          // 音乐信息
          Column() {
            Text(this.musicTitle)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 8 })

            Text(this.musicArtist)
              .fontSize(16)
              .fontColor('#ccc')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 24 })
          }

          // 进度条
          Column() {
            Row() {
              Text(this.formatTime(this.currentTime))
                .fontSize(12)
                .fontColor('#999')
              Slider({
                value: this.currentTime,
                min: 0,
                max: this.currentMusic?.duration || 100,
                step: 1
              })
                .width('100%')
                .layoutWeight(1)
                .margin({ left: 12, right: 12 })
                .onChange((value: number) => {
                  this.currentTime = value;
                })
              Text(this.formatTime(this.currentMusic?.duration || 0))
                .fontSize(12)
                .fontColor('#999')
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
          .margin({ bottom: 32 })

          // 控制按钮
          Row() {
            // 播放模式
            Button(this.repeatMode === 'none' ? '🔁' : this.repeatMode === 'one' ? '🔂' : '🔁')
              .fontSize(20)
              .fontColor(this.repeatMode !== 'none' ? '#0D9FFB' : '#ccc')
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(20)
              .width(40)
              .height(40)
              .onClick(() => this.toggleRepeatMode())

            // 上一首
            Button('⏮')
              .fontSize(24)
              .fontColor('#fff')
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(25)
              .width(50)
              .height(50)
              .margin({ left: 16 })
              .onClick(() => this.previousTrack())

            // 播放/暂停
            Button(this.isPlaying ? '⏸' : '▶')
              .fontSize(32)
              .fontColor('#fff')
              .backgroundColor('#0D9FFB')
              .borderRadius(35)
              .width(70)
              .height(70)
              .margin({ left: 16, right: 16 })
              .onClick(() => this.togglePlay())

            // 下一首
            Button('⏭')
              .fontSize(24)
              .fontColor('#fff')
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(25)
              .width(50)
              .height(50)
              .margin({ right: 16 })
              .onClick(() => this.nextTrack())

            // 随机播放
            Button('🔀')
              .fontSize(20)
              .fontColor(this.shuffleMode ? '#0D9FFB' : '#ccc')
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(20)
              .width(40)
              .height(40)
              .onClick(() => this.toggleShuffle())
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({ bottom: 32 })

          // 底部功能按钮
          Row() {
            Button('💬')
              .fontSize(20)
              .fontColor('#ccc')
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(20)
              .width(40)
              .height(40)
              .onClick(() => {
                this.showLyrics = !this.showLyrics;
              })

            Button('❤️')
              .fontSize(20)
              .fontColor('#ccc')
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(20)
              .width(40)
              .height(40)
              .margin({ left: 16 })
              .onClick(() => {
                promptAction.showToast({ message: '已添加到收藏' });
              })

            Button('📤')
              .fontSize(20)
              .fontColor('#ccc')
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(20)
              .width(40)
              .height(40)
              .margin({ left: 16 })
              .onClick(() => {
                promptAction.showToast({ message: '分享功能开发中' });
              })

            Button('📝')
              .fontSize(20)
              .fontColor('#ccc')
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(20)
              .width(40)
              .height(40)
              .margin({ left: 16 })
              .onClick(() => {
                promptAction.showToast({ message: '评论功能开发中' });
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')

      // 播放列表弹窗
      if (this.showPlaylist) {
        Column() {
          // 半透明背景
          Blank()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(0.5)
            .onClick(() => {
              this.showPlaylist = false;
            })

          // 播放列表内容
          Column() {
            // 标题栏
            Row() {
              Text('播放列表')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#fff')
              Button('×')
                .fontSize(20)
                .fontColor('#fff')
                .backgroundColor('rgba(255,255,255,0.1)')
                .borderRadius(15)
                .width(30)
                .height(30)
                .onClick(() => {
                  this.showPlaylist = false;
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })

            // 播放列表
            List() {
              ForEach(this.playlist, (item: PlaylistItem) => {
                ListItem() {
                  Row() {
                    Column() {
                      Text(item.title)
                        .fontSize(16)
                        .fontColor(item.isPlaying ? '#0D9FFB' : '#fff')
                        .fontWeight(item.isPlaying ? FontWeight.Bold : FontWeight.Normal)
                      Text(item.artist)
                        .fontSize(14)
                        .fontColor('#ccc')
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)

                    if (item.isPlaying) {
                      Text('♪')
                        .fontSize(16)
                        .fontColor('#0D9FFB')
                        .margin({ right: 8 })
                    }

                    Text(this.formatTime(item.duration))
                      .fontSize(14)
                      .fontColor('#999')
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .onClick(() => {
                    this.musicId = item.id;
                    this.musicTitle = item.title;
                    this.musicArtist = item.artist;
                    this.currentTime = 0;
                    this.updatePlaylistStatus();
                    this.showPlaylist = false;
                  })
                }
              })
            }
            .width('100%')
            .layoutWeight(1)
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .height('60%')
          .backgroundColor('#2d2d2d')
          .borderRadius({ topLeft: 20, topRight: 20 })
          .position({ x: 0, y: '40%' })
        }
        .width('100%')
        .height('100%')
      }

      // 歌词弹窗
      if (this.showLyrics) {
        Column() {
          // 半透明背景
          Blank()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(0.5)
            .onClick(() => {
              this.showLyrics = false;
            })

          // 歌词内容
          Column() {
            // 标题栏
            Row() {
              Text('歌词')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#fff')
              Button('×')
                .fontSize(20)
                .fontColor('#fff')
                .backgroundColor('rgba(255,255,255,0.1)')
                .borderRadius(15)
                .width(30)
                .height(30)
                .onClick(() => {
                  this.showLyrics = false;
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })

            // 歌词列表
            List() {
              ForEach(this.currentMusic?.lyrics || [], (lyric: string, index: number) => {
                ListItem() {
                  Text(lyric)
                    .fontSize(index === this.currentLyricIndex ? 18 : 16)
                    .fontColor(index === this.currentLyricIndex ? '#0D9FFB' : '#ccc')
                    .fontWeight(index === this.currentLyricIndex ? FontWeight.Bold : FontWeight.Normal)
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .padding({ top: 8, bottom: 8 })
                }
              })
            }
            .width('100%')
            .layoutWeight(1)
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .height('80%')
          .backgroundColor('#2d2d2d')
          .borderRadius({ topLeft: 20, topRight: 20 })
          .position({ x: 0, y: '20%' })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
} 