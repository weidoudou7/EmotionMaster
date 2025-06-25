package com.ai.companion.controller;

import com.ai.companion.entity.vo.MessageVO;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.messages.Message;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping(value="ai/history")
public class ChatHistoryController {

    private ChatMemory chatMemory;

    /**
     *
     * @param type 传入AI对话类型
     * @return 返回对话ID列表
     */
    @GetMapping(value = "{type}")
    public List<String> getChatId(@PathVariable("type") String type) {

        return List.of();
    }

    /**
     *
     * @param type 传入AI对话类型
     * @param chatId 传入AI对话ID
     * @return 返回消息（角色+内容）列表
     */
    @GetMapping(value = "{type}/{chatId}")
    public List<MessageVO> getHistory(@PathVariable("type") String type, @PathVariable("chatId") String chatId) {
        List<Message> history = chatMemory.get(chatId+"_"+type);
        if(history == null) {
            return List.of();
        }
        return history.stream().map(m->new MessageVO(m)).toList();
    }
}
