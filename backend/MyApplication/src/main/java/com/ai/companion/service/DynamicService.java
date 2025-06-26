package com.ai.companion.service;

import com.ai.companion.entity.Dynamic;
import java.util.List;

public interface DynamicService {
    
    /**
     * 创建新动态
     */
    Dynamic createDynamic(String userUID, String content, List<String> images);
    
    /**
     * 根据ID获取动态
     */
    Dynamic getDynamicById(int id);
    
    /**
     * 获取用户的所有动态
     */
    List<Dynamic> getUserDynamics(String userUID);
    
    /**
     * 获取用户公开的动态
     */
    List<Dynamic> getUserPublicDynamics(String userUID);
    
    /**
     * 获取所有公开的动态
     */
    List<Dynamic> getAllPublicDynamics();
    
    /**
     * 更新动态
     */
    boolean updateDynamic(int id, String userUID, String content, List<String> images);
    
    /**
     * 删除动态
     */
    boolean deleteDynamic(int id, String userUID);
    
    /**
     * 点赞动态
     */
    boolean likeDynamic(int id);
    
    /**
     * 取消点赞动态
     */
    boolean unlikeDynamic(int id);
} 