package com.ai.companion.controller;

import com.ai.companion.entity.Comment;
import com.ai.companion.service.CommentService;
import com.ai.companion.entity.vo.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 评论控制器
 */
@RestController
@RequestMapping("/comments")
public class CommentController {

    @Autowired
    private CommentService commentService;

    /**
     * 获取AI角色的评论列表
     */
    @GetMapping("/ai-role/{aiRoleId}")
    public ApiResponse<Map<String, Object>> getCommentsByAiRoleId(
            @PathVariable Integer aiRoleId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {

        try {
            List<Comment> comments = commentService.getCommentsByAiRoleId(aiRoleId, page, size);
            Integer totalCount = commentService.getCommentCount(aiRoleId);

            Map<String, Object> result = new HashMap<>();
            result.put("comments", comments);
            result.put("totalCount", totalCount);
            result.put("currentPage", page);
            result.put("pageSize", size);

            return ApiResponse.success(result);
        } catch (Exception e) {
            return ApiResponse.error("获取评论列表失败: " + e.getMessage());
        }
    }

    /**
     * 获取评论的回复列表
     */
    @GetMapping("/{rootCommentId}/replies")
    public ApiResponse<Map<String, Object>> getRepliesByRootCommentId(
            @PathVariable Integer rootCommentId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {

        try {
            List<Comment> replies = commentService.getRepliesByRootCommentId(rootCommentId, page, size);
            Integer totalCount = commentService.getReplyCount(rootCommentId);

            Map<String, Object> result = new HashMap<>();
            result.put("replies", replies);
            result.put("totalCount", totalCount);
            result.put("currentPage", page);
            result.put("pageSize", size);

            return ApiResponse.success(result);
        } catch (Exception e) {
            return ApiResponse.error("获取回复列表失败: " + e.getMessage());
        }
    }

    /**
     * 发布评论
     */
    @PostMapping("/publish")
    public ApiResponse<Map<String, Object>> publishComment(@RequestBody Comment comment) {
        try {
            Integer commentId = commentService.publishComment(comment);

            Map<String, Object> result = new HashMap<>();
            result.put("commentId", commentId);
            result.put("message", "评论发布成功");

            return ApiResponse.success(result);
        } catch (Exception e) {
            return ApiResponse.error("发布评论失败: " + e.getMessage());
        }
    }

    /**
     * 回复评论
     */
    @PostMapping("/reply")
    public ApiResponse<Map<String, Object>> replyComment(@RequestBody Comment comment) {
        try {
            Integer replyId = commentService.replyComment(comment);

            Map<String, Object> result = new HashMap<>();
            result.put("replyId", replyId);
            result.put("message", "回复发布成功");

            return ApiResponse.success(result);
        } catch (Exception e) {
            return ApiResponse.error("发布回复失败: " + e.getMessage());
        }
    }

    /**
     * 点赞评论
     */
    @PostMapping("/{commentId}/like")
    public ApiResponse<Map<String, Object>> likeComment(
            @PathVariable Integer commentId,
            @RequestParam Integer userId) {

        try {
            boolean success = commentService.likeComment(commentId, userId);

            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            result.put("message", success ? "点赞成功" : "已经点赞过了");

            return ApiResponse.success(result);
        } catch (Exception e) {
            return ApiResponse.error("点赞失败: " + e.getMessage());
        }
    }

    /**
     * 取消点赞评论
     */
    @DeleteMapping("/{commentId}/like")
    public ApiResponse<Map<String, Object>> unlikeComment(
            @PathVariable Integer commentId,
            @RequestParam Integer userId) {

        try {
            boolean success = commentService.unlikeComment(commentId, userId);

            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            result.put("message", success ? "取消点赞成功" : "取消点赞失败");

            return ApiResponse.success(result);
        } catch (Exception e) {
            return ApiResponse.error("取消点赞失败: " + e.getMessage());
        }
    }

    /**
     * 删除评论
     */
    @DeleteMapping("/{commentId}")
    public ApiResponse<Map<String, Object>> deleteComment(
            @PathVariable Integer commentId,
            @RequestParam Integer userId) {

        try {
            boolean success = commentService.deleteComment(commentId, userId);

            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            result.put("message", success ? "删除成功" : "删除失败或无权限");

            return ApiResponse.success(result);
        } catch (Exception e) {
            return ApiResponse.error("删除评论失败: " + e.getMessage());
        }
    }

    /**
     * 检查用户是否已点赞评论
     */
    @GetMapping("/{commentId}/liked")
    public ApiResponse<Map<String, Object>> checkUserLikedComment(
            @PathVariable Integer commentId,
            @RequestParam Integer userId) {

        try {
            boolean isLiked = commentService.isUserLikedComment(commentId, userId);

            Map<String, Object> result = new HashMap<>();
            result.put("isLiked", isLiked);

            return ApiResponse.success(result);
        } catch (Exception e) {
            return ApiResponse.error("检查点赞状态失败: " + e.getMessage());
        }
    }
}