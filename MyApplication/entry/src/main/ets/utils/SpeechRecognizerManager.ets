import { speechRecognizer } from '@kit.CoreSpeechKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

class SpeechRecognizerManager {
  private static extraParam: Record<string, Object> = {
    "locate": "CN",
    "recognizerMode": "short",
    "vadEnable": true,
    "vadTimeout": 5000
  };

  private static initParamsInfo: speechRecognizer.CreateEngineParams = {
    language: 'zh-CN',
    online: 1,
    extraParams: this.extraParam
  };

  private static asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null;
  static speechResult: speechRecognizer.SpeechRecognitionResult | null = null;
  private static sessionId: string = "asr" + this.generateSessionId();
  private static isInitialized: boolean = false;
  private static retryCount: number = 0;
  private static maxRetries: number = 3;
  private static sessionCounter: number = 0;

  /**
   * 生成会话ID
   */
  private static generateSessionId(): string {
    SpeechRecognizerManager.sessionCounter++;
    return "session_" + SpeechRecognizerManager.sessionCounter;
  }

  /**
   * 创建语音识别引擎
   */
  private static async createEngine(): Promise<boolean> {
    try {
      console.log('开始创建语音识别引擎...');

      if (SpeechRecognizerManager.asrEngine) {
        console.log('引擎已存在，跳过创建');
        return true;
      }

      SpeechRecognizerManager.asrEngine = await speechRecognizer.createEngine(SpeechRecognizerManager.initParamsInfo);
      console.log('语音识别引擎创建成功');
      return true;
    } catch (error) {
      console.error('创建语音识别引擎失败:', error);
      const businessError = error as BusinessError;
      console.error('错误代码:', businessError.code);
      console.error('错误信息:', businessError.message);

      // 如果是权限问题，给出明确提示
      if (businessError.code === 201 || businessError.code === 202) {
        console.error('语音识别权限不足，请检查麦克风权限');
      }

      return false;
    }
  }

