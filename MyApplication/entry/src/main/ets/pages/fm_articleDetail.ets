import router from '@ohos.router';

interface ArticleParams {
  articleId : string;
  articleTitle : string;
  articleType : string;
}

interface ArticleContent {
  id: string;
  title: string;
  author: string;
  publishTime: string;
  readTime: string;
  content: string;
}

// Markdown解析后的内容块
interface MarkdownBlock {
  type: 'text' | 'heading' | 'list' | 'code' | 'quote' | 'divider';
  content: string;
  level?: number; // 用于标题级别
  items?: string[]; // 用于列表项
}

interface InlineMarkdownSegment {
  type: 'normal' | 'bold' | 'italic' | 'bolditalic' | 'code';
  text: string;
}

@Entry
@Component
struct ArticleDetail {
  @State articleId: string = '1';
  @State articleTitle: string = '文章标题';
  @State articleType: string = 'deep';
  @State loading: boolean = true;
  @State articleContent: string = '等待生成中...';
  @State parsedBlocks: MarkdownBlock[] = [];

  // 文章内容数据
  private depthArticles: ArticleContent[] = [
    {
      id: '1',
      title: '心理健康在现代社会的重要性',
      author: '心理学专家',
      publishTime: '2024-01-15',
      readTime: '8分钟',
      content: '在现代快节奏的生活中，心理健康问题日益突出。本文将从多个角度分析现代人面临的心理挑战，并提供实用的应对策略。\n\n随着社会的发展，人们面临着前所未有的压力。工作压力、生活压力、人际关系压力等各种压力源不断涌现，给人们的心理健康带来了严峻的挑战。\n\n研究表明，长期的心理压力会导致各种身心疾病，包括焦虑症、抑郁症、失眠等。因此，学会管理压力、维护心理健康变得尤为重要。\n\n本文将为您详细介绍：\n1. 现代人面临的主要心理挑战\n2. 压力对身心健康的影响\n3. 有效的压力管理策略\n4. 建立健康心理状态的方法\n\n通过阅读本文，您将获得实用的心理健康知识，学会更好地照顾自己的心理状态。',
    },
    {
      id: '2',
      title: '正念冥想的科学依据与实践方法',
      author: '神经科学研究员',
      publishTime: '2024-01-14',
      readTime: '12分钟',
      content: '正念冥想作为一种古老的心理练习方法，在现代神经科学研究中得到了越来越多的验证。本文将详细介绍其科学依据和实践方法。\n\n正念冥想起源于佛教传统，但在现代心理学和神经科学中得到了广泛的应用和研究。研究表明，正念冥想能够显著改善人们的心理健康状况。\n\n神经科学研究发现，正念冥想能够改变大脑的结构和功能，特别是前额叶皮层和杏仁核的活动模式。这些变化与情绪调节、注意力集中和压力应对能力的提升密切相关。\n\n正念冥想的核心要素包括：\n1. 专注当下：将注意力集中在当前的体验上\n2. 非评判性观察：以开放和接纳的态度观察自己的感受\n3. 呼吸觉察：通过关注呼吸来锚定注意力\n4. 身体扫描：系统地觉察身体各部位的感觉\n\n实践正念冥想的方法：\n1. 找一个安静的环境，采取舒适的坐姿\n2. 闭上眼睛，专注于呼吸\n3. 当注意力分散时，温和地将其带回呼吸\n4. 每天练习10-20分钟，逐渐增加时间\n\n通过持续的正念练习，您将能够更好地管理压力，提升情绪稳定性，增强自我觉察能力。',
    },
    {
      id: '3',
      title: '情绪管理的艺术：从认知到行动',
      author: '情绪管理专家',
      publishTime: '2024-01-13',
      readTime: '10分钟',
      content: '情绪管理是每个人都需要掌握的重要技能。本文将从认知行为的角度，介绍如何更好地理解和控制自己的情绪。\n\n情绪是人类体验的重要组成部分，它们为我们提供了重要的信息和指导。然而，当情绪变得过于强烈或持续时间过长时，可能会影响我们的生活质量和工作效率。\n\n认知行为理论认为，我们的情绪主要受到思维模式的影响。当我们遇到某个事件时，我们的解释和评价决定了我们的情绪反应。因此，改变我们的思维方式是管理情绪的关键。\n\n情绪管理的核心策略：\n1. 情绪觉察：学会识别和命名自己的情绪\n2. 认知重构：挑战和改变不合理的思维模式\n3. 行为激活：通过行动来改善情绪状态\n4. 放松技巧：使用深呼吸、渐进性肌肉放松等方法\n5. 问题解决：针对情绪背后的实际问题采取行动\n\n实用的情绪管理技巧：\n1. 情绪日记：记录情绪变化和触发因素\n2. 3-3-3法则：观察3个物体，听3种声音，触摸3种物品\n3. 暂停技术：在情绪激动时暂停反应，给自己思考的时间\n4. 积极自我对话：用积极的语言与自己对话\n\n通过学习和实践这些技巧，您将能够更好地管理自己的情绪，提升心理健康水平。',
    }
  ];

