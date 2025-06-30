

interface TaskInfo {
  title: string;
  desc: string;
  status: string;
  reward: number;
  time: string;
  type: string;
  button: string;
  icon: string;
  iconColor: string;
  topBarColor: string;
  btnType: string;
  avatar: Resource;
  user: string;
}


@Entry
@Component
struct TasksPagePhone {
  @State private task_count: number = 6;

  private tasks: TaskInfo[] = [
    {
      title: '与AI分享一件开心事',
      desc: '告诉AI今天让你感到愉快的事情，分享快乐和能量',
      status: '进行中',
      reward: 25,
      time: '12:45 前',
      type: 'primary',
      button: '完成任务',
      icon: '💜',
      iconColor: '#7c3aed',
      topBarColor: '#6366f1',
      btnType: 'primary',
      avatar: $r('app.media.background'),
      user: 'AI助手'
    },
    {
      title: '记录今天的心情',
      desc: '描述你今天的心情，帮助AI了解你的情绪变化',
      status: '进行中',
      reward: 20,
      time: '18:30 前',
      type: 'warning',
      button: '完成任务',
      icon: '💛',
      iconColor: '#fbbf24',
      topBarColor: '#f59e42',
      btnType: 'warning',
      avatar: $r('app.media.QQ1222'),
      user: 'AI助手'
    },
    {
      title: '完成一次5分钟的对话',
      desc: '与AI进行一次持续5分钟的有意义对话',
      status: '进行中',
      reward: 30,
      time: '23:59 前',
      type: 'info',
      button: '开始对话',
      icon: '💙',
      iconColor: '#3b82f6',
      topBarColor: '#3b82f6',
      btnType: 'info',
      avatar: $r('app.media.doro'),
      user: 'AI助手'
    },
    {
      title: '学习一个新知识',
      desc: '向AI询问一个你感兴趣的新知识，并记录下来',
      status: '未开始',
      reward: 35,
      time: '明天 12:00',
      type: 'default',
      button: '接受任务',
      icon: '📚',
      iconColor: '#a78bfa',
      topBarColor: '#a78bfa',
      btnType: 'default',
      avatar: $r('app.media.background'),
      user: 'AI助手'
    },
    {
      title: '完成一个挑战',
      desc: '选择一个难度较高的挑战，并成功完成',
      status: '未开始',
      reward: 50,
      time: '23:59 前',
      type: 'danger',
      button: '接受任务',
      icon: '🔥',
      iconColor: '#ef4444',
      topBarColor: '#ef4444',
      btnType: 'danger',
      avatar: $r('app.media.QQ1222'),
      user: 'AI助手'
    },
    {
      title: '邀请朋友加入',
      desc: '邀请一位朋友一起使用本应用，共同成长',
      status: '进行中',
      reward: 40,
      time: '3天后',
      type: 'success',
      button: '分享邀请',
      icon: '🤝',
      iconColor: '#22c55e',
      topBarColor: '#22c55e',
      btnType: 'success',
      avatar: $r('app.media.planet1'),
      user: 'AI助手'
    },
    {
      title: '今日步数达标',
      desc: '完成10000步，保持健康生活',
      status: '未开始',
      reward: 15,
      time: '今天',
      type: 'success',
      button: '开始计步',
      icon: '🚶‍♂️',
      iconColor: '#22c55e',
      topBarColor: '#22c55e',
      btnType: 'success',
      avatar: $r('app.media.background'),
      user: 'AI助手'
    },
    {
      title: '冥想10分钟',
      desc: '静下心来，进行10分钟冥想，放松身心',
      status: '未开始',
      reward: 18,
      time: '今天',
      type: 'primary',
      button: '开始冥想',
      icon: '🧘‍♂️',
      iconColor: '#6366f1',
      topBarColor: '#6366f1',
      btnType: 'primary',
      avatar: $r('app.media.QQ1222'),
      user: 'AI助手'
    },
    {
      title: '阅读30分钟',
      desc: '阅读一本喜欢的书籍，提升自我',
      status: '未开始',
      reward: 22,
      time: '今天',
      type: 'warning',
      button: '开始阅读',
      icon: '📖',
      iconColor: '#fbbf24',
      topBarColor: '#fbbf24',
      btnType: 'warning',
      avatar: $r('app.media.planet1'),
      user: 'AI助手'
    }
  ];

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          // 顶部标题和按钮
          Text('日常任务')
            .fontSize(22).fontWeight(FontWeight.Bold)
            .fontColor('#222')
            .margin({ top: 18, left: 16, right: 16, bottom: 2 })
          Text('完成任务，让你的自我成长')
            .fontSize(13).fontColor('#888')
            .margin({ left: 16, right: 16, bottom: 8 })
          Row({ space: 10 }) {
            Button('刷新任务')
              .fontSize(13)
              .fontColor('#fff')
              .backgroundColor('#22c55e')
              .borderRadius(8)
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            Button('任务日历')
              .fontSize(13)
              .fontColor('#222')
              .backgroundColor('#fff')
              .border({ color: '#e0e0e0', width: 1 })
              .borderRadius(8)
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
          }
          .margin({ left: 16, right: 16, bottom: 8 })

