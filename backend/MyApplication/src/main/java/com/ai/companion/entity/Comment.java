package com.ai.companion.entity;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 评论实体类 - 单表设计版本
 * 统一存储评论和回复，通过root_comment_id区分顶级评论和回复
 */
@Data
@EqualsAndHashCode(callSuper = false)
public class Comment {

    /**
     * 评论唯一ID
     */
    private Integer id;

    /**
     * 被评论的AI角色ID
     */
    private Integer aiRoleId;

    /**
     * 评论用户ID
     */
    private Integer userId;

    /**
     * 评论内容
     */
    private String content;

    /**
     * 点赞数
     */
    private Integer likeCount;

    /**
     * 回复数
     */
    private Integer replyCount;

    /**
     * 根评论ID(null表示顶级评论，否则为回复)
     */
    private Integer rootCommentId;

    /**
     * 回复目标评论ID(null表示回复根评论，否则为回复某条回复)
     */
    private Integer toCommentId;

    /**
     * 回复目标用户ID
     */
    private Integer replyToUserId;

    /**
     * 回复目标用户昵称(静态存储，不随用户昵称变化)
     */
    private String replyToUsername;

    /**
     * 是否置顶(0:否/1:是)
     */
    private Boolean isTop;

    /**
     * 是否为作者评论(0:否/1:是)
     */
    private Boolean isAuthor;

    /**
     * 评论状态(normal:正常/hidden:隐藏/deleted:已删除)
     */
    private String status;

    /**
     * 评论创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 评论更新时间
     */
    private LocalDateTime updatedAt;

    // 关联查询字段（非数据库字段）
    private String username;
    private String profileImage;
    private Integer totalReplies;

    /**
     * 判断是否为顶级评论
     */
    public boolean isRootComment() {
        return rootCommentId == null;
    }

    /**
     * 判断是否为回复评论
     */
    public boolean isReplyComment() {
        return rootCommentId != null;
    }

    /**
     * 判断是否为回复根评论
     */
    public boolean isReplyToRoot() {
        return rootCommentId != null && toCommentId != null && toCommentId.equals(rootCommentId);
    }
}