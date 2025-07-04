import { audio } from '@kit.AudioKit';
import fs from '@ohos.file.fs';

export class AudioCapturerManager {
  static audioCapturer: audio.AudioCapturer | null = null;
  private static recordFilePath: string = "";

  static async createAudioCapturer() {
    if (AudioCapturerManager.audioCapturer) {
      return AudioCapturerManager.audioCapturer
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
    return AudioCapturerManager.audioCapturer;
  }

  static async startRecord(fileName: string) {
    await AudioCapturerManager.createAudioCapturer()
    let bufferSize: number = 0;
    class Options { offset?: number; length?: number; }
    let path = getContext().filesDir;
    let filePath = `${path}/${fileName}.wav`;
    let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    let readDataCallback = (buffer: ArrayBuffer) => {
      let options: Options = { offset: bufferSize, length: buffer.byteLength };
      fs.writeSync(file.fd, buffer, options);
      bufferSize += buffer.byteLength;
    };
    AudioCapturerManager.audioCapturer?.on('readData', readDataCallback);
    AudioCapturerManager.audioCapturer?.start();
    AudioCapturerManager.recordFilePath = filePath;
    return filePath;
  }

  static async stopRecord() {
    await AudioCapturerManager.audioCapturer?.stop();
    await AudioCapturerManager.audioCapturer?.release();
    AudioCapturerManager.audioCapturer = null;
  }
}
