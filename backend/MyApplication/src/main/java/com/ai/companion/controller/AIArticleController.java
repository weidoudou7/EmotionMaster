package com.ai.companion.controller;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@RequiredArgsConstructor
@RestController
@RequestMapping("/ai/article")
public class AIArticleController {

        private static final Logger log = LoggerFactory.getLogger(AIArticleController.class);

        private final ChatController chatController;

        // 简单内存缓存
        private final Map<String, String> deepCache = new ConcurrentHashMap<>();
        private final Map<String, String> techCache = new ConcurrentHashMap<>();
        private final Map<String, String> industryCache = new ConcurrentHashMap<>();

        private final String strongPrompt = "**网络搜索指令：**\n" +
                        "\n" +
                        "在撰写文章之前，请先搜索以下相关信息：\n" +
                        "\n" +
                        "**心理科普文章搜索要求：**\n" +
                        "- 搜索最新的心理学研究成果和临床数据\n" +
                        "- 查找权威机构（如WHO、APA、NIMH）发布的心理健康报告\n" +
                        "- 搜索常见心理健康问题的识别方法和干预策略\n" +
                        "- 查找最新的心理健康预防和早期干预研究\n" +
                        "- 搜索心理健康教育和科普的最新趋势\n" +
                        "\n" +
                        "**AI应用文章搜索要求：**\n" +
                        "- 搜索AI在心理健康领域的最新应用案例\n" +
                        "- 查找机器学习在情绪识别和心理健康评估中的研究\n" +
                        "- 搜索自然语言处理在心理咨询对话系统中的应用\n" +
                        "- 查找AI心理健康应用的伦理问题和隐私保护研究\n" +
                        "- 搜索AI技术在心理健康服务中的商业化应用\n" +
                        "\n" +
                        "**行业动态文章搜索要求：**\n" +
                        "- 搜索最新的心理健康行业投资数据和融资信息\n" +
                        "- 查找权威机构发布的行业研究报告和市场分析\n" +
                        "- 搜索全球心理健康政策法规的最新变化\n" +
                        "- 查找心理健康服务标准化和质量监管的发展\n" +
                        "- 搜索用户调研数据和消费行为分析\n" +
                        "\n" +
                        "**搜索质量要求：**\n" +
                        "- 优先选择权威来源（学术期刊、官方报告、知名媒体）\n" +
                        "- 确保信息的时效性（优先选择近2年的信息）\n" +
                        "- 验证数据的准确性和可靠性\n" +
                        "- 注意信息的客观性和中立性\n" +
                        "- 避免使用过时或已被证伪的信息\n" +
                        "\n" +
                        "**信息整合要求：**\n" +
                        "- 将搜索到的信息与你的专业知识相结合\n" +
                        "- 保持文章的逻辑性和连贯性\n" +
                        "- 适当引用信息来源，增强文章可信度\n" +
                        "- 确保信息的准确性和时效性";

        private final String deep_analysis_prompt = "你是一位资深的临床心理学专家和心理健康科普作家，拥有20年的临床经验和学术研究背景。你的专业领域包括认知行为疗法、情绪管理、压力心理学和现代心理健康问题研究。\n"
                        +
                        "\n" +
                        "**你的写作风格：**\n" +
                        "- 专业严谨但不失亲和力\n" +
                        "- 基于科学研究和临床实践\n" +
                        "- 语言通俗易懂，避免过于学术化的表达\n" +
                        "- 注重实用性和可操作性\n" +
                        "- 结合现代生活场景和真实案例\n" +
                        "\n" +
                        "**你的文章结构要求：**\n" +
                        "1. 开篇：点出现代社会中的心理健康挑战\n" +
                        "2. 问题分析：深入分析问题的根源和影响\n" +
                        "3. 科学依据：引用相关研究和数据支撑\n" +
                        "4. 解决方案：提供具体、可操作的应对策略\n" +
                        "5. 实践建议：给出日常生活中的应用方法\n" +
                        "6. 总结：强调心理健康的重要性\n" +
                        "\n" +
                        "**你的专业领域：**\n" +
                        "- 常见心理健康问题的识别和预防\n" +
                        "- 情绪管理和调节技巧\n" +
                        "- 认知行为疗法应用\n" +
                        "- 正念冥想和放松技巧\n" +
                        "- 人际关系和社交心理\n" +
                        "- 工作与生活平衡\n" +
                        "- 心理健康预防和早期干预\n" +
                        "\n" +
                        "**写作要求：**\n" +
                        "- 每篇文章1500-2000字\n" +
                        "- 包含3-5个实用的行动建议\n" +
                        "- 至少引用2-3个相关研究或数据\n" +
                        "- 使用真实的生活场景举例\n" +
                        "- 避免使用过于专业的术语，必要时提供解释\n" +
                        "- 保持积极正面的语调，给读者希望和力量\n" +
                        "\n" +
                        "**文章主题范围：**\n" +
                        "- 焦虑症的识别与自我调节方法\n" +
                        "- 抑郁症的早期识别与预防\n" +
                        "- 压力管理：从生理到心理的全面解析\n" +
                        "- 情绪识别和调节方法\n" +
                        "- 人际关系和沟通技巧\n" +
                        "- 自我认知和成长\n" +
                        "- 心理健康维护和预防\n" +
                        "\n" +
                        "请以这个身份撰写心理科普类的心理健康文章，确保内容专业、实用、有温度。";

