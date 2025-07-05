package com.ai.companion.controller;

import com.ai.companion.entity.User;
import com.ai.companion.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/management/user")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000",
        "http://127.0.0.1:5173" }, allowCredentials = "false")
public class UserManagementController {

    private final UserMapper userMapper;

    @Autowired
    public UserManagementController(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    /**
     * 获取所有用户
     */
    @GetMapping("/selectAll")
    public ResponseEntity<List<User>> selectAll() {
        try {
            List<User> users = userMapper.selectAll();
            return ResponseEntity.ok(users);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据ID获取用户
     */
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Integer id) {
        try {
            User user = userMapper.selectById(id);
            if (user != null) {
                return ResponseEntity.ok(user);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 创建新用户
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createUser(@RequestBody User user) {
        try {
            // 自动生成UID
            if (user.getUserUID() == null || user.getUserUID().trim().isEmpty()) {
                user.setUserUID(UUID.randomUUID().toString());
            }

            // 设置注册时间
            if (user.getRegisterTime() == null) {
                user.setRegisterTime(java.time.LocalDateTime.now());
            }

            // 检查用户名是否已存在
            if (userMapper.selectByUserName(user.getUserName()) != null) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "用户名已存在"));
            }

            // 检查邮箱是否已存在
            if (userMapper.selectByEmail(user.getEmail()) != null) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "邮箱已存在"));
            }

            // 设置默认值
            if (user.getLevel() == null) {
                user.setLevel(1);
            }
            if (user.getGender() == null) {
                user.setGender("未知");
            }

            int result = userMapper.insertUser(user);
            if (result > 0) {
                return ResponseEntity.ok(Map.of(
                        "message", "用户创建成功",
                        "user", user));
            } else {
                return ResponseEntity.internalServerError()
                        .body(Map.of("error", "用户创建失败"));
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", "服务器内部错误: " + e.getMessage()));
        }
    }

    /**
     * 更新用户信息
     */
    @PutMapping
    public ResponseEntity<Map<String, Object>> updateUser(@RequestBody User user) {
        try {
            // 检查用户是否存在
            User existingUser = userMapper.selectById(user.getId());
            if (existingUser == null) {
                return ResponseEntity.notFound().build();
            }

            // 检查用户名是否被其他用户使用
            User userWithSameName = userMapper.selectByUserName(user.getUserName());
            if (userWithSameName != null && userWithSameName.getId() != user.getId()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "用户名已被其他用户使用"));
            }

