import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { ApiService } from '../service/apiservice'

interface ArtStyle {
  name: string;
  image: Resource;
  selected: boolean;
}

interface FigureTypeImages {
  name: string;
  images: string[];
}

@Entry
@Component
struct CreateFigurePage {
  @State private artStyles: ArtStyle[] = [
    { name: '云梦泽', image: $r('app.media.background'), selected: true },
    { name: '丹青', image: $r('app.media.bc_blue'), selected: false },
    { name: '主角', image: $r('app.media.bc_pink'), selected: false },
    { name: '魔法学院', image: $r('app.media.splash'), selected: false }
  ]
  @State private styleTags: string[] = ['精选', '动漫', '可爱', '写实', '创意', '国风']
  @State private selectedTags: Set<string> = new Set(['精选'])
  @State private desc: string = ''
  @State private isGenerating: boolean = false
  @State private isGeneratingFigure: boolean = false
  @State private selectedFigureType: number = 0
  @State private selectedImageIndex: number = 0
  @State private lastClickTime: number = 0
  @State private lastClickIndex: number = -1

  // 预定义的五种风格
  private readonly figureStyles: string[] = ['古风', '赛博', '卡通', '动漫', 'Q版']
  private readonly figureTypes: string[] = ['动漫', '可爱', '科幻', '写实']
  private readonly figureTypeImages: FigureTypeImages[] = [
    { name: '动漫', images: [
      'https://image.pollinations.ai/prompt/A%20beautiful%20anime%20girl%20with%20vibrant%20colors%2C%20detailed%20background%2C%204K%20resolution%2C%20in%20a%20stylized%20anime%20art%20style.%20Her%20large%20expressive%20eyes%20sparkle%20with%20life%2C%20framed%20by%20long%20flowing%20hair%20that%20shimmers%20in%20the%20light.%20She%20wears%20an%20elegant%20outfit%20with%20intricate%20designs%20and%20delicate%20accessories.%20The%20background%20is%20a%20fantasy%20landscape%20filled%20with%20lush%20vegetation%2C%20glowing%20particles%2C%20and%20atmospheric%20lighting.%20The%20scene%20is%20rendered%20in%20ultra-high%20detail%20with%20rich%20colors%2C%20dynamic%20shading%2C%20and%20a%20dreamlike%20quality%20characteristic%20of%20premium%20anime%20art.?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20beautiful%20anime%20girl%20with%20long%20flowing%20hair%20and%20sparkling%20eyes%2C%20wearing%20an%20elegant%20fantasy%20outfit%20with%20intricate%20details%2C%20standing%20in%20a%20magical%20forest%20filled%20with%20glowing%20flowers%20and%20fireflies%2C%204K%20resolution%2C%20vibrant%20colors%2C%20ultra-detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20cute%20anime%20character%20with%20big%20expressive%20eyes%20and%20fluffy%20hair%2C%20wearing%20a%20stylish%20school%20uniform%2C%20posing%20playfully%20in%20a%20sunny%20classroom%20with%20cherry%20blossoms%20outside%20the%20window%2C%20bright%20and%20cheerful%20atmosphere%2C%204K%20resolution%2C%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20cool%20anime%20warrior%20with%20spiky%20hair%20and%20piercing%20eyes%2C%20clad%20in%20futuristic%20armor%20with%20glowing%20accents%2C%20standing%20on%20a%20cliff%20overlooking%20a%20battlefield%20with%20explosions%20in%20the%20distance%2C%20dynamic%20lighting%2C%204K%20resolution%2C%20detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20mysterious%20anime%20girl%20with%20long%20silver%20hair%20and%20a%20melancholic%20expression%2C%20wearing%20a%20gothic%20lolita%20dress%2C%20sitting%20on%20a%20moonlit%20balcony%20with%20a%20raven%20perched%20nearby%2C%20dark%20and%20dreamy%20atmosphere%2C%204K%20resolution%2C%20ultra-detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20fantasy%20anime%20princess%20with%20long%20curly%20hair%20and%20a%20radiant%20smile%2C%20wearing%20a%20sparkling%20gown%20with%20delicate%20lace%20details%2C%20standing%20in%20a%20grand%20castle%20hall%20with%20stained%20glass%20windows%2C%20warm%20and%20regal%20lighting%2C%204K%20resolution%2C%20detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20sci-fi%20anime%20heroine%20with%20short%20neon-colored%20hair%20and%20cybernetic%20implants%2C%20wearing%20a%20sleek%20battle%20suit%2C%20posing%20in%20a%20futuristic%20cityscape%20with%20hovering%20vehicles%20and%20neon%20signs%2C%20cool%20blue%20and%20purple%20lighting%2C%204K%20resolution%2C%20ultra-detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20whimsical%20anime%20catgirl%20with%20fluffy%20ears%20and%20a%20playful%20grin%2C%20wearing%20a%20casual%20hoodie%20and%20shorts%2C%20lying%20on%20a%20pile%20of%20cushions%20in%20a%20cozy%20room%20with%20string%20lights%2C%20warm%20and%20inviting%20atmosphere%2C%204K%20resolution%2C%20detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20dark%20fantasy%20anime%20villain%20with%20sharp%20features%20and%20glowing%20red%20eyes%2C%20wearing%20a%20tattered%20cloak%20and%20ornate%20armor%2C%20standing%20in%20a%20ruined%20temple%20with%20floating%20runes%20and%20ominous%20fog%2C%20dramatic%20and%20sinister%20lighting%2C%204K%20resolution%2C%20ultra-detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux'
    ]},
    { name: '可爱', images: [
      'https://image.pollinations.ai/prompt/A%20super%20cute%20anime%20girl%20with%20big%20sparkling%20eyes%20and%20rosy%20cheeks%2C%20wearing%20a%20fluffy%20pastel%20dress%20with%20animal%20ears%20hood%2C%20holding%20a%20giant%20lollipop%2C%20standing%20in%20a%20candy-colored%20fantasy%20town%20with%20floating%20cupcakes%20and%20rainbows%2C%20ultra-kawaii%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/An%20adorable%20chibi%20anime%20character%20with%20round%20cheeks%20and%20tiny%20hands%2C%20wearing%20a%20panda%20onesie%2C%20hugging%20a%20giant%20teddy%20bear%20in%20a%20nursery%20room%20filled%20with%20stuffed%20animals%20and%20fluffy%20clouds%2C%20soft%20pastel%20colors%2C%20super%20cute%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20sweet%20twin-tail%20anime%20girl%20with%20glittery%20pink%20hair%20and%20heart-shaped%20hairpins%2C%20wearing%20a%20frilly%20maid%20outfit%20with%20lace%20apron%2C%20serving%20a%20tray%20of%20macarons%20in%20a%20pastel%20cafe%20with%20floral%20wallpaper%2C%20ultra-cute%20anime%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20sleepy%20anime%20catgirl%20with%20messy%20bed%20hair%20and%20yawn%20expression%2C%20wearing%20oversized%20pajamas%20with%20paw%20prints%2C%20curled%20up%20in%20a%20cozy%20blanket%20nest%20with%20milk%20bottle%20and%20pillows%2C%20warm%20morning%20light%20streaming%20through%20window%2C%20soft%20kawaii%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20playful%20anime%20bunny%20girl%20with%20floppy%20ears%20and%20a%20cheeky%20smile%2C%20wearing%20a%20puffy%20jacket%20with%20carrot%20design%2C%20hopping%20through%20a%20flower%20field%20with%20giant%20daisies%20and%20bouncing%20butterflies%2C%20sunny%20and%20cheerful%20atmosphere%2C%20super%20cute%20style%2C%204K%20resolution?width=1024&height=1024&enhense=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20magical%20anime%20fairy%20with%20translucent%20wings%20and%20glowing%20hair%2C%20wearing%20a%20shimmering%20tutu%20dress%20with%20star%20patterns%2C%20sitting%20on%20a%20mushroom%20in%20an%20enchanted%20forest%20with%20sparkling%20dust%20and%20fireflies%2C%20ethereal%20and%20dreamy%20lighting%2C%20ultra-cute%20fantasy%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20blushing%20anime%20girl%20with%20twintails%20and%20a%20shy%20expression%2C%20wearing%20a%20sailor%20uniform%20with%20heart-shaped%20buttons%2C%20holding%20a%20love%20letter%20in%20a%20cherry%20blossom%20park%20with%20fluttering%20petals%2C%20romantic%20pink%20sunset%20lighting%2C%20super%20kawaii%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20cheerful%20anime%20dog%20girl%20with%20floppy%20ears%20and%20a%20wagging%20tail%2C%20wearing%20a%20hoodie%20with%20paw%20print%20design%2C%20playing%20fetch%20in%20a%20sunny%20backyard%20with%20tennis%20balls%20and%20chew%20toys%2C%20happy%20and%20energetic%20vibes%2C%20ultra-cute%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20tiny%20anime%20mermaid%20with%20colorful%20scales%20and%20a%20cute%20seashell%20top%2C%20floating%20in%20a%20coral%20reef%20with%20bubbles%20and%20friendly%20fish%2C%20holding%20a%20pearl%20treasure%2C%20aquatic%20blue%20lighting%2C%20adorable%20underwater%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux'
    ]},
    { name: '科幻', images: [
      'https://image.pollinations.ai/prompt/A%20futuristic%20cityscape%20with%20neon%20lights%20and%20glowing%20skyscrapers%2C%20hovering%20vehicles%20zipping%20through%20the%20air%2C%20and%20a%20starry%20electronic%20sky%20overhead.%20The%20scene%20is%20rendered%20in%20ultra-high%20detail%20with%20vibrant%20colors%20and%20dynamic%20lighting%2C%20capturing%20the%20essence%20of%20a%20sci-fi%20metropolis.%20Cyberpunk%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/An%20advanced%20space%20station%20orbiting%20a%20distant%20planet%2C%20with%20glass%20domes%20revealing%20lush%20interior%20gardens%20and%20bustling%20human%20activity.%20Robots%20and%20humans%20work%20side%20by%20side%2C%20while%20spaceships%20dock%20at%20the%20station%27s%20ports.%20Highly%20detailed%20sci-fi%20illustration%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20futuristic%20battle%20scene%20on%20an%20alien%20planet%2C%20with%20mechs%20and%20soldiers%20in%20advanced%20armor%20engaging%20in%20combat.%20Energy%20weapons%20flash%20across%20the%20battlefield%2C%20illuminating%20the%20strange%20alien%20flora%20and%20rock%20formations.%20Dynamic%20action%20composition%2C%20ultra-detailed%20sci-fi%20art%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20futuristic%20laboratory%20filled%20with%20holographic%20displays%20and%20advanced%20scientific%20equipment.%20Scientists%20in%20high-tech%20suits%20monitor%20floating%20DNA%20strands%20and%20quantum%20computations.%20The%20room%20glows%20with%20blue%20and%20purple%20lighting%2C%20creating%20a%20high-tech%20atmosphere.%20Ultra-detailed%20sci-fi%20illustration%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20futuristic%20underwater%20city%20with%20transparent%20domes%20revealing%20bustling%20streets%20and%20buildings%20inside.%20Giant%20whales%20and%20other%20sea%20creatures%20swim%20past%20the%20structures%2C%20while%20submarines%20and%20divers%20move%20between%20them.%20Beautiful%20aquatic%20lighting%20effects%2C%20ultra-detailed%20sci-fi%20art%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20futuristic%20desert%20city%20with%20sandstone%20buildings%20incorporating%20advanced%20technology.%20Solar%20panels%20and%20wind%20turbines%20dot%20the%20landscape%2C%20while%20hovering%20vehicles%20travel%20between%20the%20structures.%20The%20setting%20sun%20casts%20long%20shadows%20and%20warm%20orange%20light%20across%20the%20scene.%20Highly%20detailed%20sci-fi%20illustration%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20futuristic%20forest%20where%20the%20trees%20glow%20with%20bioluminescent%20patterns%20and%20mechanical%20creatures%20roam%20freely.%20A%20group%20of%20explorers%20in%20high-tech%20suits%20document%20the%20strange%20ecosystem%2C%20their%20equipment%20glowing%20in%20the%20dim%20light.%20Magical%20and%20scientific%20atmosphere%2C%20ultra-detailed%20sci-fi%20art%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20futuristic%20Asian-inspired%20city%20where%20traditional%20architecture%20blends%20with%20advanced%20technology.%20Neon%20signs%20in%20Chinese%20characters%20glow%20next%20to%20floating%20pagodas%2C%20while%20flying%20cars%20zoom%20through%20the%20streets.%20Vibrant%20colors%20and%20dynamic%20lighting%2C%20ultra-detailed%20sci-fi%20illustration%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20futuristic%20space%20battle%20with%20massive%20capital%20ships%20firing%20energy%20weapons%20at%20each%20other%20while%20fighters%20dodge%20between%20them.%20The%20background%20shows%20a%20distant%20nebula%20and%20stars%2C%20creating%20a%20stunning%20cosmic%20backdrop.%20Epic%20scale%20and%20ultra-detailed%20sci-fi%20art%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux'
    ]},
    { name: '写实', images: [
      'https://image.pollinations.ai/prompt/A%20detailed%20photorealistic%20portrait%20of%20an%20elderly%20man%20with%20deep%20wrinkles%20and%20wise%20eyes%2C%20standing%20in%20a%20traditional%20workshop%20with%20wooden%20tools%20and%20handcrafted%20items%2C%20soft%20natural%20lighting%20from%20a%20window%2C%208K%20resolution%2C%20ultra-realistic%20skin%20textures%20and%20fabric%20details?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20hyper-realistic%20photo%20of%20a%20busy%20farmer%27s%20market%20at%20sunrise%2C%20with%20vendors%20arranging%20fresh%20produce%2C%20steam%20rising%20from%20food%20stalls%2C%20and%20customers%20browsing%2C%20captured%20with%20a%20DSLR%20style%20depth%20of%20field%2C%20vibrant%20colors%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20stunning%20realistic%20landscape%20of%20a%20mountain%20valley%20at%20golden%20hour%2C%20with%20a%20crystal-clear%20river%20reflecting%20the%20peaks%2C%20wildflowers%20in%20the%20foreground%2C%20and%20dramatic%20clouds%20above%2C%20shot%20with%20a%20professional%20wide-angle%20lens%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20photorealistic%20close-up%20of%20a%20chef%27s%20hands%20preparing%20sushi%20in%20a%20high-end%20restaurant%2C%20with%20perfectly%20sliced%20fish%2C%20shiny%20rice%20grains%2C%20and%20delicate%20garnishes%2C%20shot%20with%20macro%20lens%20details%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20realistic%20urban%20street%20scene%20at%20night%20with%20wet%20pavements%20reflecting%20neon%20signs%2C%20taxi%20headlights%20streaking%20through%20the%20frame%2C%20and%20people%20walking%20under%20umbrellas%2C%20captured%20with%20long%20exposure%20techniques%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20hyper-detailed%20realistic%20wildlife%20photo%20of%20a%20snow%20leopard%20resting%20on%20a%20rocky%20cliff%20in%20the%20Himalayas%2C%20with%20its%20thick%20fur%20and%20piercing%20eyes%20clearly%20visible%2C%20surrounded%20by%20snow%20and%20mist%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20photorealistic%20still%20life%20of%20a%20rustic%20breakfast%20table%20with%20freshly%20baked%20bread%2C%20homemade%20jam%2C%20and%20a%20steaming%20cup%20of%20coffee%2C%20natural%20morning%20light%20streaming%20through%20a%20window%2C%20textures%20of%20wood%2C%20ceramic%2C%20and%20food%20rendered%20in%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20realistic%20documentary-style%20photo%20of%20a%20fisherman%20mending%20nets%20on%20a%20wooden%20dock%20at%20dawn%2C%20with%20boats%20in%20the%20background%20and%20seagulls%20flying%20overhead%2C%20captured%20with%20a%20reportage%20photography%20style%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux',
      'https://image.pollinations.ai/prompt/A%20highly%20detailed%20realistic%20interior%20shot%20of%20a%20cozy%20library%20with%20wooden%20bookshelves%2C%20leather%20armchairs%2C%20and%20a%20crackling%20fireplace%2C%20warm%20ambient%20lighting%2C%20dust%20particles%20in%20the%20air%2C%20and%20textured%20book%20spines%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux'
    ]}
  ]