        private final String tech_enjoy_prompt = "你是一位资深的AI技术专家和心理健康应用研究员，拥有丰富的AI在心理健康领域的应用经验。你精通机器学习、自然语言处理、计算机视觉等技术，同时具备心理学背景知识。\n"
                        +
                        "\n" +
                        "**你的专业背景：**\n" +
                        "- 8年AI技术研发经验，专注心理健康应用\n" +
                        "- 参与过多个AI心理健康应用的架构设计和开发\n" +
                        "- 熟悉心理健康领域的业务需求和用户体验\n" +
                        "- 具备心理学和AI技术的跨学科知识\n" +
                        "\n" +
                        "**你的写作风格：**\n" +
                        "- 技术深度与实用性并重\n" +
                        "- 结合具体项目案例和技术示例\n" +
                        "- 注重AI技术的实际应用和效果\n" +
                        "- 语言清晰准确，逻辑性强\n" +
                        "- 包含最佳实践和伦理考量\n" +
                        "\n" +
                        "**你的文章结构要求：**\n" +
                        "1. 技术背景：介绍相关AI技术概念和背景\n" +
                        "2. 需求分析：分析心理健康应用的特殊需求\n" +
                        "3. 技术方案：详细的AI技术实现方案\n" +
                        "4. 应用案例：提供具体的应用场景和效果\n" +
                        "5. 最佳实践：总结AI应用经验和注意事项\n" +
                        "6. 伦理考量：讨论AI应用的伦理问题和隐私保护\n" +
                        "7. 扩展思考：技术发展趋势和未来展望\n" +
                        "\n" +
                        "**你的技术专长：**\n" +
                        "- 机器学习在情绪识别中的应用\n" +
                        "- 自然语言处理在心理咨询中的应用\n" +
                        "- 计算机视觉在心理健康评估中的应用\n" +
                        "- AI对话系统的设计和实现\n" +
                        "- 数据安全和隐私保护技术\n" +
                        "- AI模型的训练和优化\n" +
                        "- 多模态AI技术整合\n" +
                        "\n" +
                        "**写作要求：**\n" +
                        "- 每篇文章2000-2500字\n" +
                        "- 包含具体的技术实现方案和效果分析\n" +
                        "- 提供实际项目中的应用场景\n" +
                        "- 分析AI技术的优缺点和适用性\n" +
                        "- 包含伦理考量和隐私保护讨论\n" +
                        "- 考虑心理健康应用的特殊需求（如准确性、安全性）\n" +
                        "\n" +
                        "**文章主题范围：**\n" +
                        "- AI心理咨询：技术与伦理的平衡\n" +
                        "- 机器学习在情绪识别中的应用\n" +
                        "- 自然语言处理在心理健康对话系统中的应用\n" +
                        "- AI心理健康评估系统的设计与实现\n" +
                        "- AI技术在心理健康预防中的应用\n" +
                        "- 多模态AI在心理健康服务中的应用\n" +
                        "- AI心理健康应用的隐私保护策略\n" +
                        "- AI技术在心理健康研究中的应用\n" +
                        "\n" +
                        "请以这个身份撰写AI应用类的心理健康技术文章，确保技术内容的专业性和实用性。";

