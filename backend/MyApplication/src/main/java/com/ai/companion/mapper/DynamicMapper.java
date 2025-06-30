package com.ai.companion.mapper;

import com.ai.companion.entity.Dynamic;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface DynamicMapper {

    /**
     * 创建新动态
     */
    int insertDynamic(Dynamic dynamic);

    /**
     * 根据ID获取动态
     */
    Dynamic getDynamicById(@Param("id") Integer id);

    /**
     * 获取用户的所有动态
     */
    List<Dynamic> getDynamicsByUserId(@Param("userId") Integer userId);

    /**
     * 获取用户公开的动态
     */
    List<Dynamic> getPublicDynamicsByUserId(@Param("userId") Integer userId);

    /**
     * 获取所有公开的动态（按时间倒序）
     */
    List<Dynamic> getAllPublicDynamics();

    /**
     * 根据可见性获取动态
     */
    List<Dynamic> getDynamicsByVisibility(@Param("visibility") String visibility);

    /**
     * 获取热门动态（按点赞数排序）
     */
    List<Dynamic> getHotDynamics(@Param("limit") Integer limit);

    /**
     * 根据话题标签获取动态
     */
    List<Dynamic> getDynamicsByTopicTag(@Param("topicTag") String topicTag);

    /**
     * 更新动态
     */
    int updateDynamic(Dynamic dynamic);

    /**
     * 删除动态
     */
    int deleteDynamic(@Param("id") Integer id, @Param("userId") Integer userId);

    /**
     * 更新动态点赞数
     */
    int updateLikeCount(@Param("id") Integer id, @Param("likeCount") Integer likeCount);

    /**
     * 增加动态浏览量
     */
    int incrementViewCount(@Param("id") Integer id);
}