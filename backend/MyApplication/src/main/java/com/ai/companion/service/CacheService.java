package com.ai.companion.service;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.concurrent.ConcurrentHashMap;

@Service
public class CacheService {
    
    private final ConcurrentHashMap<String, String> descriptionCache = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, String> promptCache = new ConcurrentHashMap<>();
    
    /**
     * 缓存描述生成结果
     */
    @Cacheable(value = "ai-descriptions", key = "#userInput")
    public String getCachedDescription(String userInput) {
        return descriptionCache.get(userInput);
    }
    
    public void cacheDescription(String userInput, String description) {
        descriptionCache.put(userInput, description);
    }
    
    /**
     * 缓存图片prompt生成结果
     */
    @Cacheable(value = "ai-prompts", key = "#userInput + '_' + #style")
    public String getCachedPrompt(String userInput, String style) {
        return promptCache.get(userInput + "_" + style);
    }
    
    public void cachePrompt(String userInput, String style, String prompt) {
        promptCache.put(userInput + "_" + style, prompt);
    }
    
    /**
     * 检查是否有缓存的描述
     */
    public boolean hasCachedDescription(String userInput) {
        return descriptionCache.containsKey(userInput);
    }
    
    /**
     * 检查是否有缓存的prompt
     */
    public boolean hasCachedPrompt(String userInput, String style) {
        return promptCache.containsKey(userInput + "_" + style);
    }
} 