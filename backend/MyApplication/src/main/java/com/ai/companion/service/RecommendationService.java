package com.ai.companion.service;

import com.ai.companion.entity.AiRole;
// 暂时注释掉未创建的DTO类
// import com.ai.companion.dto.RecommendationRequest;
// import com.ai.companion.dto.RecommendationResponse;

import java.util.List;

/**
 * 高级AI角色推荐服务接口
 * 实现多维度协同过滤推荐算法
 */
public interface RecommendationService {

    /**
     * 获取个性化推荐角色列表
     * @param userId 用户ID
     * @param limit 推荐数量限制
     * @return 推荐角色列表
     */
    List<AiRole> getPersonalizedRecommendations(Integer userId, int limit);

    /**
     * 获取基于内容的推荐角色列表
     * @param userId 用户ID
     * @param limit 推荐数量限制
     * @return 推荐角色列表
     */
    List<AiRole> getContentBasedRecommendations(Integer userId, int limit);

    /**
     * 获取协同过滤推荐角色列表
     * @param userId 用户ID
     * @param limit 推荐数量限制
     * @return 推荐角色列表
     */
    List<AiRole> getCollaborativeFilteringRecommendations(Integer userId, int limit);

    /**
     * 获取混合推荐结果（综合多种算法）
     * @param userId 用户ID
     * @param limit 推荐数量限制
     * @return 推荐角色列表
     */
    List<AiRole> getHybridRecommendations(Integer userId, int limit);

    /**
     * 记录用户行为数据（用于推荐算法学习）
     * @param userId 用户ID
     * @param roleId 角色ID
     * @param actionType 行为类型（view, click, chat, like等）
     * @param score 行为评分
     */
    void recordUserBehavior(Integer userId, Integer roleId, String actionType, Double score);

    /**
     * 获取推荐解释（为什么推荐这些角色）
     * @param userId 用户ID
     * @param roleIds 推荐的角色ID列表
     * @return 推荐解释
     */
    String getRecommendationExplanation(Integer userId, List<Integer> roleIds);

    /**
     * 更新推荐模型（定期重新训练）
     */
    void updateRecommendationModel();
} 