  build(): void {
    Column() {
      // 顶部栏
      Row() {
        Button('<')
          .backgroundColor('transparent')
          .fontColor('#fff')
          .fontSize(24)
          .onClick(() => router.back())
        Blank().width(10)
        Text('创建形象')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
        Blank()
      }
      .width('100%')
      .height(56)
      .backgroundColor('#222')
      .alignItems(VerticalAlign.Center)
      .padding({ left: 10 })

      // 形象参考图
      Column() {
        Text('形象参考图')
          .fontSize(16)
          .fontColor('#fff')
          .margin({ bottom: 8 })
        Column() {
          Button('+')
            .width(60).height(60)
            .fontSize(36)
            .fontColor('#888')
            .backgroundColor('#222')
            .borderRadius(16)
            .onClick(() => promptAction.showToast({ message: '上传图片功能开发中' }))
          Text('(可选) 将基于上传的参考图生成基础形象')
            .fontSize(12)
            .fontColor('#888')
            .margin({ top: 8 })
        }
        .width('100%')
        .backgroundColor('#232323')
        .borderRadius(16)
        .padding(20)
      }
      .width('90%')
      .margin({ top: 18, bottom: 18 })
      .alignSelf(ItemAlign.Center)

      // 形象描述
      Column() {
        Row() {
          Text('形象描述')
            .fontSize(16)
            .fontColor('#fff')
          Blank()
          Button(this.isGenerating ? '生成中...' : '自动生成')
            .fontSize(13)
            .fontColor('#FFD700')
            .backgroundColor('transparent')
            .enabled(!this.isGenerating)
            .onClick(() => this.generateDescription())
        }
        .margin({ bottom: 8 })
        Column() {
          TextInput({ text: this.desc, placeholder: '（可选）添加形象的详细描述，如五官、动作、服饰、背景等' })
            .fontSize(14)
            .fontColor('#fff')
            .backgroundColor('#232323')
            .borderRadius(12)
            .height(60)
            .onChange((v: string) => {
              this.desc = v
            })
        }
        .width('100%')
        .backgroundColor('#232323')
        .borderRadius(16)
        .padding(20)
      }
      .width('90%')
      .margin({ bottom: 18 })
      .alignSelf(ItemAlign.Center)

      // 选择形象类型
      Text('选择形象类型')
        .fontSize(15)
        .fontColor('#fff')
        .alignSelf(ItemAlign.Start)
        .margin({ left: 20, bottom: 8 })

      List({ space: 12, initialIndex: this.selectedFigureType }) {
        ForEach(this.figureTypes, (type: string, idx: number) => {
          ListItem() {
            Button(type)
              .fontSize(15)
              .fontColor(this.selectedFigureType === idx ? '#FFD700' : '#fff')
              .backgroundColor(this.selectedFigureType === idx ? '#232323' : 'transparent')
              .borderRadius(16)
              .onClick(() => { this.selectedFigureType = idx; this.selectedImageIndex = 0 })
              .width(80)
              .height(36)
          }
        })
      }
      .height(48)
      .margin({ left: 20, right: 20, top: 12, bottom: 8 })
      .listDirection(Axis.Horizontal)

      // 横向滑动9张图片
      List({ space: 12, initialIndex: this.selectedImageIndex }) {
        ForEach(this.figureTypeImages[this.selectedFigureType]?.images ?? [], (img: string, idx: number) => {
          ListItem() {
            Image(img)
              .width(100)
              .height(100)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
              .border({ width: this.selectedImageIndex === idx ? 3 : 0, color: '#FFD700' })
              .onClick(() => this.handleImageClick(img, this.figureTypes[this.selectedFigureType], idx))
          }
        })
      }
      .height(110)
      .margin({ left: 20, right: 20, bottom: 18 })
      .listDirection(Axis.Horizontal)

      // 生成形象按钮
      Button(this.isGeneratingFigure ? '生成中...' : '生成形象')
        .width('90%')
        .height(48)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(this.isGeneratingFigure ? '#666' : '#FFD700')
        .fontColor('#222')
        .borderRadius(24)
        .alignSelf(ItemAlign.Center)
        .enabled(!this.isGeneratingFigure)
        .onClick(() => this.generateFigure())

      Blank().height(30)
    }
    .width('100%')
    .backgroundColor('#181818')
    .height('100%')
  }

