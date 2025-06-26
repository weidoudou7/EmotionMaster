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
    Dynamic getDynamicById(@Param("id") int id);
    
    /**
     * 获取用户的所有动态
     */
    List<Dynamic> getDynamicsByUserUID(@Param("userUID") String userUID);
    
    /**
     * 获取用户公开的动态
     */
    List<Dynamic> getPublicDynamicsByUserUID(@Param("userUID") String userUID);
    
    /**
     * 获取所有公开的动态（按时间倒序）
     */
    List<Dynamic> getAllPublicDynamics();
    
    /**
     * 更新动态
     */
    int updateDynamic(Dynamic dynamic);
    
    /**
     * 删除动态
     */
    int deleteDynamic(@Param("id") int id, @Param("userUID") String userUID);
    
    /**
     * 更新动态点赞数
     */
    int updateLikeCount(@Param("id") int id, @Param("likeCount") int likeCount);
    
    /**
     * 更新动态评论数
     */
    int updateCommentCount(@Param("id") int id, @Param("commentCount") int commentCount);
} 