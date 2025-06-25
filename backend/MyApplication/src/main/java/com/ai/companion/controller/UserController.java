package com.ai.companion.controller;

import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.entity.vo.UserInfoVO;
import com.ai.companion.entity.vo.UpdateUserRequest;
import com.ai.companion.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RequiredArgsConstructor
@RestController
@RequestMapping("/user")
@CrossOrigin(origins = "*") // 允许跨域请求
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
     * 健康检查接口
     * @return 服务状态
     */
    @GetMapping("/health")
    public ApiResponse<String> health() {
        return ApiResponse.success("用户服务运行正常", "OK");
    }
} 