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
    private String personality; // 人格配置JSON
    private String specialty; // 专长标签JSON数组
    private String avatarUrl; // 角色形象URL
    private Boolean isTemplate; // 是否为模板角色
    private LocalDateTime createdAt; // 创建时间
}