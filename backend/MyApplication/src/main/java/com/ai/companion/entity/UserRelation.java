package com.ai.companion.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserRelation {
    private Integer id; // 关系ID
    private String followerUID; // 关注者UID
    private String followingUID; // 被关注者UID
    private String relationType; // 关系类型：follow(关注)、friend(好友)
    private LocalDateTime createTime; // 创建时间
    private LocalDateTime updateTime; // 更新时间
    private Boolean isActive; // 是否有效

    // 构造函数 - 用于创建新关系
    public UserRelation(String followerUID, String followingUID, String relationType) {
        this.followerUID = followerUID;
        this.followingUID = followingUID;
        this.relationType = relationType;
        this.createTime = LocalDateTime.now();
        this.updateTime = LocalDateTime.now();
        this.isActive = true;
    }
} 