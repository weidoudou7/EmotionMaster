package com.ai.companion.mapper;

import com.ai.companion.entity.Comment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 评论Mapper接口
 */
@Mapper
public interface CommentMapper {

        /**
         * 分页获取顶级评论列表以及各自的子评论总数
         * 
         * @param aiRoleId AI角色ID
         * @param offset   偏移量
         * @param limit    限制数量
         * @return 评论列表
         */
        List<Comment> getRootCommentsWithReplyCount(@Param("aiRoleId") Integer aiRoleId,
                        @Param("offset") Integer offset,
                        @Param("limit") Integer limit);

        /**
         * 根据顶级评论的id列表，获取他们各自前三条子评论
         * 
         * @param rootCommentIds 根评论ID列表
         * @return 回复评论列表
         */
        List<Comment> getTopRepliesByRootCommentIds(@Param("rootCommentIds") List<Integer> rootCommentIds);

        /**
         * 根据root_comment_id分页获取子评论
         * 
         * @param rootCommentId 根评论ID
         * @param offset        偏移量
         * @param limit         限制数量
         * @return 回复评论列表
         */
        List<Comment> getRepliesByRootCommentId(@Param("rootCommentId") Integer rootCommentId,
                        @Param("offset") Integer offset,
                        @Param("limit") Integer limit);

        /**
         * 插入新评论
         * 
         * @param comment 评论对象
         * @return 影响行数
         */
        int insertComment(Comment comment);

        /**
         * 根据ID查询评论
         * 
         * @param id 评论ID
         * @return 评论对象
         */
        Comment getCommentById(@Param("id") Integer id);

        /**
         * 更新评论
         * 
         * @param comment 评论对象
         * @return 影响行数
         */
        int updateComment(Comment comment);

        /**
         * 删除评论（软删除）
         * 
         * @param id 评论ID
         * @return 影响行数
         */
        int deleteComment(@Param("id") Integer id);

        /**
         * 获取评论总数
         * 
         * @param aiRoleId AI角色ID
         * @return 评论总数
         */
        int getCommentCount(@Param("aiRoleId") Integer aiRoleId);

        /**
         * 获取回复总数
         * 
         * @param rootCommentId 根评论ID
         * @return 回复总数
         */
        Integer getReplyCount(@Param("rootCommentId") Integer rootCommentId);

        /**
         * 增加评论回复数
         * 
         * @param commentId 评论ID
         */
        void increaseReplyCount(@Param("commentId") Integer commentId);

        /**
         * 减少评论回复数
         * 
         * @param commentId 评论ID
         */
        void decreaseReplyCount(@Param("commentId") Integer commentId);

        /**
         * 判断用户是否点赞了评论
         * 
         * @param commentId 评论ID
         * @param userId    用户ID
         * @return 是否点赞
         */
        boolean isUserLikedComment(@Param("commentId") Integer commentId, @Param("userId") Integer userId);
}