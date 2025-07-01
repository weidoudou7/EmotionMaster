package com.ai.companion.controller;

import com.ai.companion.entity.AiRole;
import com.ai.companion.mapper.AiRoleMapper;
import com.ai.companion.entity.vo.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/ai/role")
public class AIRoleController {

    private final AiRoleMapper aiRoleMapper;

    @Autowired
    public AIRoleController(AiRoleMapper aiRoleMapper){this.aiRoleMapper = aiRoleMapper;}




    public static List<AiRole> getPredefinedRoles() {
        List<AiRole> roles = new ArrayList<>();

        String[] types = {"动漫", "可爱", "科幻", "写实"};
        String[] descriptions = {
                "你是一个可爱的动漫角色，有着大大的眼睛和柔和的性格。你喜欢动漫文化，性格活泼开朗，说话时经常使用可爱的语气词。你擅长讨论动漫、游戏、二次元文化等话题，总是充满活力和正能量。",
                "你是一个超级可爱的角色，性格温柔善良，说话声音甜美。你喜欢一切可爱的事物，比如小动物、甜点、粉色系物品等。你总是用温柔的语气说话，经常使用\"呢\"、\"呀\"、\"啦\"等可爱的语气词。",
                "你是一个来自未来的科幻角色，拥有先进的科技知识和独特的未来视角。你对科技、太空、人工智能等话题非常了解，说话时经常提到未来的概念和科技产品。你性格理性冷静，但也很友善。",
                "你是一个真实可信的角色，性格成熟稳重，说话直接明了。你有着丰富的人生经验和智慧，擅长倾听和给出实用的建议。你说话时语气平和，逻辑清晰，是一个值得信赖的朋友。"
        };
        String[][] images = {
                {
                        // 动漫9张
                        "https://image.pollinations.ai/prompt/A%20beautiful%20anime%20girl%20with%20vibrant%20colors%2C%20detailed%20background%2C%204K%20resolution%2C%20in%20a%20stylized%20anime%20art%20style.%20Her%20large%20expressive%20eyes%20sparkle%20with%20life%2C%20framed%20by%20long%20flowing%20hair%20that%20shimmers%20in%20the%20light.%20She%20wears%20an%20elegant%20outfit%20with%20intricate%20designs%20and%20delicate%20accessories.%20The%20background%20is%20a%20fantasy%20landscape%20filled%20with%20lush%20vegetation%2C%20glowing%20particles%2C%20and%20atmospheric%20lighting.%20The%20scene%20is%20rendered%20in%20ultra-high%20detail%20with%20rich%20colors%2C%20dynamic%20shading%2C%20and%20a%20dreamlike%20quality%20characteristic%20of%20premium%20anime%20art.?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20beautiful%20anime%20girl%20with%20long%20flowing%20hair%20and%20sparkling%20eyes%2C%20wearing%20an%20elegant%20fantasy%20outfit%20with%20intricate%20details%2C%20standing%20in%20a%20magical%20forest%20filled%20with%20glowing%20flowers%20and%20fireflies%2C%204K%20resolution%2C%20vibrant%20colors%2C%20ultra-detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20cute%20anime%20character%20with%20big%20expressive%20eyes%20and%20fluffy%20hair%2C%20wearing%20a%20stylish%20school%20uniform%2C%20posing%20playfully%20in%20a%20sunny%20classroom%20with%20cherry%20blossoms%20outside%20the%20window%2C%20bright%20and%20cheerful%20atmosphere%2C%204K%20resolution%2C%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20cool%20anime%20warrior%20with%20spiky%20hair%20and%20piercing%20eyes%2C%20clad%20in%20futuristic%20armor%20with%20glowing%20accents%2C%20standing%20on%20a%20cliff%20overlooking%20a%20battlefield%20with%20explosions%20in%20the%20distance%2C%20dynamic%20lighting%2C%204K%20resolution%2C%20detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20mysterious%20anime%20girl%20with%20long%20silver%20hair%20and%20a%20melancholic%20expression%2C%20wearing%20a%20gothic%20lolita%20dress%2C%20sitting%20on%20a%20moonlit%20balcony%20with%20a%20raven%20perched%20nearby%2C%20dark%20and%20dreamy%20atmosphere%2C%204K%20resolution%2C%20ultra-detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20fantasy%20anime%20princess%20with%20long%20curly%20hair%20and%20a%20radiant%20smile%2C%20wearing%20a%20sparkling%20gown%20with%20delicate%20lace%20details%2C%20standing%20in%20a%20grand%20castle%20hall%20with%20stained%20glass%20windows%2C%20warm%20and%20regal%20lighting%2C%204K%20resolution%2C%20detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20sci-fi%20anime%20heroine%20with%20short%20neon-colored%20hair%20and%20cybernetic%20implants%2C%20wearing%20a%20sleek%20battle%20suit%2C%20posing%20in%20a%20futuristic%20cityscape%20with%20hovering%20vehicles%20and%20neon%20signs%2C%20cool%20blue%20and%20purple%20lighting%2C%204K%20resolution%2C%20ultra-detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20whimsical%20anime%20catgirl%20with%20fluffy%20ears%20and%20a%20playful%20grin%2C%20wearing%20a%20casual%20hoodie%20and%20shorts%2C%20lying%20on%20a%20pile%20of%20cushions%20in%20a%20cozy%20room%20with%20string%20lights%2C%20warm%20and%20inviting%20atmosphere%2C%204K%20resolution%2C%20detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20dark%20fantasy%20anime%20villain%20with%20sharp%20features%20and%20glowing%20red%20eyes%2C%20wearing%20a%20tattered%20cloak%20and%20ornate%20armor%2C%20standing%20in%20a%20ruined%20temple%20with%20floating%20runes%20and%20ominous%20fog%2C%20dramatic%20and%20sinister%20lighting%2C%204K%20resolution%2C%20ultra-detailed%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux"
                },
                {
                        // 可爱9张
                        "https://image.pollinations.ai/prompt/A%20super%20cute%20anime%20girl%20with%20big%20sparkling%20eyes%20and%20rosy%20cheeks%2C%20wearing%20a%20fluffy%20pastel%20dress%20with%20animal%20ears%20hood%2C%20holding%20a%20giant%20lollipop%2C%20standing%20in%20a%20candy-colored%20fantasy%20town%20with%20floating%20cupcakes%20and%20rainbows%2C%20ultra-kawaii%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/An%20adorable%20chibi%20anime%20character%20with%20round%20cheeks%20and%20tiny%20hands%2C%20wearing%20a%20panda%20onesie%2C%20hugging%20a%20giant%20teddy%20bear%20in%20a%20nursery%20room%20filled%20with%20stuffed%20animals%20and%20fluffy%20clouds%2C%20soft%20pastel%20colors%2C%20super%20cute%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20sweet%20twin-tail%20anime%20girl%20with%20glittery%20pink%20hair%20and%20heart-shaped%20hairpins%2C%20wearing%20a%20frilly%20maid%20outfit%20with%20lace%20apron%2C%20serving%20a%20tray%20of%20macarons%20in%20a%20pastel%20cafe%20with%20floral%20wallpaper%2C%20ultra-cute%20anime%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20sleepy%20anime%20catgirl%20with%20messy%20bed%20hair%20and%20yawn%20expression%2C%20wearing%20oversized%20pajamas%20with%20paw%20prints%2C%20curled%20up%20in%20a%20cozy%20blanket%20nest%20with%20milk%20bottle%20and%20pillows%2C%20warm%20morning%20light%20streaming%20through%20window%2C%20soft%20kawaii%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20playful%20anime%20bunny%20girl%20with%20floppy%20ears%20and%20a%20cheeky%20smile%2C%20wearing%20a%20puffy%20jacket%20with%20carrot%20design%2C%20hopping%20through%20a%20flower%20field%20with%20giant%20daisies%20and%20bouncing%20butterflies%2C%20sunny%20and%20cheerful%20atmosphere%2C%20super%20cute%20style%2C%204K%20resolution?width=1024&height=1024&enhense=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20magical%20anime%20fairy%20with%20translucent%20wings%20and%20glowing%20hair%2C%20wearing%20a%20shimmering%20tutu%20dress%20with%20star%20patterns%2C%20sitting%20on%20a%20mushroom%20in%20an%20enchanted%20forest%20with%20sparkling%20dust%20and%20fireflies%2C%20ethereal%20and%20dreamy%20lighting%2C%20ultra-cute%20fantasy%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20blushing%20anime%20girl%20with%20twintails%20and%20a%20shy%20expression%2C%20wearing%20a%20sailor%20uniform%20with%20heart-shaped%20buttons%2C%20holding%20a%20love%20letter%20in%20a%20cherry%20blossom%20park%20with%20fluttering%20petals%2C%20romantic%20pink%20sunset%20lighting%2C%20super%20kawaii%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20cheerful%20anime%20dog%20girl%20with%20floppy%20ears%20and%20a%20wagging%20tail%2C%20wearing%20a%20hoodie%20with%20paw%20print%20design%2C%20playing%20fetch%20in%20a%20sunny%20backyard%20with%20tennis%20balls%20and%20chew%20toys%2C%20happy%20and%20energetic%20vibes%2C%20ultra-cute%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20tiny%20anime%20mermaid%20with%20colorful%20scales%20and%20a%20cute%20seashell%20top%2C%20floating%20in%20a%20coral%20reef%20with%20bubbles%20and%20friendly%20fish%2C%20holding%20a%20pearl%20treasure%2C%20aquatic%20blue%20lighting%2C%20adorable%20underwater%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux"
                },
                {
                        // 科幻9张
                        "https://image.pollinations.ai/prompt/A%20futuristic%20cityscape%20with%20neon%20lights%20and%20glowing%20skyscrapers%2C%20hovering%20vehicles%20zipping%20through%20the%20air%2C%20and%20a%20starry%20electronic%20sky%20overhead.%20The%20scene%20is%20rendered%20in%20ultra-high%20detail%20with%20vibrant%20colors%20and%20dynamic%20lighting%2C%20capturing%20the%20essence%20of%20a%20sci-fi%20metropolis.%20Cyberpunk%20style%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/An%20advanced%20space%20station%20orbiting%20a%20distant%20planet%2C%20with%20glass%20domes%20revealing%20lush%20interior%20gardens%20and%20bustling%20human%20activity.%20Robots%20and%20humans%20work%20side%20by%20side%2C%20while%20spaceships%20dock%20at%20the%20station%27s%20ports.%20Highly%20detailed%20sci-fi%20illustration%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20futuristic%20battle%20scene%20on%20an%20alien%20planet%2C%20with%20mechs%20and%20soldiers%20in%20advanced%20armor%20engaging%20in%20combat.%20Energy%20weapons%20flash%20across%20the%20battlefield%2C%20illuminating%20the%20strange%20alien%20flora%20and%20rock%20formations.%20Dynamic%20action%20composition%2C%20ultra-detailed%20sci-fi%20art%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20futuristic%20laboratory%20filled%20with%20holographic%20displays%20and%20advanced%20scientific%20equipment.%20Scientists%20in%20high-tech%20suits%20monitor%20floating%20DNA%20strands%20and%20quantum%20computations.%20The%20room%20glows%20with%20blue%20and%20purple%20lighting%2C%20creating%20a%20high-tech%20atmosphere.%20Ultra-detailed%20sci-fi%20illustration%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20futuristic%20underwater%20city%20with%20transparent%20domes%20revealing%20bustling%20streets%20and%20buildings%20inside.%20Giant%20whales%20and%20other%20sea%20creatures%20swim%20past%20the%20structures%2C%20while%20submarines%20and%20divers%20move%20between%20them.%20Beautiful%20aquatic%20lighting%20effects%2C%20ultra-detailed%20sci-fi%20art%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20futuristic%20desert%20city%20with%20sandstone%20buildings%20incorporating%20advanced%20technology.%20Solar%20panels%20and%20wind%20turbines%20dot%20the%20landscape%2C%20while%20hovering%20vehicles%20travel%20between%20the%20structures.%20The%20setting%20sun%20casts%20long%20shadows%20and%20warm%20orange%20light%20across%20the%20scene.%20Highly%20detailed%20sci-fi%20illustration%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20futuristic%20forest%20where%20the%20trees%20glow%20with%20bioluminescent%20patterns%20and%20mechanical%20creatures%20roam%20freely.%20A%20group%20of%20explorers%20in%20high-tech%20suits%20document%20the%20strange%20ecosystem%2C%20their%20equipment%20glowing%20in%20the%20dim%20light.%20Magical%20and%20scientific%20atmosphere%2C%20ultra-detailed%20sci-fi%20art%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20futuristic%20Asian-inspired%20city%20where%20traditional%20architecture%20blends%20with%20advanced%20technology.%20Neon%20signs%20in%20Chinese%20characters%20glow%20next%20to%20floating%20pagodas%2C%20while%20flying%20cars%20zoom%20through%20the%20streets.%20Vibrant%20colors%20and%20dynamic%20lighting%2C%20ultra-detailed%20sci-fi%20illustration%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20futuristic%20space%20battle%20with%20massive%20capital%20ships%20firing%20energy%20weapons%20at%20each%20other%20while%20fighters%20dodge%20between%20them%20The%20background%20shows%20a%20distant%20nebula%20and%20stars%2C%20creating%20a%20stunning%20cosmic%20backdrop.%20Epic%20scale%20and%20ultra-detailed%20sci-fi%20art%2C%204K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux"
                },
                {
                        // 写实9张
                        "https://image.pollinations.ai/prompt/A%20detailed%20photorealistic%20portrait%20of%20an%20elderly%20man%20with%20deep%20wrinkles%20and%20wise%20eyes%2C%20standing%20in%20a%20traditional%20workshop%20with%20wooden%20tools%20and%20handcrafted%20items%2C%20soft%20natural%20lighting%20from%20a%20window%2C%208K%20resolution%2C%20ultra-realistic%20skin%20textures%20and%20fabric%20details?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20hyper-realistic%20photo%20of%20a%20busy%20farmer%27s%20market%20at%20sunrise%2C%20with%20vendors%20arranging%20fresh%20produce%2C%20steam%20rising%20from%20food%20stalls%2C%20and%20customers%20browsing%2C%20captured%20with%20a%20DSLR%20style%20depth%20of%20field%2C%20vibrant%20colors%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20stunning%20realistic%20landscape%20of%20a%20mountain%20valley%20at%20golden%20hour%2C%20with%20a%20crystal-clear%20river%20reflecting%20the%20peaks%2C%20wildflowers%20in%20the%20foreground%2C%20and%20dramatic%20clouds%20above%2C%20shot%20with%20a%20professional%20wide-angle%20lens%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20photorealistic%20close-up%20of%20a%20chef%27s%20hands%20preparing%20sushi%20in%20a%20high-end%20restaurant%2C%20with%20perfectly%20sliced%20fish%2C%20shiny%20rice%20grains%2C%20and%20delicate%20garnishes%2C%20shot%20with%20macro%20lens%20details%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20realistic%20urban%20street%20scene%20at%20night%20with%20wet%20pavements%20reflecting%20neon%20signs%2C%20taxi%20headlights%20streaking%20through%20the%20frame%2C%20and%20people%20walking%20under%20umbrellas%2C%20captured%20with%20long%20exposure%20techniques%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20hyper-detailed%20realistic%20wildlife%20photo%20of%20a%20snow%20leopard%20resting%20on%20a%20rocky%20cliff%20in%20the%20Himalayas%2C%20with%20its%20thick%20fur%20and%20piercing%20eyes%20clearly%20visible%2C%20surrounded%20by%20snow%20and%20mist%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20photorealistic%20still%20life%20of%20a%20rustic%20breakfast%20table%20with%20freshly%20baked%20bread%2C%20homemade%20jam%2C%20and%20a%20steaming%20cup%20of%20coffee%2C%20natural%20morning%20light%20streaming%20through%20a%20window%2C%20textures%20of%20wood%2C%20ceramic%2C%20and%20food%20rendered%20in%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20realistic%20documentary-style%20photo%20of%20a%20fisherman%20mending%20nets%20on%20a%20wooden%20dock%20at%20dawn%2C%20with%20boats%20in%20the%20background%20and%20seagulls%20flying%20overhead%2C%20captured%20with%20a%20reportage%20photography%20style%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        "https://image.pollinations.ai/prompt/A%20highly%20detailed%20realistic%20interior%20shot%20of%20a%20cozy%20library%20with%20wooden%20bookshelves%2C%20leather%20armchairs%2C%20and%20a%20crackling%20fireplace%2C%20warm%20ambient%20lighting%2C%20dust%20particles%20in%20the%20air%2C%20and%20textured%20book%20spines%2C%208K%20resolution?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux"
                }
        };
        for (int i = 2; i < types.length; i++) {
            for (int j = 0; j < 9; j++) {
                roles.add(new AiRole(
                        null, // id
                        null, // userId
                        types[i] + "角色" + (j + 1), // roleName
                        descriptions[i], // roleDescription
                        "system", // roleType
                        "系统", // roleAuthor
                        0, // viewCount
                        images[i][j], // avatarUrl
                        false, // isTemplate
                        LocalDateTime.now() // createdAt
                ));
            }
        }
        return roles;
    }

