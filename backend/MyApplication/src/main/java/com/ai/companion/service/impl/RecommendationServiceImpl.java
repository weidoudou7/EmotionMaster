package com.ai.companion.service.impl;

import com.ai.companion.entity.AiRole;
import com.ai.companion.entity.Conversation;
import com.ai.companion.entity.Message;
import com.ai.companion.entity.UserBehavior;
import com.ai.companion.mapper.AiRoleMapper;
import com.ai.companion.mapper.ConversationMapper;
import com.ai.companion.mapper.MessageMapper;
import com.ai.companion.mapper.UserBehaviorMapper;
import com.ai.companion.service.RecommendationService;
import com.ai.companion.service.UserBehaviorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * 高性能AI角色推荐服务实现类
 * 采用缓存驱动 + 轻量级算法 + 智能降级策略
 */
@Service
public class RecommendationServiceImpl implements RecommendationService {

    @Autowired
    private AiRoleMapper aiRoleMapper;

    @Autowired
    private ConversationMapper conversationMapper;

    @Autowired
    private MessageMapper messageMapper;

    @Autowired
    private UserBehaviorMapper userBehaviorMapper;

    @Autowired
    private UserBehaviorService userBehaviorService;

    // 内存缓存 - 提升性能
    private static final Map<String, List<AiRole>> RECOMMENDATION_CACHE = new ConcurrentHashMap<>();
    private static final Map<Integer, UserPreferenceVector> USER_PREFERENCE_CACHE = new ConcurrentHashMap<>();
    private static final List<AiRole> POPULAR_ROLES_CACHE = new ArrayList<>();
    
    // 缓存过期时间（毫秒）
    private static final long CACHE_EXPIRE_TIME = 5 * 60 * 1000; // 5分钟
    private static final long POPULAR_CACHE_EXPIRE_TIME = 30 * 60 * 1000; // 30分钟
    
    // 缓存时间戳
    private static final Map<String, Long> CACHE_TIMESTAMPS = new ConcurrentHashMap<>();
    
    // 用户行为权重配置
    private static final double CHAT_WEIGHT = 1.0;
    private static final double VIEW_WEIGHT = 0.3;
    private static final double CLICK_WEIGHT = 0.5;
    private static final double LIKE_WEIGHT = 0.8;

    @Override
    public List<AiRole> getPersonalizedRecommendations(Integer userId, int limit) {
        try {
            // 1. 检查缓存
            String cacheKey = "personalized_" + userId + "_" + limit;
            List<AiRole> cachedResult = getFromCache(cacheKey);
            if (cachedResult != null) {
                return cachedResult;
            }

            // 2. 获取用户偏好向量
            UserPreferenceVector userVector = getUserPreferenceVector(userId);
            
            if (userVector.isEmpty()) {
                // 新用户，返回热门角色
                List<AiRole> popularRoles = getPopularRoles(limit);
                putToCache(cacheKey, popularRoles);
                return popularRoles;
            }

            // 3. 快速计算推荐分数
            List<AiRole> allRoles = aiRoleMapper.selectAll();
            List<ScoredRole> scoredRoles = new ArrayList<>();

            for (AiRole role : allRoles) {
                double score = calculateFastPersonalizedScore(role, userVector);
                scoredRoles.add(new ScoredRole(role, score));
            }

            // 4. 排序并返回结果
            List<AiRole> result = scoredRoles.stream()
                    .sorted((a, b) -> Double.compare(b.score, a.score))
                    .limit(limit)
                    .map(scoredRole -> scoredRole.role)
                    .collect(Collectors.toList());

            // 5. 缓存结果
            putToCache(cacheKey, result);
            return result;

        } catch (Exception e) {
            e.printStackTrace();
            return getPopularRoles(limit);
        }
    }

    @Override
    public List<AiRole> getContentBasedRecommendations(Integer userId, int limit) {
        try {
            // 1. 检查缓存
            String cacheKey = "content_" + userId + "_" + limit;
            List<AiRole> cachedResult = getFromCache(cacheKey);
            if (cachedResult != null) {
                return cachedResult;
            }

            // 2. 获取用户偏好向量
            UserPreferenceVector userVector = getUserPreferenceVector(userId);
            
            if (userVector.isEmpty()) {
                List<AiRole> popularRoles = getPopularRoles(limit);
                putToCache(cacheKey, popularRoles);
                return popularRoles;
            }

            // 3. 快速内容相似度计算
            List<AiRole> allRoles = aiRoleMapper.selectAll();
            List<ScoredRole> scoredRoles = new ArrayList<>();

            for (AiRole role : allRoles) {
                double similarity = calculateFastContentSimilarity(role, userVector);
                scoredRoles.add(new ScoredRole(role, similarity));
            }

            // 4. 排序并返回结果
            List<AiRole> result = scoredRoles.stream()
                    .sorted((a, b) -> Double.compare(b.score, a.score))
                    .limit(limit)
                    .map(scoredRole -> scoredRole.role)
                    .collect(Collectors.toList());

            putToCache(cacheKey, result);
            return result;

        } catch (Exception e) {
            e.printStackTrace();
            return getPopularRoles(limit);
        }
    }

