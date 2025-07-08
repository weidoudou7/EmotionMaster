package com.ai.companion.controller;

import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.entity.vo.UserInfoVO;
import com.ai.companion.entity.vo.UpdateUserRequest;
import com.ai.companion.entity.vo.UserStatsVO;
import com.ai.companion.entity.vo.AvatarUploadRequest;
import com.ai.companion.entity.vo.PreviewAvatarResponse;
import com.ai.companion.service.UserService;
import com.ai.companion.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.ai.companion.entity.User;
import com.ai.companion.service.OssService;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@RestController
@RequestMapping("/user")
@CrossOrigin(origins = "http://localhost:8080", allowCredentials = "true") // 允许跨域请求
public class UserController {

    private final UserService userService;
    private final OssService ossService;
    private final UserMapper userMapper;

    /**
     * 获取用户信息
     * @param userUID 用户UID
     * @return 用户信息
     */
    @GetMapping("/{userUID}")
    public ApiResponse<UserInfoVO> getUserInfo(@PathVariable String userUID) {
        try {
            UserInfoVO userInfo = userService.getUserInfo(userUID);
            return ApiResponse.success("获取用户信息成功", userInfo);
        } catch (Exception e) {
            return ApiResponse.error("获取用户信息失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户统计信息
     * @param userUID 用户UID
     * @return 用户统计信息
     */
    @GetMapping("/{userUID}/stats")
    public ApiResponse<UserStatsVO> getUserStats(@PathVariable String userUID) {
        try {
            UserStatsVO userStats = userService.getUserStats(userUID);
            return ApiResponse.success("获取用户统计信息成功", userStats);
        } catch (Exception e) {
            return ApiResponse.error("获取用户统计信息失败: " + e.getMessage());
        }
    }

    /**
     * 更新用户信息
     * @param userUID 用户UID
     * @param request 更新请求
     * @return 更新后的用户信息
     */
    @PutMapping("/{userUID}")
    public ApiResponse<UserInfoVO> updateUserInfo(
            @PathVariable String userUID,
            @RequestBody UpdateUserRequest request) {
        try {
            UserInfoVO userInfo = userService.updateUserInfo(userUID, request);
            return ApiResponse.success("更新用户信息成功", userInfo);
        } catch (Exception e) {
            return ApiResponse.error("更新用户信息失败: " + e.getMessage());
        }
    }

    /**
     * 上传用户头像
     * @param userUID 用户UID
     * @param file 头像文件
     * @return 头像URL
     */
    @PostMapping("/{userUID}/avatar")
    public ApiResponse<String> uploadAvatar(
            @PathVariable String userUID,
            @RequestParam("file") MultipartFile file) {
        try {
            String avatarUrl = userService.uploadAvatar(userUID, file);
            return ApiResponse.success("头像上传成功", avatarUrl);
        } catch (Exception e) {
            return ApiResponse.error("头像上传失败: " + e.getMessage());
        }
    }

    /**
     * 上传用户头像（base64格式）
     * @param userUID 用户UID
     * @param request 包含base64图片数据的请求
     * @return 头像URL
     */
    @PostMapping("/{userUID}/avatar/base64")
    public ApiResponse<String> uploadAvatarBase64(
            @PathVariable String userUID,
            @RequestBody AvatarUploadRequest request) {
        try {
            String avatarUrl = userService.uploadAvatarBase64(userUID, request.getImageData());
            return ApiResponse.success("头像上传成功", avatarUrl);
        } catch (Exception e) {
            return ApiResponse.error("头像上传失败: " + e.getMessage());
        }
    }

    /**
     * 生成新的随机头像
     * @param userUID 用户UID
     * @return 新头像URL
     */
    @PostMapping("/{userUID}/avatar/generate")
    public ApiResponse<String> generateNewAvatar(@PathVariable String userUID) {
        System.out.println("🎨 ========== 头像生成请求开始 ==========");
        System.out.println("🎨 [Controller] 收到头像生成请求");
        System.out.println("🎨 [Controller] 用户UID: " + userUID);
        System.out.println("🎨 [Controller] 请求时间: " + java.time.LocalDateTime.now());
        System.out.println("🎨 [Controller] 请求路径: POST /user/" + userUID + "/avatar/generate");
        
        try {
            System.out.println("🎨 [Controller] 调用UserService.generateNewAvatar()");
            String avatarUrl = userService.generateNewAvatar(userUID);
            
            System.out.println("🎨 [Controller] UserService返回头像URL: " + avatarUrl);
            System.out.println("🎨 [Controller] 头像生成成功，准备返回响应");
            System.out.println("🎨 ========== 头像生成请求成功 ==========");
            
            return ApiResponse.success("头像生成成功", avatarUrl);
        } catch (Exception e) {
            System.err.println("❌ [Controller] 头像生成过程中发生异常");
            System.err.println("❌ [Controller] 异常类型: " + e.getClass().getSimpleName());
            System.err.println("❌ [Controller] 异常消息: " + e.getMessage());
            System.err.println("❌ [Controller] 异常堆栈:");
            e.printStackTrace();
            System.err.println("❌ ========== 头像生成请求失败 ==========");
            
            return ApiResponse.error("头像生成失败: " + e.getMessage());
        }
    }

    /**
     * 生成预览头像
     * @param userUID 用户UID
     * @return 预览头像信息
     */
    @PostMapping("/{userUID}/avatar/preview")
    public ApiResponse<PreviewAvatarResponse> generatePreviewAvatar(@PathVariable String userUID) {
        System.out.println("👁️ ========== 预览头像请求开始 ==========");
        System.out.println("👁️ [Controller] 收到预览头像请求");
        System.out.println("👁️ [Controller] 用户UID: " + userUID);
        System.out.println("👁️ [Controller] 请求时间: " + java.time.LocalDateTime.now());
        System.out.println("👁️ [Controller] 请求路径: POST /user/" + userUID + "/avatar/preview");
        
        try {
            System.out.println("👁️ [Controller] 调用UserService.generatePreviewAvatar()");
            PreviewAvatarResponse previewResponse = userService.generatePreviewAvatar(userUID);
            
            System.out.println("👁️ [Controller] UserService返回预览响应");
            System.out.println("👁️ [Controller] 预览种子: " + previewResponse.getPreviewSeed());
            System.out.println("👁️ [Controller] 预览图片长度: " + previewResponse.getPreviewImage().length());
            System.out.println("👁️ [Controller] 预览头像生成成功，准备返回响应");
            System.out.println("👁️ ========== 预览头像请求成功 ==========");
            
            return ApiResponse.success("预览头像生成成功", previewResponse);
        } catch (Exception e) {
            System.err.println("❌ [Controller] 预览头像生成过程中发生异常");
            System.err.println("❌ [Controller] 异常类型: " + e.getClass().getSimpleName());
            System.err.println("❌ [Controller] 异常消息: " + e.getMessage());
            System.err.println("❌ [Controller] 异常堆栈:");
            e.printStackTrace();
            System.err.println("❌ ========== 预览头像请求失败 ==========");
            
            return ApiResponse.error("预览头像生成失败: " + e.getMessage());
        }
    }

    /**
     * 确认并保存预览头像
     * @param userUID 用户UID
     * @param previewSeed 预览种子
     * @return 保存的头像URL
     */
    @PostMapping("/{userUID}/avatar/confirm")
    public ApiResponse<String> confirmPreviewAvatar(
            @PathVariable String userUID,
            @RequestParam long previewSeed) {
        System.out.println("💾 ========== 确认头像请求开始 ==========");
        System.out.println("💾 [Controller] 收到确认头像请求");
        System.out.println("💾 [Controller] 用户UID: " + userUID);
        System.out.println("💾 [Controller] 预览种子: " + previewSeed);
        System.out.println("💾 [Controller] 请求时间: " + java.time.LocalDateTime.now());
        System.out.println("💾 [Controller] 请求路径: POST /user/" + userUID + "/avatar/confirm");
        
        try {
            System.out.println("💾 [Controller] 调用UserService.confirmPreviewAvatar()");
            String avatarUrl = userService.confirmPreviewAvatar(userUID, previewSeed);
            
            System.out.println("💾 [Controller] UserService返回头像URL: " + avatarUrl);
            System.out.println("💾 [Controller] 头像确认并保存成功，准备返回响应");
            System.out.println("💾 ========== 确认头像请求成功 ==========");
            
            return ApiResponse.success("头像确认并保存成功", avatarUrl);
        } catch (Exception e) {
            System.err.println("❌ [Controller] 确认头像过程中发生异常");
            System.err.println("❌ [Controller] 异常类型: " + e.getClass().getSimpleName());
            System.err.println("❌ [Controller] 异常消息: " + e.getMessage());
            System.err.println("❌ [Controller] 异常堆栈:");
            e.printStackTrace();
            System.err.println("❌ ========== 确认头像请求失败 ==========");
            
            return ApiResponse.error("头像确认失败: " + e.getMessage());
        }
    }

    /**
     * 切换用户隐私可见性
     * @param userUID 用户UID
     * @return 更新后的隐私状态
     */
    @PostMapping("/{userUID}/privacy/toggle")
    public ApiResponse<Boolean> togglePrivacy(@PathVariable String userUID) {
        try {
            boolean newPrivacyState = userService.togglePrivacy(userUID);
            String message = newPrivacyState ? "隐私已隐藏" : "隐私已可见";
            return ApiResponse.success(message, newPrivacyState);
        } catch (Exception e) {
            return ApiResponse.error("切换隐私状态失败: " + e.getMessage());
        }
    }

    /**
     * 创建新用户（如果不存在）
     * @param userUID 用户UID
     * @param userName 用户名称
     * @return 用户信息
     */
    @PostMapping("/create")
    public ApiResponse<UserInfoVO> createUser(
            @RequestParam String userUID,
            @RequestParam String userName) {
        try {
            UserInfoVO userInfo = userService.createUserIfNotExists(userUID, userName);
            return ApiResponse.success("用户创建成功", userInfo);
        } catch (Exception e) {
            return ApiResponse.error("用户创建失败: " + e.getMessage());
        }
    }

    /**
     * 搜索用户
     * @param userUID 要搜索的用户UID
     * @return 用户信息（如果存在）
     */
    @GetMapping("/search/{userUID}")
    public ApiResponse<UserInfoVO> searchUser(@PathVariable String userUID) {
        System.out.println("🔍 ========== 用户搜索请求开始 ==========");
        System.out.println("🔍 请求路径: /user/search/" + userUID);
        System.out.println("🔍 请求时间: " + java.time.LocalDateTime.now());
        System.out.println("🔍 正在查找UID: " + userUID);
        
        try {
            UserInfoVO userInfo = userService.getUserInfo(userUID);
            System.out.println("✅ 查找成功，用户: " + userInfo.getUserName());
            System.out.println("✅ 用户信息: " + userInfo);
            System.out.println("🔍 ========== 用户搜索请求成功 ==========");
            return ApiResponse.success("用户查找成功", userInfo);
        } catch (Exception e) {
            System.out.println("❌ 查找失败，用户不存在: " + userUID);
            System.out.println("❌ 错误信息: " + e.getMessage());
            System.out.println("🔍 ========== 用户搜索请求失败 ==========");
            // 用户不存在时返回失败响应
            return ApiResponse.error("用户不存在");
        }
    }

    /**
     * 通过用户名模糊搜索用户
     * @param keyword 用户名关键词
     * @return 匹配的用户信息列表
     */
    @GetMapping("/searchByName")
    public ApiResponse<List<UserInfoVO>> searchUsersByName(@RequestParam String keyword) {
        try {
            List<UserInfoVO> users = userService.searchUsersByName(keyword);
            return ApiResponse.success("搜索用户成功", users);
        } catch (Exception e) {
            return ApiResponse.error("搜索用户失败: " + e.getMessage());
        }
    }

    /**
     * 健康检查接口
     * @return 服务状态
     */
    @GetMapping("/health")
    public ApiResponse<String> health() {
        System.out.println("🏥 ========== 健康检查请求 ==========");
        System.out.println("🏥 [Controller] 收到健康检查请求");
        System.out.println("🏥 [Controller] 请求时间: " + java.time.LocalDateTime.now());
        System.out.println("🏥 [Controller] 请求路径: GET /user/health");
        System.out.println("🏥 [Controller] 服务状态: 正常运行");
        System.out.println("🏥 ========== 健康检查完成 ==========");
        return ApiResponse.success("用户服务运行正常", "OK");
    }

    /**
     * 简单测试接口 - 用于验证前端连接
     * @return 测试响应
     */
    @GetMapping("/test")
    public ApiResponse<String> test() {
        System.out.println("🧪 测试接口被调用 - " + java.time.LocalDateTime.now());
        return ApiResponse.success("测试成功", "Hello from backend!");
    }

    /**
     * 通过邮箱创建或登录用户
     * @param email 用户邮箱
     * @return 用户信息
     */
    @PostMapping("/createOrLoginByEmail")
    public ApiResponse<UserInfoVO> createOrLoginUserByEmail(@RequestParam String email) {
        try {
            UserInfoVO userInfo = userService.createOrLoginUserByEmail(email);
            return ApiResponse.success("用户创建或登录成功", userInfo);
        } catch (Exception e) {
            return ApiResponse.error("用户创建或登录失败: " + e.getMessage());
        }
    }

    /**
     * 根据邮箱获取用户ID
     * @param email 用户邮箱
     * @return 用户ID
     */
    @GetMapping("/getUserIdByEmail")
    public ApiResponse<Integer> getUserIdByEmail(@RequestParam String email) {
        try {
            Integer userId = userService.getUserIdByEmail(email);
            if (userId != null) {
                return ApiResponse.success("获取用户ID成功", userId);
            } else {
                return ApiResponse.error("用户不存在");
            }
        } catch (Exception e) {
            return ApiResponse.error("获取用户ID失败: " + e.getMessage());
        }
    }

    /**
     * 插入两个测试用户（开发测试用）
     */
    @PostMapping("/insertTestUsers")
    public ApiResponse<String> insertTestUsers() {
        try {
            User user1 = new User();
            user1.setUserUID("test-uid-101");
            user1.setUserName("测试用户101");
            user1.setGender("男");
            user1.setPrivacyVisible(false);
            user1.setSignature("我是测试用户101");
            user1.setEmail("testuser101@example.com");
            user1.setLevel(1);
            user1.setRegisterTime(java.time.LocalDateTime.now());
            user1.setUserAvatar("/static/avatars/default.png");

            User user2 = new User();
            user2.setUserUID("test-uid-102");
            user2.setUserName("测试用户102");
            user2.setGender("女");
            user2.setPrivacyVisible(false);
            user2.setSignature("我是测试用户102");
            user2.setEmail("testuser102@example.com");
            user2.setLevel(1);
            user2.setRegisterTime(java.time.LocalDateTime.now());
            user2.setUserAvatar("/static/avatars/default.png");

            int count = userService.insertUser(user1) + userService.insertUser(user2);
            return ApiResponse.success("成功插入测试用户数量: " + count);
        } catch (Exception e) {
            return ApiResponse.error("插入测试用户失败: " + e.getMessage());
        }
    }

    /**
     * 根据UID获取UserID
     */
    @RequestMapping("/findIDByUID")
    public ApiResponse<Integer> findIDByUID(@RequestParam String uid) {
        UserInfoVO user = userService.getUserInfo(uid);
        if(user != null) {
            return ApiResponse.success(user.getId());
        }else{
            return null;
        }
    }

    /**
     * 简单头像上传 - 支持base64数据
     */
    @PostMapping("/{userUID}/avatar/simple")
    public ApiResponse<String> uploadAvatarSimple(
            @PathVariable String userUID,
            @RequestBody(required = false) Map<String, Object> requestBody,
            @RequestParam(value = "file", required = false) MultipartFile file) {
        try {
            System.out.println("📸 [UserController] 简单头像上传开始");
            System.out.println("📸 [UserController] 用户UID: " + userUID);

            String avatarUrl;

            if (file != null && !file.isEmpty()) {
                // 处理文件上传
                System.out.println("📸 [UserController] 处理文件上传");
                System.out.println("📸 [UserController] 文件名: " + file.getOriginalFilename());
                System.out.println("📸 [UserController] 文件大小: " + file.getSize() + " 字节");

                // 检查文件类型
                String contentType = file.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    return ApiResponse.error("只支持图片文件上传");
                }

                // 生成OSS对象名称
                String extension = getFileExtension(file.getOriginalFilename());
                String objectName = "avatars/" + userUID + "/" + System.currentTimeMillis() + extension;

                System.out.println("📸 [UserController] OSS对象名称: " + objectName);

                // 上传到OSS
                avatarUrl = ossService.uploadBytes(file.getBytes(), objectName, contentType);

            } else if (requestBody != null && requestBody.containsKey("imageData")) {
                // 处理base64数据
                System.out.println("📸 [UserController] 处理base64数据上传");
                String imageData = (String) requestBody.get("imageData");
                String fileName = (String) requestBody.getOrDefault("fileName", "avatar.jpg");

                System.out.println("📸 [UserController] 图片数据长度: " + imageData.length());
                System.out.println("📸 [UserController] 文件名: " + fileName);

                // 使用UserService的base64上传方法
                avatarUrl = userService.uploadAvatarBase64(userUID, imageData);

            } else {
                return ApiResponse.error("缺少上传数据");
            }

            System.out.println("📸 [UserController] OSS上传成功，URL: " + avatarUrl);

            // 更新用户头像信息
            User user = userMapper.selectByUID(userUID);
            if (user != null) {
                user.setUserAvatar(avatarUrl);
                user.setUpdateTime(LocalDateTime.now());
                userMapper.updateUser(user);
                System.out.println("📸 [UserController] 用户头像信息已更新");
            }

            return ApiResponse.success(avatarUrl);

        } catch (Exception e) {
            System.err.println("❌ [UserController] 简单头像上传失败: " + e.getMessage());
            e.printStackTrace();
            return ApiResponse.error("头像上传失败: " + e.getMessage());
        }
    }

    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.isEmpty()) {
            return ".jpg";
        }
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex > 0) {
            return fileName.substring(lastDotIndex);
        }
        return ".jpg";
    }

} 