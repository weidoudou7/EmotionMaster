package com.ai.companion.entity.vo;

import lombok.Data;

@Data
public class UpdateUserRequest {
    private String userName;           // 用户名称
    private String userAvatar;        // 用户头像路径
    private boolean isPrivacyVisible; // 隐私是否可见
    private String gender;            // 性别
    private String signature;         // 个性签名
} 