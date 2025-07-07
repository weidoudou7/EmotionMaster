package com.ai.companion.controller;

import com.ai.companion.config.AIIdentityConfig;
import com.ai.companion.entity.Conversation;
import com.ai.companion.entity.Message;
import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.mapper.AiRoleMapper;
import com.ai.companion.service.ChatRecordService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.SimpleLoggerAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@RestController
@RequestMapping("/ai")
public class ChatController {

    private final ChatClient chatClient;
    private final AIIdentityConfig aiIdentityConfig;
    private final ChatRecordService chatRecordService;
    private final AiRoleMapper aiRoleMapper;

    /**
     * 默认聊天接口 - 情绪管理助手
     * @param prompt 用户输入内容
     * @param chatId 会话Id
     * @param UserId 用户Id
     * @return  AI流式回复
     */


    /**
     * 生成形象描述接口
     */
    @PostMapping("/generate-description")
    @ResponseBody
    public String generateDescription(@RequestParam String userInput) {
        // 快速验证输入
        if (userInput == null || userInput.trim().isEmpty()) {
            return "请输入描述内容";
        }
        
        String systemPrompt = "你是一个ai角色形象描述词生成机器人。每次生成时都要结合输入内容，发挥想象力，丰富联想，尽量避免与历史输出重复。要求严格按照【身份】【性格】【外貌】【特点】的形式给出返回描述词，30字以内，不要添加任何额外说明或格式。";
        String userPrompt = "基于关键词生成形象描述（请生成与以往不同的描述）：" + userInput.trim();
        
        try {
            String result = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userPrompt)
                    .advisors(a -> a.param(ChatMemory.CONVERSATION_ID, "AIDescription"))
                    .advisors(new SimpleLoggerAdvisor())
                    .call()
                    .content();
            
            return (result != null && !result.trim().isEmpty()) ? result.trim() : "生成描述失败，请重试。";
        } catch (Exception e) {
            return "生成描述时出现错误，请重试。";
        }
    }

    /**
     *
     * @param userInput 用户输入描述词
     * @param style 预定义风格
     * @return 返回图片url
     */
    @RequestMapping(value = "/generate-figure")
    public String generateFigure(@RequestParam String userInput, @RequestParam String style) {
        // 快速验证输入
        if (userInput == null || userInput.trim().isEmpty()) {
            return "请输入描述内容";
        }
        
        // 风格映射 - 使用Map优化查找
        String stylePrompt = switch (style) {
            case "古风" -> "ancient Chinese style, traditional, elegant, detailed";
            case "赛博" -> "cyberpunk, futuristic, neon, high-tech, detailed";
            case "卡通" -> "cartoon, cute, colorful, animated, detailed";
            case "动漫" -> "anime, Japanese animation style, detailed, high quality";
            case "Q版" -> "chibi, cute, small, adorable, detailed";
            default -> "realistic, beautiful, detailed";
        };

        // 优化systemPrompt，生成更稳定的prompt
        String systemPrompt = "Generate a simple, clear English image prompt for " + style + " style. " +
                             "Focus on:  detailed features, " + stylePrompt + ". " +
                             "Keep it under 50 words. Return only the prompt, no quotes.";

        try {
            String result = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userInput)
                    .advisors(new SimpleLoggerAdvisor())
                    .call()
                    .content();

            // 清理和验证prompt
            String prompt = (result != null ? result.trim() : "")
                    .replaceAll("[\"'\\n\\r]", " ")
                    .replaceAll("\\s+", " ")
                    .replaceAll("[^a-zA-Z0-9\\s,.-]", ""); // 只保留安全的字符
            
            // 使用备用prompt如果为空或太短
            if (prompt.isEmpty() || prompt.length() < 10) {
                prompt = "beautiful woman portrait, detailed face, " + stylePrompt;
            }

            // 确保prompt包含必要的关键词
            if (!prompt.toLowerCase().contains("beautiful") && !prompt.toLowerCase().contains("portrait")) {
                prompt = "beautiful woman portrait, " + prompt;
            }

            // 生成URL，使用更稳定的参数
            String encodedPrompt = java.net.URLEncoder.encode(prompt, "UTF-8");
            return "https://image.pollinations.ai/prompt/" + encodedPrompt + 
                   "?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux&seed=12345";
        } catch (Exception e) {
            // 快速fallback
            try {
                String fallbackPrompt = "beautiful woman portrait, detailed face, " + stylePrompt;
                String encodedFallback = java.net.URLEncoder.encode(fallbackPrompt, "UTF-8");
                return "https://image.pollinations.ai/prompt/" + encodedFallback + 
                       "?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux&seed=12345";
            } catch (Exception fallbackError) {
                return "生成图片时出现错误，请重试。";
            }
        }
    }


        /**
     * 获取所有可用的AI身份列表
     */
    @GetMapping("/identities")
    public String[] getAvailableIdentities() {
        return aiIdentityConfig.getAvailableIdentities();
    }


