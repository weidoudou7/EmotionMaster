package com.ai.companion.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

/**
 * 用户行为记录实体类
 * 对应数据库表 user_behavior
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserBehavior {
    private Integer id;                    // 主键ID
    private Integer userId;                // 用户ID
    private Integer roleId;                // AI角色ID
    private String actionType;             // 行为类型：view(查看), click(点击), chat(聊天), like(点赞), share(分享)
    private Double score;                  // 行为评分
    private LocalDateTime createdAt;       // 行为发生时间
} 