import { TextReader, TextReaderIcon, ReadStateCode } from '@kit.SpeechKit';
import common from '@ohos.app.ability.common';
import { taskpool } from '@kit.ArkTS';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import worker from '@ohos.worker';
//import thread from '@ohos.thread';
//import { permission } from '@ohos.security';

@Entry
@Component
struct Index {
  // 输入的文本内容
  @State inputText: string = '请输入要朗读的文本';
  // 播放状态
  @State readState: ReadStateCode = ReadStateCode.WAITING;
  // 初始化状态
  @State isInit: boolean = false;
  // 朗读信息列表
  @State readInfoList: Array<TextReader.ReadInfo> = [];
  // 显示朗读状态
  @State isReading: boolean = false;

  @State hasBackgroundPermission: boolean = false;

  @State workerMessage: string = '';

  // private sensorTask?: taskpool.LongTask;
  private workerInstance?: worker.ThreadWorker;
  private isBackgroundMode: boolean = false;
  private context: common.UIAbilityContext | null = null;

  aboutToAppear() {

    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.checkPermissions();
    this.initTextReader();
    this.setActionListener();
  }

  onDestroy() {
    this.releaseActionListener();
    this.releaseTextReader();
    this.disableBackgroundMode();
  }

  // 检查并申请必要的权限
  async checkPermissions() {
    if (!this.context) return;

    try {
      // 权限检查逻辑保持不变...
    } catch (error) {
      console.error('权限检查失败:', error);
    }
  }


  async releaseTextReader() {
    if (this.isInit) {
      try {
        await TextReader.release();
        this.isInit = false;
      } catch (err) {
        console.error(`TextReader释放失败: ${err.message}`);
      }
    }
  }
  // 初始化朗读控件
  async initTextReader() {
    const readerParam: TextReader.ReaderParam = {
      isVoiceBrandVisible: true,
      businessBrandInfo: {
        panelName: '文本朗读',
        panelIcon: $r('app.media.startIcon') // 替换为你的图标资源
      }
    };
    try {
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await TextReader.init(context, readerParam);
      this.isInit = true;
      this.setActionListener();
    } catch (err) {
      console.error(`TextReader初始化失败: ${err.message}`);
    }
  }


  // 设置事件监听
  setActionListener() {
    TextReader.on('setArticle', async (id: string) => {
      console.info(`setArticle ${id}`);
    });

    TextReader.on('clickArticle', (id: string) => {
      console.info(`onClickArticle ${id}`);
    });

    TextReader.on('clickAuthor', (id: string) => {
      console.info(`onClickAuthor ${id}`);
    });

    TextReader.on('clickNotification', (id: string) => {
      console.info(`onClickNotification ${id}`);
    });

    TextReader.on('showPanel', () => {
      console.info(`onShowPanel`);
    });

    TextReader.on('hidePanel', () => {
      console.info(`onHidePanel`);
    });

    TextReader.on('stateChange', (state: TextReader.ReadState) => {
      this.readState = state.state;
      this.isReading = state.state === ReadStateCode.PLAYING;
      console.info(`朗读状态变更: ${state.state}`);

      // 处理后台模式
      if (state.state === ReadStateCode.PLAYING && this.hasBackgroundPermission) {
        this.enableBackgroundMode();
      } else if (state.state === ReadStateCode.PAUSED ||
        state.state === ReadStateCode.COMPLETED) {
        this.disableBackgroundMode();
      }
    });

    TextReader.on('requestMore', () => {
      // 加载更多内容逻辑
      this.loadMoreContent();
    });
  }

  // 注销事件监听
  releaseActionListener() {
    TextReader.off('setArticle');
    TextReader.off('clickArticle');
    TextReader.off('clickAuthor');
    TextReader.off('clickNotification');
    TextReader.off('showPanel');
    TextReader.off('hidePanel');
    TextReader.off('stateChange');
    TextReader.off('requestMore');
  }


  // 启用后台模式
  // async enableBackgroundMode() {
  //   if (!this.isBackgroundMode && this.hasBackgroundPermission) {
  //     try {
  //       // 启动长时任务
  //       this.sensorTask = new taskpool.LongTask(this.backgroundReaderTask);
  //       await taskpool.execute(this.sensorTask);
  //       this.isBackgroundMode = true;
  //       console.info('已启用后台朗读模式');
  //     } catch (error) {
  //       console.error('启用后台模式失败:', error);
  //     }
  //   }
  // }

