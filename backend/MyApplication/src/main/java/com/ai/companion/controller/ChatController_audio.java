package com.ai.companion.controller;

import com.ai.companion.service.audio.SpeechService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@RestController
@RequestMapping("/api/chat")
public class ChatController_audio {

    @Autowired
    private SpeechService speechService;

    // 原有文本聊天接口
    @PostMapping("/text")
    public String chat(@RequestBody String message) {
        // 处理文本聊天逻辑
        String aiResponse = "AI回复内容...";
        return aiResponse;
    }

    // 语音合成接口
    @GetMapping("/speech")
    public String textToSpeech(@RequestParam String text,
                               @RequestParam(defaultValue = "xiaoyan") String voiceName) throws Exception {
        return speechService.textToSpeech(text, voiceName);
    }
}
