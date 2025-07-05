import router from '@ohos.router';
import http from '@ohos.net.http';
import { Config } from '../common/config';
import { ApiService } from '../service/apiservice';
import { getUserId } from '../common/constants';
import { UserRolePreferenceAnalysis } from '../common/types';

interface FeaturedPerson {
   id: number | null;
   userId: number | null;
   roleName: string;
   roleDescription: string;
   roleType: string;
   roleAuthor: string;
   viewCount: number;
   avatarUrl: string;
   isTemplate: boolean;
   createdAt: string; // ISO字符串
}

// interface ApiResponse<T> {
//   success: boolean;
//   message: string;
//   data: T;
//   timestamp: number;
// }

@Entry
@Component
export struct FeaturedList {
  @State private selectedIndex: number = 0;
  private lastClickTime: number = 0;
  private lastClickIndex: number = -1;
  @State private isLoading: boolean = false;
  @State private errorMessage: string = '';
  @State private persons: FeaturedPerson[] = [];
  @State private userPreference: UserRolePreferenceAnalysis | null = null;
  @State private isAnalyzing: boolean = false;
  @State arcRotation: number = 0 // 圆弧旋转角度
  @State starTwinkle: number = 0 // 星星闪烁效果
  @State glowOpacity: number = 0.5 // 发光效果透明度
  @State textOpacity: number = 0.8 // 文字透明度
  @State nebulaOpacity: number = 0.3 // 星云透明度

  aboutToAppear() {
    this.startGalaxyAnimations()
    this.loadPersonalizedFeaturedPersons();
  }

  private startGalaxyAnimations() {
    // 圆弧旋转动画
    setInterval(() => {
      this.arcRotation += 1.5
    }, 50)
    
    // 星星闪烁动画
    setInterval(() => {
      this.starTwinkle += 0.1
    }, 100)
    
    // 发光效果动画
    setInterval(() => {
      this.glowOpacity = this.glowOpacity === 0.5 ? 0.8 : 0.5
    }, 1200)
    
    // 文字透明度动画
    setInterval(() => {
      this.textOpacity = this.textOpacity === 0.8 ? 1.0 : 0.8
    }, 1800)
    
    // 星云透明度动画
    setInterval(() => {
      this.nebulaOpacity = this.nebulaOpacity === 0.3 ? 0.6 : 0.3
    }, 3000)
  }

  async loadPersonalizedFeaturedPersons() {
    this.isLoading = true;
    this.errorMessage = '';
    this.isAnalyzing = true;

    try {
      // 1. 获取用户ID
      const userId = getUserId();
      if (userId === null) {
        console.log('用户未登录，加载默认特色人物');
        await this.fetchDefaultFeaturedPersons();
        return;
      }

      console.log('开始分析用户角色偏好...');
      
      // 2. 分析用户角色偏好
      const preference = await ApiService.analyzeUserRolePreference(userId, 10);
      this.userPreference = preference;
      
      console.log('用户偏好分析完成:', {
        mostPreferredType: preference.mostPreferredRoleType,
        totalConversations: preference.totalConversations,
        analysis: preference.analysis
      });

      // 3. 根据偏好加载相关角色
      if (preference.totalConversations > 0 && preference.mostPreferredRoleType !== '无数据') {
        console.log('根据用户偏好加载角色，偏好类型:', preference.mostPreferredRoleType);
        await this.fetchFeaturedPersonsByType(preference.mostPreferredRoleType);
      } else {
        console.log('用户无对话记录或无偏好，加载默认特色人物');
        await this.fetchDefaultFeaturedPersons();
      }

    } catch (error) {
      console.error('个性化推荐失败:', error);
      this.errorMessage = '个性化推荐失败，加载默认内容';
      await this.fetchDefaultFeaturedPersons();
    } finally {
      this.isLoading = false;
      this.isAnalyzing = false;
    }
  }

  async fetchFeaturedPersonsByType(roleType: string) {
    try {
      console.log(`开始请求${roleType}类型的特色人物数据...`);
      let httpRequest = http.createHttp();
      
      // 构建查询参数
      const url = `${Config.getApiBaseUrl()}/featured-people/type?roleType=${encodeURIComponent(roleType)}`;
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        readTimeout: 60000,
        header: {
          "Content-Type": "application/json"
        },
        connectTimeout: 30000
      });

      console.log("响应状态码:", response.responseCode);
      console.log("原始响应结果:", response.result);

