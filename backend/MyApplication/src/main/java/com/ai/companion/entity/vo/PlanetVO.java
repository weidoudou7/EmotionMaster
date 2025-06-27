package com.ai.companion.entity.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlanetVO {
    private Integer id; // 星球唯一ID
    private Integer userId; // 所属用户ID
    private String name; // 星球名称
    private String description; // 星球简介
    private Integer level; // 星球等级
    private String image; // 星球图片
    private Integer ecoPercent; // 生态系统百分比
    private Integer techPercent; // 科技水平百分比
    private Integer culturePercent; // 文化发展百分比
    private Double talkHours; // 总对话时长
    private Double talkTarget; // 对话目标时长
    private Integer taskCount; // 完成任务数
    private Integer taskTarget; // 任务目标数
    private Integer explorePercent; // 探索度百分比
    private String[] unlockedRewards; // 已解锁奖励
    private String[] lockedRewards; // 未解锁奖励
    private String appearance; // 外观配置JSON
    private String unlockedItems; // 已解锁物品JSON数组
} 