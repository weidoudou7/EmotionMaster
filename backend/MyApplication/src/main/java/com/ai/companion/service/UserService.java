package com.ai.companion.service;

import com.ai.companion.entity.User;
import com.ai.companion.entity.vo.UserInfoVO;
import com.ai.companion.entity.vo.UpdateUserRequest;
import com.ai.companion.entity.vo.UserStatsVO;
import org.springframework.web.multipart.MultipartFile;

public interface UserService {
    
    /**
     * 根据UID获取用户信息
     * @param userUID 用户UID
     * @return 用户信息
     */
    UserInfoVO getUserInfo(String userUID);
    
    /**
     * 更新用户信息
     * @param userUID 用户UID
     * @param request 更新请求
     * @return 更新后的用户信息
     */
    UserInfoVO updateUserInfo(String userUID, UpdateUserRequest request);
    
    /**
     * 上传用户头像
     * @param userUID 用户UID
     * @param file 头像文件
     * @return 头像URL
     */
    String uploadAvatar(String userUID, MultipartFile file);
    
    /**
     * 上传用户头像（base64格式）
     * @param userUID 用户UID
     * @param imageData base64格式的图片数据
     * @return 头像URL
     */
    String uploadAvatarBase64(String userUID, String imageData);
    
    /**
     * 切换用户隐私可见性
     * @param userUID 用户UID
     * @return 更新后的隐私状态
     */
    boolean togglePrivacy(String userUID);
    
    /**
     * 创建新用户（如果不存在）
     * @param userUID 用户UID
     * @param userName 用户名称
     * @return 用户信息
     */
    UserInfoVO createUserIfNotExists(String userUID, String userName);
    
    /**
     * 获取用户统计信息
     * @param userUID 用户UID
     * @return 用户统计信息
     */
    UserStatsVO getUserStats(String userUID);
} 