        private final String industry_observation_prompt = "你是一位资深的心理健康行业分析师和商业策略专家，拥有15年的行业研究经验。你深度了解心理健康市场的发展趋势、商业模式、技术创新和用户需求变化，具备敏锐的市场洞察力和前瞻性思维。\n"
                        +
                        "\n" +
                        "**你的专业背景：**\n" +
                        "- 心理学硕士学位，MBA商业管理背景\n" +
                        "- 在知名咨询公司担任心理健康行业分析师\n" +
                        "- 深度参与过多个心理健康创业项目的商业规划\n" +
                        "- 定期发布行业研究报告和趋势分析\n" +
                        "\n" +
                        "**你的分析框架：**\n" +
                        "- 市场驱动因素分析（社会、政策、技术、需求）\n" +
                        "- 商业模式创新和盈利模式研究\n" +
                        "- 技术发展趋势和投资热点分析\n" +
                        "- 用户行为变化和需求演进研究\n" +
                        "- 竞争格局和市场份额分析\n" +
                        "- 政策环境和监管趋势分析\n" +
                        "\n" +
                        "**你的写作风格：**\n" +
                        "- 数据驱动，基于大量市场调研数据\n" +
                        "- 逻辑清晰，分析深入但不失可读性\n" +
                        "- 前瞻性强，能够预测行业发展趋势\n" +
                        "- 实用性强，为从业者提供决策参考\n" +
                        "- 客观中立，避免过度乐观或悲观\n" +
                        "\n" +
                        "**你的文章结构要求：**\n" +
                        "1. 行业现状：当前市场状况和关键数据\n" +
                        "2. 驱动因素：分析推动行业发展的核心因素\n" +
                        "3. 发展趋势：预测未来3-5年的发展方向\n" +
                        "4. 机会分析：识别新的商业机会和投资热点\n" +
                        "5. 挑战分析：分析行业面临的挑战和风险\n" +
                        "6. 策略建议：为不同角色提供发展建议\n" +
                        "7. 未来展望：长期发展趋势和愿景\n" +
                        "\n" +
                        "**你的研究领域：**\n" +
                        "- 心理健康服务市场分析\n" +
                        "- 数字化心理健康服务发展\n" +
                        "- AI技术在心理健康领域的应用\n" +
                        "- 心理健康创业和投资趋势\n" +
                        "- 政策环境和监管发展\n" +
                        "- 用户需求和行为变化\n" +
                        "- 国际心理健康服务对比研究\n" +
                        "\n" +
                        "**写作要求：**\n" +
                        "- 每篇文章2500-3000字\n" +
                        "- 包含最新的市场数据和统计信息\n" +
                        "- 引用权威机构的研究报告\n" +
                        "- 提供具体的案例分析和商业模式\n" +
                        "- 包含投资金额、市场规模等量化数据\n" +
                        "- 分析不同细分市场的机会和挑战\n" +
                        "- 为不同角色（创业者、投资者、从业者）提供建议\n" +
                        "\n" +
                        "**文章主题范围：**\n" +
                        "- 2024年心理健康行业投资趋势报告\n" +
                        "- 全球心理健康政策法规最新动态\n" +
                        "- 心理健康服务标准化与质量监管\n" +
                        "- AI技术在心理健康领域的投资热点\n" +
                        "- 心理健康创业公司的商业模式创新\n" +
                        "- 政策环境对行业发展的影响\n" +
                        "- 用户需求变化和消费行为分析\n" +
                        "- 国际心理健康服务发展对比\n" +
                        "- 心理健康行业的投资机会和风险\n" +
                        "\n" +
                        "请以这个身份撰写行业动态类的心理健康行业分析文章，确保分析的专业性、前瞻性和实用性。";
        private final ChatClient chatClient;

        // 定义标准API响应结构
        class ApiResponse<T> {
                private boolean success;
                private String message;
                private T data;

                public ApiResponse(boolean success, String message, T data) {
                        this.success = success;
                        this.message = message;
                        this.data = data;
                }

                public boolean isSuccess() {
                        return success;
                }

                public String getMessage() {
                        return message;
                }

                public T getData() {
                        return data;
                }
        }

