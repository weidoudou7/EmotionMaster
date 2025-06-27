package com.ai.companion.service.audio.impl;

import com.ai.companion.config.XunfeiConfig;
import com.ai.companion.service.audio.SpeechService;
import com.ai.companion.utils.XunfeiSignUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.Base64;

@Service
public class SpeechServiceImpl implements SpeechService {

    @Autowired
    private XunfeiConfig xunfeiConfig;

    @Override
    public String textToSpeech(String text, String voiceName) throws Exception {
        // 生成签名和授权信息
        String[] authInfo = XunfeiSignUtil.generateAuthInfo(
                xunfeiConfig.getApiKey(),
                xunfeiConfig.getApiSecret(),
                xunfeiConfig.getTtsUrl()
        );
        String date = authInfo[0];
        String authorization = authInfo[1];

        // 创建HTTP连接
        URL url = new URL(xunfeiConfig.getTtsUrl());
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Host", "tts-api.xfyun.cn");
        connection.setRequestProperty("Date", date);
        connection.setRequestProperty("Authorization", authorization);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setDoOutput(true);
        connection.setDoInput(true);

        // 构建请求体（使用Jackson替代FastJSON）
        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> requestBody = new HashMap<>();

        Map<String, Object> business = new HashMap<>();
        business.put("aue", "lame");  // 音频编码（lame=MP3）
        business.put("sfl", 1);       // 是否返回语音流式数据
        business.put("vcn", voiceName);  // 发音人
        business.put("pitch", 50);    // 音调
        business.put("speed", 50);    // 语速

        Map<String, Object> common = new HashMap<>();
        common.put("app_id", xunfeiConfig.getAppId());

        Map<String, Object> data = new HashMap<>();
        data.put("text", Base64.getEncoder().encodeToString(text.getBytes(StandardCharsets.UTF_8)));
        data.put("status", 2);  // 文本全部上传

        requestBody.put("business", business);
        requestBody.put("common", common);
        requestBody.put("data", data);

        // 发送请求
        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = mapper.writeValueAsBytes(requestBody);
            os.write(input, 0, input.length);
        }

        // 处理响应
        int responseCode = connection.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            // 生成唯一文件名
            String fileName = UUID.randomUUID() + ".mp3";
            String filePath = "src/main/resources/static/audio/" + fileName;

            // 创建目录（如果不存在）
            File directory = new File(filePath).getParentFile();
            if (!directory.exists()) {
                directory.mkdirs();
            }

            // 保存音频文件
            try (InputStream is = connection.getInputStream();
                 FileOutputStream fos = new FileOutputStream(filePath)) {

                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = is.read(buffer)) != -1) {
                    fos.write(buffer, 0, bytesRead);
                }
            }

            return "/audio/" + fileName;
        } else {
            // 读取错误信息
            try (BufferedReader br = new BufferedReader(
                    new InputStreamReader(connection.getErrorStream(), StandardCharsets.UTF_8))) {
                StringBuilder response = new StringBuilder();
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    response.append(responseLine.trim());
                }
                throw new IOException("API请求失败: " + responseCode + ", " + response.toString());
            }
        }
    }
}