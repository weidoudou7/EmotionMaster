package com.ai.companion.controller;

import com.ai.companion.entity.AiRole;
import com.ai.companion.mapper.AiRoleMapper;
import com.ai.companion.entity.vo.ApiResponse;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/ai/role")
public class AIRoleController {

    private final AiRoleMapper aiRoleMapper;
    private final ChatClient chatClient;

    @Autowired
    public AIRoleController(AiRoleMapper aiRoleMapper, ChatClient chatClient){
        this.aiRoleMapper = aiRoleMapper;
        this.chatClient = chatClient;
    }





    @RequestMapping("/featured4types")
    public ApiResponse<Map<String, List<AiRole>>> getfeatured4types(){
        String[] types = {"动漫","可爱","科幻","写实"};
        Map<String, List<AiRole>> featured4typesRoles = new HashMap<>();
        for(String type : types){
            List<AiRole> roles = aiRoleMapper.selectByRoleType(type);
            if (roles.size() > 9) {
                roles = roles.subList(0, 9);
            }
            featured4typesRoles.put(type, roles);
        }
        return new ApiResponse<>(true, "ok", featured4typesRoles, System.currentTimeMillis());
    }

    /**
     * 创建AI角色
     * POST /ai/role/create
     */
    @PostMapping("/create")
    public ApiResponse<AiRole> createAiRole(@RequestBody CreateAiRoleRequest request) {
        try {
            // 验证必填字段
            if (request.getRoleName() == null || request.getRoleName().trim().isEmpty()) {
                return ApiResponse.error("角色名称不能为空");
            }
            if (request.getRoleDescription() == null || request.getRoleDescription().trim().isEmpty()) {
                return ApiResponse.error("角色描述不能为空");
            }
            if (request.getRoleType() == null || request.getRoleType().trim().isEmpty()) {
                return ApiResponse.error("角色类型不能为空");
            }
            if (request.getRoleAuthor() == null || request.getRoleAuthor().trim().isEmpty()) {
                return ApiResponse.error("角色作者不能为空");
            }
            if (request.getAvatarUrl() == null || request.getAvatarUrl().trim().isEmpty()) {
                return ApiResponse.error("角色头像URL不能为空");
            }

            // 检查角色名称是否已存在
            if (aiRoleMapper.existsByRoleName(request.getRoleName(), null)) {
                return ApiResponse.error("角色名称已存在，请使用其他名称");
            }

            // 创建新的AI角色
            AiRole newRole = new AiRole();
            newRole.setUserId(request.getUserId()); // 可以为null，表示系统预设
            newRole.setRoleName(request.getRoleName().trim());
            newRole.setRoleDescription(request.getRoleDescription().trim());
            newRole.setRoleType(request.getRoleType().trim());
            newRole.setRoleAuthor(request.getRoleAuthor().trim());
            newRole.setViewCount(0);
            newRole.setAvatarUrl(request.getAvatarUrl().trim());
            newRole.setIsTemplate(request.getIsTemplate() != null ? request.getIsTemplate() : false);
            newRole.setCreatedAt(LocalDateTime.now());

            // 保存到数据库
            int result = aiRoleMapper.insertAiRole(newRole);
            if (result > 0) {
                return ApiResponse.success("AI角色创建成功", newRole);
            } else {
                return ApiResponse.error("AI角色创建失败");
            }

        } catch (Exception e) {
            return ApiResponse.error("创建AI角色时发生错误: " + e.getMessage());
        }
    }

    /**
     * 创建AI角色的请求体
     */
    public static class CreateAiRoleRequest {
        private Integer userId;
        private String roleName;
        private String roleDescription;
        private String roleType;
        private String roleAuthor;
        private String avatarUrl;
        private Boolean isTemplate;

        // Getters and Setters
        public Integer getUserId() { return userId; }
        public void setUserId(Integer userId) { this.userId = userId; }

        public String getRoleName() { return roleName; }
        public void setRoleName(String roleName) { this.roleName = roleName; }

        public String getRoleDescription() { return roleDescription; }
        public void setRoleDescription(String roleDescription) { this.roleDescription = roleDescription; }

        public String getRoleType() { return roleType; }
        public void setRoleType(String roleType) { this.roleType = roleType; }

        public String getRoleAuthor() { return roleAuthor; }
        public void setRoleAuthor(String roleAuthor) { this.roleAuthor = roleAuthor; }

        public String getAvatarUrl() { return avatarUrl; }
        public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

        public Boolean getIsTemplate() { return isTemplate; }
        public void setIsTemplate(Boolean isTemplate) { this.isTemplate = isTemplate; }
    }

    /**
     * 根据描述词生成AI角色名称
     * POST /ai/role/generate-name
     */
    @PostMapping("/generate-name")
    public ApiResponse<String> generateRoleName(@RequestBody GenerateRoleNameRequest request) {
        try {
            // 验证输入
            if (request.getDescription() == null || request.getDescription().trim().isEmpty()) {
                return ApiResponse.error("描述词不能为空");
            }

            String description = request.getDescription().trim();
            
            // 构建AI提示词
            String systemPrompt = "你是一个AI角色名称生成专家。根据用户提供的角色描述，生成一个简洁、有特色、易记的角色名称。要求：\n" +
                    "1. 名称长度控制在2-8个字符\n" +
                    "2. 体现角色的核心特点\n" +
                    "3. 具有创意性和独特性\n" +
                    "4. 只返回名称，不要添加任何解释或标点符号";

            String userPrompt = "请为以下角色描述生成一个合适的名称：\n" + description;

            // 调用AI生成角色名称
            String generatedName = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userPrompt)
                    .call()
                    .content();

            // 清理和验证生成的名称
            if (generatedName != null && !generatedName.trim().isEmpty()) {
                String cleanName = generatedName.trim()
                        .replaceAll("[\\n\\r\\t]", "") // 移除换行符和制表符
                        .replaceAll("[^\\u4e00-\\u9fa5a-zA-Z0-9]", ""); // 只保留中文、英文、数字
                
                // 如果清理后为空，使用默认名称
                if (cleanName.isEmpty()) {
                    cleanName = "AI助手";
                }
                
                // 检查名称长度，如果太长则截取
                if (cleanName.length() > 10) {
                    cleanName = cleanName.substring(0, 10);
                }

                return ApiResponse.success("角色名称生成成功", cleanName);
            } else {
                return ApiResponse.error("AI生成角色名称失败，请重试");
            }

        } catch (Exception e) {
            return ApiResponse.error("生成角色名称时发生错误: " + e.getMessage());
        }
    }

    /**
     * 生成角色名称的请求体
     */
    public static class GenerateRoleNameRequest {
        private String description;

        // Getters and Setters
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
    }

}
