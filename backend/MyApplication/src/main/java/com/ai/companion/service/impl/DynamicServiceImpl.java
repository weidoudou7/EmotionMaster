package com.ai.companion.service.impl;

import com.ai.companion.entity.Dynamic;
import com.ai.companion.entity.User;
import com.ai.companion.mapper.DynamicMapper;
import com.ai.companion.mapper.UserMapper;
import com.ai.companion.service.DynamicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class DynamicServiceImpl implements DynamicService {

    private final DynamicMapper dynamicMapper;
    private final UserMapper userMapper;

    @Autowired
    public DynamicServiceImpl(DynamicMapper dynamicMapper, UserMapper userMapper) {
        this.dynamicMapper = dynamicMapper;
        this.userMapper = userMapper;
    }

    @Override
    public Dynamic createDynamic(Integer userId, String content, List<String> images, List<String> topicTags,
            String visibility) {
        Dynamic dynamic = new Dynamic(userId, content, images, topicTags, visibility);
        dynamicMapper.insertDynamic(dynamic);
        return dynamic;
    }

    @Override
    public Dynamic createDynamic(String userUID, String content, List<String> images, List<String> topicTags,
            String visibility) {
        // 通过userUID获取userId
        User user = userMapper.selectByUID(userUID);
        if (user == null) {
            throw new RuntimeException("用户不存在: " + userUID);
        }
        return createDynamic(user.getId(), content, images, topicTags, visibility);
    }

    @Override
    public Dynamic getDynamicById(Integer id) {
        return dynamicMapper.getDynamicById(id);
    }

    @Override
    public List<Dynamic> getUserDynamics(Integer userId) {
        return dynamicMapper.getDynamicsByUserId(userId);
    }

    @Override
    public List<Dynamic> getUserDynamics(String userUID) {
        // 通过userUID获取userId
        User user = userMapper.selectByUID(userUID);
        if (user == null) {
            throw new RuntimeException("用户不存在: " + userUID);
        }
        return getUserDynamics(user.getId());
    }

    @Override
    public List<Dynamic> getUserPublicDynamics(Integer userId) {
        return dynamicMapper.getPublicDynamicsByUserId(userId);
    }

    @Override
    public List<Dynamic> getUserPublicDynamics(String userUID) {
        // 通过userUID获取userId
        User user = userMapper.selectByUID(userUID);
        if (user == null) {
            throw new RuntimeException("用户不存在: " + userUID);
        }
        return getUserPublicDynamics(user.getId());
    }

    @Override
    public List<Dynamic> getAllPublicDynamics() {
        return dynamicMapper.getAllPublicDynamics();
    }

    @Override
    public List<Dynamic> getDynamicsByVisibility(String visibility) {
        return dynamicMapper.getDynamicsByVisibility(visibility);
    }

    @Override
    public List<Dynamic> getHotDynamics(Integer limit) {
        return dynamicMapper.getHotDynamics(limit);
    }

    @Override
    public List<Dynamic> getDynamicsByTopicTag(String topicTag) {
        return dynamicMapper.getDynamicsByTopicTag(topicTag);
    }

    @Override
    public boolean updateDynamic(Integer id, Integer userId, String content, List<String> images,
            List<String> topicTags, String visibility) {
        Dynamic existingDynamic = dynamicMapper.getDynamicById(id);
        if (existingDynamic == null || !existingDynamic.getUserId().equals(userId)) {
            return false;
        }

        existingDynamic.setContent(content);
        existingDynamic.setImages(images);
        existingDynamic.setTopicTags(topicTags);
        existingDynamic.setVisibility(visibility);
        existingDynamic.setUpdatedAt(LocalDateTime.now());

        return dynamicMapper.updateDynamic(existingDynamic) > 0;
    }

    @Override
    public boolean updateDynamic(Integer id, String userUID, String content, List<String> images,
            List<String> topicTags, String visibility) {
        // 通过userUID获取userId
        User user = userMapper.selectByUID(userUID);
        if (user == null) {
            return false;
        }
        return updateDynamic(id, user.getId(), content, images, topicTags, visibility);
    }

    @Override
    public boolean deleteDynamic(Integer id, Integer userId) {
        return dynamicMapper.deleteDynamic(id, userId) > 0;
    }

    @Override
    public boolean deleteDynamic(Integer id, String userUID) {
        // 通过userUID获取userId
        User user = userMapper.selectByUID(userUID);
        if (user == null) {
            return false;
        }
        return deleteDynamic(id, user.getId());
    }

    @Override
    public boolean likeDynamic(Integer id) {
        Dynamic dynamic = dynamicMapper.getDynamicById(id);
        if (dynamic == null) {
            return false;
        }

        dynamic.setLikeCount(dynamic.getLikeCount() + 1);
        return dynamicMapper.updateLikeCount(id, dynamic.getLikeCount()) > 0;
    }

    @Override
    public boolean unlikeDynamic(Integer id) {
        Dynamic dynamic = dynamicMapper.getDynamicById(id);
        if (dynamic == null || dynamic.getLikeCount() <= 0) {
            return false;
        }

        dynamic.setLikeCount(dynamic.getLikeCount() - 1);
        return dynamicMapper.updateLikeCount(id, dynamic.getLikeCount()) > 0;
    }

    @Override
    public boolean incrementViewCount(Integer id) {
        return dynamicMapper.incrementViewCount(id) > 0;
    }
}