          // 任务卡片区 - 单列竖向滚动
          Column({ space: 12 }) {
            ForEach(this.tasks.slice(0, this.task_count), (task: TaskInfo) => {
              TaskCardPhone(task)
            })
          }
          .margin({ left: 12, right: 12 })

          // 底部按钮
          Button(this.task_count < this.tasks.length ? '查看更多任务' : '已显示全部任务')
            .margin({ top: 16, bottom: 16 })
            .width('80%')
            .backgroundColor('#222')
            .fontColor('#fff')
            .fontSize(15)
            .borderRadius(8)
            .alignSelf(ItemAlign.Center)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              if (this.task_count < this.tasks.length) {
                this.task_count = this.tasks.length;
              }
            })
        }
        .backgroundColor('#f7f8fa')
        .width('100%')
        .padding(8)
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Builder
function TaskCardPhone(task: TaskInfo) {
  Column() {
    // 顶部色条
    Column()
      .width('100%')
      .height(3)
      .backgroundColor(task.topBarColor)
      .borderRadius({ topLeft: 8, topRight: 8 })
    // 内容区
    Column({ space: 6 }) {
      Row({ space: 6 }) {
        Text(task.icon)
          .fontSize(18)
        Text(task.title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222')
          .maxLines(1)
        Text(task.status)
          .fontSize(11)
          .fontColor(task.status === '进行中' ? '#22c55e' : '#888')
          .backgroundColor(task.status === '进行中' ? '#e0ffe5' : '#eee')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(8)
          .margin({ left: 4 })
      }
      Text(task.desc)
        .fontSize(12)
        .fontColor('#666')
        .maxLines(2)
        .margin({ bottom: 2 })
      Row({ space: 6 }) {
        Text('👤').fontSize(14)
        Text(task.user).fontSize(11).fontColor('#888')
        Text('★ ' + task.reward).fontSize(11).fontColor('#fbbf24')
        Text(task.time).fontSize(11).fontColor('#bbb')
      }
      Row() {
        TaskBtnPhone(task.button, getBtnColor(task.btnType), task.btnType === 'default')
      }
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 10 })
  }
  .backgroundColor('#fff')
  .borderRadius(12)
  .shadow({ radius: 5, color: '#e5e7eb', offsetX: 0, offsetY: 1 })
  .width('100%')
  .padding(2)
}

@Builder
function TaskBtnPhone(label: string, color: string, isOutline: boolean) {
  Button(label)
    .width('100%')
    .fontSize(13)
    .fontWeight(FontWeight.Bold)
    .backgroundColor(isOutline ? '#fff' : color)
    .fontColor(isOutline ? color : '#fff')
    .border({ color: color, width: isOutline ? 1 : 0 })
    .borderRadius(8)
    .padding({ top: 5, bottom: 5 })
}

function getBtnColor(type: string): string {
  switch (type) {
    case 'primary': return '#6366f1'
    case 'warning': return '#f59e42'
    case 'info': return '#3b82f6'
    case 'danger': return '#ef4444'
    case 'success': return '#22c55e'
    default: return '#888'
  }
}