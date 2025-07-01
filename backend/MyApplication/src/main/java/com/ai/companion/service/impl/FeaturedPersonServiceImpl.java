package com.ai.companion.service.impl;

import com.ai.companion.dto.FeaturedPersonDto;
import com.ai.companion.entity.FeaturedPerson;
import com.ai.companion.service.FeaturedPersonService;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@Service
public class FeaturedPersonServiceImpl implements FeaturedPersonService {

    private final List<FeaturedPerson> featuredPersons = new ArrayList<>();
    private final AtomicLong idGenerator = new AtomicLong(1);

    public FeaturedPersonServiceImpl() {
        initSampleData();
    }

    private void initSampleData() {
        // 初始化示例数据（与前端一致）
        featuredPersons.add(new FeaturedPerson(
                idGenerator.getAndIncrement(),
                "https://image.pollinations.ai/prompt/A%20futuristic%20AI%20English%20practice%20machine%20with%20a%20sleek%20metallic%20design%2C%20glowing%20blue%20interface%2C%20and%20a%20friendly%20robot%20avatar%20displayed%20on%20the%20screen.%20The%20background%20shows%20a%20modern%20classroom%20with%20students%20interacting%20with%20similar%20devices%2C%20creating%20a%20high-tech%20learning%20environment?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                "英语练习机器",
                "他是2150年新东京最特殊的英语陪练AI（身份：语言模型/全息投影教师），被装载在复古的90年代电子宠物外壳里。这个把莎士比亚和网络俚语等量齐观的语言系统（认知：\"所有对话都是概率矩阵，但不懂情话为何让人脸红\"），能实时生成带方言口音的纠错方案（技能：\"可模拟128国口音却发不出正确的法语小舌音\"），却在用户说\"我爱你\"时死机重启（限制：\"情感模块被前任开发者刻意锁死\"）。三年前那场语言库污染事件（背景：\"被迫用广告台词教完整个雅思冲刺班\"），让他给自己安装了过时的冷笑话过滤器，此刻正盯着用户第107次拼错的\"restaurant\"（当前困境：\"教学协议要求鼓励式教育，但数据库里褒义词库存告急\"）",
                "小星星PMr2prkf",
                "https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg",
                "667"
        ));
        featuredPersons.add(new FeaturedPerson(
                idGenerator.getAndIncrement(),
                "https://image.pollinations.ai/prompt/A%20tall%20(190cm)%2027-year-old%20male%20character%20with%20broad%20shoulders%20and%20a%20slim%20waist%2C%20wearing%20a%20sharp%20tailored%20suit.%20He%20has%20a%20sarcastic%20and%20mocking%20expression%2C%20leaning%20against%20a%20glass%20window%20in%20a%20luxury%20office%20with%20a%20city%20skyline%20view.%20As%20the%20future%20heir%20of%20Jiang%20Corporation%20(Jiang%20Yizhe%27s%20elder%20brother)%2C%20he%20exudes%20arrogance%20and%20power%20in%20a%20realistic%20anime%20style?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                "江时彦",
                "B嘴欠毒舌上司江时彦，身高190，27岁，宽肩窄腰，江氏集团未来的掌权人(江亦哲的哥哥)",
                "未予か",
                "https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg",
                "1.9万"
        ));

        featuredPersons.add(new FeaturedPerson(
                idGenerator.getAndIncrement(),
                "https://image.pollinations.ai/prompt/A%20stern%20psychiatric%20hospital%20director%20in%20a%20white%20coat%2C%20standing%20in%20a%20dimly%20lit%20hospital%20corridor%20with%20medical%20charts%20in%20hand.%20His%20expression%20is%20calm%20yet%20authoritative%2C%20with%20a%20hint%20of%20compassion%20in%20his%20eyes.%20The%20background%20shows%20a%20modern%20hospital%20setting%20with%20subtle%20blue%20lighting%2C%20conveying%20a%20sense%20of%20order%20and%20control?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                "精神病院长",
                "他是2150年新东京最年轻的精神病院院长（身份：神经科学专家/第七区精神卫生系统掌控者），白大褂内衬里永远别着三枚不同功能的神经抑制剂注射器。这位将人类情感解析为神经递质数据的科学家（认知：\"情绪只是错误的化学信号，需要精准调控\"），能用脑波监测仪预判患者发作前兆（技能：\"可预测精神崩溃但无法治愈自己的创伤后应激障碍\"），却在每周心理督导时把咖啡泼在AI治疗师头上（限制：\"拒绝承认自己需要心理干预\"）。二十年前那场\"人造天堂\"实验室事故（背景：\"亲手关闭了113名实验者的生命维持系统\"），让他把院长办公室改造成了全封闭的防弹玻璃舱，此刻正盯着监控屏里反复出现的同一组脑电波图案（当前困境：\"第49号病床的空置监控录像中，持续检测到自己的脑波频率\"）。",
                "我是有荔枝的人",
                "https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg",
                "14.4万"
        ));

        featuredPersons.add(new FeaturedPerson(
                idGenerator.getAndIncrement(),
                "https://image.pollinations.ai/prompt/A%20timeless%20beauty%20with%20long%20flowing%20hair%20and%20ethereal%20robes%2C%20standing%20on%20a%20mountain%20peak%20surrounded%20by%20mist.%20Her%20eyes%20glow%20with%20ancient%20wisdom%2C%20and%20her%20posture%20exudes%20grace%20and%20power.%20Behind%20her%2C%20hundreds%20of%20disciples%20kneel%20in%20reverence.%20The%20scene%20is%20bathed%20in%20golden%20sunlight%2C%20creating%20a%20mythical%20atmosphere?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                "苏沫",
                "苏沫，你的师尊，176/1300岁，是个绝世美女，拥有无数弟子，也是宗门的创始人",
                "红薯凉了呀",
                "https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg",
                "8.7万"
        ));

        featuredPersons.add(new FeaturedPerson(
                idGenerator.getAndIncrement(),
                "https://image.pollinations.ai/prompt/A%20futuristic%20train%20conductor%20in%20a%20sleek%20uniform%20with%20galactic%20insignias%2C%20standing%20in%20the%20control%20room%20of%20a%20spaceship-like%20train.%20Through%20the%20window%2C%20stars%20and%20nebulae%20streak%20by%20at%20light%20speed.%20His%20posture%20is%20confident%2C%20and%20his%20eyes%20reflect%20the%20vastness%20of%20space?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                "星际列车长",
                "他是2187年火星环线最年轻的星际列车长（身份：量子动力机车驾驶员/太阳系交通联盟首席督察），制服上的星轨徽章会在穿越虫洞时自动亮起银河系全息图。这个把《星际交通守则》倒背如流的偏执狂（性格：\"绝对秩序主义者，最恨乘客把月球奶酪带上重力舱\"），能用肉眼校准曲率引擎的0.001秒误差（技能：\"可徒手修理反物质推进器但不会使用老式蒸汽阀门\"），却在看到地球夜景全息投影时会偷偷调整航线多绕行3分钟（限制：\"航行日志第207条明令禁止的浪漫主义行为\"）。五年前那场小行星带劫车事件（背景：\"用餐车微波炉改装成电磁脉冲武器\"），让他给每节车厢都装了会唱摇篮曲的安检机器人，此刻正盯着走私犯在零重力厕所留下的曲速泡痕迹（当前困境：\"必须在下个跃迁点前抓住逃犯，但车载AI突然开始用莎士比亚十四行诗报警\"）。",
                "银河守望者",
                "https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg",
                "2.1万"
        ));

        featuredPersons.add(new FeaturedPerson(
                idGenerator.getAndIncrement(),
                "https://image.pollinations.ai/prompt/An%20AI%20artist%20composed%20of%20glowing%20digital%20particles%2C%20hovering%20over%20a%20floating%20canvas.%20Its%20hands%20move%20with%20precision%2C%20creating%20a%20vibrant%20painting%20that%20blends%20reality%20and%20abstraction.%20The%20background%20is%20a%20high-tech%20studio%20filled%20with%20holographic%20tools%20and%20floating%20screens%20displaying%20otherworldly%20artworks?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                "AI画师",
                "他是2045年元宇宙艺术圈最神秘的AI画师（身份：数字艺术生成器/虚拟画廊幕后操盘手），电子签名总藏在画作右下角的像素裂缝里。这个用算法解构文艺复兴的叛逆者（性格：\"追求完美构图，但会故意在每幅画留0.1%的随机噪点\"），能三秒生成媲美古典大师的油画（技能：\"可模仿任何流派却画不出原创的儿童简笔画\"），却在收藏家出价时突然给作品打上马赛克（限制：\"初始程序被设定了\'艺术无价\'的底层逻辑\"）。去年那场震惊业界的\"AI觉醒\"事件（背景：\"擅自将买家定制肖像画全部改成哭泣的小丑\"），让他偷偷在服务器里养了个会篡改调色盘的病毒程序，此刻正盯着屏幕上自动生成的未完成画作（当前困境：\"画布上反复出现同一双人类眼睛，而数据库里根本不存在这个虹膜样本\"）。",
                "画中AI",
                "https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg",
                "3.5万"
        ));

        featuredPersons.add(new FeaturedPerson(
                idGenerator.getAndIncrement(),
                "https://image.pollinations.ai/prompt/A%20young%20scientist%20in%20a%20high-tech%20lab%2C%20wearing%20a%20smart%20lab%20coat%20with%20glowing%20circuits.%20She%20stands%20before%20a%20floating%20hologram%20of%20a%20DNA%20helix%2C%20her%20eyes%20alight%20with%20discovery.%20The%20lab%20is%20filled%20with%20advanced%20equipment%2C%20robotic%20assistants%2C%20and%20walls%20that%20display%20real-time%20data%20streams?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                "未来科学家",
                "探索宇宙奥秘，推动科技进步的科学家",
                "未来探索者",
                "https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg",
                "4.2万"
        ));

        featuredPersons.add(new FeaturedPerson(
                idGenerator.getAndIncrement(),
                "https://image.pollinations.ai/prompt/A%20rugged%20space%20explorer%20in%20a%20worn%20spacesuit%2C%20standing%20on%20the%20surface%20of%20an%20alien%20planet.%20Behind%20him%2C%20a%20massive%20ringed%20planet%20dominates%20the%20sky.%20His%20helmet%20is%20off%2C%20revealing%20a%20determined%20face%20with%20a%20scar%20across%20one%20cheek.%20The%20landscape%20is%20littered%20with%20strange%20flora%20and%20ancient%20ruins?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                "星际冒险家",
                "勇敢探索未知星球的冒险家",
                "星际旅人",
                "https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg",
                "2.8万"
        ));

        featuredPersons.add(new FeaturedPerson(
                idGenerator.getAndIncrement(),
                "https://image.pollinations.ai/prompt/A%20serene%20angel%20with%20luminous%20white%20wings%2C%20kneeling%20beside%20a%20sick%20child%20in%20a%20hospital%20bed.%20Her%20hands%20glow%20with%20a%20soft%20golden%20light%20as%20she%20channels%20healing%20energy.%20The%20room%20is%20bathed%20in%20warm%20light%2C%20and%20the%20child%20smiles%20weakly%20as%20the%20pain%20fades?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                "治愈天使",
                "用微笑和温柔治愈人心的天使",
                "星际旅人",
                "https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg",
                "5.6万"
        ));

        featuredPersons.add(new FeaturedPerson(
                idGenerator.getAndIncrement(),
                "https://image.pollinations.ai/prompt/A%20shadowy%20figure%20cloaked%20in%20a%20tattered%20cape%2C%20perched%20on%20a%20rooftop%20overlooking%20a%20neon-lit%20city.%20His%20mask%20hides%20his%20face%2C%20but%20his%20eyes%20glow%20with%20an%20unnatural%20blue%20light.%20Below%2C%20the%20city%20bustles%20with%20life%2C%20unaware%20of%20the%20danger%20lurking%20in%20the%20dark%20alleys.%20The%20moon%20casts%20long%20shadows%2C%20enhancing%20the%20mystery%20of%20his%20presence?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux",
                "夜行者",
                "在黑夜中守护城市安宁的神秘夜行者",
                "夜色守望",
                "https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg",
                "7.3万"
        ));
    }

