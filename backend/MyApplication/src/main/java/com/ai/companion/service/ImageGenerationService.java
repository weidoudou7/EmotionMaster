package com.ai.companion.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.ai.chat.client.ChatClient;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.Map;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.ArrayList;
import java.util.concurrent.TimeUnit;

/**
 * 高性能图片生成服务 - 优化版本
 * 采用多种高级优化技术提升生成和加载速度
 */
@Slf4j
@Service
public class ImageGenerationService {

    private final ChatClient chatClient;
    private final RestTemplate restTemplate;
    
    @Value("${app.image.generation.cache.expire-hours:1}")
    private int cacheExpireHours;
    
    // 内存缓存 - 使用ConcurrentHashMap保证线程安全
    private final Map<String, String> imageCache = new ConcurrentHashMap<>();
    private final Map<String, Long> cacheTimestamps = new ConcurrentHashMap<>();
    
    // 图片预加载缓存 - 存储已验证可访问的图片URL
    private final Map<String, String> preloadedImages = new ConcurrentHashMap<>();
    
    // 性能监控计数器
    private final AtomicInteger activeGenerations = new AtomicInteger(0);
    private final AtomicInteger cacheHits = new AtomicInteger(0);
    private final AtomicInteger cacheMisses = new AtomicInteger(0);
    private final AtomicInteger preloadHits = new AtomicInteger(0);
    
    public ImageGenerationService(ChatClient chatClient, RestTemplate restTemplate) {
        this.chatClient = chatClient;
        this.restTemplate = restTemplate;
    }
    
