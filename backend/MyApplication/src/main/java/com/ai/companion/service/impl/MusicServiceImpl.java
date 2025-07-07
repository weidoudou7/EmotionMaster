package com.ai.companion.service.impl;

import com.ai.companion.service.MusicService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MusicServiceImpl implements MusicService {

    private static final Logger log = LoggerFactory.getLogger(MusicServiceImpl.class);

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

    @Override
    public com.ai.companion.entity.vo.MusicDetailVO getMusicDetail(String musicId) {
        String apiUrl = "https://v3.alapi.cn/api/music/detail";
        log.info("Requesting music detail from ALAPI for musicId: {}", musicId);
        log.info("ALAPI token used: {}", alapiToken);
        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.setContentType(org.springframework.http.MediaType.APPLICATION_JSON);
        java.util.Map<String, String> body = new java.util.HashMap<>();
        body.put("token", alapiToken);
        body.put("id", musicId);
        log.info("ALAPI music detail API request body: {}", body);
        org.springframework.http.HttpEntity<java.util.Map<String, String>> request = new org.springframework.http.HttpEntity<>(body, headers);
        org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate();
        org.springframework.http.ResponseEntity<String> response = restTemplate.postForEntity(apiUrl, request, String.class);
        
        log.info("ALAPI music detail API response status: {}", response.getStatusCode());
        log.info("ALAPI music detail API raw response body: {}", response.getBody());

        try {
            com.fasterxml.jackson.databind.JsonNode root = objectMapper.readTree(response.getBody());
            if (root.path("success").asBoolean() && root.path("data").has("songs")) {
                com.fasterxml.jackson.databind.JsonNode songsNode = root.path("data").path("songs");
                if (!songsNode.isArray() || songsNode.size() == 0) {
                    log.warn("ALAPI music detail API returned empty or invalid songs array for musicId: {}", musicId);
                    throw new RuntimeException("获取歌曲详情失败: songs数据为空或格式不正确");
                }
                com.fasterxml.jackson.databind.JsonNode song = songsNode.get(0);
                String name = song.path("name").asText("");
                String artist = song.path("ar").isArray() && song.path("ar").size() > 0 ? song.path("ar").get(0).path("name").asText("") : "";
                int durationMs = song.path("dt").asInt(0);
                String duration = formatDuration(durationMs);
                String coverUrl = song.path("al").path("picUrl").asText("");
                com.ai.companion.entity.vo.MusicDetailVO vo = new com.ai.companion.entity.vo.MusicDetailVO();
                vo.setName(name);
                vo.setArtist(artist);
                vo.setDuration(duration);
                vo.setCoverUrl(coverUrl);
                return vo;
            } else {
                log.error("ALAPI music detail API returned unsuccessful response or missing data for musicId: {}. Raw response: {}", musicId, response.getBody());
                throw new RuntimeException("获取歌曲详情失败: " + root.path("message").asText());
            }
        } catch (Exception e) {
            log.error("Error parsing ALAPI music detail response or processing data for musicId: {}. Error: {}", musicId, e.getMessage(), e);
            throw new RuntimeException("解析alapi返回数据失败: " + e.getMessage());
        }
    }

    // 工具方法：毫秒转 mm:ss
    private String formatDuration(int ms) {
        int totalSeconds = ms / 1000;
        int minutes = totalSeconds / 60;
        int seconds = totalSeconds % 60;
        return String.format("%02d:%02d", minutes, seconds);
    }
} 