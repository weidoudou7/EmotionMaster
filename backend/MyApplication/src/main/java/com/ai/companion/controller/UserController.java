package com.ai.companion.controller;

import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.entity.vo.UserInfoVO;
import com.ai.companion.entity.vo.UpdateUserRequest;
import com.ai.companion.entity.vo.UserStatsVO;
import com.ai.companion.entity.vo.AvatarUploadRequest;
import com.ai.companion.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.ai.companion.entity.User;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/user")
@CrossOrigin(origins = "http://localhost:8080", allowCredentials = "true") // 允许跨域请求
public class UserController {

    private final UserService userService;

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
} 