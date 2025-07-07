package com.ai.companion.service;

import com.ai.companion.entity.UserBehavior;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 用户行为服务接口
 * 定义用户行为相关的业务逻辑
 */
public interface UserBehaviorService {

    /**
     * 记录用户行为
     * @param userId 用户ID
     * @param roleId 角色ID
     * @param actionType 行为类型
     * @param score 行为评分
     * @return 是否记录成功
     */
    boolean recordUserBehavior(Integer userId, Integer roleId, String actionType, Double score);

    /**
     * 记录用户查看角色行为
     * @param userId 用户ID
     * @param roleId 角色ID
     * @return 是否记录成功
     */
    boolean recordViewAction(Integer userId, Integer roleId);

    /**
     * 记录用户点击角色行为
     * @param userId 用户ID
     * @param roleId 角色ID
     * @return 是否记录成功
     */
    boolean recordClickAction(Integer userId, Integer roleId);

    /**
     * 记录用户聊天行为
     * @param userId 用户ID
     * @param roleId 角色ID
     * @return 是否记录成功
     */
    boolean recordChatAction(Integer userId, Integer roleId);

    /**
     * 记录用户点赞行为
     * @param userId 用户ID
     * @param roleId 角色ID
     * @return 是否记录成功
     */
    boolean recordLikeAction(Integer userId, Integer roleId);

    /**
     * 记录用户分享行为
     * @param userId 用户ID
     * @param roleId 角色ID
     * @return 是否记录成功
     */
    boolean recordShareAction(Integer userId, Integer roleId);

    /**
     * 获取用户行为记录
     * @param userId 用户ID
     * @return 用户行为记录列表
     */
    List<UserBehavior> getUserBehaviors(Integer userId);

    /**
     * 获取角色行为记录
     * @param roleId 角色ID
     * @return 角色行为记录列表
     */
    List<UserBehavior> getRoleBehaviors(Integer roleId);

    /**
     * 获取用户对特定角色的行为记录
     * @param userId 用户ID
     * @param roleId 角色ID
     * @return 用户行为记录列表
     */
    List<UserBehavior> getUserRoleBehaviors(Integer userId, Integer roleId);

    /**
     * 获取热门角色列表
     * @param limit 限制数量
     * @return 热门角色数据
     */
    List<Map<String, Object>> getPopularRoles(Integer limit);

    /**
     * 获取活跃用户列表
     * @param limit 限制数量
     * @return 活跃用户数据
     */
    List<Map<String, Object>> getActiveUsers(Integer limit);

    /**
     * 获取用户行为分析数据
     * @param userId 用户ID
     * @return 行为分析数据
     */
    Map<String, Object> getUserBehaviorAnalysis(Integer userId);

    /**
     * 获取角色受欢迎度分析
     * @param roleId 角色ID
     * @return 受欢迎度分析数据
     */
    Map<String, Object> getRolePopularityAnalysis(Integer roleId);

    /**
     * 获取用户相似度数据（用于协同过滤）
     * @param userId 用户ID
     * @return 相似用户数据
     */
    List<Map<String, Object>> getUserSimilarityData(Integer userId);

    /**
     * 删除用户行为记录
     * @param id 记录ID
     * @return 是否删除成功
     */
    boolean deleteUserBehavior(Integer id);

    /**
     * 删除用户的所有行为记录
     * @param userId 用户ID
     * @return 是否删除成功
     */
    boolean deleteUserBehaviors(Integer userId);

    /**
     * 删除角色的所有行为记录
     * @param roleId 角色ID
     * @return 是否删除成功
     */
    boolean deleteRoleBehaviors(Integer roleId);

    /**
     * 获取用户行为统计
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 行为统计数据
     */
    Map<String, Object> getUserBehaviorStats(Integer userId, LocalDateTime startTime, LocalDateTime endTime);
} 