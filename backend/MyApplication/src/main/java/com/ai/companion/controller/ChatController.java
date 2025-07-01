package com.ai.companion.controller;

import com.ai.companion.config.AIIdentityConfig;
import com.ai.companion.entity.Conversation;
import com.ai.companion.entity.Message;
import com.ai.companion.mapper.AiRoleMapper;
import com.ai.companion.service.ChatRecordService;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import jakarta.servlet.http.HttpServletResponse;

import java.util.List;

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
    @RequestMapping(value = "/chat", produces = "text/html;charset=utf-8")
    public Flux<String> chat(@RequestParam String prompt, @RequestParam String chatId/*,@RequestParam Integer UserId*/) {

//        // 1.获取ai角色,待修改
//        Integer aiRoleId = 1;
//
//        //2.获取或创建对话
//        Conversation conversation = chatRecordService.getOrCreateConversation(UserId,aiRoleId,chatId,null,null);
//
//        //3.保存用户信息
//        chatRecordService.saveMessage(conversation.getId(),"user", prompt,null,null,null);
//
//        //4.加载历史信息到ChatMemory
//        List<Message> history = chatRecordService.getMessagesByConversationId(conversation.getId());
//        ChatMemory chatMemory = MessageWindowChatMemory.builder().build();
//        for(Message message : history) {
//            if("user".equals(message.getSenderType())){
//                chatMemory.add(String.valueOf(conversation.getId()),new UserMessage(message.getContent()));
//            }else if("ai".equals(message.getSenderType())){
//                chatMemory.add(String.valueOf(conversation.getId()),new AssistantMessage(message.getContent()));
//            }
//        }

        Flux<String> aiResponse = chatClient.prompt()
                .system(aiIdentityConfig.getSystemPrompt("default"))
                .user(prompt)
                .advisors(a -> a.param(ChatMemory.CONVERSATION_ID, chatId))
                .stream()
                .content();

        return aiResponse;
//        return aiResponse.doOnNext(aiMsg -> {
//            chatRecordService.saveMessage(conversation.getId(), "ai", aiMsg, null, null, null);
//        });
    }

    /**
     * 通用身份聊天接口 - 支持动态身份切换
     */
    @RequestMapping(value = "/chat/{identity}", produces = "text/html;charset=utf-8")
    public Flux<String> dynamicChat(
            @PathVariable String identity,
            @RequestParam String prompt,
            @RequestParam String chatId) {

        // 检查身份是否存在
        if (!aiIdentityConfig.hasIdentity(identity)) {
            // 如果身份不存在，返回错误信息
            return Flux.just("错误：不支持的身份类型 '" + identity + "'。请使用以下身份之一：" +
                    String.join(", ", aiIdentityConfig.getAvailableIdentities()));
        }

        return chatClient.prompt()
                .system(aiIdentityConfig.getSystemPrompt(identity))
                .user(prompt)
                .advisors(a -> a.param(ChatMemory.CONVERSATION_ID, chatId + "_" + identity))
                .stream()
                .content();
    }

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
        
        String systemPrompt = "你是一个ai角色形象描述词生成机器人。要求严格按照【身份】【性格】【外貌】【特点】的形式给出返回描述词，并且在30字以内，不要添加任何额外的说明或格式。";
        String userPrompt = "基于关键词生成形象描述：" + userInput.trim();
        
        try {
            String result = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userPrompt)
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

    @RequestMapping(value="/featured_chat", produces = "text/html;charset=utf-8")
    public Flux<String> getFeatured_chat(@RequestParam String desc,@RequestParam String prompt,@RequestParam String chatId){
        return chatClient.prompt()
                .system(desc)
                .user(prompt)
                .advisors(a -> a.param(ChatMemory.CONVERSATION_ID, chatId))
                .stream()
                .content();
    }
}
