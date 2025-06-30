package com.ai.companion.entity.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateDynamicRequest {
    private String content; // 动态内容
    private List<String> images; // 图片URL列表
    private Boolean isPrivate; // 是否私密
    private List<String> topicTags; // 话题标签
    private String visibility; // 可见性设置
} 