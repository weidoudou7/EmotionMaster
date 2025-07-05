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

  aboutToAppear() {
    this.loadPersonalizedFeaturedPersons();
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
    Column() {
      // 顶部标题和用户偏好信息
      if (this.userPreference && this.userPreference.totalConversations > 0) {
        Column() {
          Text('为你推荐')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
            .margin({ top: 16, bottom: 8 })
          
          Text(`基于你的${this.userPreference.totalConversations}次对话，推荐${this.userPreference.mostPreferredRoleType}类型角色`)
            .fontSize(14)
            .fontColor('#aaa')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 16 })
            .padding({ left: 20, right: 20 })
        }
        .width('100%')
        .backgroundColor('rgba(255,255,255,0.05)')
        .borderRadius(12)
        .margin({ bottom: 16 })
      }

      // 加载状态
      if (this.isAnalyzing) {
        Column() {
          LoadingProgress()
            .color('#fff')
            .width(24)
            .height(24)
          Text('正在分析你的偏好...')
            .fontSize(14)
            .fontColor('#aaa')
            .margin({ top: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 100 })
      } else if (this.isLoading) {
        Column() {
          LoadingProgress()
            .color('#fff')
            .width(24)
            .height(24)
          Text('正在加载推荐内容...')
            .fontSize(14)
            .fontColor('#aaa')
            .margin({ top: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 100 })
      } else if (this.errorMessage) {
        Column() {
          Text('⚠️')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#aaa')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 16 })
          Button('重新加载')
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
              Column() {
                // 图片
                Image(item.avatarUrl)
                  .width('100%')
                  .aspectRatio(1.2)
                  .borderRadius(12)
                  .objectFit(ImageFit.Cover)
                // 内容区
                Column() {
                  Text(item.roleName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#fff')
                    .margin({ top: 2, bottom: 2 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(item.roleDescription)
                    .fontSize(13)
                    .fontColor('#ccc')
                    .maxLines(2)
                    .margin({ bottom: 2 })
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Row() {
                    Text('@' + item.roleAuthor)
                      .fontSize(12)
                      .fontColor('#aaa')
                      .margin({ left: 4, right: 8 })
                    // 浏览量
                    Image($r('app.media.message_icon'))
                      .width(14)
                      .height(14)
                    Text(item.viewCount.toString())
                      .fontSize(12)
                      .fontColor('#aaa')
                      .margin({ left: 2 })
                  }
                  .alignItems(VerticalAlign.Center)
                }
                .padding({ left: 8, right: 8, bottom: 8 })
              }
              .backgroundColor('#232323')
              .borderRadius(16)
              .shadow({ radius: 8, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 2 })
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
    .backgroundColor('#181818')
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    .padding({ left: 12, right: 12 })
  }
}

