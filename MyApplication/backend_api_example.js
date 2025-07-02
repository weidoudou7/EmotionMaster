/**
 * 后端API示例代码 - 支持人物类型特点的聊天系统
 * 使用Node.js Express框架示例
 */

const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 8081;

// 中间件
app.use(cors());
app.use(express.json());

// 加载人物类型配置
function loadCharacterPersonalities() {
    try {
        const configPath = path.join(__dirname, 'character_personalities.json');
        const configData = fs.readFileSync(configPath, 'utf8');
        return JSON.parse(configData).character_personalities;
    } catch (error) {
        console.warn('警告: character_personalities.json 文件未找到，使用默认配置');
        return {
            "default": {
                "name": "AI助手",
                "personality": "我是一个友好的AI助手，乐于帮助用户解决问题。",
                "conversation_style": "friendly, helpful, informative, patient",
                "language": "Chinese",
                "specialties": ["问题解答", "信息提供", "友好交流", "技术支持"],
                "greeting": "你好！我是AI助手，很高兴为你服务。有什么我可以帮助你的吗？",
                "system_prompt": "你是一个友好的AI助手，乐于帮助用户解决问题。说话要友好、耐心、有礼貌，提供有用的信息和帮助。"
            }
        };
    }
}

// 全局变量
const CHARACTER_PERSONALITIES = loadCharacterPersonalities();
const chatHistories = new Map(); // 聊天历史存储

// AI角色存储（实际项目中应该使用数据库）
const aiRoles = new Map(); // 存储AI角色数据
let nextRoleId = 1; // 角色ID计数器

/**
 * 调用AI服务
 * 这里使用模拟的AI服务，你可以替换为实际的AI API
 */
async function callAIService(messages, characterConfig) {
    try {
        // 这里应该调用实际的AI服务，比如OpenAI、Claude等
        // 示例：使用OpenAI API
        /*
        const { Configuration, OpenAIApi } = require('openai');
        const configuration = new Configuration({
            apiKey: process.env.OPENAI_API_KEY,
        });
        const openai = new OpenAIApi(configuration);
        
        const response = await openai.createChatCompletion({
            model: "gpt-3.5-turbo",
            messages: messages,
            max_tokens: 1000,
            temperature: 0.7,
        });
        
        return response.data.choices[0].message.content;
        */
        
        // 模拟AI回复（实际项目中删除这部分）
        const systemPrompt = characterConfig.system_prompt;
        const userMessage = messages[messages.length - 1].content;
        
        // 根据人物类型生成模拟回复
        let response = '';
        if (characterConfig.name === '英语练习机器') {
            response = `Hello! I understand you said: "${userMessage}". Let me help you practice English. `;
            response += `Remember to use proper grammar and pronunciation. Would you like to continue our conversation in English?`;
        } else if (characterConfig.name === '江时彦') {
            response = `哼，${userMessage}？你这种问题也敢来问我？不过既然你问了，我就勉为其难回答一下。`;
            response += `作为江氏集团的未来掌权人，我的时间很宝贵，下次问点有价值的问题。`;
        } else if (characterConfig.name === '苏沫') {
            response = `徒儿，${userMessage}...为师明白你的困惑。`;
            response += `修行之路漫长，需要耐心和毅力。让为师为你指点迷津。`;
        } else {
            response = `作为${characterConfig.name}，我对你的问题"${userMessage}"很感兴趣。`;
            response += `让我用我的专业知识和经验来帮助你。`;
        }
        
        return response;
        
    } catch (error) {
        console.error('AI服务调用失败:', error);
        return `抱歉，我现在无法回复。${characterConfig.name || 'AI助手'}正在休息中，请稍后再试。`;
    }
}

/**
 * AI聊天接口
 * POST /api/ai/chat/:identity
 */
app.post('/api/ai/chat/:identity', async (req, res) => {
    try {
        const { identity } = req.params;
        const { prompt, chatId = 'default' } = req.query;
        
        if (!prompt) {
            return res.status(400).json({
                success: false,
                message: '用户消息不能为空',
                data: ''
            });
        }
        
        // 获取人物配置
        const characterConfig = CHARACTER_PERSONALITIES[identity] || CHARACTER_PERSONALITIES['default'];
        
        // 构建系统提示词
        const systemPrompt = characterConfig.system_prompt;
        
        // 获取聊天历史
        const chatHistory = chatHistories.get(chatId) || [];
        
        // 构建完整的对话上下文
        const messages = [
            { role: "system", content: systemPrompt }
        ];
        
        // 添加历史对话（限制长度）
        for (const msg of chatHistory.slice(-10)) {
            messages.push({
                role: msg.is_user ? "user" : "assistant",
                content: msg.content
            });
        }
        
        // 添加当前用户消息
        messages.push({ role: "user", content: prompt });
        
        // 调用AI服务
        const aiResponse = await callAIService(messages, characterConfig);
        
        // 保存对话历史
        const newHistory = chatHistory.concat([
            { is_user: true, content: prompt },
            { is_user: false, content: aiResponse }
        ]);
        
        // 限制历史记录长度
        if (newHistory.length > 20) {
            newHistory.splice(0, newHistory.length - 20);
        }
        
        chatHistories.set(chatId, newHistory);
        
        res.json({
            success: true,
            message: 'success',
            data: aiResponse
        });
        
    } catch (error) {
        console.error('聊天API错误:', error);
        res.status(500).json({
            success: false,
            message: `聊天失败: ${error.message}`,
            data: ''
        });
    }
});