  /**
   * 设置监听器
   */
  private static setListener(callback: (srr: speechRecognizer.SpeechRecognitionResult) => void = () => {}) {
    try {
      let setListener: speechRecognizer.RecognitionListener = {
        onStart(sessionId: string, eventMessage: string) {
          console.log('语音识别开始:', sessionId, eventMessage);
        },
        onEvent(sessionId: string, eventCode: number, eventMessage: string) {
          console.log('语音识别事件:', sessionId, eventCode, eventMessage);
        },
        onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
          console.log('语音识别结果:', result);
          SpeechRecognizerManager.speechResult = result;
          callback && callback(result);
        },
        onComplete(sessionId: string, eventMessage: string) {
          console.log('语音识别完成:', sessionId, eventMessage);
        },
        onError(sessionId: string, errorCode: number, errorMessage: string) {
          console.error('语音识别错误:', sessionId, errorCode, errorMessage);
          // 如果是网络错误，可以尝试重试
          if (errorCode === 1001 || errorCode === 1002) {
            console.log('网络错误，尝试重试...');
            SpeechRecognizerManager.retryRecognition();
          }
        },
      };

      SpeechRecognizerManager.asrEngine?.setListener(setListener);
      console.log('监听器设置成功');
    } catch (error) {
      console.error('设置监听器失败:', error);
    }
  }

  /**
   * 开始监听
   */
  static startListening2(): boolean {
    try {
      if (!SpeechRecognizerManager.asrEngine) {
        console.error('语音识别引擎未初始化');
        return false;
      }

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
          maxAudioDuration: 60000,
          vadEnable: true,
          vadTimeout: 5000
        }
      };

      SpeechRecognizerManager.asrEngine.startListening(recognizerParams);
      console.log('开始语音识别监听');
      return true;
    } catch (error) {
      console.error('开始监听失败:', error);
      return false;
    }
  }

  /**
   * 写入音频数据
   */
  private static async writeAudio(fileName: string): Promise<boolean> {
    try {
      let ctx = getContext();
      let filePath: string = `${ctx.filesDir}/${fileName}.wav`;

      // 检查文件是否存在
      if (!fileIo.accessSync(filePath)) {
        console.error('音频文件不存在:', filePath);
        return false;
      }

      let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
      let buf: ArrayBuffer = new ArrayBuffer(1280);
      let offset: number = 0;
      let readSize: number;

      console.log('开始读取音频文件:', filePath);

      while ((readSize = fileIo.readSync(file.fd, buf, { offset: offset })) > 0) {
        let uint8Array: Uint8Array = new Uint8Array(buf, 0, readSize);
        SpeechRecognizerManager.asrEngine?.writeAudio(SpeechRecognizerManager.sessionId, uint8Array);
        await SpeechRecognizerManager.sleep(40);
        offset = offset + readSize;
      }

      fileIo.closeSync(file);
      console.log('音频数据写入完成，总字节数:', offset);
      return true;
    } catch (error) {
      console.error('写入音频数据失败:', error);
      return false;
    }
  }

  /**
   * 重试识别
   */
  private static async retryRecognition() {
    if (SpeechRecognizerManager.retryCount < SpeechRecognizerManager.maxRetries) {
      SpeechRecognizerManager.retryCount++;
      console.log(`第${SpeechRecognizerManager.retryCount}次重试语音识别`);

      // 重新初始化引擎
      await SpeechRecognizerManager.releaseEngine();
      await SpeechRecognizerManager.sleep(1000);

      const success = await SpeechRecognizerManager.createEngine();
      if (success) {
        SpeechRecognizerManager.isInitialized = true;
      }
    } else {
      console.error('语音识别重试次数已达上限');
    }
  }

  /**
   * 停止语音识别引擎
   */
  static async releaseEngine() {
    try {
      if (SpeechRecognizerManager.asrEngine) {
        // 使用 shutup 方法停止语音识别
        SpeechRecognizerManager.asrEngine.shutdown();
        SpeechRecognizerManager.asrEngine = null;
        SpeechRecognizerManager.isInitialized = false;
        console.log('语音识别引擎已停止');
      }
    } catch (error) {
      console.error('停止引擎失败:', error);
    }
  }

  /**
   * 测试语音识别引擎方法（调试用）
   */
  static testEngineMethods() {
    try {
      if (SpeechRecognizerManager.asrEngine) {
        console.log('测试语音识别引擎方法...');

        // 测试可用的方法
        console.log('引擎对象:', SpeechRecognizerManager.asrEngine);
        console.log('引擎类型:', typeof SpeechRecognizerManager.asrEngine);

        // 检查引擎是否可用
        console.log('引擎是否可用:', !!SpeechRecognizerManager.asrEngine);

        // 尝试调用已知的方法来验证引擎状态
        try {
          // 这里只是测试引擎是否存在，不实际调用方法
          console.log('引擎状态检查完成');
        } catch (methodError) {
          console.log('引擎方法调用失败:', methodError);
        }

        return true;
      } else {
        console.log('引擎未初始化，无法测试方法');
        return false;
      }
    } catch (error) {
      console.error('测试引擎方法失败:', error);
      return false;
    }
  }

  static sleep(time: number) {
    return new Promise<void>((resolve) => {
      // 在 ArkTS 中，setTimeout 是允许的
      setTimeout(() => {
        resolve();
      }, time);
    })
  }

  /**
   * 语音文件转文本主入口
   * @param callback 识别结果回调
   * @param fileName 录音文件名（不带路径和扩展名）
   */
  static async init2(callback: (srr: speechRecognizer.SpeechRecognitionResult) => void = () => {}, fileName: string) {
    try {
      console.log('开始语音识别，文件名:', fileName);

      // 重置重试计数
      SpeechRecognizerManager.retryCount = 0;

      // 创建引擎
      const engineCreated = await SpeechRecognizerManager.createEngine();
      if (!engineCreated) {
        console.error('语音识别引擎创建失败');
        callback({ result: '语音识别初始化失败' } as speechRecognizer.SpeechRecognitionResult);
        return;
      }

      SpeechRecognizerManager.isInitialized = true;

      // 设置监听器
      SpeechRecognizerManager.setListener(callback);

      // 开始监听
      const listeningStarted = SpeechRecognizerManager.startListening2();
      if (!listeningStarted) {
        console.error('开始监听失败');
        callback({ result: '语音识别启动失败' } as speechRecognizer.SpeechRecognitionResult);
        return;
      }

      // 写入音频数据
      const audioWritten = await SpeechRecognizerManager.writeAudio(fileName);
      if (!audioWritten) {
        console.error('音频数据写入失败');
        callback({ result: '音频文件读取失败' } as speechRecognizer.SpeechRecognitionResult);
        return;
      }

      console.log('语音识别流程启动成功');
    } catch (error) {
      console.error('语音识别初始化失败:', error);
      callback({ result: '语音识别失败: ' + (error as Error).message } as speechRecognizer.SpeechRecognitionResult);
    }
  }
}

export default SpeechRecognizerManager
