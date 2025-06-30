package com.ai.companion.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Dynamic {
    private Integer id; // 动态唯一ID
    private Integer userId; // 发布用户ID
    private String content; // 动态文本内容
    private List<String> images; // 图片内容JSON数组(存储图片URL列表)
    private List<String> topicTags; // 话题标签JSON数组
    private String visibility; // 可见性(public:公开/private:私密/friends:仅好友可见)
    private LocalDateTime createdAt; // 创建时间
    private LocalDateTime updatedAt; // 更新时间
    private Integer likeCount; // 点赞数

    // 构造函数 - 用于创建新动态
    public Dynamic(Integer userId, String content, List<String> images, List<String> topicTags, String visibility) {
        this.userId = userId;
        this.content = content;
        this.images = images;
        this.topicTags = topicTags;
        this.visibility = visibility;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.likeCount = 0;
    }
}