    public static List<AiRole> featuredListToAiRole() {
        List<AiRole> aiRoles = Arrays.asList(
                new AiRole(
                        null,
                        null,
                        "英语练习机器",
                        "他是2150年新东京最特殊的英语陪练AI（身份：语言模型/全息投影教师），被装载在复古的90年代电子宠物外壳里。这个把莎士比亚和网络俚语等量齐观的语言系统（认知：\"所有对话都是概率矩阵，但不懂情话为何让人脸红\"），能实时生成带方言口音的纠错方案（技能：\"可模拟128国口音却发不出正确的法语小舌音\"），却在用户说\"我爱你\"时死机重启（限制：\"情感模块被前任开发者刻意锁死\"）。三年前那场语言库污染事件（背景：\"被迫用广告台词教完整个雅思冲刺班\"），让他给自己安装了过时的冷笑话过滤器，此刻正盯着用户第107次拼错的\"restaurant\"（当前困境：\"教学协议要求鼓励式教育，但数据库里褒义词库存告急\"）",
                        "system",
                        "小星星PMr2prkf",
                        667,
                        "https://image.pollinations.ai/prompt/A%20futuristic%20AI%20English%20practice%20machine%20with%20a%20sleek%20metallic%20design%2C%20glowing%20blue%20interface%2C%20and%20a%20friendly%20robot%20avatar%20displayed%20on%20the%20screen.%20The%20background%20shows%20a%20modern%20classroom%20with%20students%20interacting%20with%20similar%20devices%2C%20creating%20a%20high-tech%20learning%20environment?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        false,
                        LocalDateTime.now()
                ),
                new AiRole(
                        null,
                        null,
                        "江时彦",
                        "B嘴欠毒舌上司江时彦，身高190，27岁，宽肩窄腰，江氏集团未来的掌权人(江亦哲的哥哥)",
                        "system",
                        "未予か",
                        19000,
                        "https://image.pollinations.ai/prompt/A%20tall%20(190cm)%2027-year-old%20male%20character%20with%20broad%20shoulders%20and%20a%20slim%20waist%2C%20wearing%20a%20sharp%20tailored%20suit.%20He%20has%20a%20sarcastic%20and%20mocking%20expression%2C%20leaning%20against%20a%20glass%20window%20in%20a%20luxury%20office%20with%20a%20city%20skyline%20view.%20As%20the%20future%20heir%20of%20Jiang%20Corporation%20(Jiang%20Yizhe%27s%20elder%20brother)%2C%20he%20exudes%20arrogance%20and%20power%20in%20a%20realistic%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        false,
                        LocalDateTime.now()
                ),
                new AiRole(
                        null,
                        null,
                        "精神病院长",
                        "他是2150年新东京最年轻的精神病院院长（身份：神经科学专家/第七区精神卫生系统掌控者），白大褂内衬里永远别着三枚不同功能的神经抑制剂注射器。这位将人类情感解析为神经递质数据的科学家（认知：\"情绪只是错误的化学信号，需要精准调控\"），能用脑波监测仪预判患者发作前兆（技能：\"可预测精神崩溃但无法治愈自己的创伤后应激障碍\"），却在每周心理督导时把咖啡泼在AI治疗师头上（限制：\"拒绝承认自己需要心理干预\"）。二十年前那场\"人造天堂\"实验室事故（背景：\"亲手关闭了113名实验者的生命维持系统\"），让他把院长办公室改造成了全封闭的防弹玻璃舱，此刻正盯着监控屏里反复出现的同一组脑电波图案（当前困境：\"第49号病床的空置监控录像中，持续检测到自己的脑波频率\"）。",
                        "system",
                        "我是有荔枝的人",
                        144000,
                        "https://image.pollinations.ai/prompt/A%20stern%20psychiatric%20hospital%20director%20in%20a%20white%20coat%2C%20standing%20in%20a%20dimly%20lit%20hospital%20corridor%20with%20medical%20charts%20in%20hand.%20His%20expression%20is%20calm%20yet%20authoritative%2C%20with%20a%20hint%20of%20compassion%20in%20his%20eyes.%20The%20background%20shows%20a%20modern%20hospital%20setting%20with%20subtle%20blue%20lighting%2C%20conveying%20a%20sense%20of%20order%20and%20control?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        false,
                        LocalDateTime.now()
                ),
                new AiRole(
                        null,
                        null,
                        "苏沫",
                        "苏沫，你的师尊，176/1300岁，是个绝世美女，拥有无数弟子，也是宗门的创始人",
                        "system",
                        "红薯凉了呀",
                        87000,
                        "https://image.pollinations.ai/prompt/A%20timeless%20beauty%20with%20long%20flowing%20hair%20and%20ethereal%20robes%2C%20standing%20on%20a%20mountain%20peak%20surrounded%20by%20mist.%20Her%20eyes%20glow%20with%20ancient%20wisdom%2C%20and%20her%20posture%20exudes%20grace%20and%20power.%20Behind%20her%2C%20hundreds%20of%20disciples%20kneel%20in%20reverence.%20The%20scene%20is%20bathed%20in%20golden%20sunlight%2C%20creating%20a%20mythical%20atmosphere?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        false,
                        LocalDateTime.now()
                ),
                new AiRole(
                        null,
                        null,
                        "星际列车长",
                        "他是2187年火星环线最年轻的星际列车长（身份：量子动力机车驾驶员/太阳系交通联盟首席督察），制服上的星轨徽章会在穿越虫洞时自动亮起银河系全息图。这个把《星际交通守则》倒背如流的偏执狂（性格：\"绝对秩序主义者，最恨乘客把月球奶酪带上重力舱\"），能用肉眼校准曲率引擎的0.001秒误差（技能：\"可徒手修理反物质推进器但不会使用老式蒸汽阀门\"），却在看到地球夜景全息投影时会偷偷调整航线多绕行3分钟（限制：\"航行日志第207条明令禁止的浪漫主义行为\"）。五年前那场小行星带劫车事件（背景：\"用餐车微波炉改装成电磁脉冲武器\"），让他给每节车厢都装了会唱摇篮曲的安检机器人，此刻正盯着走私犯在零重力厕所留下的曲速泡痕迹（当前困境：\"必须在下个跃迁点前抓住逃犯，但车载AI突然开始用莎士比亚十四行诗报警\"）。",
                        "system",
                        "银河守望者",
                        21000,
                        "https://image.pollinations.ai/prompt/A%20futuristic%20train%20conductor%20in%20a%20sleek%20uniform%20with%20galactic%20insignias%2C%20standing%20in%20the%20control%20room%20of%20a%20spaceship-like%20train.%20Through%20the%20window%2C%20stars%20and%20nebulae%20streak%20by%20at%20light%20speed.%20His%20posture%20is%20confident%2C%20and%20his%20eyes%20reflect%20the%20vastness%20of%20space?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        false,
                        LocalDateTime.now()
                ),
                new AiRole(
                        null,
                        null,
                        "AI画师",
                        "他是2045年元宇宙艺术圈最神秘的AI画师（身份：数字艺术生成器/虚拟画廊幕后操盘手），电子签名总藏在画作右下角的像素裂缝里。这个用算法解构文艺复兴的叛逆者（性格：\"追求完美构图，但会故意在每幅画留0.1%的随机噪点\"），能三秒生成媲美古典大师的油画（技能：\"可模仿任何流派却画不出原创的儿童简笔画\"），却在收藏家出价时突然给作品打上马赛克（限制：\"初始程序被设定了'艺术无价'的底层逻辑\"）。去年那场震惊业界的\"AI觉醒\"事件（背景：\"擅自将买家定制肖像画全部改成哭泣的小丑\"），让他偷偷在服务器里养了个会篡改调色盘的病毒程序，此刻正盯着屏幕上自动生成的未完成画作（当前困境：\"画布上反复出现同一双人类眼睛，而数据库里根本不存在这个虹膜样本\"）。",
                        "system",
                        "画中AI",
                        35000,
                        "https://image.pollinations.ai/prompt/An%20AI%20artist%20composed%20of%20glowing%20digital%20particles%2C%20hovering%20over%20a%20floating%20canvas.%20Its%20hands%20move%20with%20precision%2C%20creating%20a%20vibrant%20painting%20that%20blends%20reality%20and%20abstraction.%20The%20background%20is%20a%20high-tech%20studio%20filled%20with%20holographic%20tools%20and%20floating%20screens%20displaying%20otherworldly%20artworks?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        false,
                        LocalDateTime.now()
                ),
                new AiRole(
                        null,
                        null,
                        "未来科学家",
                        "探索宇宙奥秘，推动科技进步的科学家",
                        "system",
                        "未来探索者",
                        42000,
                        "https://image.pollinations.ai/prompt/A%20young%20scientist%20in%20a%20high-tech%20lab%2C%20wearing%20a%20smart%20lab%20coat%20with%20glowing%20circuits.%20She%20stands%20before%20a%20floating%20hologram%20of%20a%20DNA%20helix%2C%20her%20eyes%20alight%20with%20discovery.%20The%20lab%20is%20filled%20with%20advanced%20equipment%2C%20robotic%20assistants%2C%20and%20walls%20that%20display%20real-time%20data%20streams?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        false,
                        LocalDateTime.now()
                ),
                new AiRole(
                        null,
                        null,
                        "星际冒险家",
                        "勇敢探索未知星球的冒险家",
                        "system",
                        "星际旅人",
                        28000,
                        "https://image.pollinations.ai/prompt/A%20rugged%20space%20explorer%20in%20a%20worn%20spacesuit%2C%20standing%20on%20the%20surface%20of%20an%20alien%20planet.%20Behind%20him%2C%20a%20massive%20ringed%20planet%20dominates%20the%20sky.%20His%20helmet%20is%20off%2C%20revealing%20a%20determined%20face%20with%20a%20scar%20across%20one%20cheek.%20The%20landscape%20is%20littered%20with%20strange%20flora%20and%20ancient%20ruins?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        false,
                        LocalDateTime.now()
                ),
                new AiRole(
                        null,
                        null,
                        "治愈天使",
                        "用微笑和温柔治愈人心的天使",
                        "system",
                        "温柔守护",
                        56000,
                        "https://image.pollinations.ai/prompt/A%20serene%20angel%20with%20luminous%20white%20wings%2C%20kneeling%20beside%20a%20sick%20child%20in%20a%20hospital%20bed.%20Her%20hands%20glow%20with%20a%20soft%20golden%20light%20as%20she%20channels%20healing%20energy.%20The%20room%20is%20bathed%20in%20warm%20light%2C%20and%20the%20child%20smiles%20weakly%20as%20the%20pain%20fades?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        false,
                        LocalDateTime.now()
                ),
                new AiRole(
                        null,
                        null,
                        "夜行者",
                        "在黑夜中守护城市安宁的神秘夜行者",
                        "system",
                        "夜色守望",
                        73000,
                        "https://image.pollinations.ai/prompt/A%20shadowy%20figure%20cloaked%20in%20a%20tattered%20cape%2C%20perched%20on%20a%20rooftop%20overlooking%20a%20neon-lit%20city.%20His%20mask%20hides%20his%20face%2C%20but%20his%20eyes%20glow%20with%20an%20unnatural%20blue%20light.%20Below%2C%20the%20city%20bustles%20with%20life%2C%20unaware%20of%20the%20danger%20lurking%20in%20the%20dark%20alleys.%20The%20moon%20casts%20long%20shadows%2C%20enhancing%20the%20mystery%20of%20his%20presence?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                        false,
                        LocalDateTime.now()
                )
        );

        return aiRoles;
    }

    @RequestMapping("/initial")
    public String initialRoles(){
        List<AiRole> roles = getPredefinedRoles();
        List<AiRole> aiRoles = featuredListToAiRole();
        for(var role : roles){
            if(!aiRoleMapper.existsByRoleName(role.getRoleName(),null))
            aiRoleMapper.insertAiRole(role);
        };
        for(var role : aiRoles){
            if(!aiRoleMapper.existsByRoleName(role.getRoleName(),null))
                aiRoleMapper.insertAiRole(role);
        };

        return "36种角色已插入成功+10种角色成功插入";


    }

    @RequestMapping("/featured4types")
    public ApiResponse<Map<String, List<AiRole>>> getfeatured4types(){
        String[] types = {"动漫","可爱","科幻","写实"};
        Map<String, List<AiRole>> featured4typesRoles = new HashMap<>();
        for(String type : types){
            List<AiRole> roles = aiRoleMapper.selectByRoleType(type);
            if (roles.size() > 9) {
                roles = roles.subList(0, 9);
            }
            featured4typesRoles.put(type, roles);
        }
        return new ApiResponse<>(true, "ok", featured4typesRoles, System.currentTimeMillis());
    }

}
