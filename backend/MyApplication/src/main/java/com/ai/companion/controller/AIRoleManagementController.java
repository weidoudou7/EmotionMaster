package com.ai.companion.controller;

import com.ai.companion.entity.AiRole;
import com.ai.companion.mapper.AiRoleMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/management/role")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000",
        "http://127.0.0.1:5173" }, allowCredentials = "false")
public class AIRoleManagementController {
    private final AiRoleMapper aiRoleMapper;

    @Autowired
    public AIRoleManagementController(AiRoleMapper aiRoleMapper) {
        this.aiRoleMapper = aiRoleMapper;
    }

    /**
     * 获取所有AI角色
     */
    @GetMapping("/selectAll")
    public List<AiRole> selectAll() {
        return aiRoleMapper.selectAll();
    }

    /**
     * 根据ID获取AI角色
     */
    @GetMapping("/{id}")
    public Map<String, Object> getById(@PathVariable Integer id) {
        Map<String, Object> response = new HashMap<>();
        try {
            AiRole role = aiRoleMapper.selectById(id);
            if (role != null) {
                response.put("success", true);
                response.put("data", role);
            } else {
                response.put("success", false);
                response.put("error", "角色不存在");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "获取角色失败: " + e.getMessage());
        }
        return response;
    }

    /**
     * 创建AI角色
     */
    @PostMapping
    public Map<String, Object> create(@RequestBody AiRole role) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 设置创建时间
            role.setCreatedAt(LocalDateTime.now());
            // 设置默认值
            if (role.getViewCount() == null) {
                role.setViewCount(0);
            }
            if (role.getIsTemplate() == null) {
                role.setIsTemplate(false);
            }

            int result = aiRoleMapper.insertAiRole(role);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "角色创建成功");
                response.put("data", role);
            } else {
                response.put("success", false);
                response.put("error", "角色创建失败");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "创建角色失败: " + e.getMessage());
        }
        return response;
    }

    /**
     * 更新AI角色
     */
    @PutMapping
    public Map<String, Object> update(@RequestBody AiRole role) {
        Map<String, Object> response = new HashMap<>();
        try {
            int result = aiRoleMapper.updateAiRole(role);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "角色更新成功");
            } else {
                response.put("success", false);
                response.put("error", "角色更新失败");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "更新角色失败: " + e.getMessage());
        }
        return response;
    }

    /**
     * 删除AI角色
     */
    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable Integer id) {
        Map<String, Object> response = new HashMap<>();
        try {
            int result = aiRoleMapper.deleteAiRole(id);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "角色删除成功");
            } else {
                response.put("success", false);
                response.put("error", "角色删除失败");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "删除角色失败: " + e.getMessage());
        }
        return response;
    }

    /**
     * 批量删除AI角色
     */
    @PostMapping("/batchDelete")
    public Map<String, Object> batchDelete(@RequestBody List<Integer> ids) {
        Map<String, Object> response = new HashMap<>();
        try {
            int successCount = 0;
            int failCount = 0;
            List<Integer> failedIds = new java.util.ArrayList<>();

            for (Integer id : ids) {
                try {
                    int result = aiRoleMapper.deleteAiRole(id);
                    if (result > 0) {
                        successCount++;
                    } else {
                        failCount++;
                        failedIds.add(id);
                    }
                } catch (Exception e) {
                    failCount++;
                    failedIds.add(id);
                }
            }

            response.put("success", true);
            response.put("successCount", successCount);
            response.put("failCount", failCount);
            response.put("failedIds", failedIds);
            response.put("message", String.format("批量删除完成：成功删除 %d 个角色，失败 %d 个角色", successCount, failCount));
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "批量删除失败: " + e.getMessage());
        }
        return response;
    }

    /**
     * 搜索AI角色
     */
    @GetMapping("/search")
    public Map<String, Object> search(@RequestParam String keyword) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<AiRole> roles = aiRoleMapper.searchRoles(keyword, 100);
            response.put("success", true);
            response.put("data", roles);
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "搜索失败: " + e.getMessage());
        }
        return response;
    }

    /**
     * 根据类型获取AI角色
     */
    @GetMapping("/type/{roleType}")
    public Map<String, Object> getByType(@PathVariable String roleType) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<AiRole> roles = aiRoleMapper.selectByRoleType(roleType);
            response.put("success", true);
            response.put("data", roles);
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "获取角色失败: " + e.getMessage());
        }
        return response;
    }

    /**
     * 获取角色统计信息
     */
    @GetMapping("/stats")
    public Map<String, Object> getStats() {
        Map<String, Object> response = new HashMap<>();
        try {
            Map<String, Object> stats = new HashMap<>();
            Integer totalCount = safeInt(aiRoleMapper.countAll());
            Integer systemCount = safeInt(aiRoleMapper.countByRoleType("system"));
            Integer customCount = safeInt(aiRoleMapper.countByRoleType("custom"));
            Integer newRolesThisWeek = safeInt(aiRoleMapper.countNewRolesThisWeek());
            Integer templateCount = safeInt(aiRoleMapper.countByIsTemplate(true));
            Integer totalViewCount = safeInt(aiRoleMapper.sumViewCount());

            stats.put("totalCount", totalCount);
            stats.put("systemCount", systemCount);
            stats.put("customCount", customCount);
            stats.put("newRolesThisWeek", newRolesThisWeek);
            stats.put("templateCount", templateCount);
            stats.put("totalViewCount", totalViewCount);

            response.put("success", true);
            response.put("data", stats);
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "获取统计信息失败: " + e.getMessage());
        }
        return response;
    }

    // 工具方法，保证返回数字且不为null
    private Integer safeInt(Integer value) {
        if (value == null || value < 0)
            return 0;
        return value;
    }

    /**
     * 更新角色浏览量
     */
    @PostMapping("/{id}/view")
    public Map<String, Object> incrementViewCount(@PathVariable Integer id) {
        Map<String, Object> response = new HashMap<>();
        try {
            int result = aiRoleMapper.incrementViewCount(id);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "浏览量更新成功");
            } else {
                response.put("success", false);
                response.put("error", "浏览量更新失败");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "更新浏览量失败: " + e.getMessage());
        }
        return response;
    }
}
