package com.ai.companion.entity.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserStatsVO {
    private String userUID; // 用户UID
    private Integer dynamicCount; // 动态数量
    private Integer followingCount; // 关注数量
    private Integer followerCount; // 粉丝数量
    private Integer friendCount; // 好友数量
    private Integer totalLikes; // 总获赞数
    private Integer totalViews; // 总浏览量
} 