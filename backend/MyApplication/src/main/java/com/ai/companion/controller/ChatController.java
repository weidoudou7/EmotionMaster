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
     * 获取所有可用的AI身份列表
     */
    @GetMapping("/identities")
    public String[] getAvailableIdentities() {
        return aiIdentityConfig.getAvailableIdentities();
    }
}
