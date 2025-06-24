package com.ai.companion.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping(value="ai/history")
public class ChatHistoryController {

    /**
     *
     * @param type 传入AI对话类型
     * @return 返回对话ID列表
     */
    @GetMapping(value = "{type}")
    public List<String> getChatId(@PathVariable("type") String type) {

        return List.of();
    }

}
