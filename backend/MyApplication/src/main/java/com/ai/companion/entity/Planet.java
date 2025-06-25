package com.ai.companion.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Planet {
    private Integer id; // 星球唯一ID
    private Integer userId; // 所属用户ID
    private Integer level; // 星球等级
    private Long experience; // 累计经验值
    private String name; // 星球名称
    private String appearance; // 外观配置JSON
    private String unlockedItems; // 已解锁物品JSON数组
    private LocalDateTime lastUpdated; // 最后更新时间
}