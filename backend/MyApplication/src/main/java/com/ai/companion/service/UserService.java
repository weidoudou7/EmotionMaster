package com.ai.companion.service;

import com.ai.companion.entity.User;
import com.ai.companion.entity.vo.UserInfoVO;
import com.ai.companion.entity.vo.UpdateUserRequest;
import com.ai.companion.entity.vo.UserStatsVO;
import com.ai.companion.entity.vo.PreviewAvatarResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface UserService {
    
    /**
     * 根据UID获取用户信息
     * @param userUID 用户UID
     * @return 用户信息
     */
    UserInfoVO getUserInfo(String userUID);
    
    /**
     * 根据用户ID获取用户信息
     * @param userId 用户ID
     * @return 用户信息
     */
    UserInfoVO getUserInfoById(Integer userId);

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
     * 生成新的随机头像
     * @param userUID 用户UID
     * @return 新头像URL
     */
    String generateNewAvatar(String userUID);
    
    /**
     * 生成预览头像
     * @param userUID 用户UID
     * @return 预览头像的base64编码和种子信息
     */
    PreviewAvatarResponse generatePreviewAvatar(String userUID);
    
    /**
     * 确认并保存预览的头像
     * @param userUID 用户UID
     * @param previewSeed 预览种子
     * @return 保存的头像URL
     */
    String confirmPreviewAvatar(String userUID, long previewSeed);
    
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

    
    /**
     * 通过用户名关键词模糊搜索用户
     * @param keyword 用户名关键词
     * @return 匹配的用户信息列表
     */
    List<UserInfoVO> searchUsersByName(String keyword);
    
    /**
     * 删除用户
     * @param userUID 用户UID
     * @return 是否删除成功
     */
    boolean deleteUser(String userUID);
    
    /**
     * 插入新用户
     * @param user 用户实体
     * @return 影响的行数
     */
    int insertUser(User user);

    /**
     *
     * @param email 邮箱
     * @return
     */
    UserInfoVO createOrLoginUserByEmail(String email);

    /**
     * 根据邮箱获取用户ID
     * @param email 邮箱地址
     * @return 用户ID，如果用户不存在则返回null
     */
    Integer getUserIdByEmail(String email);

} 