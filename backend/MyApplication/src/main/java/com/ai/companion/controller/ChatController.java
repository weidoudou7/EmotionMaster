package com.ai.companion.controller;

import com.ai.companion.config.AIIdentityConfig;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;

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
     * 获取所有可用的AI身份列表
     */
    @GetMapping("/identities")
    public String[] getAvailableIdentities() {
        return aiIdentityConfig.getAvailableIdentities();
    }
}
