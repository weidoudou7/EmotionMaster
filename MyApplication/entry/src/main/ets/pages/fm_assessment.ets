import router from '@ohos.router';

// 压力评估问题接口
interface AssessmentQuestion {
  id: number;
  question: string;
  category: string;
  options: AssessmentOption[];
}

interface AssessmentOption {
  value: number;
  text: string;
  description: string;
}

// 评估结果接口
interface AssessmentResult {
  totalScore: number;
  stressLevel: 'low' | 'moderate' | 'high' | 'severe';
  levelName: string;
  levelColor: string;
  levelDescription: string;
  recommendations: string[];
  categoryScores: CategoryScore[];
}

interface CategoryScore {
  category: string;
  score: number;
  maxScore: number;
  percentage: number;
  description: string;
}

interface ScoreCount {
  score: number;
  count: number;
}

// 路由参数接口
interface RouterParams {
  toolName?: string;
  toolType?: string;
}

// 压力评估问题库
const ASSESSMENT_QUESTIONS: AssessmentQuestion[] = [
  {
    id: 1,
    question: '最近一周，你感到紧张或焦虑的频率如何？',
    category: '情绪状态',
    options: [
      { value: 1, text: '几乎没有', description: '很少感到紧张' },
      { value: 2, text: '偶尔', description: '有时会感到紧张' },
      { value: 3, text: '经常', description: '经常感到紧张' },
      { value: 4, text: '总是', description: '几乎总是紧张' }
    ]
  },
  {
    id: 2,
    question: '你的睡眠质量如何？',
    category: '睡眠质量',
    options: [
      { value: 1, text: '很好', description: '睡眠质量优秀' },
      { value: 2, text: '一般', description: '睡眠质量一般' },
      { value: 3, text: '较差', description: '经常失眠或质量差' },
      { value: 4, text: '很差', description: '严重睡眠问题' }
    ]
  },
  {
    id: 3,
    question: '你感到身体疲劳的程度如何？',
    category: '身体状态',
    options: [
      { value: 1, text: '精力充沛', description: '感觉很有活力' },
      { value: 2, text: '轻微疲劳', description: '偶尔感到疲劳' },
      { value: 3, text: '明显疲劳', description: '经常感到疲劳' },
      { value: 4, text: '极度疲劳', description: '总是感到疲惫' }
    ]
  },
  {
    id: 4,
    question: '你对日常工作的专注度如何？',
    category: '工作状态',
    options: [
      { value: 1, text: '非常专注', description: '能够很好集中注意力' },
      { value: 2, text: '比较专注', description: '大部分时间能专注' },
      { value: 3, text: '容易分心', description: '经常难以集中注意力' },
      { value: 4, text: '很难专注', description: '几乎无法集中注意力' }
    ]
  },
  {
    id: 5,
    question: '你的人际关系满意度如何？',
    category: '社交关系',
    options: [
      { value: 1, text: '很满意', description: '人际关系良好' },
      { value: 2, text: '比较满意', description: '人际关系一般' },
      { value: 3, text: '不太满意', description: '人际关系有些问题' },
      { value: 4, text: '很不满意', description: '人际关系紧张' }
    ]
  },
  {
    id: 6,
    question: '你感到压力的主要来源是什么？',
    category: '压力源',
    options: [
      { value: 1, text: '几乎没有压力', description: '生活压力很小' },
      { value: 2, text: '工作压力', description: '主要来自工作' },
      { value: 3, text: '生活压力', description: '来自生活各方面' },
      { value: 4, text: '多重压力', description: '多个方面都有压力' }
    ]
  },
  {
    id: 7,
    question: '你处理压力的能力如何？',
    category: '应对能力',
    options: [
      { value: 1, text: '很强', description: '能够很好处理压力' },
      { value: 2, text: '较强', description: '大部分压力能处理' },
      { value: 3, text: '一般', description: '处理压力能力有限' },
      { value: 4, text: '较弱', description: '很难处理压力' }
    ]
  },
  {
    id: 8,
    question: '你进行放松活动的频率如何？',
    category: '放松活动',
    options: [
      { value: 1, text: '每天都有', description: '经常进行放松活动' },
      { value: 2, text: '每周几次', description: '偶尔进行放松活动' },
      { value: 3, text: '很少', description: '很少进行放松活动' },
      { value: 4, text: '从不', description: '从不进行放松活动' }
    ]
  }
];

