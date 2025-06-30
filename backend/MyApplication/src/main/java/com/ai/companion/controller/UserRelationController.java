package com.ai.companion.controller;

import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.service.UserRelationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/relation")
@CrossOrigin(origins = "*") // 允许跨域请求
public class UserRelationController {

    private final UserRelationService userRelationService;

    /**
     * 关注用户
     * @param followerUID 关注者UID
     * @param followingUID 被关注者UID
     * @return 操作结果
     */
    @PostMapping("/follow")
    public ApiResponse<Boolean> followUser(
            @RequestParam String followerUID,
            @RequestParam String followingUID) {
        try {
            boolean success = userRelationService.followUser(followerUID, followingUID);
            if (success) {
                return ApiResponse.success("关注成功", true);
            } else {
                return ApiResponse.error("已经关注过该用户");
            }
        } catch (Exception e) {
            return ApiResponse.error("关注失败: " + e.getMessage());
        }
    }

    /**
     * 取消关注用户
     * @param followerUID 关注者UID
     * @param followingUID 被关注者UID
     * @return 操作结果
     */
    @PostMapping("/unfollow")
    public ApiResponse<Boolean> unfollowUser(
            @RequestParam String followerUID,
            @RequestParam String followingUID) {
        try {
            boolean success = userRelationService.unfollowUser(followerUID, followingUID);
            if (success) {
                return ApiResponse.success("取消关注成功", true);
            } else {
                return ApiResponse.error("没有关注关系");
            }
        } catch (Exception e) {
            return ApiResponse.error("取消关注失败: " + e.getMessage());
        }
    }

    /**
     * 添加好友
     * @param userUID1 用户1 UID
     * @param userUID2 用户2 UID
     * @return 操作结果
     */
    @PostMapping("/friend/add")
    public ApiResponse<Boolean> addFriend(
            @RequestParam String userUID1,
            @RequestParam String userUID2) {
        try {
            boolean success = userRelationService.addFriend(userUID1, userUID2);
            if (success) {
                return ApiResponse.success("添加好友成功", true);
            } else {
                return ApiResponse.error("添加好友失败");
            }
        } catch (Exception e) {
            return ApiResponse.error("添加好友失败: " + e.getMessage());
        }
    }

    /**
     * 删除好友
     * @param userUID1 用户1 UID
     * @param userUID2 用户2 UID
     * @return 操作结果
     */
    @PostMapping("/friend/remove")
    public ApiResponse<Boolean> removeFriend(
            @RequestParam String userUID1,
            @RequestParam String userUID2) {
        try {
            boolean success = userRelationService.removeFriend(userUID1, userUID2);
            if (success) {
                return ApiResponse.success("删除好友成功", true);
            } else {
                return ApiResponse.error("没有好友关系");
            }
        } catch (Exception e) {
            return ApiResponse.error("删除好友失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户的关注列表
     * @param userUID 用户UID
     * @return 关注列表
     */
    @GetMapping("/following/{userUID}")
    public ApiResponse<List<String>> getFollowingList(@PathVariable String userUID) {
        try {
            List<String> followingList = userRelationService.getFollowingList(userUID);
            return ApiResponse.success("获取关注列表成功", followingList);
        } catch (Exception e) {
            return ApiResponse.error("获取关注列表失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户的粉丝列表
     * @param userUID 用户UID
     * @return 粉丝列表
     */
    @GetMapping("/followers/{userUID}")
    public ApiResponse<List<String>> getFollowerList(@PathVariable String userUID) {
        try {
            List<String> followerList = userRelationService.getFollowerList(userUID);
            return ApiResponse.success("获取粉丝列表成功", followerList);
        } catch (Exception e) {
            return ApiResponse.error("获取粉丝列表失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户的好友列表
     * @param userUID 用户UID
     * @return 好友列表
     */
    @GetMapping("/friends/{userUID}")
    public ApiResponse<List<String>> getFriendList(@PathVariable String userUID) {
        try {
            List<String> friendList = userRelationService.getFriendList(userUID);
            return ApiResponse.success("获取好友列表成功", friendList);
        } catch (Exception e) {
            return ApiResponse.error("获取好友列表失败: " + e.getMessage());
        }
    }

    /**
     * 检查是否关注
     * @param followerUID 关注者UID
     * @param followingUID 被关注者UID
     * @return 是否关注
     */
    @GetMapping("/isFollowing")
    public ApiResponse<Boolean> isFollowing(
            @RequestParam String followerUID,
            @RequestParam String followingUID) {
        try {
            boolean isFollowing = userRelationService.isFollowing(followerUID, followingUID);
            return ApiResponse.success("检查关注状态成功", isFollowing);
        } catch (Exception e) {
            return ApiResponse.error("检查关注状态失败: " + e.getMessage());
        }
    }

    /**
     * 检查是否是好友
     * @param userUID1 用户1 UID
     * @param userUID2 用户2 UID
     * @return 是否是好友
     */
    @GetMapping("/isFriend")
    public ApiResponse<Boolean> isFriend(
            @RequestParam String userUID1,
            @RequestParam String userUID2) {
        try {
            boolean isFriend = userRelationService.isFriend(userUID1, userUID2);
            return ApiResponse.success("检查好友状态成功", isFriend);
        } catch (Exception e) {
            return ApiResponse.error("检查好友状态失败: " + e.getMessage());
        }
    }

    /**
     * 获取关注数量
     * @param userUID 用户UID
     * @return 关注数量
     */
    @GetMapping("/following/count/{userUID}")
    public ApiResponse<Integer> getFollowingCount(@PathVariable String userUID) {
        try {
            int count = userRelationService.getFollowingCount(userUID);
            return ApiResponse.success("获取关注数量成功", count);
        } catch (Exception e) {
            return ApiResponse.error("获取关注数量失败: " + e.getMessage());
        }
    }

    /**
     * 获取粉丝数量
     * @param userUID 用户UID
     * @return 粉丝数量
     */
    @GetMapping("/followers/count/{userUID}")
    public ApiResponse<Integer> getFollowerCount(@PathVariable String userUID) {
        try {
            int count = userRelationService.getFollowerCount(userUID);
            return ApiResponse.success("获取粉丝数量成功", count);
        } catch (Exception e) {
            return ApiResponse.error("获取粉丝数量失败: " + e.getMessage());
        }
    }

    /**
     * 获取好友数量
     * @param userUID 用户UID
     * @return 好友数量
     */
    @GetMapping("/friends/count/{userUID}")
    public ApiResponse<Integer> getFriendCount(@PathVariable String userUID) {
        try {
            int count = userRelationService.getFriendCount(userUID);
            return ApiResponse.success("获取好友数量成功", count);
        } catch (Exception e) {
            return ApiResponse.error("获取好友数量失败: " + e.getMessage());
        }
    }

    /**
     * 健康检查接口
     * @return 服务状态
     */
    @GetMapping("/health")
    public ApiResponse<String> health() {
        return ApiResponse.success("用户关系服务运行正常", "OK");
    }
} 