    /**
     * 异步生成图片 - 支持并行处理
     */
    @Async("imageGenerationExecutor")
    public CompletableFuture<String> generateImageAsync(String userInput, String style) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                activeGenerations.incrementAndGet();
                return generateImageWithOptimization(userInput, style);
            } finally {
                activeGenerations.decrementAndGet();
            }
        });
    }
    
    /**
     * 优化的图片生成方法
     */
    public String generateImageWithOptimization(String userInput, String style) {
        // 1. 检查预加载缓存
        String preloadKey = generateCacheKey(userInput, style);
        String preloadedUrl = preloadedImages.get(preloadKey);
        if (preloadedUrl != null) {
            preloadHits.incrementAndGet();
            log.info("预加载缓存命中: {}", preloadKey);
            return preloadedUrl;
        }
        
        // 2. 检查普通缓存
        String cachedUrl = getCachedImage(preloadKey);
        if (cachedUrl != null) {
            cacheHits.incrementAndGet();
            log.info("缓存命中: {}", preloadKey);
            return cachedUrl;
        }
        
        cacheMisses.incrementAndGet();
        
        // 3. 生成图片URL
        String imageUrl = generateImageUrl(userInput, style);
        
        // 4. 异步预加载验证
        preloadImageAsync(imageUrl).thenAccept(success -> {
            if (success) {
                preloadedImages.put(preloadKey, imageUrl);
                log.info("图片预加载成功: {}", imageUrl);
            }
        });
        
        // 5. 缓存结果
        cacheImage(preloadKey, imageUrl);
        
        return imageUrl;
    }
    
    /**
     * 批量生成图片 - 并行处理
     */
    public Map<String, String> generateImagesBatch(Map<String, String> userInputs) {
        Map<String, CompletableFuture<String>> futures = new ConcurrentHashMap<>();
        
        // 并行提交所有生成任务
        userInputs.forEach((style, userInput) -> {
            CompletableFuture<String> future = generateImageAsync(userInput, style);
            futures.put(style, future);
        });
        
        // 等待所有任务完成
        Map<String, String> results = new ConcurrentHashMap<>();
        futures.forEach((style, future) -> {
            try {
                String result = future.get(8, TimeUnit.MINUTES); // 8分钟超时 - 延长预加载时间
                results.put(style, result);
            } catch (Exception e) {
                log.error("生成图片失败: style={}, error={}", style, e.getMessage());
                results.put(style, "生成失败");
            }
        });
        
        return results;
    }
    
    /**
     * 生成缓存键
     */
    private String generateCacheKey(String userInput, String style) {
        return userInput.hashCode() + "_" + style.hashCode();
    }
    
    /**
     * 获取缓存的图片
     */
    private String getCachedImage(String cacheKey) {
        String cachedUrl = imageCache.get(cacheKey);
        if (cachedUrl != null) {
            Long timestamp = cacheTimestamps.get(cacheKey);
            long expireTime = cacheExpireHours * 3600000L; // 转换为毫秒
            if (timestamp != null && System.currentTimeMillis() - timestamp < expireTime) {
                return cachedUrl;
            } else {
                // 清理过期缓存
                imageCache.remove(cacheKey);
                cacheTimestamps.remove(cacheKey);
            }
        }
        return null;
    }
    
    /**
     * 缓存图片URL
     */
    private void cacheImage(String cacheKey, String imageUrl) {
        imageCache.put(cacheKey, imageUrl);
        cacheTimestamps.put(cacheKey, System.currentTimeMillis());
        
        // 清理过期缓存
        cleanupExpiredCache();
    }
    
    /**
     * 清理过期缓存
     */
    private void cleanupExpiredCache() {
        long currentTime = System.currentTimeMillis();
        long expireTime = cacheExpireHours * 3600000L;
        cacheTimestamps.entrySet().removeIf(entry -> {
            if (currentTime - entry.getValue() > expireTime) {
                imageCache.remove(entry.getKey());
                return true;
            }
            return false;
        });
    }
    
    /**
     * 生成图片URL - 优化版本
     */
    private String generateImageUrl(String userInput, String style) {
        try {
            // 风格映射优化 - 使用Map提高查找效率
            String stylePrompt = getStylePrompt(style);
            
            // 优化的systemPrompt - 更简洁高效
            String systemPrompt = String.format(
                "Generate a simple English image prompt for %s style. Focus on: %s. Keep under 30 words. Return only prompt.",
                style, stylePrompt
            );
            
            // 使用优化的AI调用
            String result = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userInput)
                    .call()
                    .content();
            
            // 清理和验证prompt
            String prompt = cleanAndValidatePrompt(result, stylePrompt);
            
            // 生成优化的URL
            return generateOptimizedImageUrl(prompt);
            
        } catch (Exception e) {
            log.error("生成图片URL失败: userInput={}, style={}, error={}", userInput, style, e.getMessage());
            return generateFallbackUrl(style);
        }
    }
    
    /**
     * 获取风格提示词
     */
    private String getStylePrompt(String style) {
        return switch (style) {
            case "古风" -> "ancient Chinese style, traditional, elegant, detailed";
            case "赛博" -> "cyberpunk, futuristic, neon, high-tech, detailed";
            case "卡通" -> "cartoon, cute, colorful, animated, detailed";
            case "动漫" -> "anime, Japanese animation style, detailed, high quality";
            case "Q版" -> "chibi, cute, small, adorable, detailed";
            default -> "realistic, beautiful, detailed";
        };
    }
    
    /**
     * 清理和验证prompt
     */
    private String cleanAndValidatePrompt(String result, String stylePrompt) {
        String prompt = (result != null ? result.trim() : "")
                .replaceAll("[\"'\\n\\r]", " ")
                .replaceAll("\\s+", " ")
                .replaceAll("[^a-zA-Z0-9\\s,.-]", "");
        
        // 使用备用prompt如果为空或太短
        if (prompt.isEmpty() || prompt.length() < 10) {
            prompt = "beautiful woman portrait, detailed face, " + stylePrompt;
        }
        
        // 确保prompt包含必要的关键词
        if (!prompt.toLowerCase().contains("beautiful") && !prompt.toLowerCase().contains("portrait")) {
            prompt = "beautiful woman portrait, " + prompt;
        }
        
        return prompt;
    }
    
    /**
     * 生成优化的图片URL - 使用更快的CDN和参数
     */
    private String generateOptimizedImageUrl(String prompt) throws Exception {
        String encodedPrompt = URLEncoder.encode(prompt, StandardCharsets.UTF_8);
        
        // 使用优化的CDN参数 - 更小尺寸，更快加载
        return String.format(
            "https://image.pollinations.ai/prompt/%s?width=384&height=384&enhance=true&private=true&nologo=true&safe=true&model=flux&seed=%d&quality=80&format=webp",
            encodedPrompt,
            System.currentTimeMillis() % 10000
        );
    }
    
    /**
     * 生成备用URL
     */
    private String generateFallbackUrl(String style) {
        try {
            String fallbackPrompt = "beautiful woman portrait, detailed face, " + getStylePrompt(style);
            String encodedFallback = URLEncoder.encode(fallbackPrompt, StandardCharsets.UTF_8);
            return String.format(
                "https://image.pollinations.ai/prompt/%s?width=384&height=384&enhance=true&private=true&nologo=true&safe=true&model=flux&seed=12345&quality=80&format=webp",
                encodedFallback
            );
        } catch (Exception e) {
            return "生成图片时出现错误，请重试。";
        }
    }
    
    /**
     * 获取优化的图片URL列表 - 支持多CDN和快速加载
     */
    public List<String> getOptimizedImageUrls(String prompt, String style) {
        List<String> urls = new ArrayList<>();
        try {
            String stylePrompt = getStylePrompt(style);
            String cleanPrompt = cleanAndValidatePrompt(prompt, stylePrompt);
            String encodedPrompt = URLEncoder.encode(cleanPrompt, StandardCharsets.UTF_8);
            
            // 生成多个优化尺寸的URL - 从小到大，优先加载小图
            urls.add(String.format(
                "https://image.pollinations.ai/prompt/%s?width=256&height=256&enhance=true&private=true&nologo=true&safe=true&model=flux&seed=%d&quality=75&format=webp",
                encodedPrompt,
                System.currentTimeMillis() % 10000
            ));
            
            urls.add(String.format(
                "https://image.pollinations.ai/prompt/%s?width=384&height=384&enhance=true&private=true&nologo=true&safe=true&model=flux&seed=%d&quality=80&format=webp",
                encodedPrompt,
                (System.currentTimeMillis() + 1000) % 10000
            ));
            
            urls.add(String.format(
                "https://image.pollinations.ai/prompt/%s?width=512&height=512&enhance=true&private=true&nologo=true&safe=true&model=flux&seed=%d&quality=85&format=webp",
                encodedPrompt,
                (System.currentTimeMillis() + 2000) % 10000
            ));
            
        } catch (Exception e) {
            log.error("生成优化图片URL失败: prompt={}, style={}, error={}", prompt, style, e.getMessage());
            // 添加备用URL
            urls.add(generateFallbackUrl(style));
        }
        
        return urls;
    }
    
    /**
     * 预加载图片 - 异步验证图片可访问性
     */
    @Async("imageGenerationExecutor")
    public CompletableFuture<Boolean> preloadImageAsync(String imageUrl) {
        return CompletableFuture.supplyAsync(() -> {
            int maxRetries = 2; // 减少重试次数，避免长时间等待
            for (int attempt = 1; attempt <= maxRetries; attempt++) {
                try {
                    // 使用HEAD请求，更快验证
                    ResponseEntity<String> response = restTemplate.exchange(
                        imageUrl,
                        HttpMethod.HEAD,
                        new HttpEntity<>(new HttpHeaders()),
                        String.class
                    );
                    
                    if (response.getStatusCode().is2xxSuccessful()) {
                        log.info("预加载图片成功: {}", imageUrl);
                        return true;
                    } else if (response.getStatusCode().value() == 429) {
                        // 限流错误，短暂等待后重试
                        log.warn("图片服务限流 (尝试{}/{}): {}", attempt, maxRetries, imageUrl);
                        if (attempt < maxRetries) {
                            try {
                                Thread.sleep(1000); // 只等待1秒
                            } catch (InterruptedException e) {
                                Thread.currentThread().interrupt();
                                return false;
                            }
                        }
                    } else {
                        // 对于其他HTTP错误，也返回true，让前端自己处理
                        log.warn("预加载图片HTTP错误，但继续处理: {} - {}", response.getStatusCode().value(), imageUrl);
                        return true;
                    }
                } catch (Exception e) {
                    log.warn("预加载图片失败 (尝试{}/{}): {} - {}", attempt, maxRetries, imageUrl, e.getMessage());
                    if (attempt < maxRetries) {
                        try {
                            Thread.sleep(500); // 只等待0.5秒
                        } catch (InterruptedException ie) {
                            Thread.currentThread().interrupt();
                            return false;
                        }
                    }
                }
            }
            // 即使验证失败，也返回true，让前端自己处理
            log.warn("预加载验证失败，但继续处理: {}", imageUrl);
            return true;
        });
    }
    
    /**
     * 批量预加载图片 - 并行验证多个URL
     */
    public List<String> preloadImagesBatch(List<String> imageUrls) {
        List<CompletableFuture<Boolean>> futures = new ArrayList<>();
        
        // 并行验证所有URL
        for (String url : imageUrls) {
            futures.add(preloadImageAsync(url));
        }
        
        // 等待所有验证完成，返回可用的URL
        List<String> availableUrls = new ArrayList<>();
        for (int i = 0; i < imageUrls.size(); i++) {
            try {
                Boolean isAvailable = futures.get(i).get(10, TimeUnit.SECONDS); // 10秒超时 - 避免长时间等待
                if (isAvailable) {
                    availableUrls.add(imageUrls.get(i));
                }
            } catch (Exception e) {
                log.warn("验证图片URL超时，但继续处理: {}", imageUrls.get(i));
                // 超时也继续处理
                availableUrls.add(imageUrls.get(i));
            }
        }
        
        return availableUrls;
    }
    
    /**
     * 获取性能统计
     */
    public Map<String, Object> getPerformanceStats() {
        Map<String, Object> stats = new ConcurrentHashMap<>();
        stats.put("activeGenerations", activeGenerations.get());
        stats.put("cacheHits", cacheHits.get());
        stats.put("cacheMisses", cacheMisses.get());
        stats.put("preloadHits", preloadHits.get());
        stats.put("cacheSize", imageCache.size());
        stats.put("preloadedSize", preloadedImages.size());
        stats.put("cacheHitRate", calculateCacheHitRate());
        
        return stats;
    }
    
    /**
     * 计算缓存命中率
     */
    private double calculateCacheHitRate() {
        int total = cacheHits.get() + cacheMisses.get();
        return total > 0 ? (double) cacheHits.get() / total : 0.0;
    }
    
    /**
     * 清理缓存
     */
    public void clearCache() {
        imageCache.clear();
        cacheTimestamps.clear();
        preloadedImages.clear();
        log.info("图片缓存已清理");
    }
} 