import { audio } from '@kit.AudioKit';
import fs from '@ohos.file.fs';
import { BusinessError } from '@kit.BasicServicesKit';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';

// 定义文件写入选项接口
interface WriteOptions {
  offset: number;
  length: number;
}

export class AudioCapturerManager {
  static audioCapturer: audio.AudioCapturer | null = null;
  private static recordFilePath: string = "";
  private static isRecording: boolean = false;
  private static fileHandle: fs.File | null = null;

  /**
   * 检查麦克风权限
   */
  static async checkMicrophonePermission(): Promise<boolean> {
    try {
      let atManager = abilityAccessCtrl.createAtManager();
      let context = getContext();
      if (!context) {
        console.error('无法获取应用上下文');
        return false;
      }
      // 获取应用的tokenID
      const tokenID = context.applicationInfo.accessTokenId;
      const permissionStatus = await atManager.verifyAccessToken(tokenID, 'ohos.permission.MICROPHONE');
      console.log('麦克风权限状态:', permissionStatus);
      return permissionStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (error) {
      console.error('检查麦克风权限失败:', error);
      return false;
    }
  }

  /**
   * 创建音频录制器
   */
  static async createAudioCapturer(): Promise<audio.AudioCapturer | null> {
    try {
      if (AudioCapturerManager.audioCapturer) {
        console.log('音频录制器已存在，返回现有实例');
        return AudioCapturerManager.audioCapturer;
      }

      console.log('开始创建音频录制器...');

      // 检查麦克风权限
      const hasPermission = await AudioCapturerManager.checkMicrophonePermission();
      if (!hasPermission) {
        console.error('麦克风权限未授权，无法创建音频录制器');
        return null;
      }

      let audioStreamInfo: audio.AudioStreamInfo = {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      };

      let audioCapturerInfo: audio.AudioCapturerInfo = {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0
      };

      let audioCapturerOptions: audio.AudioCapturerOptions = {
        streamInfo: audioStreamInfo,
        capturerInfo: audioCapturerInfo
      };

      AudioCapturerManager.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions);
      console.log('音频录制器创建成功');
      return AudioCapturerManager.audioCapturer;
    } catch (error) {
      console.error('创建音频录制器失败:', error);
      const businessError = error as BusinessError;
      console.error('错误代码:', businessError.code);
      console.error('错误信息:', businessError.message);
      return null;
    }
  }

  /**
   * 开始录音
   */
  static async startRecord(fileName: string): Promise<string | null> {
    try {
      console.log('开始录音，文件名:', fileName);

      // 创建音频录制器
      const capturer = await AudioCapturerManager.createAudioCapturer();
      if (!capturer) {
        console.error('音频录制器创建失败');
        return null;
      }

      // 准备文件路径
      let path = getContext().filesDir;
      let filePath = `${path}/${fileName}.wav`;
      AudioCapturerManager.recordFilePath = filePath;

      console.log('录音文件路径:', filePath);

      // 创建文件
      try {
        AudioCapturerManager.fileHandle = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        console.log('录音文件创建成功');
      } catch (fileError) {
        console.error('创建录音文件失败:', fileError);
        return null;
      }

      let bufferSize: number = 0;

      // 设置音频数据回调
      let readDataCallback = (buffer: ArrayBuffer) => {
        try {
          if (AudioCapturerManager.fileHandle && AudioCapturerManager.isRecording) {
            let options: WriteOptions = { offset: bufferSize, length: buffer.byteLength };
            fs.writeSync(AudioCapturerManager.fileHandle.fd, buffer, options);
            bufferSize += buffer.byteLength;
            console.log('写入音频数据，当前大小:', bufferSize);
          }
        } catch (writeError) {
          console.error('写入音频数据失败:', writeError);
        }
      };

      // 注册回调
      capturer.on('readData', readDataCallback);

      // 开始录音
      await capturer.start();
      AudioCapturerManager.isRecording = true;

      console.log('录音开始成功');
      return filePath;
    } catch (error) {
      console.error('开始录音失败:', error);
      return null;
    }
  }

  /**
   * 停止录音
   */
  static async stopRecord(): Promise<boolean> {
    try {
      console.log('停止录音...');

      AudioCapturerManager.isRecording = false;

      // 停止音频录制器
      if (AudioCapturerManager.audioCapturer) {
        await AudioCapturerManager.audioCapturer.stop();
        console.log('音频录制器已停止');
      }

      // 关闭文件
      if (AudioCapturerManager.fileHandle) {
        fs.closeSync(AudioCapturerManager.fileHandle);
        AudioCapturerManager.fileHandle = null;
        console.log('录音文件已关闭');
      }

      // 释放音频录制器
      if (AudioCapturerManager.audioCapturer) {
        await AudioCapturerManager.audioCapturer.release();
        AudioCapturerManager.audioCapturer = null;
        console.log('音频录制器已释放');
      }

      console.log('录音停止成功，文件路径:', AudioCapturerManager.recordFilePath);
      return true;
    } catch (error) {
      console.error('停止录音失败:', error);
      return false;
    }
  }

  /**
   * 获取录音文件路径
   */
  static getRecordFilePath(): string {
    return AudioCapturerManager.recordFilePath;
  }

  /**
   * 检查录音状态
   */
  static isRecordingNow(): boolean {
    return AudioCapturerManager.isRecording;
  }
}
