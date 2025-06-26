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
    private int id;
    private String userUID; // 发布动态的用户UID
    private String content; // 动态文字内容
    private List<String> images; // 动态图片列表（JSON格式存储）
    private LocalDateTime createTime; // 创建时间
    private LocalDateTime updateTime; // 更新时间
    private int likeCount; // 点赞数
    private int commentCount; // 评论数
    
    // 构造函数 - 用于创建新动态
    public Dynamic(String userUID, String content, List<String> images) {
        this.userUID = userUID;
        this.content = content;
        this.images = images;
        this.createTime = LocalDateTime.now();
        this.updateTime = LocalDateTime.now();
        this.likeCount = 0;
        this.commentCount = 0;
    }
} 