    @Override
    public List<AiRole> getCollaborativeFilteringRecommendations(Integer userId, int limit) {
        try {
            // 1. 检查缓存
            String cacheKey = "collaborative_" + userId + "_" + limit;
            List<AiRole> cachedResult = getFromCache(cacheKey);
            if (cachedResult != null) {
                return cachedResult;
            }

            // 2. 快速找到相似用户（限制数量）
            List<Integer> similarUsers = findSimilarUsersFast(userId, 20);
            
            if (similarUsers.isEmpty()) {
                List<AiRole> popularRoles = getPopularRoles(limit);
                putToCache(cacheKey, popularRoles);
                return popularRoles;
            }

            // 3. 计算角色推荐分数
            Map<Integer, Double> roleScores = new HashMap<>();
            
            for (Integer similarUserId : similarUsers) {
                // 获取相似用户的行为数据
                List<UserBehavior> behaviors = userBehaviorMapper.selectByUserId(similarUserId);
                for (UserBehavior behavior : behaviors) {
                    double weight = behavior.getScore();
                    switch (behavior.getActionType()) {
                        case "chat":
                            weight *= CHAT_WEIGHT;
                            break;
                        case "like":
                            weight *= LIKE_WEIGHT;
                            break;
                        case "click":
                            weight *= CLICK_WEIGHT;
                            break;
                        case "view":
                            weight *= VIEW_WEIGHT;
                            break;
                    }
                    roleScores.merge(behavior.getRoleId(), weight, Double::sum);
                }
            }

            // 4. 获取推荐角色
            List<AiRole> recommendedRoles = new ArrayList<>();
            List<Map.Entry<Integer, Double>> sortedScores = roleScores.entrySet().stream()
                    .sorted(Map.Entry.<Integer, Double>comparingByValue().reversed())
                    .limit(limit)
                    .collect(Collectors.toList());

            for (Map.Entry<Integer, Double> entry : sortedScores) {
                AiRole role = aiRoleMapper.selectById(entry.getKey());
                if (role != null) {
                    recommendedRoles.add(role);
                }
            }

            putToCache(cacheKey, recommendedRoles);
            return recommendedRoles;

        } catch (Exception e) {
            e.printStackTrace();
            return getPopularRoles(limit);
        }
    }

