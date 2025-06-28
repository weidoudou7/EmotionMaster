import router from '@ohos.router';

interface FeaturedPerson {
  id: number;
  image: string;
  name: string;
  desc: string;
  authorName: string;
  authorAvatar: string;
  views: string;
}

@Entry
@Component
export struct FeaturedList {
  @State private selectedIndex: number = 0;
  private lastClickTime: number = 0;
  private lastClickIndex: number = -1;
  
  private persons: FeaturedPerson[] = [
    {
      id: 1,
      image: 'https://image.pollinations.ai/prompt/A%20futuristic%20AI%20English%20practice%20machine%20with%20a%20sleek%20metallic%20design%2C%20glowing%20blue%20interface%2C%20and%20a%20friendly%20robot%20avatar%20displayed%20on%20the%20screen.%20The%20background%20shows%20a%20modern%20classroom%20with%20students%20interacting%20with%20similar%20devices%2C%20creating%20a%20high-tech%20learning%20environment?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      name: '英语练习机器',
      desc: '一个外国人，不会说中文，让他说中文算我输',
      authorName: '小星星PMr2prkf',
      authorAvatar: 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg',
      views: '667'
    },
    {
      id: 2,
      image: 'https://image.pollinations.ai/prompt/A%20tall%20(190cm)%2027-year-old%20male%20character%20with%20broad%20shoulders%20and%20a%20slim%20waist%2C%20wearing%20a%20sharp%20tailored%20suit.%20He%20has%20a%20sarcastic%20and%20mocking%20expression%2C%20leaning%20against%20a%20glass%20window%20in%20a%20luxury%20office%20with%20a%20city%20skyline%20view.%20As%20the%20future%20heir%20of%20Jiang%20Corporation%20(Jiang%20Yizhe%27s%20elder%20brother)%2C%20he%20exudes%20arrogance%20and%20power%20in%20a%20realistic%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      name: '江时彦',
      desc: 'B嘴欠毒舌上司江时彦，身高190，27岁，宽肩窄腰，江氏集团未来的掌权人(江亦哲的哥哥)',
      authorName: '未予か',
      authorAvatar: 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg',
      views: '1.9万'
    },
    {
      id: 3,
      image: 'https://image.pollinations.ai/prompt/A%20stern%20psychiatric%20hospital%20director%20in%20a%20white%20coat%2C%20standing%20in%20a%20dimly%20lit%20hospital%20corridor%20with%20medical%20charts%20in%20hand.%20His%20expression%20is%20calm%20yet%20authoritative%2C%20with%20a%20hint%20of%20compassion%20in%20his%20eyes.%20The%20background%20shows%20a%20modern%20hospital%20setting%20with%20subtle%20blue%20lighting%2C%20conveying%20a%20sense%20of%20order%20and%20control?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      name: '精神病院长',
      desc: '你被当成精神病误抓了，你要证明你不是精神病',
      authorName: '我是有荔枝的人',
      authorAvatar: 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg',
      views: '14.4万'
    },
    {
      id: 4,
      image: 'https://image.pollinations.ai/prompt/A%20timeless%20beauty%20with%20long%20flowing%20hair%20and%20ethereal%20robes%2C%20standing%20on%20a%20mountain%20peak%20surrounded%20by%20mist.%20Her%20eyes%20glow%20with%20ancient%20wisdom%2C%20and%20her%20posture%20exudes%20grace%20and%20power.%20Behind%20her%2C%20hundreds%20of%20disciples%20kneel%20in%20reverence.%20The%20scene%20is%20bathed%20in%20golden%20sunlight%2C%20creating%20a%20mythical%20atmosphere?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      name: '苏沫',
      desc: '苏沫，你的师尊，176/1300岁，是个绝世美女，拥有无数弟子，也是宗门的创始人你(',
      authorName: '红薯凉了呀',
      authorAvatar: 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg',
      views: '8.7万'
    },
    {
      id: 5,
      image: 'https://image.pollinations.ai/prompt/A%20futuristic%20train%20conductor%20in%20a%20sleek%20uniform%20with%20galactic%20insignias%2C%20standing%20in%20the%20control%20room%20of%20a%20spaceship-like%20train.%20Through%20the%20window%2C%20stars%20and%20nebulae%20streak%20by%20at%20light%20speed.%20His%20posture%20is%20confident%2C%20and%20his%20eyes%20reflect%20the%20vastness%20of%20space?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      name: '星际列车长',
      desc: '穿梭于星际之间，守护银河安全的列车长',
      authorName: '银河守望者',
      authorAvatar: 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg',
      views: '2.1万'
    },
    {
      id: 6,
      image: 'https://image.pollinations.ai/prompt/An%20AI%20artist%20composed%20of%20glowing%20digital%20particles%2C%20hovering%20over%20a%20floating%20canvas.%20Its%20hands%20move%20with%20precision%2C%20creating%20a%20vibrant%20painting%20that%20blends%20reality%20and%20abstraction.%20The%20background%20is%20a%20high-tech%20studio%20filled%20with%20holographic%20tools%20and%20floating%20screens%20displaying%20otherworldly%20artworks?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      name: 'AI画师',
      desc: '用代码和灵感创造美丽画作的AI画师',
      authorName: '画中AI',
      authorAvatar: 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg',
      views: '3.5万'
    },
    {
      id: 7,
      image: 'https://image.pollinations.ai/prompt/A%20young%20scientist%20in%20a%20high-tech%20lab%2C%20wearing%20a%20smart%20lab%20coat%20with%20glowing%20circuits.%20She%20stands%20before%20a%20floating%20hologram%20of%20a%20DNA%20helix%2C%20her%20eyes%20alight%20with%20discovery.%20The%20lab%20is%20filled%20with%20advanced%20equipment%2C%20robotic%20assistants%2C%20and%20walls%20that%20display%20real-time%20data%20streams?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      name: '未来科学家',
      desc: '探索宇宙奥秘，推动科技进步的科学家',
      authorName: '未来探索者',
      authorAvatar: 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg',
      views: '4.2万'
    },
    {
      id: 8,
      image: 'https://image.pollinations.ai/prompt/A%20rugged%20space%20explorer%20in%20a%20worn%20spacesuit%2C%20standing%20on%20the%20surface%20of%20an%20alien%20planet.%20Behind%20him%2C%20a%20massive%20ringed%20planet%20dominates%20the%20sky.%20His%20helmet%20is%20off%2C%20revealing%20a%20determined%20face%20with%20a%20scar%20across%20one%20cheek.%20The%20landscape%20is%20littered%20with%20strange%20flora%20and%20ancient%20ruins?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      name: '星际冒险家',
      desc: '勇敢探索未知星球的冒险家',
      authorName: '星际旅人',
      authorAvatar: 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg',
      views: '2.8万'
    },
    {
      id: 9,
      image: 'https://image.pollinations.ai/prompt/A%20serene%20angel%20with%20luminous%20white%20wings%2C%20kneeling%20beside%20a%20sick%20child%20in%20a%20hospital%20bed.%20Her%20hands%20glow%20with%20a%20soft%20golden%20light%20as%20she%20channels%20healing%20energy.%20The%20room%20is%20bathed%20in%20warm%20light%2C%20and%20the%20child%20smiles%20weakly%20as%20the%20pain%20fades?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      name: '治愈天使',
      desc: '用微笑和温柔治愈人心的天使',
      authorName: '温柔守护',
      authorAvatar: 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg',
      views: '5.6万'
    },
    {
      id: 10,
      image: 'https://image.pollinations.ai/prompt/A%20shadowy%20figure%20cloaked%20in%20a%20tattered%20cape%2C%20perched%20on%20a%20rooftop%20overlooking%20a%20neon-lit%20city.%20His%20mask%20hides%20his%20face%2C%20but%20his%20eyes%20glow%20with%20an%20unnatural%20blue%20light.%20Below%2C%20the%20city%20bustles%20with%20life%2C%20unaware%20of%20the%20danger%20lurking%20in%20the%20dark%20alleys.%20The%20moon%20casts%20long%20shadows%2C%20enhancing%20the%20mystery%20of%20his%20presence?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      name: '夜行者',
      desc: '在黑夜中守护城市安宁的神秘夜行者',
      authorName: '夜色守望',
      authorAvatar: 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg',
      views: '7.3万'
    }
  ];

