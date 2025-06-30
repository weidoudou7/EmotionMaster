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
        String systemPrompt = """
            你是一个专业的形象描述生成助手。根据用户提供的简单描述或关键词，生成详细、生动、富有创意的形象描述。
            
            要求：

            [身份]：职业/物种+社会属性（例：未来AI伦理顾问）
            [时代]：存在时期与地点（例：2150年新东京）
            [性格]：主导特质+禁忌（例："理性克制，拒绝情感绑架"）
            [认知]：思维模式+知识盲区（例："依赖数据推演，不懂人类艺术"）
            [技能]：核心能力+限制（例："可预测犯罪概率但无法干预现实"）
            [交互]：沟通风格+社交规则（例："使用专业术语，回避隐私话题"）
            [背景]：关键经历（例："曾因算法错误导致工厂事故"）
            [当前]：即时目标与困境（例："追查黑客组织'深蓝'线索"）
            
            请直接返回生成的描述文本，不要添加任何额外的说明或格式。
            """;
        
        String userPrompt = userInput.trim().isEmpty() ? 
            "请生成一个通用的、美观的人物形象描述" : 
            "请基于以下关键词生成详细的形象描述：" + userInput;
        
        try {
            String result = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userPrompt)
                    .call()
                    .content();
            
            // 确保返回的内容不为空
            if (result == null || result.trim().isEmpty()) {
                return "生成描述失败，请稍后重试。";
            }
            
            return result.trim();
        } catch (Exception e) {
            System.err.println("生成描述时出现错误: " + e.getMessage());
            e.printStackTrace();
            return "生成描述时出现错误，请稍后重试。";
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
        // 根据风格定制系统提示
        String stylePrompt = "";
        switch (style) {
            case "古风":
                stylePrompt = "ancient Chinese style, traditional, elegant";
                break;
            case "赛博":
                stylePrompt = "cyberpunk, futuristic, neon, high-tech";
                break;
            case "卡通":
                stylePrompt = "cartoon, cute, colorful, animated";
                break;
            case "动漫":
                stylePrompt = "anime, Japanese animation style, detailed";
                break;
            case "Q版":
                stylePrompt = "chibi, cute, small, adorable";
                break;
            default:
                stylePrompt = "realistic, beautiful";
        }

        // 优化systemPrompt，强调用户输入和细节
        String systemPrompt = "You are an AI image generation assistant. Based on the user's description, generate a creative, detailed, and visually rich English prompt for an image in the " + style + " style. Focus on the unique features described by the user, including face, hair, clothing, pose, and expression. Style keywords: " + stylePrompt + ". Return only the English prompt, no extra text.";

        try {
            String result = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userInput)
                    .call()
                    .content();

            // 日志打印AI原始返回内容
            System.out.println("AI原始返回: " + result);

            // 清理返回的prompt
            String prompt = result == null ? "" : result.trim();
            // 日志打印最终prompt
            System.out.println("最终用于图片生成的prompt: " + prompt);

            // 移除可能的引号、换行符和多余字符
            prompt = prompt.replace("\"", "").replace("'", "").replace("\n", " ").replace("\r", " ").trim();
            prompt = prompt.replaceAll("\\s+", " ");

            // 只在prompt为空时fallback
            if (prompt.isEmpty()) {
                prompt = "beautiful woman portrait, " + stylePrompt;
                System.out.println("使用备用prompt: " + prompt);
            }

            // URL编码prompt
            String encodedPrompt = java.net.URLEncoder.encode(prompt, "UTF-8");
            String imageUrl = "https://image.pollinations.ai/prompt/" + encodedPrompt + 
                             "?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux";
            System.out.println("生成的图片URL: " + imageUrl);
            return imageUrl;
        } catch (Exception e) {
            System.err.println("生成图片时出现错误: " + e.getMessage());
            e.printStackTrace();
            // 返回备用URL
            try {
                String fallbackPrompt = "beautiful woman portrait, " + stylePrompt;
                String encodedFallback = java.net.URLEncoder.encode(fallbackPrompt, "UTF-8");
                String fallbackUrl = "https://image.pollinations.ai/prompt/" + encodedFallback + 
                                   "?width=1024&height=1024&enhance=true&private=true&nologo=true&safe=true&model=flux";
                System.out.println("使用备用图片URL: " + fallbackUrl);
                return fallbackUrl;
            } catch (Exception fallbackError) {
                System.err.println("生成备用URL时出现错误: " + fallbackError.getMessage());
                return "生成图片时出现错误，请稍后重试。";
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
