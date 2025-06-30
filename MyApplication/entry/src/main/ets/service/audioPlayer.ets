import media from '@ohos.multimedia.media';
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';

// 音频播放器状态
export enum AudioPlayerState {
  IDLE = 'idle',
  PREPARED = 'prepared',
  PLAYING = 'playing',
  PAUSED = 'paused',
  STOPPED = 'stopped',
  ERROR = 'error'
}

// 音频播放器事件回调
export interface AudioPlayerCallbacks {
  onStateChange?: (state: AudioPlayerState) => void;
  onProgressChange?: (currentTime: number, duration: number) => void;
  onError?: (error: string) => void;
  onComplete?: () => void;
}

/**
 * 音频播放器服务类
 */
export class AudioPlayerService {
  private audioPlayer: media.AudioPlayer | null = null;
  private currentUrl: string = '';
  private currentState: AudioPlayerState = AudioPlayerState.IDLE;
  private callbacks: AudioPlayerCallbacks = {};
  private progressTimer: number = -1;
  private currentTime: number = 0;
  private duration: number = 0;

  /**
   * 初始化播放器
   */
  async initPlayer(url: string): Promise<void> {
    try {
      // 如果已有播放器，先释放
      if (this.audioPlayer) {
        await this.releasePlayer();
      }

      console.log('初始化音频播放器，URL:', url);
      
      // 创建音频播放器
      this.audioPlayer = media.createAudioPlayer();
      this.currentUrl = url;
      
      // 设置音频源
      this.audioPlayer.src = url;
      
      // 设置播放器回调
      this.setupCallbacks();
      
      this.currentState = AudioPlayerState.PREPARED;
      this.notifyStateChange();
      
      console.log('音频播放器初始化成功');
      
    } catch (error) {
      console.error('初始化音频播放器失败:', error);
      this.currentState = AudioPlayerState.ERROR;
      this.notifyStateChange();
      this.notifyError('初始化播放器失败: ' + (error instanceof Error ? error.message : String(error)));
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }

  /**
   * 设置回调函数
   */
  setCallbacks(callbacks: AudioPlayerCallbacks): void {
    this.callbacks = callbacks;
  }

  /**
   * 设置播放器回调
   */
  private setupCallbacks(): void {
    if (!this.audioPlayer) return;

    // 播放状态变化回调
    this.audioPlayer.on('play', () => {
      console.log('音频开始播放');
      this.currentState = AudioPlayerState.PLAYING;
      // 这里获取真实 duration
      if (this.audioPlayer) {
        this.duration = this.audioPlayer.duration;
        this.notifyProgressChange(); // 触发UI更新
      }
      this.notifyStateChange();
      this.startProgressTimer();
    });

    this.audioPlayer.on('pause', () => {
      console.log('音频暂停');
      this.currentState = AudioPlayerState.PAUSED;
      this.notifyStateChange();
      this.stopProgressTimer();
    });

    this.audioPlayer.on('stop', () => {
      console.log('音频停止');
      this.currentState = AudioPlayerState.STOPPED;
      this.notifyStateChange();
      this.stopProgressTimer();
      this.currentTime = 0;
    });

    this.audioPlayer.on('finish', () => {
      console.log('音频播放完成');
      this.currentState = AudioPlayerState.STOPPED;
      this.notifyStateChange();
      this.stopProgressTimer();
      this.currentTime = 0;
      this.notifyComplete();
    });

    this.audioPlayer.on('error', (err) => {
      if (err) {
        console.error('player error:', err.message);
        this.currentState = AudioPlayerState.ERROR;
        this.notifyStateChange();
        this.stopProgressTimer();
        this.notifyError('播放错误: ' + err.message);
      }
    });

    this.audioPlayer.on('timeUpdate', () => {
      this.currentTime = this.audioPlayer ? this.audioPlayer.currentTime : 0;
      this.notifyProgressChange();
    });

    // 如有dataLoad事件也监听
    if (typeof this.audioPlayer.on === 'function') {
      this.audioPlayer.on('dataLoad', () => {
        if (this.audioPlayer) {
          this.duration = this.audioPlayer.duration;
          this.notifyProgressChange();
        }
      });
    }
  }

  /**
   * 开始播放
   */
  async play(): Promise<void> {
    try {
      if (!this.audioPlayer) {
        throw new Error('播放器未初始化');
      }

      if (this.currentState === AudioPlayerState.PLAYING) {
        console.log('音频已在播放中');
        return;
      }

      console.log('开始播放音频');
      await this.audioPlayer.play();
      
    } catch (error) {
      console.error('播放失败:', error);
      this.notifyError('播放失败: ' + (error instanceof Error ? error.message : String(error)));
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }

  /**
   * 暂停播放
   */
  async pause(): Promise<void> {
    try {
      if (!this.audioPlayer) {
        throw new Error('播放器未初始化');
      }

      if (this.currentState !== AudioPlayerState.PLAYING) {
        console.log('音频未在播放中');
        return;
      }

      console.log('暂停播放音频');
      await this.audioPlayer.pause();
      
    } catch (error) {
      console.error('暂停失败:', error);
      this.notifyError('暂停失败: ' + (error instanceof Error ? error.message : String(error)));
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }

  /**
   * 停止播放
   */
  async stop(): Promise<void> {
    try {
      if (!this.audioPlayer) {
        throw new Error('播放器未初始化');
      }

      console.log('停止播放音频');
      await this.audioPlayer.stop();
      
    } catch (error) {
      console.error('停止播放失败:', error);
      this.notifyError('停止播放失败: ' + (error instanceof Error ? error.message : String(error)));
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }

  /**
   * 跳转到指定位置
   */
  async seek(position: number): Promise<void> {
    try {
      if (!this.audioPlayer) {
        throw new Error('播放器未初始化');
      }

      // seek校验用最新duration
      const realDuration = this.audioPlayer.duration > 0 ? this.audioPlayer.duration : this.duration;
      if (position < 0 || position > realDuration) {
        throw new Error('跳转位置超出范围');
      }

      console.log('跳转到位置:', position);
      // seek单位为毫秒
      this.audioPlayer.seek(position * 1000);
      this.currentTime = position;
      
    } catch (error) {
      console.error('跳转失败:', error);
      this.notifyError('跳转失败: ' + (error instanceof Error ? error.message : String(error)));
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }

  /**
   * 设置音量
   */
  async setVolume(volume: number): Promise<void> {
    try {
      if (!this.audioPlayer) {
        throw new Error('播放器未初始化');
      }

      if (volume < 0 || volume > 1) {
        throw new Error('音量值超出范围(0-1)');
      }

      console.log('设置音量:', volume);
      this.audioPlayer.setVolume(volume);
      
    } catch (error) {
      console.error('设置音量失败:', error);
      this.notifyError('设置音量失败: ' + (error instanceof Error ? error.message : String(error)));
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }

  /**
   * 获取当前播放时间
   */
  async getCurrentTime(): Promise<number> {
    try {
      if (!this.audioPlayer) {
        return 0;
      }
      return this.audioPlayer.currentTime;
    } catch (error) {
      console.error('获取当前时间失败:', error);
      return this.currentTime;
    }
  }

  /**
   * 获取音频总时长
   */
  getDuration(): number {
    return this.duration;
  }

  /**
   * 获取当前状态
   */
  getState(): AudioPlayerState {
    return this.currentState;
  }

  /**
   * 是否正在播放
   */
  isPlaying(): boolean {
    return this.currentState === AudioPlayerState.PLAYING;
  }

  /**
   * 开始进度定时器
   */
  private startProgressTimer(): void {
    this.stopProgressTimer();
    this.progressTimer = setInterval(() => {
      try {
        if (this.audioPlayer && this.currentState === AudioPlayerState.PLAYING) {
          this.currentTime = this.audioPlayer.currentTime;
          this.notifyProgressChange();
        }
      } catch (error) {
        console.error('获取播放进度失败:', error);
      }
    }, 1000); // 每秒更新一次
  }

  /**
   * 停止进度定时器
   */
  private stopProgressTimer(): void {
    if (this.progressTimer !== -1) {
      clearInterval(this.progressTimer);
      this.progressTimer = -1;
    }
  }

  /**
   * 通知状态变化
   */
  private notifyStateChange(): void {
    if (this.callbacks.onStateChange) {
      this.callbacks.onStateChange(this.currentState);
    }
  }

  /**
   * 通知进度变化
   */
  private notifyProgressChange(): void {
    if (this.callbacks.onProgressChange) {
      this.callbacks.onProgressChange(this.currentTime, this.duration);
    }
  }

  /**
   * 通知错误
   */
  private notifyError(error: string): void {
    if (this.callbacks.onError) {
      this.callbacks.onError(error);
    }
  }

  /**
   * 通知播放完成
   */
  private notifyComplete(): void {
    if (this.callbacks.onComplete) {
      this.callbacks.onComplete();
    }
  }

  /**
   * 释放播放器资源
   */
  async releasePlayer(): Promise<void> {
    try {
      this.stopProgressTimer();
      
      if (this.audioPlayer) {
        await this.audioPlayer.release();
        this.audioPlayer = null;
      }
      
      this.currentState = AudioPlayerState.IDLE;
      this.currentTime = 0;
      this.duration = 0;
      this.currentUrl = '';
      
      console.log('音频播放器资源已释放');
      
    } catch (error) {
      console.error('释放播放器资源失败:', error);
    }
  }

  /**
   * 销毁播放器
   */
  destroy(): void {
    this.releasePlayer();
    this.callbacks = {};
  }
} 