@Entry
@Component
struct FMAssessmentPage {
  @State currentStep: 'welcome' | 'assessment' | 'result' = 'welcome';
  @State currentQuestionIndex: number = 0;
  @State answers: Map<number, number> = new Map();
  @State selectedOption: number = -1;
  @State assessmentResult: AssessmentResult | null = null;
  @State progress: number = 0;
  @State showProgress: boolean = false;
  @State resultOpacity: number = 0;
  @State resultScale: number = 0.8;
  
  // 动画状态
  @State questionOpacity: number = 1;
  @State questionTranslateX: number = 0;
  @State optionScale: number = 1;
  @State optionOpacity: number = 1;

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as RouterParams;
    if (params && params.toolType === 'assessment') {
      this.currentStep = 'welcome';
    }
  }

  // 开始评估
  private startAssessment() {
    this.currentStep = 'assessment';
    this.currentQuestionIndex = 0;
    this.answers.clear();
    this.selectedOption = -1;
    this.progress = (1 / ASSESSMENT_QUESTIONS.length) * 100;
    this.showProgress = false;
  }

  // 选择答案
  private selectOption(questionId: number, optionValue: number) {
    this.selectedOption = optionValue;
    
    // 添加动画效果
    animateTo({ duration: 150, curve: Curve.EaseOut }, () => {
      this.optionScale = 0.95;
      this.optionOpacity = 0.8;
    });
    
    setTimeout(() => {
      this.answers.set(questionId, optionValue);
      this.nextQuestion();
    }, 200);
  }

  // 下一题
  private nextQuestion() {
    if (this.currentQuestionIndex < ASSESSMENT_QUESTIONS.length - 1) {
      // 切换题目动画
      animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
        this.questionOpacity = 0;
        this.questionTranslateX = -50;
      });
      
      setTimeout(() => {
        this.currentQuestionIndex++;
        this.selectedOption = -1;
        this.progress = ((this.currentQuestionIndex + 1) / ASSESSMENT_QUESTIONS.length) * 100;
        
        // 重置动画状态
        this.questionTranslateX = 50;
        animateTo({ duration: 300, curve: Curve.EaseIn }, () => {
          this.questionOpacity = 1;
          this.questionTranslateX = 0;
          this.optionScale = 1;
          this.optionOpacity = 1;
        });
      }, 300);
    } else {
      // 完成评估
      this.completeAssessment();
    }
  }

  // 完成评估
  private completeAssessment() {
    this.showProgress = true;
    
    // 模拟计算过程
    setTimeout(() => {
      this.calculateResult();
      this.currentStep = 'result';
      
      // 结果展示动画
      setTimeout(() => {
        animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
          this.resultOpacity = 1;
          this.resultScale = 1;
        });
      }, 100);
    }, 2000);
  }

  // 计算结果
  private calculateResult() {
    let totalScore = 0;
    const categoryScores: Map<string, ScoreCount> = new Map();
    
    // 计算总分和分类分数
    this.answers.forEach((value, questionId) => {
      totalScore += value;
      const question = ASSESSMENT_QUESTIONS.find(q => q.id === questionId);
      if (question) {
        const category = question.category;
        let current = categoryScores.get(category);
        if (!current) {
          current = { score: 0, count: 0 } as ScoreCount;
        }
        current.score += value;
        current.count += 1;
        categoryScores.set(category, current);
      }
    });

    // 确定压力水平
    let stressLevel: 'low' | 'moderate' | 'high' | 'severe';
    let levelName: string;
    let levelColor: string;
    let levelDescription: string;
    let recommendations: string[];

    if (totalScore <= 12) {
      stressLevel = 'low';
      levelName = '轻度压力';
      levelColor = '#4CAF50';
      levelDescription = '你的压力水平较低，整体状态良好。继续保持健康的生活方式。';
      recommendations = [
        '保持规律的作息时间',
        '继续现有的放松活动',
        '定期进行轻度运动',
        '与朋友家人保持联系'
      ];
    } else if (totalScore <= 20) {
      stressLevel = 'moderate';
      levelName = '中度压力';
      levelColor = '#FF9800';
      levelDescription = '你目前处于中度压力状态，需要适当关注和调节。';
      recommendations = [
        '学习压力管理技巧',
        '增加放松活动时间',
        '改善睡眠质量',
        '寻求社交支持'
      ];
    } else if (totalScore <= 28) {
      stressLevel = 'high';
      levelName = '高度压力';
      levelColor = '#F44336';
      levelDescription = '你的压力水平较高，建议采取积极的应对措施。';
      recommendations = [
        '考虑寻求专业心理咨询',
        '学习冥想和呼吸练习',
        '调整工作生活平衡',
        '建立健康的应对机制'
      ];
    } else {
      stressLevel = 'severe';
      levelName = '严重压力';
      levelColor = '#9C27B0';
      levelDescription = '你的压力水平很高，强烈建议寻求专业帮助。';
      recommendations = [
        '立即寻求专业心理咨询师帮助',
        '与医生讨论压力管理方案',
        '考虑调整工作或生活环境',
        '学习紧急压力缓解技巧'
      ];
    }

    // 构建分类分数
    const categoryScoreArray: CategoryScore[] = [];
    categoryScores.forEach((value, category) => {
      const maxScore = value.count * 4;
      const percentage = (value.score / maxScore) * 100;
      let description = '';
      
      if (percentage <= 25) description = '状态良好';
      else if (percentage <= 50) description = '需要关注';
      else if (percentage <= 75) description = '需要改善';
      else description = '需要重视';
      
      categoryScoreArray.push({
        category,
        score: value.score,
        maxScore,
        percentage,
        description
      });
    });

    this.assessmentResult = {
      totalScore,
      stressLevel,
      levelName,
      levelColor,
      levelDescription,
      recommendations,
      categoryScores: categoryScoreArray
    };
  }

  // 重新评估
  private restartAssessment() {
    this.currentStep = 'welcome';
    this.currentQuestionIndex = 0;
    this.answers.clear();
    this.selectedOption = -1;
    this.assessmentResult = null;
    this.progress = 0;
    this.showProgress = false;
    this.resultOpacity = 0;
    this.resultScale = 0.8;
  }

  // 返回首页
  private goHome() {
    router.back();
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Image($r('app.media.back'))
          .width(24)
          //.shadow({ radius: 4, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 2 })
          .onClick(() => router.back())
        Text('压力评估')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(36)
      }
      .width('100%')
      .padding({ top: 16, left: 12, right: 12, bottom: 12 })

      // 内容区域
      if (this.currentStep === 'welcome') {
        this.BuildWelcomeView();
      } else if (this.currentStep === 'assessment') {
        this.BuildAssessmentView();
      } else if (this.currentStep === 'result') {
        this.BuildResultView();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .expandSafeArea([SafeAreaType.SYSTEM])
  }

  @Builder
  BuildWelcomeView() {
    Column() {
      // 欢迎卡片
      Column() {
        Text('🧠')
          .fontSize(48)
          .margin({ bottom: 16 })
        Text('压力评估')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1976D2')
          .margin({ bottom: 8 })
        Text('通过专业量表评估你的压力水平')
          .fontSize(16)
          .fontColor('#666')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 24 })
        
        // 评估说明
        Column() {
          Row() {
            Text('📋')
              .fontSize(20)
              .margin({ right: 12 })
            Text('8个专业问题')
              .fontSize(16)
              .fontColor('#333')
          }
          .margin({ bottom: 12 })
          
          Row() {
            Text('⏱️')
              .fontSize(20)
              .margin({ right: 12 })
            Text('约3-5分钟完成')
              .fontSize(16)
              .fontColor('#333')
          }
          .margin({ bottom: 12 })
          
          Row() {
            Text('🔒')
              .fontSize(20)
              .margin({ right: 12 })
            Text('隐私保护，数据安全')
              .fontSize(16)
              .fontColor('#333')
          }
        }
        .margin({ bottom: 32 })
        
        Button('开始评估')
          .width('100%')
          .height(48)
          .backgroundColor('#1976D2')
          .fontColor('#fff')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .borderRadius(24)
          .onClick(() => this.startAssessment())
      }
      .backgroundColor('#fff')
      .borderRadius(20)
      .padding(24)
      .margin({ top: 40, left: 16, right: 16 })
      .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
    }
    .margin({top:80})
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  BuildAssessmentView() {
    Column() {
      // 进度条
      Row() {
        Progress({ value: this.progress, total: 100 })
          .width('80%')
          .height(6)
          .color('#1976D2')
          .backgroundColor('#e0e0e0')
          .borderRadius(3)
        Text(`${this.currentQuestionIndex + 1}/${ASSESSMENT_QUESTIONS.length}`)
          .fontSize(14)
          .fontColor('#666')
          .margin({ left: 12 })
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 问题卡片
      if (this.showProgress) {
        // 计算进度显示
        Column() {
          Text('正在分析结果...')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1976D2')
            .margin({ bottom: 16 })
          Progress({ value: 50, total: 100 })
            .width(200)
            .height(8)
            .color('#1976D2')
            .backgroundColor('#e0e0e0')
            .borderRadius(4)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          // 问题标题
          Text(ASSESSMENT_QUESTIONS[this.currentQuestionIndex].category)
            .fontSize(14)
            .fontColor('#1976D2')
            .backgroundColor('#E3F2FD')
            .borderRadius(12)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .margin({ bottom: 16 })
          
          // 问题内容
          Text(ASSESSMENT_QUESTIONS[this.currentQuestionIndex].question)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 32 })
            .opacity(this.questionOpacity)
            .translate({ x: this.questionTranslateX })

          // 选项列表
          ForEach(ASSESSMENT_QUESTIONS[this.currentQuestionIndex].options, (option: AssessmentOption, index: number) => {
            Row() {
              Column() {
                Text(option.text)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.selectedOption === option.value ? '#fff' : '#333')
                  .margin({ bottom: 4 })
                Text(option.description)
                  .fontSize(14)
                  .fontColor(this.selectedOption === option.value ? '#fff' : '#666')
              }
              .layoutWeight(1)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.selectedOption === option.value ? '#1976D2' : '#fff')
            .borderRadius(12)
            .border({ width: this.selectedOption === option.value ? 0 : 1, color: '#e0e0e0' })
            .margin({ bottom: 12 })
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetX: 0, offsetY: 2 })
            .scale({ x: this.optionScale, y: this.optionScale })
            .opacity(this.optionOpacity)
            .onClick(() => this.selectOption(ASSESSMENT_QUESTIONS[this.currentQuestionIndex].id, option.value))
          }, (option: AssessmentOption) => `${this.currentQuestionIndex}-${option.value}`)
        }
        .backgroundColor('#fff')
        .borderRadius(20)
        .padding(24)
        .margin({ left: 16, right: 16 })
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
      }
    }
    .layoutWeight(1)
  }

  @Builder
  BuildResultView() {
    if (this.assessmentResult) {
      Scroll() {
        Column() {
          // 结果卡片
          Column() {
            // 压力水平指示器
            Column() {
              Text(this.assessmentResult.levelName)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.assessmentResult.levelColor)
                .margin({ bottom: 8 })
              
              Row() {
                ForEach([1, 2, 3, 4], (level: number) => {
                  Blank()
                    .width(40)
                    .height(8)
                    .backgroundColor(level <= this.getStressLevelNumber(this.assessmentResult!.stressLevel) ? 
                      this.assessmentResult!.levelColor : '#e0e0e0')
                    .borderRadius(4)
                    .margin({ right: 8 })
                }, (level: number) => level.toString())
              }
              .margin({ bottom: 16 })
              
              Text(`总分：${this.assessmentResult.totalScore}/32`)
                .fontSize(16)
                .fontColor('#666')
            }
            .margin({ bottom: 24 })

            // 描述
            Text(this.assessmentResult.levelDescription)
              .fontSize(16)
              .fontColor('#333')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 24 })

            // 分类分数
            Column() {
              Text('详细分析')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .margin({ bottom: 16 })

              ForEach(this.assessmentResult.categoryScores, (category: CategoryScore) => {
                Column() {
                  Row() {
                    Text(category.category)
                      .fontSize(16)
                      .fontColor('#333')
                      .layoutWeight(1)
                    Text(category.description)
                      .fontSize(14)
                      .fontColor(this.getCategoryColor(category.percentage))
                  }
                  .margin({ bottom: 8 })

                  Progress({ value: category.percentage, total: 100 })
                    .width('100%')
                    .height(6)
                    .color(this.getCategoryColor(category.percentage))
                    .backgroundColor('#e0e0e0')
                    .borderRadius(3)
                }
                .margin({ bottom: 16 })
              }, (category: CategoryScore) => category.category)
            }
            .margin({ bottom: 24 })

            // 建议
            Column() {
              Text('个性化建议')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .margin({ bottom: 16 })

              ForEach(this.assessmentResult.recommendations, (recommendation: string, index: number) => {
                Row() {
                  Text(`${index + 1}.`)
                    .fontSize(16)
                    .fontColor('#1976D2')
                    .fontWeight(FontWeight.Bold)
                    .margin({ right: 8 })
                  Text(recommendation)
                    .fontSize(16)
                    .fontColor('#333')
                    .layoutWeight(1)
                }
                .margin({ bottom: 12 })
              }, (recommendation: string) => recommendation)
            }
          }
          .backgroundColor('#fff')
          .borderRadius(20)
          .padding(24)
          .margin({ top: 16, left: 16, right: 16, bottom: 16 })
          .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 4 })
          .opacity(this.resultOpacity)
          .scale({ x: this.resultScale, y: this.resultScale })

          // 操作按钮
          Row() {
            Button('重新评估')
              .layoutWeight(1)
              .height(48)
              .backgroundColor('#fff')
              .fontColor('#1976D2')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .borderRadius(24)
              .border({ width: 1, color: '#1976D2' })
              .margin({ right: 8 })
              .onClick(() => this.restartAssessment())

            Button('返回首页')
              .layoutWeight(1)
              .height(48)
              .backgroundColor('#1976D2')
              .fontColor('#fff')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .borderRadius(24)
              .margin({ left: 8 })
              .onClick(() => this.goHome())
          }
          .padding({ left: 16, right: 16, bottom: 32 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  // 获取压力水平数字
  private getStressLevelNumber(level: string): number {
    switch (level) {
      case 'low': return 1;
      case 'moderate': return 2;
      case 'high': return 3;
      case 'severe': return 4;
      default: return 1;
    }
  }

  // 获取分类颜色
  private getCategoryColor(percentage: number): string {
    if (percentage <= 25) return '#4CAF50';
    if (percentage <= 50) return '#FF9800';
    if (percentage <= 75) return '#F44336';
    return '#9C27B0';
  }
} 