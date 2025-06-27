package com.ai.companion.service.audio;

import java.io.IOException;

public interface SpeechService {
    /**
     * 将文本转换为语音并返回音频文件路径
     */
    String textToSpeech(String text, String voiceName) throws Exception;
}