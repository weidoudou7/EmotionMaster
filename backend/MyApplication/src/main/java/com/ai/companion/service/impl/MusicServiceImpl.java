package com.ai.companion.service.impl;

import com.ai.companion.service.MusicService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MusicServiceImpl implements MusicService {

    @Value("${alapi.music.token}")
    private String alapiToken;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String getMusicPlayUrl(String musicId) {
        String apiUrl = "https://v3.alapi.cn/api/music/url"
                + "?token=" + alapiToken
                + "&id=" + musicId;
        RestTemplate restTemplate = new RestTemplate();
        String response = restTemplate.getForObject(apiUrl, String.class);

        try {
            JsonNode root = objectMapper.readTree(response);
            if (root.path("success").asBoolean() && root.path("data").has("url")) {
                String url = root.path("data").path("url").asText();
                if (url == null || url.equals("null") || url.isEmpty()) {
                    throw new RuntimeException("该歌曲无播放权限或无版权");
                }
                return url;
            } else {
                throw new RuntimeException("获取播放链接失败: " + root.path("message").asText());
            }
        } catch (Exception e) {
            throw new RuntimeException("解析alapi返回数据失败: " + e.getMessage());
        }
    }
} 