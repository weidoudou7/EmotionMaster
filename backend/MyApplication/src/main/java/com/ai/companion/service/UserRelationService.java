package com.ai.companion.service;

import com.ai.companion.entity.UserRelation;
import java.util.List;

public interface UserRelationService {
    
    /**
     * 关注用户
     * @param followerUID 关注者UID
     * @param followingUID 被关注者UID
     * @return 是否成功
     */
    boolean followUser(String followerUID, String followingUID);
    
    /**
     * 取消关注用户
     * @param followerUID 关注者UID
     * @param followingUID 被关注者UID
     * @return 是否成功
     */
    boolean unfollowUser(String followerUID, String followingUID);
    
    /**
     * 添加好友
     * @param userUID1 用户1 UID
     * @param userUID2 用户2 UID
     * @return 是否成功
     */
    boolean addFriend(String userUID1, String userUID2);
    
    /**
     * 删除好友
     * @param userUID1 用户1 UID
     * @param userUID2 用户2 UID
     * @return 是否成功
     */
    boolean removeFriend(String userUID1, String userUID2);
    
    /**
     * 获取用户的关注列表
     * @param userUID 用户UID
     * @return 关注列表
     */
    List<String> getFollowingList(String userUID);
    
    /**
     * 获取用户的粉丝列表
     * @param userUID 用户UID
     * @return 粉丝列表
     */
    List<String> getFollowerList(String userUID);
    
    /**
     * 获取用户的好友列表
     * @param userUID 用户UID
     * @return 好友列表
     */
    List<String> getFriendList(String userUID);
    
    /**
     * 检查是否关注
     * @param followerUID 关注者UID
     * @param followingUID 被关注者UID
     * @return 是否关注
     */
    boolean isFollowing(String followerUID, String followingUID);
    
    /**
     * 检查是否是好友
     * @param userUID1 用户1 UID
     * @param userUID2 用户2 UID
     * @return 是否是好友
     */
    boolean isFriend(String userUID1, String userUID2);
    
    /**
     * 获取关注数量
     * @param userUID 用户UID
     * @return 关注数量
     */
    int getFollowingCount(String userUID);
    
    /**
     * 获取粉丝数量
     * @param userUID 用户UID
     * @return 粉丝数量
     */
    int getFollowerCount(String userUID);
    
    /**
     * 获取好友数量
     * @param userUID 用户UID
     * @return 好友数量
     */
    int getFriendCount(String userUID);
} 