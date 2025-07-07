package com.ai.companion.controller;

import com.ai.companion.entity.UserBehavior;
import com.ai.companion.service.UserBehaviorService;
import com.ai.companion.entity.vo.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 用户行为控制器
 * 提供用户行为相关的REST API接口
 */
@RestController
@RequestMapping("/api/user-behavior")
@CrossOrigin(origins = "*")
public class UserBehaviorController {

    @Autowired
    private UserBehaviorService userBehaviorService;

    /**
     * 记录用户行为
     */
    @PostMapping("/record")
    public ApiResponse<Boolean> recordUserBehavior(
            @RequestParam Integer userId,
            @RequestParam Integer roleId,
            @RequestParam String actionType,
            @RequestParam(defaultValue = "1.0") Double score) {
        try {
            boolean result = userBehaviorService.recordUserBehavior(userId, roleId, actionType, score);
            return ApiResponse.success("行为记录成功", result);
        } catch (Exception e) {
            return ApiResponse.error("行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 记录用户查看行为
     */
    @PostMapping("/record/view")
    public ApiResponse<Boolean> recordViewAction(
            @RequestParam Integer userId,
            @RequestParam Integer roleId) {
        try {
            boolean result = userBehaviorService.recordViewAction(userId, roleId);
            return ApiResponse.success("查看行为记录成功", result);
        } catch (Exception e) {
            return ApiResponse.error("查看行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 记录用户点击行为
     */
    @PostMapping("/record/click")
    public ApiResponse<Boolean> recordClickAction(
            @RequestParam Integer userId,
            @RequestParam Integer roleId) {
        try {
            boolean result = userBehaviorService.recordClickAction(userId, roleId);
            return ApiResponse.success("点击行为记录成功", result);
        } catch (Exception e) {
            return ApiResponse.error("点击行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 记录用户聊天行为
     */
    @PostMapping("/record/chat")
    public ApiResponse<Boolean> recordChatAction(
            @RequestParam Integer userId,
            @RequestParam Integer roleId) {
        try {
            boolean result = userBehaviorService.recordChatAction(userId, roleId);
            return ApiResponse.success("聊天行为记录成功", result);
        } catch (Exception e) {
            return ApiResponse.error("聊天行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 记录用户点赞行为
     */
    @PostMapping("/record/like")
    public ApiResponse<Boolean> recordLikeAction(
            @RequestParam Integer userId,
            @RequestParam Integer roleId) {
        try {
            boolean result = userBehaviorService.recordLikeAction(userId, roleId);
            return ApiResponse.success("点赞行为记录成功", result);
        } catch (Exception e) {
            return ApiResponse.error("点赞行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 记录用户分享行为
     */
    @PostMapping("/record/share")
    public ApiResponse<Boolean> recordShareAction(
            @RequestParam Integer userId,
            @RequestParam Integer roleId) {
        try {
            boolean result = userBehaviorService.recordShareAction(userId, roleId);
            return ApiResponse.success("分享行为记录成功", result);
        } catch (Exception e) {
            return ApiResponse.error("分享行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户行为记录
     */
    @GetMapping("/user/{userId}")
    public ApiResponse<List<UserBehavior>> getUserBehaviors(@PathVariable Integer userId) {
        try {
            List<UserBehavior> behaviors = userBehaviorService.getUserBehaviors(userId);
            return ApiResponse.success("获取用户行为记录成功", behaviors);
        } catch (Exception e) {
            return ApiResponse.error("获取用户行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 获取角色行为记录
     */
    @GetMapping("/role/{roleId}")
    public ApiResponse<List<UserBehavior>> getRoleBehaviors(@PathVariable Integer roleId) {
        try {
            List<UserBehavior> behaviors = userBehaviorService.getRoleBehaviors(roleId);
            return ApiResponse.success("获取角色行为记录成功", behaviors);
        } catch (Exception e) {
            return ApiResponse.error("获取角色行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户对特定角色的行为记录
     */
    @GetMapping("/user/{userId}/role/{roleId}")
    public ApiResponse<List<UserBehavior>> getUserRoleBehaviors(
            @PathVariable Integer userId,
            @PathVariable Integer roleId) {
        try {
            List<UserBehavior> behaviors = userBehaviorService.getUserRoleBehaviors(userId, roleId);
            return ApiResponse.success("获取用户角色行为记录成功", behaviors);
        } catch (Exception e) {
            return ApiResponse.error("获取用户角色行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 获取热门角色列表
     */
    @GetMapping("/popular-roles")
    public ApiResponse<List<Map<String, Object>>> getPopularRoles(
            @RequestParam(defaultValue = "10") Integer limit) {
        try {
            List<Map<String, Object>> popularRoles = userBehaviorService.getPopularRoles(limit);
            return ApiResponse.success("获取热门角色成功", popularRoles);
        } catch (Exception e) {
            return ApiResponse.error("获取热门角色失败: " + e.getMessage());
        }
    }

    /**
     * 获取活跃用户列表
     */
    @GetMapping("/active-users")
    public ApiResponse<List<Map<String, Object>>> getActiveUsers(
            @RequestParam(defaultValue = "10") Integer limit) {
        try {
            List<Map<String, Object>> activeUsers = userBehaviorService.getActiveUsers(limit);
            return ApiResponse.success("获取活跃用户成功", activeUsers);
        } catch (Exception e) {
            return ApiResponse.error("获取活跃用户失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户行为分析数据
     */
    @GetMapping("/analysis/user/{userId}")
    public ApiResponse<Map<String, Object>> getUserBehaviorAnalysis(@PathVariable Integer userId) {
        try {
            Map<String, Object> analysis = userBehaviorService.getUserBehaviorAnalysis(userId);
            return ApiResponse.success("获取用户行为分析成功", analysis);
        } catch (Exception e) {
            return ApiResponse.error("获取用户行为分析失败: " + e.getMessage());
        }
    }

    /**
     * 获取角色受欢迎度分析
     */
    @GetMapping("/analysis/role/{roleId}")
    public ApiResponse<Map<String, Object>> getRolePopularityAnalysis(@PathVariable Integer roleId) {
        try {
            Map<String, Object> analysis = userBehaviorService.getRolePopularityAnalysis(roleId);
            return ApiResponse.success("获取角色受欢迎度分析成功", analysis);
        } catch (Exception e) {
            return ApiResponse.error("获取角色受欢迎度分析失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户相似度数据
     */
    @GetMapping("/similarity/user/{userId}")
    public ApiResponse<List<Map<String, Object>>> getUserSimilarityData(@PathVariable Integer userId) {
        try {
            List<Map<String, Object>> similarityData = userBehaviorService.getUserSimilarityData(userId);
            return ApiResponse.success("获取用户相似度数据成功", similarityData);
        } catch (Exception e) {
            return ApiResponse.error("获取用户相似度数据失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户行为统计
     */
    @GetMapping("/stats/user/{userId}")
    public ApiResponse<Map<String, Object>> getUserBehaviorStats(
            @PathVariable Integer userId,
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime) {
        try {
            LocalDateTime start = startTime != null ? LocalDateTime.parse(startTime) : LocalDateTime.now().minusDays(30);
            LocalDateTime end = endTime != null ? LocalDateTime.parse(endTime) : LocalDateTime.now();
            
            Map<String, Object> stats = userBehaviorService.getUserBehaviorStats(userId, start, end);
            return ApiResponse.success("获取用户行为统计成功", stats);
        } catch (Exception e) {
            return ApiResponse.error("获取用户行为统计失败: " + e.getMessage());
        }
    }

    /**
     * 删除用户行为记录
     */
    @DeleteMapping("/{id}")
    public ApiResponse<Boolean> deleteUserBehavior(@PathVariable Integer id) {
        try {
            boolean result = userBehaviorService.deleteUserBehavior(id);
            return ApiResponse.success("删除用户行为记录成功", result);
        } catch (Exception e) {
            return ApiResponse.error("删除用户行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 删除用户的所有行为记录
     */
    @DeleteMapping("/user/{userId}")
    public ApiResponse<Boolean> deleteUserBehaviors(@PathVariable Integer userId) {
        try {
            boolean result = userBehaviorService.deleteUserBehaviors(userId);
            return ApiResponse.success("删除用户所有行为记录成功", result);
        } catch (Exception e) {
            return ApiResponse.error("删除用户所有行为记录失败: " + e.getMessage());
        }
    }

    /**
     * 删除角色的所有行为记录
     */
    @DeleteMapping("/role/{roleId}")
    public ApiResponse<Boolean> deleteRoleBehaviors(@PathVariable Integer roleId) {
        try {
            boolean result = userBehaviorService.deleteRoleBehaviors(roleId);
            return ApiResponse.success("删除角色所有行为记录成功", result);
        } catch (Exception e) {
            return ApiResponse.error("删除角色所有行为记录失败: " + e.getMessage());
        }
    }
} 