package com.ai.companion.service.impl;

import com.ai.companion.entity.User;
import com.ai.companion.entity.vo.UserInfoVO;
import com.ai.companion.entity.vo.UpdateUserRequest;
import com.ai.companion.entity.vo.UserStatsVO;
import com.ai.companion.service.UserService;
import com.ai.companion.service.DynamicService;
import com.ai.companion.service.UserRelationService;
import com.ai.companion.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.List;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private DynamicService dynamicService;
    
    @Autowired
    private UserRelationService userRelationService;
    
    @Autowired
    private UserMapper userMapper;

    // 头像存储路径
    private static final String AVATAR_UPLOAD_PATH = "uploads/avatars/";

    static {
        // 确保头像目录存在
        createAvatarDirectory();
    }

    @Override
    public UserInfoVO getUserInfo(String userUID) {
        User user = userMapper.selectByUID(userUID);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        return convertToVO(user);
    }

    @Override
    public UserInfoVO updateUserInfo(String userUID, UpdateUserRequest request) {
        User user = userMapper.selectByUID(userUID);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        // 更新用户信息
        if (request.getUserName() != null && !request.getUserName().trim().isEmpty()) {
            user.setUserName(request.getUserName().trim());
        }
        if (request.getUserAvatar() != null) {
            user.setUserAvatar(request.getUserAvatar());
        }
        if (request.getGender() != null) {
            user.setGender(request.getGender());
        }
        if (request.getSignature() != null) {
            user.setSignature(request.getSignature());
        }
        
        user.setPrivacyVisible(request.isPrivacyVisible());
        user.setUpdateTime(LocalDateTime.now());

        // 保存更新到数据库
        userMapper.updateUser(user);
        
        return convertToVO(user);
    }

    @Override
    public String uploadAvatar(String userUID, MultipartFile file) {
        if (file.isEmpty()) {
            throw new RuntimeException("上传的文件为空");
        }

        // 检查文件类型
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new RuntimeException("只能上传图片文件");
        }

        // 生成唯一文件名
        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        String filename = userUID + "_" + UUID.randomUUID().toString() + extension;

        try {
            // 保存文件
            Path uploadPath = Paths.get(AVATAR_UPLOAD_PATH);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            Path filePath = uploadPath.resolve(filename);
            Files.copy(file.getInputStream(), filePath);

            // 更新用户头像信息
            String avatarUrl = "/avatars/" + filename;
            User user = userMapper.selectByUID(userUID);
            if (user != null) {
                user.setUserAvatar(avatarUrl);
                user.setUpdateTime(LocalDateTime.now());
                userMapper.updateUser(user);
            }

            return avatarUrl;
        } catch (IOException e) {
            throw new RuntimeException("头像上传失败: " + e.getMessage());
        }
    }

    @Override
    public boolean togglePrivacy(String userUID) {
        User user = userMapper.selectByUID(userUID);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        user.setPrivacyVisible(!user.isPrivacyVisible());
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateUser(user);

        return user.isPrivacyVisible();
    }

    @Override
    public UserInfoVO createUserIfNotExists(String userUID, String userName) {
        User user = userMapper.selectByUID(userUID);
        if (user == null) {
            user = new User(userUID, userName);
            userMapper.insertUser(user);
        }
        return convertToVO(user);
    }

    @Override
    public UserStatsVO getUserStats(String userUID) {
        // 确保用户存在
        User user = userMapper.selectByUID(userUID);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        
        // 获取用户动态数量
        List<com.ai.companion.entity.Dynamic> userDynamics = dynamicService.getUserDynamics(userUID);
        int dynamicCount = userDynamics.size();
        
        // 计算总获赞数
        int totalLikes = userDynamics.stream()
                .mapToInt(dynamic -> dynamic.getLikeCount() != null ? dynamic.getLikeCount() : 0)
                .sum();
        
        // 获取真实的社交数据
        int followingCount = userRelationService.getFollowingCount(userUID);
        int followerCount = userRelationService.getFollowerCount(userUID);
        int friendCount = userRelationService.getFriendCount(userUID);
        
        // 计算总浏览量（模拟数据，实际项目中应该从数据库获取）
        int totalViews = userDynamics.stream()
                .mapToInt(dynamic -> (int) (Math.random() * 1000) + 100)
                .sum();
        
        return new UserStatsVO(
            userUID,
            dynamicCount,
            followingCount,
            followerCount,
            friendCount,
            totalLikes,
            totalViews
        );
    }

    /**
     * 将User实体转换为UserInfoVO
     */
    private UserInfoVO convertToVO(User user) {
        return new UserInfoVO(
            user.getUserName(),
            user.getUserUID(),
            user.getUserAvatar(),
            user.isPrivacyVisible(),
            user.getLevel(),
            user.getGender(),
            user.getSignature(),
            user.getRegisterTime(),
            user.getUpdateTime()
        );
    }

    /**
     * 创建头像目录
     */
    private static void createAvatarDirectory() {
        try {
            Path uploadPath = Paths.get(AVATAR_UPLOAD_PATH);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
        } catch (IOException e) {
            System.err.println("创建头像目录失败: " + e.getMessage());
        }
    }
} 