      if (response.responseCode === 200 && typeof response.result === 'string') {
        const result = JSON.parse(response.result) as FeaturedPerson[];
        this.persons = result;
        console.log(`成功加载${roleType}类型角色，数量:`, result.length);
        // 打印角色列表详情
        for (const r of result) {
          console.log(`角色详情: ID=${r.id}, 名称=${r.roleName}, 浏览量=${r.viewCount}`);
        }
        
        // 检查是否有角色数据
        if (result.length === 0) {
          console.warn(`数据库中${roleType}类型的角色数量为0，加载默认内容`);
          await this.fetchDefaultFeaturedPersons();
        }
      } else {
        console.warn(`获取${roleType}类型角色失败，状态码: ${response.responseCode}，加载默认内容`);
        await this.fetchDefaultFeaturedPersons();
      }
    } catch (error) {
      console.error(`获取${roleType}类型角色失败:`, error);
      await this.fetchDefaultFeaturedPersons();
    }
  }

  async fetchDefaultFeaturedPersons() {
    try {
      console.log("开始请求默认特色人物数据...");
      let httpRequest = http.createHttp();
      const response = await httpRequest.request(
        Config.getApiBaseUrl()+"/featured-people/all",
        {
          method: http.RequestMethod.GET,
          readTimeout: 60000,
          header: {
            "Content-Type": "application/json"
          },
          connectTimeout: 30000
        }
      );

      console.log("响应状态码:", response.responseCode);
      console.log("原始响应结果:", response.result);

      if (response.responseCode === 200 && typeof response.result === 'string') {
        const result = JSON.parse(response.result) as FeaturedPerson[];
        this.persons = result;
        console.log("成功加载默认特色人物，数量:", result.length);
        // 打印默认角色列表详情
        for (const r of result) {
          console.log(`默认角色详情: ID=${r.id}, 名称=${r.roleName}, 类型=${r.roleType}, 浏览量=${r.viewCount}`);
        }
      } else {
        this.errorMessage = "请求失败，状态码: " + response.responseCode;
      }
    } catch (error) {
      this.errorMessage = "加载出错: " + (error as Error).message;
    }
  }

  build() {
    Stack() {
      // 深色渐变背景 - 改为纯黑色主题
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#000000', 0.0], ['#0a0a0a', 0.5], ['#1a1a1a', 1.0]]
        })
      
      // 旋转的圆弧背景 - 改为黑色系装饰
      Stack() {
        // 多个同心圆弧轨道
        ForEach([0, 1, 2, 3], (index: number) => {
          Stack() {
            // 圆弧轨道 - 改为深灰色
            Column()
              .width(250 + index * 60)
              .height(250 + index * 60)
              .borderRadius((250 + index * 60) / 2)
              .border({ width: 1, color: `rgba(64, 64, 64, ${0.3 - index * 0.05})` })
              .position({ x: '50%', y: '50%' })
              .translate({ x: -(250 + index * 60) / 2, y: -(250 + index * 60) / 2 })
            
            // 旋转的圆弧点 - 改为白色系
            Column()
              .width(6)
              .height(6)
              .backgroundColor(`rgba(255, 255, 255, ${0.6 - index * 0.1})`)
              .borderRadius(3)
              .position({ x: '50%', y: '50%' })
              .translate({ 
                x: -3 + Math.cos((this.arcRotation + index * 90) * Math.PI / 180) * (125 + index * 30),
                y: -3 + Math.sin((this.arcRotation + index * 90) * Math.PI / 180) * (125 + index * 30)
              })
          }
        })
        
        // 外圈装饰点 - 改为银色系
        ForEach([0, 1, 2, 3, 4, 5], (index: number) => {
          Column()
            .width(6)
            .height(6)
            .backgroundColor(`rgba(192, 192, 192, ${0.4 - index * 0.05})`)
            .borderRadius(3)
            .position({ x: '50%', y: '50%' })
            .translate({ 
              x: -3 + Math.cos((this.arcRotation * 0.5 + index * 60) * Math.PI / 180) * 120,
              y: -3 + Math.sin((this.arcRotation * 0.5 + index * 60) * Math.PI / 180) * 120
            })
        })
      }
      .width('100%')
      .height('100%')
      
      // 主要内容区域
      Column() {
        // 顶部标题和用户偏好信息
        if (this.userPreference && this.userPreference.totalConversations > 0) {
          Stack() {
            // 推荐卡片背景发光效果
            Column()
              .width('100%')
              .height('auto')
              .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.03})`)
              .borderRadius(16)
              .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
            
            Column() {
              Text('为你推荐')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff')
                .opacity(this.textOpacity)
                .margin({ top: 16, bottom: 8 })
              
              Text(`基于你的${this.userPreference.totalConversations}次对话，推荐${this.userPreference.mostPreferredRoleType}类型角色`)
                .fontSize(14)
                .fontColor('rgba(255, 255, 255, 0.7)')
                .textAlign(TextAlign.Center)
                .opacity(this.textOpacity)
                .margin({ bottom: 16 })
                .padding({ left: 20, right: 20 })
            }
            .width('100%')
            .backgroundColor('rgba(255, 255, 255, 0.03)')
            .borderRadius(16)
            .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
            .margin({ bottom: 16 })
            .shadow({ radius: 12, color: '#00000030', offsetX: 0, offsetY: 4 })
          }
        }

        // 加载状态
        if (this.isAnalyzing) {
          Column() {
            // 发光圆圈
            Stack() {
              Column()
                .width(80)
                .height(80)
                .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.05})`)
                .borderRadius(40)
                .border({ width: 2, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.2})` })
              
              LoadingProgress()
                .color('#ffffff')
                .width(24)
                .height(24)
            }
            .margin({ bottom: 16 })
            
            Text('正在分析你的偏好...')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.7)')
              .opacity(this.textOpacity)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 100 })
        } else if (this.isLoading) {
          Column() {
            // 发光圆圈
            Stack() {
              Column()
                .width(80)
                .height(80)
                .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.05})`)
                .borderRadius(40)
                .border({ width: 2, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.2})` })
              
              LoadingProgress()
                .color('#ffffff')
                .width(24)
                .height(24)
            }
            .margin({ bottom: 16 })
            
            Text('正在加载推荐内容...')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.7)')
              .opacity(this.textOpacity)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 100 })
        } else if (this.errorMessage) {
          Column() {
            Text('⚠️')
              .fontSize(32)
              .fontColor('#ff6b6b')
              .margin({ bottom: 8 })
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.7)')
              .textAlign(TextAlign.Center)
              .opacity(this.textOpacity)
              .margin({ bottom: 16 })
            Button('重新加载')
              .fontSize(14)
              .fontColor('#000000')
              .backgroundColor('#ffffff')
              .borderRadius(20)
              .padding({ left: 24, right: 24, top: 8, bottom: 8 })
              .onClick(() => {
                this.loadPersonalizedFeaturedPersons();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 100 })
        } else {
          // 角色网格
          Grid() {
            ForEach(this.persons, (item: FeaturedPerson, index: number) => {
              GridItem() {
                Stack() {
                  // 角色卡片背景发光效果
                  Column()
                    .width('100%')
                    .height('auto')
                    .backgroundColor(`rgba(255, 255, 255, ${this.glowOpacity * 0.02})`)
                    .borderRadius(20)
                    .border({ width: 1, color: `rgba(255, 255, 255, ${this.glowOpacity * 0.1})` })
                  
                  Column() {
                    // 图片
                    Image(item.avatarUrl)
                      .width('100%')
                      .aspectRatio(1.2)
                      .borderRadius(16)
                      .objectFit(ImageFit.Cover)
                      .border({ width: 2, color: 'rgba(255, 255, 255, 0.2)' })
                    
                    // 内容区
                    Column() {
                      Text(item.roleName)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#ffffff')
                        .opacity(this.textOpacity)
                        .margin({ top: 2, bottom: 2 })
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      
                      Text(item.roleDescription)
                        .fontSize(13)
                        .fontColor('rgba(255, 255, 255, 0.8)')
                        .opacity(this.textOpacity)
                        .maxLines(2)
                        .margin({ bottom: 2 })
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      
                      Row() {
                        Text('@' + item.roleAuthor)
                          .fontSize(12)
                          .fontColor('rgba(255, 255, 255, 0.6)')
                          .margin({ left: 4, right: 8 })
                        // 浏览量
                        Image($r('app.media.message_icon'))
                          .width(14)
                          .height(14)
                        Text(item.viewCount.toString())
                          .fontSize(12)
                          .fontColor('rgba(255, 255, 255, 0.6)')
                          .margin({ left: 2 })
                      }
                      .alignItems(VerticalAlign.Center)
                    }
                    .padding({ left: 8, right: 8, bottom: 8 })
                  }
                  .width('100%')
                  .backgroundColor('rgba(255, 255, 255, 0.03)')
                  .borderRadius(20)
                  .border({ width: 1, color: 'rgba(255, 255, 255, 0.1)' })
                  .shadow({ radius: 12, color: '#00000030', offsetX: 0, offsetY: 4 })
                }
                .margin({ bottom: 4 })
                .onClick(() => {
                  const currentTime = Date.now();
                  
                  // 检查是否是双击（300ms内的两次点击）
                  if (currentTime - this.lastClickTime < 300 && this.lastClickIndex === index) {
                    // 双击事件 - 跳转到聊天页面
                    router.pushUrl({
                      url: 'pages/chat',
                      params: {
                        figureImageUrl: item.avatarUrl,
                        figureType: item.roleType,
                        figureName: item.roleName,
                        isFromCreateFigure: true,
                        description: item.roleDescription,
                        createdAiRoleId:item.id
                      }
                    });
                    // 重置状态
                    this.lastClickTime = 0;
                    this.lastClickIndex = -1;
                  } else {
                    // 单击事件 - 选择卡片
                    this.selectedIndex = index;
                    this.lastClickTime = currentTime;
                    this.lastClickIndex = index;
                  }
                })
              }
            }, (item: FeaturedPerson) => item.id?item.id.toString():"1")
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(16)
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
      .padding({ left: 12, right: 12 })
    }
    .width('100%')
    .height('100%')
  }
}

