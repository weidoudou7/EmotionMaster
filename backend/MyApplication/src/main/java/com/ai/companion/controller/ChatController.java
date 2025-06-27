package com.ai.companion.controller;

import com.ai.companion.config.AIIdentityConfig;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import jakarta.servlet.http.HttpServletResponse;

@RequiredArgsConstructor
@RestController
@RequestMapping("/ai")
public class ChatController {

    private final ChatClient chatClient;
    private final AIIdentityConfig aiIdentityConfig;

    /**
     * 默认聊天接口 - 情绪管理助手
     */
    @RequestMapping(value = "/chat", produces = "text/html;charset=utf-8")
    public Flux<String> chat(@RequestParam String prompt, @RequestParam String chatId) {
        return chatClient.prompt()
                .system(aiIdentityConfig.getSystemPrompt("default"))
                .user(prompt)
                .advisors(a -> a.param(ChatMemory.CONVERSATION_ID, chatId))
                .stream()
                .content();
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
            1. 描述要包含五官特征、动作，服饰，背景，性格等细节
            2. 语言要生动形象，富有画面感
            3. 适合用于AI绘画生成
            4. 长度控制在100-200字之间
            5. 如果用户输入为空或过于简单，请基于常见形象特征进行扩展
            
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
}
