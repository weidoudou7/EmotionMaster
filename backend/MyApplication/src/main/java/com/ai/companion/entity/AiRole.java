package com.ai.companion.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AiRole {
    private Integer id; // 角色唯一ID
    private Integer userId; // 所属用户ID(null表示系统预设)
    private String roleName; // 角色名称
    private String roleDescription; // 角色详细描述
    private String personality; // 角色性格特征(JSON格式)
    private String specialty; // 角色专长领域(JSON数组格式)
    private String roleType; // 角色类型(custom:自定义/system:系统预设/community:社区分享)
    private String roleAuthor; // 角色作者
    private Integer viewCount; // 角色浏览量
    private String avatarUrl; // 角色形象URL
    private Boolean isTemplate; // 是否为模板角色
    private LocalDateTime createdAt; // 创建时间
}