  /**
   * 生成形象描述
   */
  private generateDescription(): void {
    if (this.isGenerating) {
      return
    }

    this.isGenerating = true
    
    // 使用setTimeout确保UI更新在正确的上下文中执行
    setTimeout(() => {
      this.generateDescriptionAsync()
    }, 0)
  }

  /**
   * 异步生成描述
   */
  private async generateDescriptionAsync(): Promise<void> {
    try {
      console.log('开始生成描述，用户输入:', this.desc);
      
      // 调用后端API生成描述
      const generatedDesc = await ApiService.generateDescription(this.desc)
      
      console.log('成功生成描述:', generatedDesc);
      
      // 使用setTimeout确保UI更新在正确的上下文中执行
      setTimeout(() => {
        try {
          // 将生成的描述设置到输入框
          this.desc = generatedDesc
          this.isGenerating = false
          
          // 使用setTimeout确保toast在正确的上下文中显示
          setTimeout(() => {
            try {
              promptAction.showToast({ 
                message: '描述生成成功！',
                duration: 2000
              })
            } catch (toastError) {
              console.error('Toast显示失败:', toastError)
            }
          }, 100)
        } catch (uiError) {
          console.error('UI更新失败:', uiError)
        }
      }, 0)
      
    } catch (error) {
      console.error('生成描述失败:', error);
      console.error('错误类型:', typeof error);
      console.error('错误详情:', JSON.stringify(error));
      
      // 使用setTimeout确保UI更新在正确的上下文中执行
      setTimeout(() => {
        try {
          this.isGenerating = false
          
          let errorMessage = '生成描述失败，请稍后重试';
          if (error instanceof Error) {
            errorMessage = error.message;
          }
          
          // 使用setTimeout确保toast在正确的上下文中显示
          setTimeout(() => {
            try {
              promptAction.showToast({ 
                message: errorMessage,
                duration: 3000
              })
            } catch (toastError) {
              console.error('Toast显示失败:', toastError)
            }
          }, 100)
        } catch (uiError) {
          console.error('UI错误处理失败:', uiError)
        }
      }, 0)
    }
  }