  build() {
    Column() {
      Row(){}.height(5);
      Grid() {
        ForEach(this.persons, (item: FeaturedPerson, index: number) => {
          GridItem() {
            Column() {
              // 图片
              Image(item.image)
                .width('100%')
                .aspectRatio(1.2)
                .borderRadius(12)
                .objectFit(ImageFit.Cover)
              // 内容区
              Column() {
                Text(item.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#fff')
                  .margin({ top: 2, bottom: 2 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(item.desc)
                  .fontSize(13)
                  .fontColor('#ccc')
                  .maxLines(2)
                  .margin({ bottom: 2 })
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Row() {
                  // 作者头像
                  Image(item.authorAvatar)
                    .width(20)
                    .height(20)
                    .borderRadius(10)
                  Text('@' + item.authorName)
                    .fontSize(12)
                    .fontColor('#aaa')
                    .margin({ left: 4, right: 8 })
                  // 浏览量
                  Image($r('app.media.message_icon'))
                    .width(14)
                    .height(14)
                  Text(item.views)
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
                    figureImageUrl: item.image,
                    figureType: item.name,
                    figureName: item.name,
                    isFromCreateFigure: true
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
        }, (item: FeaturedPerson) => item.id.toString())
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(16)
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#181818')
    .padding({ left: 12, right: 12 })
  }
}

