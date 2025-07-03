package com.ai.companion.service;

import com.ai.companion.entity.Comment;

import java.util.List;

/**
 * 评论服务接口
 */
public interface CommentService {

    /**
     * 获取AI角色的评论列表（分页）
     * 
     * @param aiRoleId AI角色ID
     * @param page     页码（从1开始）
     * @param size     每页大小
     * @return 评论列表
     */
    List<Comment> getCommentsByAiRoleId(Integer aiRoleId, Integer page, Integer size);

    /**
     * 获取评论的回复列表（分页）
     * 
     * @param rootCommentId 根评论ID
     * @param page          页码（从1开始）
     * @param size          每页大小
     * @return 回复列表
     */
    List<Comment> getRepliesByRootCommentId(Integer rootCommentId, Integer page, Integer size);

    /**
     * 发布评论
     * 
     * @param comment 评论对象
     * @return 评论ID
     */
    Integer publishComment(Comment comment);

    /**
     * 回复评论
     * 
     * @param comment 回复对象
     * @return 回复ID
     */
    Integer replyComment(Comment comment);

    /**
     * 点赞评论
     * 
     * @param commentId 评论ID
     * @param userId    用户ID
     * @return 是否成功
     */
    boolean likeComment(Integer commentId, Integer userId);

    /**
     * 取消点赞评论
     * 
     * @param commentId 评论ID
     * @param userId    用户ID
     * @return 是否成功
     */
    boolean unlikeComment(Integer commentId, Integer userId);

    /**
     * 删除评论
     * 
     * @param commentId 评论ID
     * @param userId    用户ID（验证权限）
     * @return 是否成功
     */
    boolean deleteComment(Integer commentId, Integer userId);

    /**
     * 获取评论总数
     * 
     * @param aiRoleId AI角色ID
     * @return 评论总数
     */
    Integer getCommentCount(Integer aiRoleId);

    /**
     * 获取回复总数
     * 
     * @param rootCommentId 根评论ID
     * @return 回复总数
     */
    Integer getReplyCount(Integer rootCommentId);

    /**
     * 检查用户是否已点赞评论
     * 
     * @param commentId 评论ID
     * @param userId    用户ID
     * @return 是否已点赞
     */
    boolean isUserLikedComment(Integer commentId, Integer userId);
}