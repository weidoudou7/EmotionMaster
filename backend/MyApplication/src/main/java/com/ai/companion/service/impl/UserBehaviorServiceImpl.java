package com.ai.companion.service.impl;

import com.ai.companion.entity.UserBehavior;
import com.ai.companion.mapper.UserBehaviorMapper;
import com.ai.companion.service.UserBehaviorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用户行为服务实现类
 */
@Service
public class UserBehaviorServiceImpl implements UserBehaviorService {

    @Autowired
    private UserBehaviorMapper userBehaviorMapper;

    // 行为类型常量
    private static final String ACTION_VIEW = "view";
    private static final String ACTION_CLICK = "click";
    private static final String ACTION_CHAT = "chat";
    private static final String ACTION_LIKE = "like";
    private static final String ACTION_SHARE = "share";

    // 行为评分常量
    private static final Double SCORE_VIEW = 1.0;
    private static final Double SCORE_CLICK = 2.0;
    private static final Double SCORE_CHAT = 5.0;
    private static final Double SCORE_LIKE = 3.0;
    private static final Double SCORE_SHARE = 4.0;

    @Override
    public boolean recordUserBehavior(Integer userId, Integer roleId, String actionType, Double score) {
        try {
            UserBehavior userBehavior = new UserBehavior();
            userBehavior.setUserId(userId);
            userBehavior.setRoleId(roleId);
            userBehavior.setActionType(actionType);
            userBehavior.setScore(score);
            userBehavior.setCreatedAt(LocalDateTime.now());
            
            int result = userBehaviorMapper.insertUserBehavior(userBehavior);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean recordViewAction(Integer userId, Integer roleId) {
        return recordUserBehavior(userId, roleId, ACTION_VIEW, SCORE_VIEW);
    }

    @Override
    public boolean recordClickAction(Integer userId, Integer roleId) {
        return recordUserBehavior(userId, roleId, ACTION_CLICK, SCORE_CLICK);
    }

    @Override
    public boolean recordChatAction(Integer userId, Integer roleId) {
        return recordUserBehavior(userId, roleId, ACTION_CHAT, SCORE_CHAT);
    }

    @Override
    public boolean recordLikeAction(Integer userId, Integer roleId) {
        return recordUserBehavior(userId, roleId, ACTION_LIKE, SCORE_LIKE);
    }

    @Override
    public boolean recordShareAction(Integer userId, Integer roleId) {
        return recordUserBehavior(userId, roleId, ACTION_SHARE, SCORE_SHARE);
    }

    @Override
    public List<UserBehavior> getUserBehaviors(Integer userId) {
        return userBehaviorMapper.selectByUserId(userId);
    }

    @Override
    public List<UserBehavior> getRoleBehaviors(Integer roleId) {
        return userBehaviorMapper.selectByRoleId(roleId);
    }

    @Override
    public List<UserBehavior> getUserRoleBehaviors(Integer userId, Integer roleId) {
        return userBehaviorMapper.selectByUserIdAndRoleId(userId, roleId);
    }

    @Override
    public List<Map<String, Object>> getPopularRoles(Integer limit) {
        List<UserBehavior> popularRoles = userBehaviorMapper.selectPopularRoles(limit);
        // 转换为Map格式，便于前端使用
        return popularRoles.stream().map(role -> {
            Map<String, Object> map = new HashMap<>();
            map.put("roleId", role.getRoleId());
            map.put("actionCount", role.getScore()); // 这里score字段存储的是action_count
            return map;
        }).toList();
    }

    @Override
    public List<Map<String, Object>> getActiveUsers(Integer limit) {
        List<UserBehavior> activeUsers = userBehaviorMapper.selectActiveUsers(limit);
        // 转换为Map格式，便于前端使用
        return activeUsers.stream().map(user -> {
            Map<String, Object> map = new HashMap<>();
            map.put("userId", user.getUserId());
            map.put("actionCount", user.getScore()); // 这里score字段存储的是action_count
            return map;
        }).toList();
    }

    @Override
    public Map<String, Object> getUserBehaviorAnalysis(Integer userId) {
        try {
            // 这里需要添加对应的方法到Mapper中
            // List<Map<String, Object>> analysis = userBehaviorMapper.getUserBehaviorAnalysis(userId);
            // 暂时返回空Map，需要实现具体的分析逻辑
            Map<String, Object> analysis = new HashMap<>();
            analysis.put("userId", userId);
            analysis.put("totalActions", userBehaviorMapper.countByUserId(userId));
            analysis.put("analysisTime", LocalDateTime.now());
            return analysis;
        } catch (Exception e) {
            e.printStackTrace();
            return new HashMap<>();
        }
    }

    @Override
    public Map<String, Object> getRolePopularityAnalysis(Integer roleId) {
        try {
            // 这里需要添加对应的方法到Mapper中
            // Map<String, Object> analysis = userBehaviorMapper.getRolePopularityAnalysis(roleId);
            // 暂时返回基础统计信息
            Map<String, Object> analysis = new HashMap<>();
            analysis.put("roleId", roleId);
            analysis.put("totalActions", userBehaviorMapper.countByRoleId(roleId));
            analysis.put("analysisTime", LocalDateTime.now());
            return analysis;
        } catch (Exception e) {
            e.printStackTrace();
            return new HashMap<>();
        }
    }

    @Override
    public List<Map<String, Object>> getUserSimilarityData(Integer userId) {
        try {
            // 这里需要添加对应的方法到Mapper中
            // return userBehaviorMapper.getUserSimilarityData(userId);
            // 暂时返回空列表，需要实现具体的相似度计算逻辑
            return List.of();
        } catch (Exception e) {
            e.printStackTrace();
            return List.of();
        }
    }

    @Override
    public boolean deleteUserBehavior(Integer id) {
        try {
            int result = userBehaviorMapper.deleteById(id);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteUserBehaviors(Integer userId) {
        try {
            int result = userBehaviorMapper.deleteByUserId(userId);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteRoleBehaviors(Integer roleId) {
        try {
            int result = userBehaviorMapper.deleteByRoleId(roleId);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Map<String, Object> getUserBehaviorStats(Integer userId, LocalDateTime startTime, LocalDateTime endTime) {
        try {
            List<UserBehavior> behaviors = userBehaviorMapper.selectByTimeRange(startTime, endTime);
            
            Map<String, Object> stats = new HashMap<>();
            stats.put("userId", userId);
            stats.put("startTime", startTime);
            stats.put("endTime", endTime);
            stats.put("totalActions", behaviors.size());
            
            // 按行为类型统计
            Map<String, Long> actionTypeStats = behaviors.stream()
                .collect(java.util.stream.Collectors.groupingBy(
                    UserBehavior::getActionType,
                    java.util.stream.Collectors.counting()
                ));
            stats.put("actionTypeStats", actionTypeStats);
            
            // 计算平均评分
            double avgScore = behaviors.stream()
                .mapToDouble(UserBehavior::getScore)
                .average()
                .orElse(0.0);
            stats.put("averageScore", avgScore);
            
            return stats;
        } catch (Exception e) {
            e.printStackTrace();
            return new HashMap<>();
        }
    }
} 