  // 启用后台模式（使用Worker）
  async enableBackgroundMode() {
    if (!this.isBackgroundMode && this.hasBackgroundPermission) {
      try {
        // 创建Worker实例（注意路径格式）
        this.workerInstance = new worker.ThreadWorker(
          'entry/ets/workers/backgroundWorker.ets'
        );

        // 注册消息回调
        this.workerInstance.onmessage = (e) => {
          this.workerMessage = e.data;
          console.info('主线程收到Worker消息:', e.data);

          // 根据Worker消息更新状态
          if (e.data === 'readingStarted') {
            this.isReading = true;
          } else if (e.data === 'readingStopped') {
            this.isReading = false;
          }
        };

        // 注册错误回调
        this.workerInstance.onerror = (err) => {
          console.error('Worker错误:', err.message);
        };

        // 注册退出回调
        this.workerInstance.onexit = (code) => {
          console.info('Worker退出，代码:', code);
          this.isBackgroundMode = false;
          this.workerInstance = undefined;
        };

        // 启动Worker
        this.workerInstance.postMessage('init');
        console.info('已启用后台朗读模式（使用Worker）');
        this.isBackgroundMode = true;
      } catch (error) {
        console.error('启用后台模式失败:', error);
      }
    }
  }

  // 禁用后台模式
  async disableBackgroundMode() {
    if (this.isBackgroundMode && this.workerInstance) {
      try {
        // 发送停止消息给Worker
        this.workerInstance.postMessage('stopReading');

        // 等待Worker确认停止（可选）
        // setTimeout(() => {
        //   // 终止Worker
        //  this.workerInstance.terminate();
        //   this.workerInstance = undefined;
        //   this.isBackgroundMode = false;
        //   console.info('已禁用后台朗读模式');
        // }, 500);
      } catch (error) {
        console.error('禁用后台模式失败:', error);
      }
    }
  }


  // 加载更多内容
  loadMoreContent() {
    // 实现内容加载逻辑
    console.info('加载更多内容...');
    // 示例：从服务器获取更多文本
    // this.newData = await fetchMoreContent();
    // TextReader.loadMore(this.newData, true);
  }

  // 处理朗读按钮点击
  async handleReadClick() {
    const startTime = Date.now();
    if (!this.inputText || !this.isInit) {

      console.warn('输入文本为空，无法朗读');
      return;
    }

    console.info('点击成功')
    // 创建朗读信息
    const readInfo: TextReader.ReadInfo = {
      id: 'text_' + new Date().getTime(),
      title: {
        text: '用户输入文本',
        isClickable: false
      },
      author: {
        text: '用户',
        isClickable: false
      },
      date: {
        text: new Date().toLocaleString(),
        isClickable: false
      },
      bodyInfo: this.inputText
    };

    this.readInfoList = [readInfo];

    try {
      await TextReader.start(this.readInfoList);
      console.info('文本朗读启动成功');
    } catch (err) {
      console.error(`文本朗读启动失败: ${err.message}`);
    }
    console.info(`[PERF] 朗读操作完成，耗时: ${Date.now() - startTime}ms`);
  }

  build() {
    Column() {
      // 标题
      Text('文本朗读功能')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 30, bottom: 20 })

      // 输入框
      TextInput({
        placeholder: '请输入要朗读的文字...',
      })
        .width('90%')
        .height(50)
        .margin({ bottom: 20 })
        .backgroundColor('#F0F0F0')
        .borderRadius(8)
        .onChange((value: string) => {
          this.inputText = value;
        })

      // 朗读按钮
      Button('开始朗读')
        .width('60%')
        .height(50)
        .backgroundColor('#007DFF')
        .borderRadius(25)
        .onClick(() => {
          this.handleReadClick();
        })

      // 朗读状态图标
      TextReaderIcon({ readState: $readState })
        .margin({ top: 30 })
        .width(40)
        .height(40)

      // 朗读状态提示
      if (this.isReading) {
        Text('正在朗读...')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })
          .foregroundColor('#007DFF')
      }else{
        Text('nonono')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })
          .foregroundColor('#007DFF')
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(20)


  }
}