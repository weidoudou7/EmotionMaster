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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

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
        System.out.println("🔍 UserService: 正在查询用户UID: " + userUID);
        User user = userMapper.selectByUID(userUID);
        if (user == null) {
            System.out.println("❌ UserService: 用户不存在，UID: " + userUID);
            throw new RuntimeException("用户不存在");
        }
        System.out.println("✅ UserService: 找到用户，UID: " + userUID + ", 用户名: " + user.getUserName());
        return convertToVO(user);
    }

    @Override
    public UserInfoVO getUserInfoById(Integer userId) {
        System.out.println("🔍 UserService: 正在查询用户ID: " + userId);
        User user = userMapper.selectById(userId);
        if (user == null) {
            System.out.println("❌ UserService: 用户不存在，ID: " + userId);
            throw new RuntimeException("用户不存在");
        }
        System.out.println("✅ UserService: 找到用户，ID: " + userId + ", 用户名: " + user.getUserName());
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
    public String uploadAvatarBase64(String userUID, String imageData) {
        System.out.println("🖼️ [Service] 开始处理Base64头像上传");
        System.out.println("🖼️ [Service] 用户UID: " + userUID);
        
        if (imageData == null || imageData.trim().isEmpty()) {
            System.out.println("❌ [Service] 图片数据为空");
            throw new RuntimeException("图片数据为空");
        }

        try {
            // 解析base64数据
            String[] parts = imageData.split(",");
            if (parts.length != 2) {
                System.out.println("❌ [Service] 无效的base64图片数据格式，parts长度: " + parts.length);
                throw new RuntimeException("无效的base64图片数据格式");
            }

            String header = parts[0];
            String base64Data = parts[1];
            
            System.out.println("🖼️ [Service] Base64头部信息: " + header);
            System.out.println("🖼️ [Service] Base64数据长度: " + base64Data.length());

            // 确定文件扩展名
            String extension = ".jpg"; // 默认扩展名
            if (header.contains("image/png")) {
                extension = ".png";
            } else if (header.contains("image/gif")) {
                extension = ".gif";
            } else if (header.contains("image/webp")) {
                extension = ".webp";
            }
            
            System.out.println("🖼️ [Service] 检测到的文件扩展名: " + extension);

            // 生成唯一文件名
            String filename = userUID + "_" + UUID.randomUUID().toString() + extension;
            System.out.println("🖼️ [Service] 生成的文件名: " + filename);

            // 解码base64数据
            byte[] imageBytes = java.util.Base64.getDecoder().decode(base64Data);
            System.out.println("🖼️ [Service] 解码后的图片字节数: " + imageBytes.length);

            // 保存文件
            Path uploadPath = Paths.get(AVATAR_UPLOAD_PATH);
            System.out.println("🖼️ [Service] 上传目录路径: " + uploadPath.toAbsolutePath());
            
            if (!Files.exists(uploadPath)) {
                System.out.println("🖼️ [Service] 创建上传目录");
                Files.createDirectories(uploadPath);
            }

            Path filePath = uploadPath.resolve(filename);
            System.out.println("🖼️ [Service] 完整文件路径: " + filePath.toAbsolutePath());
            
            Files.write(filePath, imageBytes);
            System.out.println("🖼️ [Service] 文件写入成功，文件大小: " + Files.size(filePath) + " 字节");

            // 更新用户头像信息
            String avatarUrl = "/avatars/" + filename;
            System.out.println("🖼️ [Service] 生成的相对URL: " + avatarUrl);
            
            User user = userMapper.selectByUID(userUID);
            if (user != null) {
                System.out.println("🖼️ [Service] 找到用户，更新头像URL");
                user.setUserAvatar(avatarUrl);
                user.setUpdateTime(LocalDateTime.now());
                userMapper.updateUser(user);
                System.out.println("🖼️ [Service] 用户头像URL已更新到数据库");
            } else {
                System.out.println("⚠️ [Service] 警告：未找到用户 " + userUID + "，无法更新数据库");
            }

            System.out.println("🖼️ [Service] 头像上传完成，返回URL: " + avatarUrl);
            return avatarUrl;
        } catch (Exception e) {
            System.out.println("❌ [Service] 头像上传失败: " + e.getMessage());
            e.printStackTrace();
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

    @Override
    public List<UserInfoVO> searchUsersByName(String keyword) {
        List<User> users = userMapper.searchUsers(keyword, 50); // 限制最多返回50个
        List<UserInfoVO> result = new ArrayList<>();
        for (User user : users) {
            result.add(convertToVO(user));
        }
        return result;
    }

    @Override
    public int insertUser(User user) {
        return userMapper.insertUser(user);
    }
    
    @Override
    public boolean deleteUser(String userUID) {
        try {
            int result = userMapper.deleteUser(userUID);
            return result > 0;
        } catch (Exception e) {
            System.err.println("删除用户失败: " + e.getMessage());
            return false;
        }
    }
    @Override
    public UserInfoVO createOrLoginUserByEmail(String email) {
        User user = userMapper.selectByEmail(email);
        LocalDateTime now = LocalDateTime.now();
        if (user == null) {
            System.out.println("[用户注册] 插入新用户: " + email);
            String userUID = UUID.randomUUID().toString().replace("-", "");
            user = new User();
            user.setUserUID(userUID);
            user.setUserName("用户" + userUID.substring(0, 6));
            user.setGender("未设置");
            user.setPrivacyVisible(false);
            user.setSignature("这个人很懒，什么都没留下~");
            user.setEmail(email);
            user.setLevel(1);
            user.setRegisterTime(now);
            user.setUpdateTime(now);
            user.setUserAvatar("/avatars/default.png");
            userMapper.insertUser(user);
        } else {
            System.out.println("[用户登录] 更新老用户登录时间: " + email);
            user.setUpdateTime(now);
            userMapper.updateUser(user);
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