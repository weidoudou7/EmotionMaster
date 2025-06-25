package com.ai.companion.service.impl;

import com.ai.companion.entity.User;
import com.ai.companion.entity.vo.UserInfoVO;
import com.ai.companion.entity.vo.UpdateUserRequest;
import com.ai.companion.service.UserService;
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

@Service
public class UserServiceImpl implements UserService {

    // 内存存储用户数据（实际项目中应该使用数据库）
    private static final Map<String, User> userStorage = new HashMap<>();
    
    // 头像存储路径
    private static final String AVATAR_UPLOAD_PATH = "uploads/avatars/";

    static {
        // 创建默认用户
        User defaultUser = new User("100000000", "用户");
        userStorage.put("100000000", defaultUser);
        
        // 确保头像目录存在
        createAvatarDirectory();
    }

    @Override
    public UserInfoVO getUserInfo(String userUID) {
        User user = userStorage.get(userUID);
        if (user == null) {
            // 如果用户不存在，创建默认用户
            return createUserIfNotExists(userUID, "用户");
        }
        return convertToVO(user);
    }

    @Override
    public UserInfoVO updateUserInfo(String userUID, UpdateUserRequest request) {
        User user = userStorage.get(userUID);
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

        // 保存更新
        userStorage.put(userUID, user);
        
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
            User user = userStorage.get(userUID);
            if (user != null) {
                user.setUserAvatar(avatarUrl);
                user.setUpdateTime(LocalDateTime.now());
                userStorage.put(userUID, user);
            }

            return avatarUrl;
        } catch (IOException e) {
            throw new RuntimeException("头像上传失败: " + e.getMessage());
        }
    }

    @Override
    public boolean togglePrivacy(String userUID) {
        User user = userStorage.get(userUID);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        user.setPrivacyVisible(!user.isPrivacyVisible());
        user.setUpdateTime(LocalDateTime.now());
        userStorage.put(userUID, user);

        return user.isPrivacyVisible();
    }

    @Override
    public UserInfoVO createUserIfNotExists(String userUID, String userName) {
        User user = userStorage.get(userUID);
        if (user == null) {
            user = new User(userUID, userName);
            userStorage.put(userUID, user);
        }
        return convertToVO(user);
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