    @Override
    public List<AiRole> getHybridRecommendations(Integer userId, int limit) {
        try {
            // 1. 检查缓存
            String cacheKey = "hybrid_" + userId + "_" + limit;
            List<AiRole> cachedResult = getFromCache(cacheKey);
            if (cachedResult != null) {
                return cachedResult;
            }

            // 2. 并行获取各种推荐结果
            CompletableFuture<List<AiRole>> personalizedFuture = CompletableFuture.supplyAsync(() -> 
                getPersonalizedRecommendations(userId, limit));
            
            CompletableFuture<List<AiRole>> contentFuture = CompletableFuture.supplyAsync(() -> 
                getContentBasedRecommendations(userId, limit));
            
            CompletableFuture<List<AiRole>> collaborativeFuture = CompletableFuture.supplyAsync(() -> 
                getCollaborativeFilteringRecommendations(userId, limit));

            // 3. 等待所有结果
            List<AiRole> personalized = personalizedFuture.get();
            List<AiRole> contentBased = contentFuture.get();
            List<AiRole> collaborative = collaborativeFuture.get();

            // 4. 混合权重配置
            double personalizedWeight = 0.4;
            double contentWeight = 0.3;
            double collaborativeWeight = 0.3;

            // 5. 计算混合分数
            Map<Integer, Double> hybridScores = new HashMap<>();
            
            // 个性化推荐分数
            for (int i = 0; i < personalized.size(); i++) {
                AiRole role = personalized.get(i);
                double score = (personalized.size() - i) * personalizedWeight;
                hybridScores.merge(role.getId(), score, Double::sum);
            }
            
            // 内容推荐分数
            for (int i = 0; i < contentBased.size(); i++) {
                AiRole role = contentBased.get(i);
                double score = (contentBased.size() - i) * contentWeight;
                hybridScores.merge(role.getId(), score, Double::sum);
            }
            
            // 协同过滤推荐分数
            for (int i = 0; i < collaborative.size(); i++) {
                AiRole role = collaborative.get(i);
                double score = (collaborative.size() - i) * collaborativeWeight;
                hybridScores.merge(role.getId(), score, Double::sum);
            }

            // 6. 获取最终推荐结果
            List<AiRole> result = hybridScores.entrySet().stream()
                    .sorted(Map.Entry.<Integer, Double>comparingByValue().reversed())
                    .limit(limit)
                    .map(entry -> aiRoleMapper.selectById(entry.getKey()))
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());

            putToCache(cacheKey, result);
            return result;

        } catch (Exception e) {
            e.printStackTrace();
            return getPopularRoles(limit);
        }
    }

    @Override
    public void recordUserBehavior(Integer userId, Integer roleId, String actionType, Double score) {
        try {
            // 1. 保存行为数据
            userBehaviorService.recordUserBehavior(userId, roleId, actionType, score);
            
            // 2. 清除相关缓存
            clearUserCache(userId);
            
            // 3. 异步更新用户偏好向量
            CompletableFuture.runAsync(() -> {
                try {
                    updateUserPreferenceVector(userId);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public String getRecommendationExplanation(Integer userId, List<Integer> roleIds) {
        try {
            UserPreferenceVector userVector = getUserPreferenceVector(userId);
            
            if (userVector.isEmpty()) {
                return "基于热门角色为您推荐";
            }

            // 分析推荐原因
            StringBuilder explanation = new StringBuilder();
            
            if (userVector.getMostPreferredRoleType() != null) {
                explanation.append("根据您对").append(userVector.getMostPreferredRoleType())
                          .append("类型角色的偏好，");
            }
            
            if (userVector.getTotalChats() > 0) {
                explanation.append("结合您").append(userVector.getTotalChats()).append("次聊天记录，");
            }
            
            if (userVector.getTotalViews() > 0) {
                explanation.append("以及").append(userVector.getTotalViews()).append("次浏览行为，");
            }
            
            explanation.append("为您精选了这些角色。");
            
            return explanation.toString();
            
        } catch (Exception e) {
            e.printStackTrace();
            return "基于您的偏好为您推荐";
        }
    }

    @Override
    public void updateRecommendationModel() {
        try {
            // 异步更新推荐模型
            CompletableFuture.runAsync(() -> {
                try {
                    // 1. 更新热门角色缓存
                    updatePopularRolesCache();
                    
                    // 2. 清理过期缓存
                    cleanExpiredCache();
                    
                    System.out.println("推荐模型更新完成");
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ==================== 私有方法 ====================

    /**
     * 获取用户偏好向量（带缓存）
     */
    private UserPreferenceVector getUserPreferenceVector(Integer userId) {
        // 1. 检查缓存
        UserPreferenceVector cached = USER_PREFERENCE_CACHE.get(userId);
        if (cached != null) {
            return cached;
        }

        // 2. 计算用户偏好向量
        UserPreferenceVector vector = calculateUserPreferenceVector(userId);
        
        // 3. 缓存结果
        USER_PREFERENCE_CACHE.put(userId, vector);
        
        return vector;
    }

    /**
     * 计算用户偏好向量
     */
    private UserPreferenceVector calculateUserPreferenceVector(Integer userId) {
        UserPreferenceVector vector = new UserPreferenceVector();
        
        try {
            // 1. 获取用户对话
            List<Conversation> conversations = conversationMapper.selectByUserId(userId);
            vector.setTotalChats(conversations.size());
            
            // 2. 获取用户行为
            List<UserBehavior> behaviors = userBehaviorMapper.selectByUserId(userId);
            vector.setTotalViews((int) behaviors.stream().filter(b -> "view".equals(b.getActionType())).count());
            vector.setTotalClicks((int) behaviors.stream().filter(b -> "click".equals(b.getActionType())).count());
            vector.setTotalLikes((int) behaviors.stream().filter(b -> "like".equals(b.getActionType())).count());
            
            // 3. 分析角色类型偏好
            Map<String, Integer> roleTypeCount = new HashMap<>();
            for (Conversation conv : conversations) {
                AiRole role = aiRoleMapper.selectById(conv.getAiRoleId());
                if (role != null && role.getRoleType() != null) {
                    roleTypeCount.merge(role.getRoleType(), 1, Integer::sum);
                }
            }
            
            if (!roleTypeCount.isEmpty()) {
                String mostPreferred = roleTypeCount.entrySet().stream()
                        .max(Map.Entry.comparingByValue())
                        .map(Map.Entry::getKey)
                        .orElse(null);
                vector.setMostPreferredRoleType(mostPreferred);
                vector.setRoleTypePreferences(roleTypeCount);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return vector;
    }

    /**
     * 快速计算个性化推荐分数
     */
    private double calculateFastPersonalizedScore(AiRole role, UserPreferenceVector userVector) {
        double score = 0.0;
        
        // 1. 角色类型匹配分数
        if (userVector.getMostPreferredRoleType() != null && 
            userVector.getMostPreferredRoleType().equals(role.getRoleType())) {
            score += 2.0;
        }
        
        // 2. 用户活跃度分数
        score += userVector.getTotalChats() * 0.1;
        score += userVector.getTotalViews() * 0.05;
        score += userVector.getTotalLikes() * 0.08;
        
        // 3. 角色热度分数
        score += role.getViewCount() * 0.001;
        
        return score;
    }

    /**
     * 快速计算内容相似度
     */
    private double calculateFastContentSimilarity(AiRole role, UserPreferenceVector userVector) {
        double similarity = 0.0;
        
        // 1. 角色类型相似度
        if (userVector.getRoleTypePreferences() != null) {
            Integer typeCount = userVector.getRoleTypePreferences().get(role.getRoleType());
            if (typeCount != null) {
                similarity += typeCount * 0.5;
            }
        }
        
        // 2. 描述关键词匹配（简化版）
        if (role.getRoleDescription() != null && userVector.getMostPreferredRoleType() != null) {
            if (role.getRoleDescription().contains(userVector.getMostPreferredRoleType())) {
                similarity += 0.3;
            }
        }
        
        return similarity;
    }

    /**
     * 快速找到相似用户
     */
    private List<Integer> findSimilarUsersFast(Integer userId, int limit) {
        try {
            // 1. 获取当前用户的行为数据
            List<UserBehavior> userBehaviors = userBehaviorMapper.selectByUserId(userId);
            Set<Integer> userRoleIds = userBehaviors.stream()
                    .map(UserBehavior::getRoleId)
                    .collect(Collectors.toSet());
            
            if (userRoleIds.isEmpty()) {
                return new ArrayList<>();
            }
            
            // 2. 找到有相似行为的用户
            List<UserBehavior> allBehaviors = userBehaviorMapper.selectAll();
            Map<Integer, Set<Integer>> userRoleMap = new HashMap<>();
            
            for (UserBehavior behavior : allBehaviors) {
                if (!behavior.getUserId().equals(userId)) {
                    userRoleMap.computeIfAbsent(behavior.getUserId(), k -> new HashSet<>())
                              .add(behavior.getRoleId());
                }
            }
            
            // 3. 计算相似度并排序
            List<Map.Entry<Integer, Double>> similarities = new ArrayList<>();
            for (Map.Entry<Integer, Set<Integer>> entry : userRoleMap.entrySet()) {
                Set<Integer> otherRoleIds = entry.getValue();
                double similarity = calculateJaccardSimilarity(userRoleIds, otherRoleIds);
                similarities.add(new AbstractMap.SimpleEntry<>(entry.getKey(), similarity));
            }
            
            // 4. 返回最相似的用户
            return similarities.stream()
                    .sorted(Map.Entry.<Integer, Double>comparingByValue().reversed())
                    .limit(limit)
                    .map(Map.Entry::getKey)
                    .collect(Collectors.toList());
                    
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    /**
     * 计算Jaccard相似度
     */
    private double calculateJaccardSimilarity(Set<Integer> set1, Set<Integer> set2) {
        if (set1.isEmpty() && set2.isEmpty()) {
            return 1.0;
        }
        
        Set<Integer> intersection = new HashSet<>(set1);
        intersection.retainAll(set2);
        
        Set<Integer> union = new HashSet<>(set1);
        union.addAll(set2);
        
        return union.isEmpty() ? 0.0 : (double) intersection.size() / union.size();
    }

    /**
     * 获取热门角色（带缓存）
     */
    private List<AiRole> getPopularRoles(int limit) {
        // 1. 检查缓存
        if (!POPULAR_ROLES_CACHE.isEmpty()) {
            return POPULAR_ROLES_CACHE.stream().limit(limit).collect(Collectors.toList());
        }
        
        // 2. 从数据库获取
        try {
            List<AiRole> popularRoles = aiRoleMapper.selectAll().stream()
                    .sorted((a, b) -> Integer.compare(b.getViewCount(), a.getViewCount()))
                    .limit(limit)
                    .collect(Collectors.toList());
            
            // 3. 更新缓存
            POPULAR_ROLES_CACHE.clear();
            POPULAR_ROLES_CACHE.addAll(popularRoles);
            
            return popularRoles;
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // ==================== 缓存管理 ====================

    private List<AiRole> getFromCache(String key) {
        Long timestamp = CACHE_TIMESTAMPS.get(key);
        if (timestamp != null && System.currentTimeMillis() - timestamp < CACHE_EXPIRE_TIME) {
            return RECOMMENDATION_CACHE.get(key);
        }
        return null;
    }

    private void putToCache(String key, List<AiRole> data) {
        RECOMMENDATION_CACHE.put(key, data);
        CACHE_TIMESTAMPS.put(key, System.currentTimeMillis());
    }

    private void clearUserCache(Integer userId) {
        List<String> keysToRemove = RECOMMENDATION_CACHE.keySet().stream()
                .filter(key -> key.contains("_" + userId + "_"))
                .collect(Collectors.toList());
        
        for (String key : keysToRemove) {
            RECOMMENDATION_CACHE.remove(key);
            CACHE_TIMESTAMPS.remove(key);
        }
        
        USER_PREFERENCE_CACHE.remove(userId);
    }

    private void updateUserPreferenceVector(Integer userId) {
        UserPreferenceVector newVector = calculateUserPreferenceVector(userId);
        USER_PREFERENCE_CACHE.put(userId, newVector);
    }

    private void updatePopularRolesCache() {
        POPULAR_ROLES_CACHE.clear();
        List<AiRole> popularRoles = aiRoleMapper.selectAll().stream()
                .sorted((a, b) -> Integer.compare(b.getViewCount(), a.getViewCount()))
                .limit(50)
                .collect(Collectors.toList());
        POPULAR_ROLES_CACHE.addAll(popularRoles);
    }

    private void cleanExpiredCache() {
        long currentTime = System.currentTimeMillis();
        List<String> expiredKeys = CACHE_TIMESTAMPS.entrySet().stream()
                .filter(entry -> currentTime - entry.getValue() > CACHE_EXPIRE_TIME)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
        
        for (String key : expiredKeys) {
            RECOMMENDATION_CACHE.remove(key);
            CACHE_TIMESTAMPS.remove(key);
        }
    }

    // ==================== 内部类 ====================

    private static class ScoredRole {
        AiRole role;
        double score;

        ScoredRole(AiRole role, double score) {
            this.role = role;
            this.score = score;
        }
    }

    /**
     * 用户偏好向量
     */
    private static class UserPreferenceVector {
        private int totalChats = 0;
        private int totalViews = 0;
        private int totalClicks = 0;
        private int totalLikes = 0;
        private String mostPreferredRoleType = null;
        private Map<String, Integer> roleTypePreferences = new HashMap<>();

        public boolean isEmpty() {
            return totalChats == 0 && totalViews == 0 && totalClicks == 0 && totalLikes == 0;
        }

        // Getters and Setters
        public int getTotalChats() { return totalChats; }
        public void setTotalChats(int totalChats) { this.totalChats = totalChats; }
        
        public int getTotalViews() { return totalViews; }
        public void setTotalViews(int totalViews) { this.totalViews = totalViews; }
        
        public int getTotalClicks() { return totalClicks; }
        public void setTotalClicks(int totalClicks) { this.totalClicks = totalClicks; }
        
        public int getTotalLikes() { return totalLikes; }
        public void setTotalLikes(int totalLikes) { this.totalLikes = totalLikes; }
        
        public String getMostPreferredRoleType() { return mostPreferredRoleType; }
        public void setMostPreferredRoleType(String mostPreferredRoleType) { this.mostPreferredRoleType = mostPreferredRoleType; }
        
        public Map<String, Integer> getRoleTypePreferences() { return roleTypePreferences; }
        public void setRoleTypePreferences(Map<String, Integer> roleTypePreferences) { this.roleTypePreferences = roleTypePreferences; }
    }
} 