            // 检查邮箱是否被其他用户使用
            User userWithSameEmail = userMapper.selectByEmail(user.getEmail());
            if (userWithSameEmail != null && userWithSameEmail.getId() != user.getId()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "邮箱已被其他用户使用"));
            }

            int result = userMapper.updateUser(user);
            if (result > 0) {
                return ResponseEntity.ok(Map.of(
                        "message", "用户更新成功",
                        "user", user));
            } else {
                return ResponseEntity.internalServerError()
                        .body(Map.of("error", "用户更新失败"));
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", "服务器内部错误: " + e.getMessage()));
        }
    }

    /**
     * 删除用户
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteUser(@PathVariable Integer id) {
        try {
            // 检查用户是否存在
            User existingUser = userMapper.selectById(id);
            if (existingUser == null) {
                return ResponseEntity.notFound().build();
            }

            int result = userMapper.deleteUserById(id);
            if (result > 0) {
                return ResponseEntity.ok(Map.of("message", "用户删除成功"));
            } else {
                return ResponseEntity.internalServerError()
                        .body(Map.of("error", "用户删除失败"));
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", "服务器内部错误: " + e.getMessage()));
        }
    }

    /**
     * 批量删除用户
     */
    @PostMapping("/batchDelete")
    public ResponseEntity<Map<String, Object>> batchDeleteUsers(@RequestBody List<Integer> userIds) {
        try {
            if (userIds == null || userIds.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "请选择要删除的用户"));
            }

            int successCount = 0;
            int failCount = 0;
            List<Integer> failedIds = new java.util.ArrayList<>();

            for (Integer userId : userIds) {
                try {
                    User existingUser = userMapper.selectById(userId);
                    if (existingUser != null) {
                        int result = userMapper.deleteUserById(userId);
                        if (result > 0) {
                            successCount++;
                        } else {
                            failCount++;
                            failedIds.add(userId);
                        }
                    } else {
                        failCount++;
                        failedIds.add(userId);
                    }
                } catch (Exception e) {
                    failCount++;
                    failedIds.add(userId);
                }
            }

            Map<String, Object> response = Map.of(
                    "message", "批量删除完成",
                    "successCount", successCount,
                    "failCount", failCount,
                    "failedIds", failedIds);

            if (failCount > 0) {
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.ok(response);
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", "批量删除失败: " + e.getMessage()));
        }
    }

    /**
     * 搜索用户
     */
    @GetMapping("/search")
    public ResponseEntity<List<User>> searchUsers(@RequestParam String keyword) {
        try {
            if (keyword == null || keyword.trim().isEmpty()) {
                return ResponseEntity.ok(userMapper.selectAll());
            }

            List<User> users = userMapper.searchUsers(keyword.trim(), 100);
            return ResponseEntity.ok(users);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取用户统计信息
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getUserStats() {
        try {
            List<User> allUsers = userMapper.selectAll();
            java.time.LocalDateTime now = java.time.LocalDateTime.now();

            // 计算本周开始时间（周一）
            java.time.LocalDateTime weekStart = now.with(java.time.DayOfWeek.MONDAY).withHour(0).withMinute(0)
                    .withSecond(0).withNano(0);
            // 计算上周开始时间
            java.time.LocalDateTime lastWeekStart = weekStart.minusWeeks(1);
            // 计算上周结束时间
            java.time.LocalDateTime lastWeekEnd = weekStart.minusNanos(1);

            // 总用户数
            int totalUsers = allUsers.size();

            // 计算本周活跃用户（根据updateTime在本周内有更新的用户）
            long activeUsers = allUsers.stream()
                    .filter(user -> user.getUpdateTime() != null &&
                            user.getUpdateTime().isAfter(weekStart) &&
                            user.getUpdateTime().isBefore(now))
                    .count();

            // 计算上周活跃用户
            long lastWeekActiveUsers = allUsers.stream()
                    .filter(user -> user.getUpdateTime() != null &&
                            user.getUpdateTime().isAfter(lastWeekStart) &&
                            user.getUpdateTime().isBefore(lastWeekEnd))
                    .count();

            // 计算活跃用户增长率
            double activeGrowthRate = lastWeekActiveUsers > 0
                    ? ((double) (activeUsers - lastWeekActiveUsers) / lastWeekActiveUsers) * 100
                    : 0;
            if (Double.isNaN(activeGrowthRate) || Double.isInfinite(activeGrowthRate))
                activeGrowthRate = 0;

            // 计算本周新增用户（根据registerTime在本周内注册的用户）
            long newUsers = allUsers.stream()
                    .filter(user -> user.getRegisterTime() != null &&
                            user.getRegisterTime().isAfter(weekStart) &&
                            user.getRegisterTime().isBefore(now))
                    .count();

            // 计算上周新增用户
            long lastWeekNewUsers = allUsers.stream()
                    .filter(user -> user.getRegisterTime() != null &&
                            user.getRegisterTime().isAfter(lastWeekStart) &&
                            user.getRegisterTime().isBefore(lastWeekEnd))
                    .count();

            // 计算新增用户增长率
            double newUserGrowthRate = lastWeekNewUsers > 0
                    ? ((double) (newUsers - lastWeekNewUsers) / lastWeekNewUsers) * 100
                    : 0;
            if (Double.isNaN(newUserGrowthRate) || Double.isInfinite(newUserGrowthRate))
                newUserGrowthRate = 0;

            // 计算总用户数增长率（与上周相比）
            long lastWeekTotalUsers = allUsers.stream()
                    .filter(user -> user.getRegisterTime() == null ||
                            user.getRegisterTime().isBefore(lastWeekEnd))
                    .count();

            double totalGrowthRate = lastWeekTotalUsers > 0
                    ? ((double) (totalUsers - lastWeekTotalUsers) / lastWeekTotalUsers) * 100
                    : 0;
            if (Double.isNaN(totalGrowthRate) || Double.isInfinite(totalGrowthRate))
                totalGrowthRate = 0;

            // VIP用户数
            long vipUsers = allUsers.stream()
                    .filter(user -> user.getLevel() != null && user.getLevel() > 1)
                    .count();

            Map<String, Object> stats = Map.of(
                    "totalUsers", totalUsers,
                    "totalGrowthRate", Math.round(totalGrowthRate * 10.0) / 10.0, // 保留一位小数
                    "activeUsers", (int) activeUsers,
                    "activeGrowthRate", Math.round(activeGrowthRate * 10.0) / 10.0,
                    "newUsers", (int) newUsers,
                    "newUserGrowthRate", Math.round(newUserGrowthRate * 10.0) / 10.0,
                    "vipUsers", (int) vipUsers);

            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