  // 技术分享专栏文章内容
  private techArticles: ArticleContent[] = [
    {
      id: '1',
      title: '鸿蒙开发实战：从零开始构建心理健康应用',
      author: '鸿蒙开发专家',
      publishTime: '2024-01-15',
      readTime: '15分钟',
      content: '本文将从零开始，详细介绍如何使用鸿蒙HarmonyOS开发一个心理健康应用。包括项目搭建、UI设计、数据管理等核心内容。\n\n鸿蒙HarmonyOS作为新一代智能终端操作系统，为开发者提供了强大的开发框架和丰富的API。在心理健康应用开发中，我们可以充分利用鸿蒙的分布式能力和多设备协同特性。\n\n项目搭建步骤：\n1. 安装DevEco Studio开发环境\n2. 创建鸿蒙应用项目\n3. 配置项目基本信息\n4. 设置应用权限\n\nUI设计要点：\n1. 遵循鸿蒙设计规范\n2. 使用ArkTS声明式UI\n3. 实现响应式布局\n4. 优化用户体验\n\n核心功能实现：\n1. 用户认证和授权\n2. 数据存储和管理\n3. 网络通信\n4. 设备间数据同步\n\n技术架构设计：\n1. 分层架构：UI层、业务层、数据层\n2. 组件化开发：提高代码复用性\n3. 状态管理：使用@State、@Link等装饰器\n4. 生命周期管理：合理管理组件生命周期\n\n性能优化策略：\n1. 图片懒加载\n2. 列表虚拟化\n3. 内存管理\n4. 网络请求优化\n\n通过本文的学习，您将掌握鸿蒙应用开发的核心技能，能够独立开发高质量的心理健康应用。',
    },
    {
      id: '2',
      title: 'ArkTS状态管理最佳实践',
      author: '前端架构师',
      publishTime: '2024-01-14',
      readTime: '12分钟',
      content: '状态管理是应用开发中的核心概念。本文将深入探讨ArkTS中的状态管理机制，包括@State、@Link、@Prop等装饰器的使用。\n\nArkTS作为鸿蒙应用开发的主要语言，提供了丰富的状态管理装饰器，帮助开发者构建响应式的用户界面。理解这些装饰器的特性和使用场景对于开发高质量的应用至关重要。\n\n核心装饰器详解：\n1. @State：组件内部状态，触发UI更新\n2. @Link：父子组件间的双向数据绑定\n3. @Prop：父组件向子组件传递数据\n4. @Observed：观察对象变化\n5. @ObjectLink：对象引用传递\n\n状态管理最佳实践：\n1. 合理使用装饰器：避免过度使用@State\n2. 数据流向清晰：遵循单向数据流原则\n3. 状态最小化：只保存必要的状态\n4. 性能优化：避免不必要的重渲染\n\n常见问题解决：\n1. 状态更新不生效：检查装饰器使用是否正确\n2. 性能问题：优化状态更新频率\n3. 内存泄漏：及时清理不需要的状态\n4. 数据同步：确保多组件间数据一致性\n\n高级技巧：\n1. 自定义装饰器：创建符合业务需求的状态管理工具\n2. 状态持久化：将重要状态保存到本地存储\n3. 状态调试：使用开发工具调试状态变化\n4. 测试策略：编写状态管理相关的单元测试\n\n通过掌握这些状态管理技巧，您将能够构建更加稳定和高效的应用。',
    },
    {
      id: '3',
      title: '鸿蒙UI组件库设计与实现',
      author: 'UI工程师',
      publishTime: '2024-01-13',
      readTime: '10分钟',
      content: '优秀的UI组件库能够大大提高开发效率。本文将分享如何设计一个高质量的鸿蒙UI组件库，包括组件设计原则、实现技巧等。\n\nUI组件库是提高开发效率和保证产品一致性的重要工具。在鸿蒙应用开发中，设计一个好的组件库需要考虑多个方面的因素。\n\n组件库设计原则：\n1. 一致性：保持视觉和交互的一致性\n2. 可复用性：组件应该能够在不同场景中复用\n3. 可扩展性：支持自定义和扩展\n4. 易用性：提供简单清晰的API\n5. 性能：确保组件的性能表现\n\n核心组件设计：\n1. 基础组件：按钮、输入框、标签等\n2. 布局组件：容器、网格、列表等\n3. 反馈组件：加载、提示、对话框等\n4. 导航组件：标签栏、面包屑、分页等\n\n实现技巧：\n1. 使用@Builder装饰器：创建可复用的UI构建器\n2. 参数化设计：通过props传递配置参数\n3. 插槽机制：支持内容自定义\n4. 主题系统：支持多主题切换\n5. 动画效果：添加流畅的交互动画\n\n组件库架构：\n1. 分层设计：基础层、业务层、应用层\n2. 模块化：按功能模块组织组件\n3. 文档完善：提供详细的使用文档和示例\n4. 版本管理：合理的版本控制和更新策略\n\n质量保证：\n1. 单元测试：为每个组件编写测试用例\n2. 视觉测试：确保组件在不同设备上的显示效果\n3. 性能测试：验证组件的性能表现\n4. 兼容性测试：确保在不同鸿蒙版本上的兼容性\n\n通过本文的学习，您将掌握组件库设计和实现的核心技能，能够为团队提供高质量的UI组件库。',
    }
  ];

