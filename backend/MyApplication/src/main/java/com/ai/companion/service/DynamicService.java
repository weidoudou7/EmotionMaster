package com.ai.companion.service;

import com.ai.companion.entity.Dynamic;
import java.util.List;

public interface DynamicService {

    /**
     * 创建新动态
     */
    Dynamic createDynamic(Integer userId, String content, List<String> images, List<String> topicTags,
            String visibility);

    /**
     * 创建新动态（使用userUID）
     */
    Dynamic createDynamic(String userUID, String content, List<String> images, List<String> topicTags,
            String visibility);

    /**
     * 根据ID获取动态
     */
    Dynamic getDynamicById(Integer id);

    /**
     * 获取用户的所有动态
     */
    List<Dynamic> getUserDynamics(Integer userId);

    /**
     * 获取用户的所有动态（使用userUID）
     */
    List<Dynamic> getUserDynamics(String userUID);

    /**
     * 获取用户公开的动态
     */
    List<Dynamic> getUserPublicDynamics(Integer userId);

    /**
     * 获取用户公开的动态（使用userUID）
     */
    List<Dynamic> getUserPublicDynamics(String userUID);

    /**
     * 获取所有公开的动态
     */
    List<Dynamic> getAllPublicDynamics();

    /**
     * 根据可见性获取动态
     */
    List<Dynamic> getDynamicsByVisibility(String visibility);

    /**
     * 获取热门动态
     */
    List<Dynamic> getHotDynamics(Integer limit);

    /**
     * 根据话题标签获取动态
     */
    List<Dynamic> getDynamicsByTopicTag(String topicTag);

    /**
     * 更新动态
     */
    boolean updateDynamic(Integer id, Integer userId, String content, List<String> images, List<String> topicTags,
            String visibility);

    /**
     * 更新动态（使用userUID）
     */
    boolean updateDynamic(Integer id, String userUID, String content, List<String> images, List<String> topicTags,
            String visibility);

    /**
     * 删除动态
     */
    boolean deleteDynamic(Integer id, Integer userId);

    /**
     * 删除动态（使用userUID）
     */
    boolean deleteDynamic(Integer id, String userUID);

    /**
     * 点赞动态
     */
    boolean likeDynamic(Integer id);

    /**
     * 取消点赞动态
     */
    boolean unlikeDynamic(Integer id);

    /**
     * 增加动态浏览量
     */
    boolean incrementViewCount(Integer id);
}