  /**
   * 生成形象
   */
  private generateFigure(): void {
    if (this.isGeneratingFigure) {
      return
    }

    if (!this.desc.trim()) {
      try {
        promptAction.showToast({ 
          message: '请先输入形象描述',
          duration: 2000
        })
      } catch (toastError) {
        console.error('Toast显示失败:', toastError)
      }
      return
    }

    this.isGeneratingFigure = true
    
    // 使用setTimeout确保UI更新在正确的上下文中执行
    setTimeout(() => {
      this.generateFigureAsync()
    }, 0)
  }

  /**
   * 异步生成形象
   */
  private async generateFigureAsync(): Promise<void> {
    try {
      console.log('开始生成形象，描述:', this.desc);
      
      // 为每种风格生成图片URL
      const imageUrls: string[] = []
      
      for (const style of this.figureStyles) {
        try {
          console.log(`生成${style}风格图片...`)
          const imageUrl = await ApiService.generateFigure(this.desc, style)
          imageUrls.push(imageUrl)
          console.log(`${style}风格图片URL:`, imageUrl)
        } catch (error) {
          console.error(`生成${style}风格图片失败:`, error)
          console.error('错误类型:', typeof error);
          console.error('错误详情:', JSON.stringify(error));
          
          // 检查是否是超时错误
          if (error && typeof error === 'object' && error.hasOwnProperty('code') && error.code === 2300028) {
            console.error(`生成${style}风格图片失败: Error: 生成图片超时，请稍后重试。AI生成需要较长时间，请耐心等待。`)
          }
          
          imageUrls.push('') // 添加空字符串作为占位符
        }
      }
      
      console.log('所有图片URL:', imageUrls);
      
      // 使用setTimeout确保UI更新在正确的上下文中执行
      setTimeout(() => {
        try {
          this.isGeneratingFigure = false
          
          // 跳转到图片展示页面
          router.pushUrl({
            url: 'pages/FigureResult',
            params: {
              imageUrls: imageUrls,
              styles: this.figureStyles,
              description: this.desc
            }
          })
        } catch (uiError) {
          console.error('UI更新失败:', uiError)
        }
      }, 0)
      
    } catch (error) {
      console.error('生成形象失败:', error);
      console.error('错误类型:', typeof error);
      console.error('错误详情:', JSON.stringify(error));
      
      // 使用setTimeout确保UI更新在正确的上下文中执行
      setTimeout(() => {
        try {
          this.isGeneratingFigure = false
          
          let errorMessage = '生成形象失败，请稍后重试';
          if (error instanceof Error) {
            errorMessage = error.message;
          }
          
          // 使用setTimeout确保toast在正确的上下文中显示
          setTimeout(() => {
            try {
              promptAction.showToast({ 
                message: errorMessage,
                duration: 3000
              })
            } catch (toastError) {
              console.error('Toast显示失败:', toastError)
            }
          }, 100)
        } catch (uiError) {
          console.error('UI错误处理失败:', uiError)
        }
      }, 0)
    }
  }

