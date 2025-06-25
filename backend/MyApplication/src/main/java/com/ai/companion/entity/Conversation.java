package com.ai.companion.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Conversation {
    private Integer id; // 会话唯一ID
    private Integer userId; // 所属用户ID
    private Integer aiRoleId; // 使用的AI角色ID
    private Integer turns; // 对话轮数
    private String title; // 对话标题
    private LocalDateTime startTime; // 开始时间
    private LocalDateTime lastActive; // 最后活跃时间
    private String moodTag; // 情绪标签
    private String mode; // 对话模式（text/voice）
    private Integer planetGrowth; // 对星球的成长值贡献
}