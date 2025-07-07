package com.ai.companion.controller;

import com.ai.companion.entity.AiRole;
import com.ai.companion.service.RecommendationService;
import com.ai.companion.entity.vo.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 高级AI角色推荐控制器
 * 提供多种推荐算法的API接口
 */
@RestController
@RequestMapping("/recommendation")
public class RecommendationController {

    @Autowired
    private RecommendationService recommendationService;

    /**
     * 获取个性化推荐角色列表
     * @param userId 用户ID
     * @param limit 推荐数量限制（默认10）
     * @return 推荐角色列表
     */
    @GetMapping("/personalized")
    public ApiResponse<List<AiRole>> getPersonalizedRecommendations(
            @RequestParam Integer userId,
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<AiRole> recommendations = recommendationService.getPersonalizedRecommendations(userId, limit);
            return ApiResponse.success("个性化推荐获取成功", recommendations);
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error("个性化推荐获取失败: " + e.getMessage());
        }
    }

    /**
     * 获取基于内容的推荐角色列表
     * @param userId 用户ID
     * @param limit 推荐数量限制（默认10）
     * @return 推荐角色列表
     */
    @GetMapping("/content-based")
    public ApiResponse<List<AiRole>> getContentBasedRecommendations(
            @RequestParam Integer userId,
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<AiRole> recommendations = recommendationService.getContentBasedRecommendations(userId, limit);
            return ApiResponse.success("内容推荐获取成功", recommendations);
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error("内容推荐获取失败: " + e.getMessage());
        }
    }

    /**
     * 获取协同过滤推荐角色列表
     * @param userId 用户ID
     * @param limit 推荐数量限制（默认10）
     * @return 推荐角色列表
     */
    @GetMapping("/collaborative")
    public ApiResponse<List<AiRole>> getCollaborativeFilteringRecommendations(
            @RequestParam Integer userId,
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<AiRole> recommendations = recommendationService.getCollaborativeFilteringRecommendations(userId, limit);
            return ApiResponse.success("协同过滤推荐获取成功", recommendations);
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error("协同过滤推荐获取失败: " + e.getMessage());
        }
    }

    /**
     * 获取混合推荐结果（推荐使用此接口）
     * @param userId 用户ID
     * @param limit 推荐数量限制（默认10）
     * @return 推荐角色列表
     */
    @GetMapping("/hybrid")
    public ApiResponse<List<AiRole>> getHybridRecommendations(
            @RequestParam Integer userId,
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<AiRole> recommendations = recommendationService.getHybridRecommendations(userId, limit);
            return ApiResponse.success("混合推荐获取成功", recommendations);
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error("混合推荐获取失败: " + e.getMessage());
        }
    }

    /**
     * 记录用户行为数据
     * @param userId 用户ID
     * @param roleId 角色ID
     * @param actionType 行为类型（view, click, chat, like等）
     * @param score 行为评分（可选）
     */
    @PostMapping("/behavior")
    public ApiResponse<Void> recordUserBehavior(
            @RequestParam Integer userId,
            @RequestParam Integer roleId,
            @RequestParam String actionType,
            @RequestParam(defaultValue = "1.0") Double score) {
        try {
            recommendationService.recordUserBehavior(userId, roleId, actionType, score);
            return ApiResponse.success("用户行为记录成功", null);
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error("用户行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 获取推荐解释
     * @param userId 用户ID
     * @param roleIds 推荐的角色ID列表（逗号分隔）
     * @return 推荐解释
     */
    @GetMapping("/explanation")
    public ApiResponse<String> getRecommendationExplanation(
            @RequestParam Integer userId,
            @RequestParam String roleIds) {
        try {
            List<Integer> roleIdList = List.of(roleIds.split(","))
                    .stream()
                    .map(Integer::parseInt)
                    .toList();
            
            String explanation = recommendationService.getRecommendationExplanation(userId, roleIdList);
            return ApiResponse.success("推荐解释获取成功", explanation);
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error("推荐解释获取失败: " + e.getMessage());
        }
    }

    /**
     * 更新推荐模型（管理员接口）
     */
    @PostMapping("/update-model")
    public ApiResponse<Void> updateRecommendationModel() {
        try {
            recommendationService.updateRecommendationModel();
            return ApiResponse.success("推荐模型更新成功", null);
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error("推荐模型更新失败: " + e.getMessage());
        }
    }
} 