  /**
   * 处理图片点击事件，实现双击功能
   */
  private handleImageClick(figureImageUrl: string, figureType: string, index: number): void {
    const currentTime = Date.now()
    
    // 检查是否是双击（300ms内的两次点击）
    if (currentTime - this.lastClickTime < 300 && this.lastClickIndex === index) {
      // 双击事件 - 跳转到聊天页面
      this.startChatWithFigure(figureImageUrl, figureType)
      // 重置状态
      this.lastClickTime = 0
      this.lastClickIndex = -1
    } else {
      // 单击事件 - 选择图片
      this.selectedImageIndex = index
      this.lastClickTime = currentTime
      this.lastClickIndex = index
    }
  }

  /**
   * 开始与选定人物聊天
   */
  private startChatWithFigure(figureImageUrl: string, figureType: string): void {
    try {
      console.log('开始与人物聊天，图片URL:', figureImageUrl);
      console.log('人物类型:', figureType);
      
      // 跳转到聊天页面，传递人物信息
      router.pushUrl({
        url: 'pages/chat',
        params: {
          figureImageUrl: figureImageUrl,
          figureType: figureType,
          figureName: `${figureType}角色`,
          isFromCreateFigure: true
        }
      })
    } catch (error) {
      console.error('跳转到聊天页面失败:', error);
      promptAction.showToast({ 
        message: '跳转失败，请稍后重试',
        duration: 2000
      })
    }
  }
} 