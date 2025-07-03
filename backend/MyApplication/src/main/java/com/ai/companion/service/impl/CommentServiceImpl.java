package com.ai.companion.service.impl;

import com.ai.companion.entity.Comment;
import com.ai.companion.entity.CommentLike;
import com.ai.companion.mapper.CommentLikeMapper;
import com.ai.companion.mapper.CommentMapper;
import com.ai.companion.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 评论服务实现类
 */
@Service
public class CommentServiceImpl implements CommentService {

    @Autowired
    private CommentMapper commentMapper;

    @Autowired
    private CommentLikeMapper commentLikeMapper;

    @Override
    public List<Comment> getCommentsByAiRoleId(Integer aiRoleId, Integer page, Integer size) {
        int offset = (page - 1) * size;
        return commentMapper.getRootCommentsWithReplyCount(aiRoleId, offset, size);
    }

    @Override
    public List<Comment> getRepliesByRootCommentId(Integer rootCommentId, Integer page, Integer size) {
        int offset = (page - 1) * size;
        return commentMapper.getRepliesByRootCommentId(rootCommentId, offset, size);
    }

    @Override
    @Transactional
    public Integer publishComment(Comment comment) {
        // 设置默认值
        comment.setLikeCount(0);
        comment.setReplyCount(0);
        comment.setIsTop(false);
        comment.setIsAuthor(false);
        comment.setStatus("normal");

        // 插入评论
        commentMapper.insertComment(comment);
        return comment.getId();
    }

    @Override
    @Transactional
    public Integer replyComment(Comment comment) {
        // 验证根评论是否存在
        Comment rootComment = commentMapper.getCommentById(comment.getRootCommentId());
        if (rootComment == null) {
            throw new RuntimeException("根评论不存在");
        }

        // 设置回复的默认值
        comment.setLikeCount(0);
        comment.setReplyCount(0);
        comment.setIsTop(false);
        comment.setIsAuthor(false);
        comment.setStatus("normal");

        // 设置回复目标信息
        if (comment.getToCommentId() == null) {
            // 回复根评论
            comment.setToCommentId(comment.getRootCommentId());
            comment.setReplyToUserId(rootComment.getUserId());
            comment.setReplyToUsername(rootComment.getUsername());
        } else {
            // 回复某条回复
            Comment toComment = commentMapper.getCommentById(comment.getToCommentId());
            if (toComment != null) {
                comment.setReplyToUserId(toComment.getUserId());
                comment.setReplyToUsername(toComment.getUsername());
            }
        }

        // 插入回复
        commentMapper.insertComment(comment);
        // 主动更新父评论的回复数
        if (comment.getRootCommentId() != null) {
            commentMapper.increaseReplyCount(comment.getRootCommentId());
        }
        return comment.getId();
    }

    @Override
    @Transactional
    public boolean likeComment(Integer commentId, Integer userId) {
        // 检查是否已点赞
        if (isUserLikedComment(commentId, userId)) {
            return false;
        }

        // 创建点赞记录
        CommentLike commentLike = new CommentLike();
        commentLike.setUserId(userId);
        commentLike.setCommentId(commentId);

        return commentLikeMapper.insertCommentLike(commentLike) > 0;
    }

    @Override
    @Transactional
    public boolean unlikeComment(Integer commentId, Integer userId) {
        return commentLikeMapper.deleteCommentLike(userId, commentId) > 0;
    }

    @Override
    @Transactional
    public boolean deleteComment(Integer commentId, Integer userId) {
        // 获取评论信息
        Comment comment = commentMapper.getCommentById(commentId);
        if (comment == null) {
            return false;
        }

        // 验证权限（只能删除自己的评论）
        if (!comment.getUserId().equals(userId)) {
            return false;
        }

        boolean deleted = commentMapper.deleteComment(commentId) > 0;
        // 主动减少父评论的回复数
        if (deleted && comment.getRootCommentId() != null) {
            commentMapper.decreaseReplyCount(comment.getRootCommentId());
        }
        return deleted;
    }

    @Override
    public Integer getCommentCount(Integer aiRoleId) {
        return commentMapper.getCommentCount(aiRoleId);
    }

    @Override
    public Integer getReplyCount(Integer rootCommentId) {
        return commentMapper.getReplyCount(rootCommentId);
    }

    @Override
    public boolean isUserLikedComment(Integer commentId, Integer userId) {
        return commentLikeMapper.checkUserLikedComment(userId, commentId) > 0;
    }
}