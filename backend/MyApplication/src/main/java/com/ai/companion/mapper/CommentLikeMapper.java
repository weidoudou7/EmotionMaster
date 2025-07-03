package com.ai.companion.mapper;

import com.ai.companion.entity.CommentLike;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 评论点赞Mapper接口
 */
@Mapper
public interface CommentLikeMapper {

    /**
     * 插入点赞记录
     * 
     * @param commentLike 点赞记录
     * @return 影响行数
     */
    int insertCommentLike(CommentLike commentLike);

    /**
     * 删除点赞记录
     * 
     * @param userId    用户ID
     * @param commentId 评论ID
     * @return 影响行数
     */
    int deleteCommentLike(@Param("userId") Integer userId, @Param("commentId") Integer commentId);

    /**
     * 检查用户是否已点赞评论
     * 
     * @param userId    用户ID
     * @param commentId 评论ID
     * @return 点赞记录数量
     */
    int checkUserLikedComment(@Param("userId") Integer userId, @Param("commentId") Integer commentId);
}