  // 行业观察专栏文章内容
  private observeArticles: ArticleContent[] = [
    {
      id: '1',
      title: '2024年心理健康行业发展趋势分析',
      author: '行业分析师',
      publishTime: '2024-01-15',
      readTime: '18分钟',
      content: '随着人们对心理健康的重视程度不断提升，心理健康行业正在经历前所未有的发展机遇。本文将从多个维度分析2024年的行业趋势。\n\n心理健康行业在近年来呈现出快速发展的态势，特别是在后疫情时代，人们对心理健康的关注度显著提升。2024年，这个行业将继续保持强劲的增长势头。\n\n市场驱动因素：\n1. 社会认知提升：心理健康问题得到更多关注\n2. 政策支持：政府加大对心理健康服务的投入\n3. 技术发展：AI、大数据等技术推动服务创新\n4. 需求增长：各年龄段人群对心理健康服务的需求增加\n\n主要发展趋势：\n1. 数字化服务普及：在线咨询、移动应用等数字化服务将成为主流\n2. AI技术应用：人工智能在心理评估、个性化治疗等方面发挥重要作用\n3. 预防性服务：从治疗向预防转变，注重心理健康教育和早期干预\n4. 个性化服务：基于大数据和AI的个性化心理健康服务\n5. 跨界融合：心理健康与其他行业的深度融合\n\n细分市场机会：\n1. 儿童青少年心理健康：校园心理健康服务需求旺盛\n2. 职场心理健康：企业EAP服务市场潜力巨大\n3. 老年心理健康：老龄化社会带来的新需求\n4. 特殊群体服务：针对特定人群的专业化服务\n\n投资热点：\n1. 心理健康科技公司：AI、VR等技术在心理健康领域的应用\n2. 在线咨询平台：便捷的心理健康服务入口\n3. 心理健康教育：预防性心理健康服务\n4. 数据服务：心理健康数据分析和洞察服务\n\n挑战与机遇：\n1. 专业人才短缺：需要培养更多心理健康专业人才\n2. 服务质量参差不齐：需要建立行业标准和监管体系\n3. 隐私保护：在数据利用和隐私保护之间找到平衡\n4. 成本控制：降低心理健康服务的成本，提高可及性\n\n未来展望：\n心理健康行业将在2024年迎来更加广阔的发展空间，技术创新和服务模式创新将成为推动行业发展的主要动力。',
    },
    {
      id: '2',
      title: 'AI技术在心理健康领域的应用前景',
      author: 'AI研究员',
      publishTime: '2024-01-14',
      readTime: '14分钟',
      content: '人工智能技术正在各个领域发挥重要作用，心理健康领域也不例外。本文将探讨AI在心理咨询、情绪识别、个性化治疗等方面的应用。\n\n人工智能技术的快速发展为心理健康服务带来了革命性的变化。从情绪识别到个性化治疗，AI正在改变传统的心理健康服务模式。\n\nAI在心理健康领域的主要应用：\n1. 情绪识别与分析：通过语音、文字、面部表情识别情绪状态\n2. 智能聊天机器人：提供24/7的心理支持和初步咨询\n3. 个性化治疗推荐：基于用户数据推荐最适合的治疗方案\n4. 风险评估：识别心理健康风险，提供早期预警\n5. 治疗效果评估：客观评估治疗效果和进展\n\n技术实现方案：\n1. 自然语言处理：分析用户的语言表达和情感倾向\n2. 计算机视觉：识别面部表情和身体语言\n3. 机器学习：从大量数据中学习模式和规律\n4. 深度学习：构建复杂的神经网络模型\n5. 知识图谱：构建心理健康知识体系\n\n应用场景分析：\n1. 在线咨询平台：AI助手提供初步咨询和转介服务\n2. 移动应用：智能情绪跟踪和心理健康管理\n3. 医疗机构：辅助医生进行诊断和治疗\n4. 企业EAP：员工心理健康监测和支持\n5. 教育机构：学生心理健康评估和干预\n\n技术优势：\n1. 24/7可用性：不受时间和地点限制\n2. 标准化服务：提供一致的服务质量\n3. 数据驱动：基于大量数据的科学决策\n4. 成本效益：降低心理健康服务的成本\n5. 隐私保护：用户数据的安全处理\n\n挑战与限制：\n1. 技术准确性：AI模型的准确性和可靠性\n2. 伦理问题：AI决策的透明度和可解释性\n3. 隐私安全：用户数据的安全和隐私保护\n4. 人机协作：AI与人类专家的有效协作\n5. 监管合规：符合相关法律法规要求\n\n未来发展方向：\n1. 多模态融合：结合语音、视觉、文本等多种信息\n2. 个性化增强：提供更加个性化的服务\n3. 实时交互：实现更加自然的实时交互\n4. 跨文化适应：适应不同文化背景的用户需求\n5. 持续学习：AI模型的持续优化和更新\n\nAI技术在心理健康领域的应用前景广阔，但需要在技术发展和伦理规范之间找到平衡，确保技术真正服务于人类的心理健康。',
    },
    {
      id: '3',
      title: '数字化心理健康服务的商业模式创新',
      author: '商业模式专家',
      publishTime: '2024-01-13',
      readTime: '16分钟',
      content: '数字化正在重塑心理健康服务的商业模式。本文将分析传统心理健康服务向数字化转型的路径，以及新的商业机会。\n\n数字化技术的普及为心理健康服务带来了新的可能性，传统的面对面咨询模式正在被更加灵活和高效的数字化服务所补充和替代。\n\n传统模式与数字化模式的对比：\n1. 服务方式：从线下面对面到线上线下结合\n2. 服务时间：从固定时间到24/7全天候服务\n3. 服务范围：从本地服务到全球覆盖\n4. 服务成本：从高成本到成本效益优化\n5. 服务个性化：从标准化到高度个性化\n\n数字化心理健康服务的商业模式：\n1. 订阅制模式：按月或按年收费的会员服务\n2. 按需付费：按使用量或服务次数收费\n3. 企业服务：为企业提供员工心理健康服务\n4. 保险合作：与保险公司合作提供心理健康保险\n5. 数据服务：提供心理健康数据分析和洞察服务\n\n创新服务模式：\n1. 混合服务：线上初步咨询+线下深度治疗\n2. 社区服务：构建心理健康社区，用户互助\n3. 预防服务：心理健康教育和早期干预\n4. 家庭服务：面向整个家庭的综合服务\n5. 专业网络：连接专业心理咨询师和用户\n\n技术驱动的创新：\n1. AI辅助服务：智能聊天机器人和虚拟助手\n2. VR/AR治疗：虚拟现实技术在心理治疗中的应用\n3. 可穿戴设备：通过智能设备监测心理健康状态\n4. 大数据分析：基于用户数据的个性化服务\n5. 区块链技术：确保数据安全和隐私保护\n\n市场机会分析：\n1. 新兴市场：发展中国家心理健康服务需求增长\n2. 细分市场：针对特定人群的专业化服务\n3. 企业市场：企业员工心理健康服务\n4. 政府合作：与政府合作提供公共服务\n5. 国际扩张：将服务扩展到国际市场\n\n成功要素：\n1. 技术能力：强大的技术开发和创新能力\n2. 专业团队：心理健康专业人才和技术人才\n3. 用户体验：简洁易用的产品界面\n4. 数据安全：严格的数据保护和隐私政策\n5. 合规经营：符合相关法律法规要求\n\n未来发展趋势：\n1. 服务整合：提供一站式的心理健康服务\n2. 智能化增强：AI技术在服务中的深度应用\n3. 个性化提升：更加精准的个性化服务\n4. 社区化发展：构建心理健康生态系统\n5. 国际化扩张：服务全球用户\n\n数字化心理健康服务的商业模式创新将为行业带来新的发展机遇，同时也为用户提供更加便捷和高效的心理健康服务。',
    }
  ];