//与ai聊天
    @RequestMapping(value="/featured_chat", produces = "text/html;charset=utf-8")
    public String getFeatured_chat(@RequestParam String desc, @RequestParam String prompt, @RequestParam String chatId, @RequestParam(required = false) Integer userId){
        try {
            // 1.参数验证
            if (desc == null || desc.trim().isEmpty()) {
                return "角色描述不能为空";
            }
            if (prompt == null || prompt.trim().isEmpty()) {
                return "用户输入不能为空";
            }
            if (chatId == null || chatId.trim().isEmpty()) {
                return "会话ID不能为空";
            }
            
            // 2.如果userId为null，使用默认值
            Integer defaultUserId = userId != null ? userId : 405;
            
            // 3.获取或创建对话
            Conversation conversation = chatRecordService.getOrCreateConversation(defaultUserId, chatId, null, null);

            // 计算情感分值
            String emotionResponse = getEmotionJson(prompt);
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonNode = objectMapper.readTree(emotionResponse);

            Double score = Double.parseDouble(jsonNode.get("score").asText()) ;
            String sentiment = jsonNode.get("sentiment").asText();

            // 4.保存用户消息到数据库
            chatRecordService.saveMessage(conversation.getId(), "user", prompt, null, (byte)(score*10), null);

            // 情感增强提示词
            String emotionPrompt = "该条消息用户的情绪分数为(-10到10，-10是最消极的，10是最积极的):"+score*10+"\n"
                    +"该条消息用户的情绪为(可能值为:POSITIVE、WEAK_POSITIVE、NEGATIVE、WEAK_NEGATIVE、NEUTRAL)"+sentiment+"\n"
                    +"请根据以上信息，并结合自己的身份，对用户进行合理的回应";

            // 5.生成AI回复
            String aiResponse = chatClient.prompt()
                    .system(desc)
                    .user(u->u.text("提示: {emotionPrompt}"+"\n"
                            +" Context: {context} ")
                            .params(Map.of("emotionPrompt",emotionPrompt,"context",prompt))
                    )
                    .advisors(a -> a.param(ChatMemory.CONVERSATION_ID, chatId))
                    .advisors(new SimpleLoggerAdvisor())
                    .call()
                    .content();

            // 6.保存AI回复到数据库
            chatRecordService.saveMessage(conversation.getId(), "ai", aiResponse, null, (byte)0, null);

            return aiResponse;
        } catch (Exception e) {
            return "聊天过程中出现错误: " + e.getMessage();
        }
    }

    /**
     * 保存消息到数据库
     * 对应前端apiservice中的saveMessage方法
     */
    @PostMapping("/message/save")
    public ApiResponse<Message> saveMessage(@RequestBody Message message) {
        try {
            // 参数验证
            if (message.getConversationId() == null) {
                return ApiResponse.error("会话ID不能为空");
            }
            if (message.getSenderType() == null || message.getSenderType().trim().isEmpty()) {
                return ApiResponse.error("发送者类型不能为空");
            }
            if (message.getContent() == null || message.getContent().trim().isEmpty()) {
                return ApiResponse.error("消息内容不能为空");
            }

            // 保存消息
            Message savedMessage = chatRecordService.saveMessage(
                message.getConversationId(),
                message.getSenderType(),
                message.getContent(),
                message.getAudioUrl(),
                message.getSentimentScore(),
                message.getTopicTag()
            );
            
            return ApiResponse.success("消息保存成功", savedMessage);
        } catch (Exception e) {
            return ApiResponse.error("保存消息失败: " + e.getMessage());
        }
    }

    /**
     * 根据会话ID获取消息列表
     * 对应前端apiservice中的getMessagesByConversationId方法
     */
    @GetMapping("/message/list")
    public ApiResponse<List<Message>> getMessagesByConversationId(@RequestParam Integer conversationId) {
        try {
            // 参数验证
            if (conversationId == null) {
                return ApiResponse.error("会话ID不能为空");
            }

            // 获取消息列表
            List<Message> messages = chatRecordService.getMessagesByConversationId(conversationId);
            return ApiResponse.success("获取消息列表成功", messages);
        } catch (Exception e) {
            return ApiResponse.error("获取消息列表失败: " + e.getMessage());
        }
    }

    /**
     * 分析对话情绪并更新conversation的情绪标签
     * POST /ai/analyze-emotion
     */
    @PostMapping("/analyze-emotion")
    public ApiResponse<String> analyzeConversationEmotion(@RequestParam Integer conversationId) {
        try {
            // 参数验证
            if (conversationId == null) {
                return ApiResponse.error("会话ID不能为空");
            }

            // 1. 获取对话中的所有消息
            List<Message> messages = chatRecordService.getMessagesByConversationId(conversationId);
            if (messages == null || messages.isEmpty()) {
                return ApiResponse.error("未找到该会话的消息记录");
            }

            // 2. 提取用户消息内容
            StringBuilder userMessages = new StringBuilder();
            for (Message message : messages) {
                if ("user".equals(message.getSenderType()) && message.getContent() != null) {
                    userMessages.append(message.getContent()).append("\n");
                }
            }

            if (userMessages.length() == 0) {
                return ApiResponse.error("该会话中没有用户消息");
            }

            // 3. 构建情绪分析提示词
            String systemPrompt = "你是一个专业的情绪分析专家。请分析以下用户对话内容，判断用户的主要情绪状态。" +
                    "请从以下情绪标签中选择最合适的一个：\n" +
                    "- happy (开心)\n" +
                    "- sad (悲伤)\n" +
                    "- angry (愤怒)\n" +
                    "- anxious (焦虑)\n" +
                    "- excited (兴奋)\n" +
                    "- calm (平静)\n" +
                    "- confused (困惑)\n" +
                    "- neutral (中性)\n" +
                    "请只返回情绪标签的英文名称，不要包含任何其他内容。";

            String userPrompt = "请分析以下用户对话的情绪：\n" + userMessages.toString();

            // 4. 调用AI进行情绪分析
            String emotionResult = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userPrompt)
                    .advisors(new SimpleLoggerAdvisor())
                    .call()
                    .content();

            // 5. 清理和验证情绪标签
            String emotionTag = emotionResult != null ? emotionResult.trim().toLowerCase() : "neutral";
            
            // 验证情绪标签是否有效
            String[] validEmotions = {"happy", "sad", "angry", "anxious", "excited", "calm", "confused", "neutral"};
            boolean isValidEmotion = false;
            for (String valid : validEmotions) {
                if (emotionTag.contains(valid)) {
                    emotionTag = valid;
                    isValidEmotion = true;
                    break;
                }
            }
            
            if (!isValidEmotion) {
                emotionTag = "neutral"; // 默认使用中性情绪
            }

            // 6. 更新conversation的情绪标签
            // 这里需要调用ConversationMapper来更新mood_tag字段
            // 由于ChatController中没有直接注入ConversationMapper，我们需要通过ChatRecordService来实现
            boolean updateSuccess = chatRecordService.updateConversationMoodTag(conversationId, emotionTag);
            
            if (updateSuccess) {
                return ApiResponse.success("情绪分析完成，情绪标签已更新为: " + emotionTag, emotionTag);
            } else {
                return ApiResponse.error("情绪分析完成，但更新情绪标签失败");
            }

        } catch (Exception e) {
            return ApiResponse.error("情绪分析失败: " + e.getMessage());
        }
    }

    /**
     * 根据对话内容和情绪标签生成回复建议
     * POST /ai/generate-replies
     */
    @PostMapping("/generate-replies")
    public ApiResponse<List<String>> generateReplySuggestions(@RequestParam Integer conversationId) {
        try {
            // 参数验证
            if (conversationId == null) {
                return ApiResponse.error("会话ID不能为空");
            }

            // 1. 获取对话中的所有消息
            List<Message> messages = chatRecordService.getMessagesByConversationId(conversationId);
            if (messages == null || messages.isEmpty()) {
                return ApiResponse.error("未找到该会话的消息记录");
            }

            // 2. 获取conversation的情绪标签
            Conversation conversation = chatRecordService.getOrCreateConversation(null, conversationId.toString(), null, null);
            String moodTag = conversation != null ? conversation.getMoodTag() : "neutral";
            if (moodTag == null || moodTag.trim().isEmpty()) {
                moodTag = "neutral";
            }

            // 3. 提取最近的对话上下文（包括AI回复，更好地理解对话主题）
            StringBuilder conversationContext = new StringBuilder();
            int messageCount = 0;
            // 取最近6条消息（3轮对话）
            for (int i = messages.size() - 1; i >= 0 && messageCount < 6; i--) {
                Message message = messages.get(i);
                if (message.getContent() != null) {
                    String sender = "user".equals(message.getSenderType()) ? "用户" : "AI";
                    conversationContext.insert(0, sender + ": " + message.getContent() + "\n");
                    messageCount++;
                }
            }

            if (conversationContext.length() == 0) {
                return ApiResponse.error("该会话中没有消息记录");
            }

            // 4. 构建用户视角的回复生成提示词
            String systemPrompt = "你是一个专业的聊天助手。根据对话内容和用户的情绪状态，为用户生成3个合适的回复建议。" +
                    "重要：这些回复是用户要发送给AI的，不是AI给用户的回复。\n" +
                    "生成要求：\n" +
                    "1. 每个回复15-25个字\n" +
                    "2. 回复要符合用户的情绪状态和对话主题\n" +
                    "3. 回复要自然、符合用户表达习惯\n" +
                    "4. 考虑对话的上下文，生成用户可能想说的话\n" +
                    "5. 避免过于正式或生硬的表达\n" +
                    "6. 返回格式：每行一个回复，不要编号\n" +
                    "7. 不要添加任何额外说明";

            String userPrompt = String.format("用户当前情绪：%s\n\n最近对话内容：\n%s\n\n请为用户生成3个合适的回复建议（用户要发送给AI的话）：", 
                    getEmotionDescription(moodTag), conversationContext.toString());

            // 5. 调用AI生成回复建议
            String replyResult = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userPrompt)
                    .advisors(new SimpleLoggerAdvisor())
                    .call()
                    .content();

            // 6. 解析回复结果
            List<String> replies = new ArrayList<>();
            if (replyResult != null && !replyResult.trim().isEmpty()) {
                String[] lines = replyResult.trim().split("\n");
                for (String line : lines) {
                    String reply = line.trim();
                    if (!reply.isEmpty() && replies.size() < 3) {
                        // 清理回复内容，移除可能的编号或多余字符
                        reply = reply.replaceAll("^[0-9]+[.、]\\s*", ""); // 移除开头的编号
                        reply = reply.replaceAll("^[-*]\\s*", ""); // 移除开头的符号
                        reply = reply.trim();
                        
                        if (!reply.isEmpty()) {
                            // 限制回复长度
                            if (reply.length() > 25) {
                                reply = reply.substring(0, 25);
                            }
                            replies.add(reply);
                        }
                    }
                }
            }

            // 7. 如果AI生成的回复不足3个，补充智能默认回复
            while (replies.size() < 3) {
                replies.add(getSmartDefaultReply(moodTag, conversationContext.toString()));
            }

            return ApiResponse.success("回复建议生成成功", replies);

        } catch (Exception e) {
            return ApiResponse.error("生成回复建议失败: " + e.getMessage());
        }
    }

    /**
     * 获取情绪描述
     */
    private String getEmotionDescription(String moodTag) {
        return switch (moodTag.toLowerCase()) {
            case "happy" -> "开心";
            case "sad" -> "悲伤";
            case "angry" -> "愤怒";
            case "anxious" -> "焦虑";
            case "excited" -> "兴奋";
            case "calm" -> "平静";
            case "confused" -> "困惑";
            default -> "中性";
        };
    }

    /**
     * 获取默认回复（AI给用户的回复）
     */
    private String getDefaultReply(String moodTag) {
        return switch (moodTag.toLowerCase()) {
            case "happy" -> "我也为你感到开心！";
            case "sad" -> "我理解你的感受，需要聊聊吗？";
            case "angry" -> "冷静一下，深呼吸。";
            case "anxious" -> "别担心，一切都会好起来的。";
            case "excited" -> "你的兴奋感染了我！";
            case "calm" -> "保持这份平静很好。";
            case "confused" -> "让我帮你理清思路。";
            default -> "我在这里陪着你。";
        };
    }

    /**
     * 获取用户默认回复（用户给AI的回复）
     */
    private String getUserDefaultReply(String moodTag) {
        return switch (moodTag.toLowerCase()) {
            case "happy" -> "我今天心情不错";
            case "sad" -> "我最近心情不太好";
            case "angry" -> "有些事情让我很生气";
            case "anxious" -> "我最近有些焦虑";
            case "excited" -> "我最近很兴奋";
            case "calm" -> "我最近心情比较平静";
            case "confused" -> "我有些困惑";
            default -> "想和你聊聊";
        };
    }

    /**
     * 获取智能默认回复（基于对话上下文）- 用户视角
     */
    private String getSmartDefaultReply(String moodTag, String conversationContext) {
        // 分析对话上下文，提取关键词
        String context = conversationContext.toLowerCase();
        
        // 根据对话主题和情绪生成用户可能想说的话
        if (context.contains("工作") || context.contains("加班") || context.contains("压力")) {
            return switch (moodTag.toLowerCase()) {
                case "sad", "anxious" -> "我最近工作压力真的很大";
                case "angry" -> "工作上的事情让我很烦";
                case "happy" -> "今天工作很顺利，心情不错";
                default -> "工作确实很累，想找人聊聊";
            };
        } else if (context.contains("学习") || context.contains("考试") || context.contains("作业")) {
            return switch (moodTag.toLowerCase()) {
                case "sad", "anxious" -> "学习压力好大，不知道怎么办";
                case "confused" -> "这道题我不会做，好困惑";
                case "happy" -> "今天学习很有收获，很开心";
                default -> "学习上遇到了一些困难";
            };
        } else if (context.contains("朋友") || context.contains("关系") || context.contains("感情")) {
            return switch (moodTag.toLowerCase()) {
                case "sad" -> "和朋友之间有些小矛盾";
                case "happy" -> "今天和朋友聊得很开心";
                case "angry" -> "朋友的做法让我很生气";
                default -> "想聊聊朋友之间的事情";
            };
        } else if (context.contains("天气") || context.contains("下雨") || context.contains("阳光")) {
            return switch (moodTag.toLowerCase()) {
                case "sad" -> "今天天气不好，心情也受影响";
                case "happy" -> "今天天气真好，心情不错";
                case "calm" -> "天气不错，感觉很放松";
                default -> "天气变化影响心情";
            };
        } else {
            // 如果没有特定主题，使用情绪相关的通用回复
            return getUserDefaultReply(moodTag);
        }
    }

    /**
     *
     * @param text 传入需要分析的内容
     * @return json格式情感分析内容
     */
    @RequestMapping(value = "/sentiment")
    String getEmotionJson(String text) {

        String engText = chatClient.prompt()
                .user("请帮我把下面的话转换为英文，要求只返回英文，内容："+text)
                .call()
                .content();

        String apiUrl = "https://api.api-ninjas.com/v1/sentiment?text=" + engText;
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Api-Key", "GH+Oa9ATa1BFNzluARTOGA==4brA6BivryQoRvJg");
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<String> response = restTemplate.exchange(
                apiUrl,
                HttpMethod.GET,
                entity,
                String.class
        );

        if (response.getStatusCode() == HttpStatus.OK) {
            return response.getBody();
        } else {
            return "Error: " + response.getStatusCode() + " " + response.getBody();
        }

    }

}