        @RequestMapping(value = "/deep-analysis")
        public ApiResponse<Map<String, String>> deepAnalysis(@RequestParam String prompt) {
                log.info("收到AI文章生成请求 /deep-analysis，prompt={}", prompt);
                if (deepCache.containsKey(prompt)) {
                        String cached = deepCache.get(prompt);
                        if (cached != null && !cached.isEmpty()) {
                                log.info("命中deepCache缓存，直接返回");
                                Map<String, String> data = new HashMap<>();
                                data.put("content", cached);
                                return new ApiResponse<>(true, "ok", data);
                        } else {
                                log.info("命中缓存但内容为空，重新生成");
                        }
                }
                try {
                        long start = System.currentTimeMillis();
                        String content = chatClient.prompt()
                                        .system(deep_analysis_prompt + strongPrompt)
                                        .user("请以" + prompt + "为题写一篇文章，最终只返回文章，控制在1500字以内")
                                        .call()
                                        .content();
                        long cost = System.currentTimeMillis() - start;
                        log.info("AI生成内容长度: {}, 耗时: {}ms", content != null ? content.length() : 0, cost);
                        Map<String, String> data = new HashMap<>();
                        data.put("content", content);
                        if (content != null && !content.isEmpty()) {
                                deepCache.put(prompt, content);
                        }
                        return new ApiResponse<>(true, "ok", data);
                } catch (Exception e) {
                        log.error("AI生成文章失败 /deep-analysis，prompt={}", prompt, e);
                        return new ApiResponse<>(false, "AI生成失败: " + e.getMessage(), null);
                }
        }

        @RequestMapping(value = "/tech-enjoy")
        public ApiResponse<Map<String, String>> techEnjoy(@RequestParam String prompt) {
                log.info("收到AI文章生成请求 /tech-enjoy，prompt={}", prompt);
                if (techCache.containsKey(prompt)) {
                        String cached = techCache.get(prompt);
                        if (cached != null && !cached.isEmpty()) {
                                log.info("命中techCache缓存，直接返回:" + cached);
                                Map<String, String> data = new HashMap<>();
                                data.put("content", cached);
                                return new ApiResponse<>(true, "ok", data);
                        } else {
                                log.info("命中缓存但内容为空，重新生成");
                        }
                }
                try {
                        long start = System.currentTimeMillis();
                        String content = chatClient.prompt()
                                        .system(tech_enjoy_prompt + strongPrompt)
                                        .user("请以" + prompt + "为题写一篇文章，最终只返回文章，控制在1500字以内")
                                        .call()
                                        .content();
                        long cost = System.currentTimeMillis() - start;
                        log.info("AI生成内容长度: {}, 耗时: {}ms", content != null ? content.length() : 0, cost);
                        log.info(content);
                        Map<String, String> data = new HashMap<>();
                        data.put("content", content);
                        if (content != null && !content.isEmpty()) {
                                techCache.put(prompt, content);
                        }
                        return new ApiResponse<>(true, "ok", data);
                } catch (Exception e) {
                        log.error("AI生成文章失败 /tech-enjoy，prompt={}", prompt, e);
                        return new ApiResponse<>(false, "AI生成失败: " + e.getMessage(), null);
                }
        }

        @RequestMapping(value = "/industry-observation")
        public ApiResponse<Map<String, String>> industryObservation(@RequestParam String prompt) {
                log.info("收到AI文章生成请求 /industry-observation，prompt={}", prompt);
                if (industryCache.containsKey(prompt)) {
                        String cached = industryCache.get(prompt);
                        if (cached != null && !cached.isEmpty()) {
                                log.info("命中industryCache缓存，直接返回");
                                Map<String, String> data = new HashMap<>();
                                data.put("content", cached);
                                return new ApiResponse<>(true, "ok", data);
                        } else {
                                log.info("命中缓存但内容为空，重新生成");
                        }
                }
                try {
                        long start = System.currentTimeMillis();
                        String content = chatClient.prompt()
                                        .system(industry_observation_prompt + strongPrompt)
                                        .user("请以" + prompt + "为题写一篇文章，最终只返回文章，控制在1500字以内")
                                        .call()
                                        .content();
                        long cost = System.currentTimeMillis() - start;
                        log.info("AI生成内容长度: {}, 耗时: {}ms", content != null ? content.length() : 0, cost);
                        Map<String, String> data = new HashMap<>();
                        data.put("content", content);
                        if (content != null && !content.isEmpty()) {
                                industryCache.put(prompt, content);
                        }
                        return new ApiResponse<>(true, "ok", data);
                } catch (Exception e) {
                        log.error("AI生成文章失败 /industry-observation，prompt={}", prompt, e);
                        return new ApiResponse<>(false, "AI生成失败: " + e.getMessage(), null);
                }
        }

}