  // 简单的Markdown解析器
  parseMarkdown(markdown: string): MarkdownBlock[] {
    const blocks: MarkdownBlock[] = [];
    const lines = markdown.split('\n');
    let currentBlock: MarkdownBlock | null = null;
    let listItems: string[] = [];

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();
      
      if (line === '') {
        // 空行，结束当前块
        if (currentBlock) {
          if (currentBlock.type === 'list' && listItems.length > 0) {
            currentBlock.items = [...listItems];
            listItems = [];
          }
          blocks.push(currentBlock);
          currentBlock = null;
        }
        continue;
      }

      // 检查标题
      if (line.startsWith('#')) {
        if (currentBlock) {
          if (currentBlock.type === 'list' && listItems.length > 0) {
            currentBlock.items = [...listItems];
            listItems = [];
          }
          blocks.push(currentBlock);
        }
        const match = line.match(/^#+/);
        const level = match ? match[0].length : 1;
        currentBlock = {
          type: 'heading',
          content: line.replace(/^#+\s*/, ''),
          level: level
        };
        continue;
      }

      // 检查列表
      if (line.match(/^[\-\*]\s/)) {
        if (currentBlock && currentBlock.type !== 'list') {
          blocks.push(currentBlock);
        }
        if (!currentBlock || currentBlock.type !== 'list') {
          currentBlock = {
            type: 'list',
            content: '',
            items: []
          };
        }
        listItems.push(line.replace(/^[\-\*]\s/, ''));
        continue;
      }

      // 检查代码块
      if (line.startsWith('```')) {
        if (currentBlock) {
          if (currentBlock.type === 'list' && listItems.length > 0) {
            currentBlock.items = [...listItems];
            listItems = [];
          }
          blocks.push(currentBlock);
        }
        currentBlock = {
          type: 'code',
          content: ''
        };
        continue;
      }

      // 检查引用
      if (line.startsWith('>')) {
        if (currentBlock && currentBlock.type !== 'quote') {
          if (currentBlock.type === 'list' && listItems.length > 0) {
            currentBlock.items = [...listItems];
            listItems = [];
          }
          blocks.push(currentBlock);
        }
        if (!currentBlock || currentBlock.type !== 'quote') {
          currentBlock = {
            type: 'quote',
            content: ''
          };
        }
        currentBlock.content += (currentBlock.content ? '\n' : '') + line.replace(/^>\s*/, '');
        continue;
      }

      // 检查分割线
      if (line.match(/^[\-\*_]{3,}$/)) {
        if (currentBlock) {
          if (currentBlock.type === 'list' && listItems.length > 0) {
            currentBlock.items = [...listItems];
            listItems = [];
          }
          blocks.push(currentBlock);
        }
        blocks.push({
          type: 'divider',
          content: ''
        });
        currentBlock = null;
        continue;
      }

      // 普通文本
      if (!currentBlock) {
        currentBlock = {
          type: 'text',
          content: ''
        };
      }
      
      if (currentBlock.type === 'text') {
        currentBlock.content += (currentBlock.content ? '\n' : '') + line;
      } else if (currentBlock.type === 'code') {
        currentBlock.content += (currentBlock.content ? '\n' : '') + line;
      }
    }

    // 处理最后一个块
    if (currentBlock) {
      if (currentBlock.type === 'list' && listItems.length > 0) {
        currentBlock.items = [...listItems];
      }
      blocks.push(currentBlock);
    }

    return blocks;
  }

  aboutToAppear() {
    // 每次页面出现时都重新获取参数
    const params = router.getParams() as ArticleParams;
    this.articleId = params.articleId || '1';
    this.articleTitle = params.articleTitle || '文章标题';
    this.articleType = params.articleType || 'deep';

    this.articleContent = '等待生成中...';
    this.loading = true;

    // 根据articleType只在对应专栏查找title
    let matchedTitle = this.articleTitle;
    let targetArticle: ArticleContent | undefined;

    if (this.articleType === 'tech') {
      targetArticle = this.techArticles.find(article => article.id === this.articleId);
    } else if (this.articleType === 'observe') {
      targetArticle = this.observeArticles.find(article => article.id === this.articleId);
    } else {
      targetArticle = this.depthArticles.find(article => article.id === this.articleId);
    }

    if (targetArticle) {
      matchedTitle = targetArticle.title;
    }

    console.log(this.articleTitle+" "+this.articleType+" "+this.articleId)

    import('../service/apiservice').then((mod) => {
      const ApiService = mod.ApiService;

      let safeType: 'deep' | 'tech' | 'industry' = 'deep';
      if (this.articleType === 'tech') safeType = 'tech';
      else if (this.articleType === 'observe') safeType = 'industry';

      ApiService.generateAIArticle(safeType, this.articleTitle).then(content => {
        this.articleContent = content;
        this.parsedBlocks = this.parseMarkdown(content);
        this.loading = false;
      }).catch((error: Error) => {
        console.error('AI请求失败:', error);
        if (error instanceof Error) {
          console.error('error.message:', error.message);
          if (error.stack) {
            console.error('error.stack:', error.stack);
          }
        } else {
          console.error('error(非Error类型):', JSON.stringify(error));
        }
        this.articleContent = '生成失败，请稍后重试';
        this.parsedBlocks = [];
        this.loading = false;
      });
    });
  }

  // 修改后的renderMarkdownContent方法如下：
  @Builder
  renderMarkdownContent(block: MarkdownBlock, index: number) {
    if (block.type === 'heading') {
      Column()
      {
        Column(){
        ForEach(this.parseInlineMarkdown(block.content), (seg: InlineMarkdownSegment, idx: number) => {
          if (seg.type === 'bolditalic') {
            Text(seg.text).fontWeight(FontWeight.Bold).fontStyle(FontStyle.Italic).fontColor('#ffffff').fontSize(block.level === 1 ? 22 : block.level === 2 ? 20 : 18)
          } else if (seg.type === 'bold') {
            Text(seg.text).fontWeight(FontWeight.Bold).fontColor('#ffffff').fontSize(block.level === 1 ? 22 : block.level === 2 ? 20 : 18)
          } else if (seg.type === 'italic') {
            Text(seg.text).fontStyle(FontStyle.Italic).fontColor('#b0c4de').fontSize(block.level === 1 ? 22 : block.level === 2 ? 20 : 18)
          } else if (seg.type === 'code') {
            Text(seg.text).fontColor('#0D9FFB').backgroundColor('rgba(13,159,251,0.10)').fontSize(block.level === 1 ? 22 : block.level === 2 ? 20 : 18)
          } else {
            Text(seg.text).fontColor('#ffffff').fontSize(block.level === 1 ? 22 : block.level === 2 ? 20 : 18)
          }
        })
        }
          .margin({ top: 16, bottom: 8 })
          .padding({ left: 16, right: 16 })

      }
    } else if (block.type === 'text') {
      Column() {
        Column(){
        ForEach(this.parseInlineMarkdown(block.content), (seg: InlineMarkdownSegment, idx: number) => {
          if (seg.type === 'bolditalic') {
            Text(seg.text).fontWeight(FontWeight.Bold).fontStyle(FontStyle.Italic).fontColor('#ffffff').fontSize(16)
          } else if (seg.type === 'bold') {
            Text(seg.text).fontWeight(FontWeight.Bold).fontColor('#ffffff').fontSize(16)
          } else if (seg.type === 'italic') {
            Text(seg.text).fontStyle(FontStyle.Italic).fontColor('#b0c4de').fontSize(16)
          } else if (seg.type === 'code') {
            Text(seg.text).fontColor('#0D9FFB').backgroundColor('rgba(13,159,251,0.10)').fontSize(16)
          } else {
            Text(seg.text).fontColor('#ffffff').fontSize(16)
          }
        })
          }
        .margin({ top: 8, bottom: 8 })
        .padding({ left: 16, right: 16 })
      }
    } else if (block.type === 'list') {
      Column() {
        ForEach(block.items || [], (item: string, itemIndex: number) => {
          Row() {
            // 有序列表支持 - 用条件渲染
            if (item.match(/^(\d+)\.\s(.*)$/)) {
              Text(item.replace(/^(\d+)\..*/, '$1.')).fontSize(16).fontColor('#0D9FFB').margin({ right: 8 })
              ForEach(this.parseInlineMarkdown(item.replace(/^\d+\.\s/, '')), (seg: InlineMarkdownSegment, idx: number) => {
                if (seg.type === 'bolditalic') {
                  Text(seg.text).fontWeight(FontWeight.Bold).fontStyle(FontStyle.Italic).fontColor('#ffffff').fontSize(16)
                } else if (seg.type === 'bold') {
                  Text(seg.text).fontWeight(FontWeight.Bold).fontColor('#ffffff').fontSize(16)
                } else if (seg.type === 'italic') {
                  Text(seg.text).fontStyle(FontStyle.Italic).fontColor('#b0c4de').fontSize(16)
                } else if (seg.type === 'code') {
                  Text(seg.text).fontColor('#0D9FFB').backgroundColor('rgba(13,159,251,0.10)').fontSize(16)
                } else {
                  Text(seg.text).fontColor('#ffffff').fontSize(16)
                }
              })
            } else {
              Text('•').fontSize(16).fontColor('#0D9FFB').margin({ right: 8 })
              ForEach(this.parseInlineMarkdown(item), (seg: InlineMarkdownSegment, idx: number) => {
                if (seg.type === 'bolditalic') {
                  Text(seg.text).fontWeight(FontWeight.Bold).fontStyle(FontStyle.Italic).fontColor('#ffffff').fontSize(16)
                } else if (seg.type === 'bold') {
                  Text(seg.text).fontWeight(FontWeight.Bold).fontColor('#ffffff').fontSize(16)
                } else if (seg.type === 'italic') {
                  Text(seg.text).fontStyle(FontStyle.Italic).fontColor('#b0c4de').fontSize(16)
                } else if (seg.type === 'code') {
                  Text(seg.text).fontColor('#0D9FFB').backgroundColor('rgba(13,159,251,0.10)').fontSize(16)
                } else {
                  Text(seg.text).fontColor('#ffffff').fontSize(16)
                }
              })
            }
          }
          .width('100%')
          .margin({ top: 4, bottom: 4 })
        })
      }
      .margin({ top: 8, bottom: 8 })
      .padding({ left: 16, right: 16 })
    } else if (block.type === 'code') {
      Column() {
        Text(block.content)
          .fontSize(14)
          .fontColor('#0D9FFB')
          .lineHeight(20)
          .backgroundColor('rgba(13,159,251,0.10)')
          .borderRadius(8)
          .padding(12)
          .width('100%')
      }
      .margin({ top: 8, bottom: 8 })
      .padding({ left: 16, right: 16 })
    } else if (block.type === 'quote') {
      Column() {
        ForEach(this.parseInlineMarkdown(block.content), (seg: InlineMarkdownSegment, idx: number) => {
          if (seg.type === 'bolditalic') {
            Text(seg.text).fontWeight(FontWeight.Bold).fontStyle(FontStyle.Italic).fontColor('#ffffff').fontSize(16)
          } else if (seg.type === 'bold') {
            Text(seg.text).fontWeight(FontWeight.Bold).fontColor('#ffffff').fontSize(16)
          } else if (seg.type === 'italic') {
            Text(seg.text).fontStyle(FontStyle.Italic).fontColor('#b0c4de').fontSize(16)
          } else if (seg.type === 'code') {
            Text(seg.text).fontColor('#0D9FFB').backgroundColor('rgba(13,159,251,0.10)').fontSize(16)
          } else {
            Text(seg.text).fontColor('#ffffff').fontSize(16)
          }
        })
      }
      .backgroundColor('rgba(255,255,255,0.03)')
      .borderRadius(8)
      .border({ width: { left: 4 }, color: '#0D9FFB' })
      .padding(12)
      .width('100%')
      .margin({ top: 8, bottom: 8 })
      .padding({ left: 16, right: 16 })
    } else if (block.type === 'divider') {
      Divider()
        .color('rgba(255,255,255,0.08)')
        .width('100%')
        .margin({ top: 16, bottom: 16 })
    }
  }

  // 加载文章内容
  loadArticleContent() {
    // 根据文章ID确定属于哪个专栏
    const articleId = this.articleId;
    let targetArticle: ArticleContent | undefined;

    // 如果没找到，使用默认文章
    console.log('未找到文章，使用默认内容');
  }

  // 1. 在 ArticleDetail 结构体内添加 parseInlineMarkdown 方法
  parseInlineMarkdown(text: string): InlineMarkdownSegment[] {
    const result: InlineMarkdownSegment[] = [];
    let pattern = /(\*\*\*.+?\*\*\*)|(\*\*.+?\*\*)|(\*.+?\*)|(`.+?`)/g;
    let lastIndex = 0;
    let match: RegExpExecArray | null;
    while ((match = pattern.exec(text)) !== null) {
      if (match.index > lastIndex) {
        result.push({ type: 'normal', text: text.substring(lastIndex, match.index) });
      }
      if (match[1]) {
        result.push({ type: 'bolditalic', text: match[1].slice(3, -3) });
      } else if (match[2]) {
        result.push({ type: 'bold', text: match[2].slice(2, -2) });
      } else if (match[3]) {
        result.push({ type: 'italic', text: match[3].slice(1, -1) });
      } else if (match[4]) {
        result.push({ type: 'code', text: match[4].slice(1, -1) });
      }
      lastIndex = pattern.lastIndex;
    }
    if (lastIndex < text.length) {
      result.push({ type: 'normal', text: text.substring(lastIndex) });
    }
    return result;
  }

  // 2. 修改 renderMarkdownContent 方法，所有 Text(block.content) 处，改为 ForEach(this.parseInlineMarkdown(block.content), ...) 分段渲染
  // 3. 列表渲染支持有序和无序
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('‹')
          .fontSize(24)
          .fontColor('#ffffff')
          .backgroundColor('transparent')
          .onClick(() => router.back())

        Text(this.articleTitle)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ffffff')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
          .margin({ left: 16, right: 16 })
          .onClick(()=>{
            console.log(this.articleTitle+' '+this.articleType)
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('rgba(10,10,10,1)')
      .border({ width: { bottom: 1 }, color: 'rgba(255,255,255,0.08)' })

      // 文章内容
      Scroll() {
        Column() {
          // 文章标题
          Text(this.articleTitle)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')
            .margin({ top: 20, bottom: 12 })
            .padding({ left: 16, right: 16 })

          // 正文内容或加载动画
          if (this.loading) {
            Text(this.articleContent)
              .fontSize(16)
              .fontColor('#b0c4de')
              .lineHeight(24)
              .padding({ left: 16, right: 16, bottom: 40 })
          } else {
            // 渲染解析后的markdown内容
            ForEach(this.parsedBlocks, (block: MarkdownBlock, index: number) => this.renderMarkdownContent(block, index))

            // 底部间距，避免被底部操作栏遮挡
            Column()
              .height(80)
              .width('100%')
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('rgba(10,10,10,1)')

      // 底部操作栏
      Row() {
        Row() {
          Button('📖')
            .fontSize(20)
            .backgroundColor('transparent')
            .fontColor('#ffffff')
        }

      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .backgroundColor('rgba(10,10,10,1)')
      .border({ width: { top: 1 }, color: 'rgba(255,255,255,0.08)' })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(10,10,10,1)')
  }
} 