/**
 * 获取AI身份列表
 * GET /api/ai/identities
 */
app.get('/api/ai/identities', (req, res) => {
    try {
        const identities = Object.keys(CHARACTER_PERSONALITIES);
        res.json({
            success: true,
            message: 'success',
            data: identities
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: `获取身份列表失败: ${error.message}`,
            data: []
        });
    }
});

/**
 * 创建AI角色
 * POST /api/ai/role/create
 */
app.post('/api/ai/role/create', (req, res) => {
    try {
        const { roleName, roleDescription, roleType, roleAuthor, avatarUrl, isTemplate = false } = req.body;
        
        // 验证必填字段
        if (!roleName || !roleDescription || !roleType || !roleAuthor || !avatarUrl) {
            return res.status(400).json({
                success: false,
                message: '缺少必填字段',
                data: null
            });
        }
        
        // 创建新的AI角色
        const newRole = {
            id: nextRoleId++,
            userId: null, // 暂时设为null，实际项目中应该关联用户ID
            roleName: roleName,
            roleDescription: roleDescription,
            roleType: roleType,
            roleAuthor: roleAuthor,
            viewCount: 0,
            avatarUrl: avatarUrl,
            isTemplate: isTemplate,
            createdAt: new Date().toISOString()
        };
        
        // 保存到内存中（实际项目中应该保存到数据库）
        aiRoles.set(newRole.id, newRole);
        
        console.log('创建AI角色成功:', newRole);
        
        res.json({
            success: true,
            message: 'AI角色创建成功',
            data: newRole
        });
        
    } catch (error) {
        console.error('创建AI角色失败:', error);
        res.status(500).json({
            success: false,
            message: `创建AI角色失败: ${error.message}`,
            data: null
        });
    }
});

/**
 * 获取特色AI角色（四种类型）
 * GET /api/ai/role/featured4types
 */
app.get('/api/ai/role/featured4types', (req, res) => {
    try {
        // 模拟返回四种类型的AI角色数据
        const featuredRoles = {
            '动漫': [
                {
                    id: 1,
                    userId: null,
                    roleName: '动漫少女',
                    roleDescription: '可爱的动漫少女角色',
                    roleType: '动漫',
                    roleAuthor: '系统',
                    viewCount: 100,
                    avatarUrl: 'https://example.com/anime1.jpg',
                    isTemplate: true,
                    createdAt: '2024-01-01T00:00:00.000Z'
                }
            ],
            '可爱': [
                {
                    id: 2,
                    userId: null,
                    roleName: '可爱宠物',
                    roleDescription: '超级可爱的宠物角色',
                    roleType: '可爱',
                    roleAuthor: '系统',
                    viewCount: 150,
                    avatarUrl: 'https://example.com/cute1.jpg',
                    isTemplate: true,
                    createdAt: '2024-01-01T00:00:00.000Z'
                }
            ],
            '科幻': [
                {
                    id: 3,
                    userId: null,
                    roleName: '未来战士',
                    roleDescription: '来自未来的科幻战士',
                    roleType: '科幻',
                    roleAuthor: '系统',
                    viewCount: 80,
                    avatarUrl: 'https://example.com/scifi1.jpg',
                    isTemplate: true,
                    createdAt: '2024-01-01T00:00:00.000Z'
                }
            ],
            '写实': [
                {
                    id: 4,
                    userId: null,
                    roleName: '写实人物',
                    roleDescription: '真实可信的人物角色',
                    roleType: '写实',
                    roleAuthor: '系统',
                    viewCount: 120,
                    avatarUrl: 'https://example.com/realistic1.jpg',
                    isTemplate: true,
                    createdAt: '2024-01-01T00:00:00.000Z'
                }
            ]
        };
        
        res.json({
            success: true,
            message: 'success',
            data: featuredRoles
        });
        
    } catch (error) {
        res.status(500).json({
            success: false,
            message: `获取特色角色失败: ${error.message}`,
            data: {}
        });
    }
});

/**
 * 健康检查接口
 * GET /api/user/health
 */
app.get('/api/user/health', (req, res) => {
    res.json({
        success: true,
        message: 'Service is healthy',
        data: 'OK'
    });
});

/**
 * 获取特定人物的详细信息
 * GET /api/character/:identity
 */
app.get('/api/character/:identity', (req, res) => {
    try {
        const { identity } = req.params;
        const characterInfo = CHARACTER_PERSONALITIES[identity] || CHARACTER_PERSONALITIES['default'];
        
        res.json({
            success: true,
            message: 'success',
            data: characterInfo
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: `获取人物信息失败: ${error.message}`,
            data: {}
        });
    }
});

// 启动服务器
app.listen(PORT, () => {
    console.log(`服务器运行在 http://localhost:${PORT}`);
    console.log('可用的AI身份:');
    Object.entries(CHARACTER_PERSONALITIES).forEach(([identity, config]) => {
        console.log(`- ${identity}: ${config.personality}`);
    });
});

module.exports = app; 