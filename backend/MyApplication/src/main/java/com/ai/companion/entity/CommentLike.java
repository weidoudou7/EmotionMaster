package com.ai.companion.entity;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 评论点赞记录实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
public class CommentLike {

    /**
     * 点赞记录唯一ID
     */
    private Integer id;

    /**
     * 点赞用户ID
     */
    private Integer userId;

    /**
     * 被点赞的评论ID
     */
    private Integer commentId;

    /**
     * 点赞时间
     */
    private LocalDateTime createdAt;
}