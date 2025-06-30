package com.ai.companion.service.impl;

import com.ai.companion.entity.UserRelation;
import com.ai.companion.service.UserRelationService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
public class UserRelationServiceImpl implements UserRelationService {

    // 内存存储用户关系数据（实际项目中应该使用数据库）
    private static final Map<String, UserRelation> relationStorage = new ConcurrentHashMap<>();
    private static final Map<String, Set<String>> followingCache = new ConcurrentHashMap<>();
    private static final Map<String, Set<String>> followerCache = new ConcurrentHashMap<>();
    private static final Map<String, Set<String>> friendCache = new ConcurrentHashMap<>();

    @Override
    public boolean followUser(String followerUID, String followingUID) {
        if (followerUID.equals(followingUID)) {
            throw new RuntimeException("不能关注自己");
        }

        String relationKey = followerUID + "_" + followingUID + "_follow";
        UserRelation existingRelation = relationStorage.get(relationKey);
        
        if (existingRelation != null && existingRelation.getIsActive()) {
            return false; // 已经关注了
        }

        UserRelation relation = new UserRelation(followerUID, followingUID, "follow");
        relationStorage.put(relationKey, relation);
        
        // 更新缓存
        followingCache.computeIfAbsent(followerUID, k -> new HashSet<>()).add(followingUID);
        followerCache.computeIfAbsent(followingUID, k -> new HashSet<>()).add(followerUID);
        
        return true;
    }

    @Override
    public boolean unfollowUser(String followerUID, String followingUID) {
        String relationKey = followerUID + "_" + followingUID + "_follow";
        UserRelation relation = relationStorage.get(relationKey);
        
        if (relation == null || !relation.getIsActive()) {
            return false; // 没有关注关系
        }

        relation.setIsActive(false);
        relation.setUpdateTime(LocalDateTime.now());
        relationStorage.put(relationKey, relation);
        
        // 更新缓存
        Set<String> following = followingCache.get(followerUID);
        if (following != null) {
            following.remove(followingUID);
        }
        
        Set<String> followers = followerCache.get(followingUID);
        if (followers != null) {
            followers.remove(followerUID);
        }
        
        return true;
    }

    @Override
    public boolean addFriend(String userUID1, String userUID2) {
        if (userUID1.equals(userUID2)) {
            throw new RuntimeException("不能添加自己为好友");
        }

        // 确保两个用户都关注了对方
        if (!isFollowing(userUID1, userUID2) || !isFollowing(userUID2, userUID1)) {
            throw new RuntimeException("需要先相互关注才能成为好友");
        }

        String relationKey1 = userUID1 + "_" + userUID2 + "_friend";
        String relationKey2 = userUID2 + "_" + userUID1 + "_friend";
        
        UserRelation relation1 = new UserRelation(userUID1, userUID2, "friend");
        UserRelation relation2 = new UserRelation(userUID2, userUID1, "friend");
        
        relationStorage.put(relationKey1, relation1);
        relationStorage.put(relationKey2, relation2);
        
        // 更新缓存
        friendCache.computeIfAbsent(userUID1, k -> new HashSet<>()).add(userUID2);
        friendCache.computeIfAbsent(userUID2, k -> new HashSet<>()).add(userUID1);
        
        return true;
    }

    @Override
    public boolean removeFriend(String userUID1, String userUID2) {
        String relationKey1 = userUID1 + "_" + userUID2 + "_friend";
        String relationKey2 = userUID2 + "_" + userUID1 + "_friend";
        
        UserRelation relation1 = relationStorage.get(relationKey1);
        UserRelation relation2 = relationStorage.get(relationKey2);
        
        if (relation1 == null || relation2 == null || !relation1.getIsActive() || !relation2.getIsActive()) {
            return false; // 没有好友关系
        }

        relation1.setIsActive(false);
        relation1.setUpdateTime(LocalDateTime.now());
        relation2.setIsActive(false);
        relation2.setUpdateTime(LocalDateTime.now());
        
        relationStorage.put(relationKey1, relation1);
        relationStorage.put(relationKey2, relation2);
        
        // 更新缓存
        Set<String> friends1 = friendCache.get(userUID1);
        if (friends1 != null) {
            friends1.remove(userUID2);
        }
        
        Set<String> friends2 = friendCache.get(userUID2);
        if (friends2 != null) {
            friends2.remove(userUID1);
        }
        
        return true;
    }

    @Override
    public List<String> getFollowingList(String userUID) {
        Set<String> following = followingCache.get(userUID);
        return following != null ? new ArrayList<>(following) : new ArrayList<>();
    }

    @Override
    public List<String> getFollowerList(String userUID) {
        Set<String> followers = followerCache.get(userUID);
        return followers != null ? new ArrayList<>(followers) : new ArrayList<>();
    }

    @Override
    public List<String> getFriendList(String userUID) {
        Set<String> friends = friendCache.get(userUID);
        return friends != null ? new ArrayList<>(friends) : new ArrayList<>();
    }

    @Override
    public boolean isFollowing(String followerUID, String followingUID) {
        Set<String> following = followingCache.get(followerUID);
        return following != null && following.contains(followingUID);
    }

    @Override
    public boolean isFriend(String userUID1, String userUID2) {
        Set<String> friends = friendCache.get(userUID1);
        return friends != null && friends.contains(userUID2);
    }

    @Override
    public int getFollowingCount(String userUID) {
        Set<String> following = followingCache.get(userUID);
        return following != null ? following.size() : 0;
    }

    @Override
    public int getFollowerCount(String userUID) {
        Set<String> followers = followerCache.get(userUID);
        return followers != null ? followers.size() : 0;
    }

    @Override
    public int getFriendCount(String userUID) {
        Set<String> friends = friendCache.get(userUID);
        return friends != null ? friends.size() : 0;
    }
} 