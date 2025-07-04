import { speechRecognizer } from '@kit.CoreSpeechKit';
import { fileIo } from '@kit.CoreFileKit';

class SpeechRecognizerManager {
  private static extraParam: Record<string, Object> = { "locate": "CN", "recognizerMode": "short" };
  private static initParamsInfo: speechRecognizer.CreateEngineParams = {
    language: 'zh-CN',
    online: 1,
    extraParams: this.extraParam
  };
  private static asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null
  static speechResult: speechRecognizer.SpeechRecognitionResult | null = null
  private static sessionId: string = "asr" + Date.now()

  private static async createEngine() {
    SpeechRecognizerManager.asrEngine = await speechRecognizer.createEngine(SpeechRecognizerManager.initParamsInfo)
  }

  private static setListener(callback: (srr: speechRecognizer.SpeechRecognitionResult) => void = () => {}) {
    let setListener: speechRecognizer.RecognitionListener = {
      onStart(sessionId: string, eventMessage: string) {},
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {},
      onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
        SpeechRecognizerManager.speechResult = result
        callback && callback(result)
      },
      onComplete(sessionId: string, eventMessage: string) {},
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        console.log("errorMessage", errorMessage)
      },
    }
    SpeechRecognizerManager.asrEngine?.setListener(setListener);
  }

  static startListening2() {
    try {
      let recognizerParams: speechRecognizer.StartParams = {
        sessionId: SpeechRecognizerManager.sessionId,
        audioInfo: {
          audioType: 'pcm',
          sampleRate: 16000,
          soundChannel: 1,
          sampleBit: 16
        },
        extraParams: {
          "recognitionMode": 1, // 1 表示识别语音文件
          maxAudioDuration: 60000
        }
      }
      SpeechRecognizerManager.asrEngine?.startListening(recognizerParams);
    } catch (e) {
      console.log("e", e.code, e.message)
    }
  };

  private static async writeAudio(fileName: string) {
    let ctx = getContext();
    let filePath: string = `${ctx.filesDir}/${fileName}.wav`;
    let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE);
    let buf: ArrayBuffer = new ArrayBuffer(1280);
    let offset: number = 0;
    while (1280 == fileIo.readSync(file.fd, buf, { offset: offset })) {
      let uint8Array: Uint8Array = new Uint8Array(buf);
      SpeechRecognizerManager.asrEngine?.writeAudio(SpeechRecognizerManager.sessionId, uint8Array);
      await SpeechRecognizerManager.sleep(40)
      offset = offset + 1280;
    }
    fileIo.closeSync(file);
  }

  static sleep(time: number) {
    return new Promise<void>((resolve) => {
      setTimeout(() => {
        resolve()
      }, time)
    })
  }

  /**
   * 语音文件转文本主入口
   * @param callback 识别结果回调
   * @param fileName 录音文件名（不带路径和扩展名）
   */
  static async init2(callback: (srr: speechRecognizer.SpeechRecognitionResult) => void = () => {}, fileName: string) {
    try {
      await SpeechRecognizerManager.createEngine()
      SpeechRecognizerManager.setListener(callback)
      SpeechRecognizerManager.startListening2()
      await SpeechRecognizerManager.writeAudio(fileName)
    } catch (e) {
      console.log("e", e.message)
    }
  }
}

export default SpeechRecognizerManager