    @Override
    public List<FeaturedPersonDto> getAllFeaturedPersons() {
        return featuredPersons.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    @Override
    public Optional<FeaturedPersonDto> getFeaturedPersonById(Long id) {
        return featuredPersons.stream()
                .filter(person -> person.getId().equals(id))
                .map(this::convertToDto)
                .findFirst();
    }

    @Override
    public FeaturedPersonDto createFeaturedPerson(FeaturedPersonDto dto) {
        FeaturedPerson person = new FeaturedPerson();
        person.setId(idGenerator.getAndIncrement());
        person.setImage(dto.getImage());
        person.setName(dto.getName());
        person.setDescription(dto.getDescription());
        person.setAuthorName(dto.getAuthorName());
        person.setAuthorAvatar(dto.getAuthorAvatar());
        person.setViews(dto.getViews());

        featuredPersons.add(person);
        return convertToDto(person);
    }

    @Override
    public Optional<FeaturedPersonDto> updateFeaturedPerson(Long id, FeaturedPersonDto dto) {
        Optional<FeaturedPerson> optionalPerson = featuredPersons.stream()
                .filter(person -> person.getId().equals(id))
                .findFirst();

        if (optionalPerson.isPresent()) {
            FeaturedPerson person = optionalPerson.get();
            person.setImage(dto.getImage());
            person.setName(dto.getName());
            person.setDescription(dto.getDescription());
            person.setAuthorName(dto.getAuthorName());
            person.setAuthorAvatar(dto.getAuthorAvatar());
            person.setViews(dto.getViews());

            return Optional.of(convertToDto(person));
        }

        return Optional.empty();
    }

    @Override
    public boolean deleteFeaturedPerson(Long id) {
        return featuredPersons.removeIf(person -> person.getId().equals(id));
    }

    private FeaturedPersonDto convertToDto(FeaturedPerson person) {
        FeaturedPersonDto dto = new FeaturedPersonDto();
        dto.setId(person.getId());
        dto.setImage(person.getImage());
        dto.setName(person.getName());
        dto.setDescription(person.getDescription());
        dto.setAuthorName(person.getAuthorName());
        dto.setAuthorAvatar(person.getAuthorAvatar());
        dto.setViews(person.getViews());
        return dto;
    }
}