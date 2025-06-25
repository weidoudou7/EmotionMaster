package com.ai.companion.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private String userUID;           // 用户UID（主键）
    private String userName;          // 用户名称
    private String userAvatar;        // 用户头像路径
    private boolean isPrivacyVisible; // 隐私是否可见
    private String level;             // 用户等级
    private String gender;            // 性别
    private String signature;         // 个性签名
    private LocalDateTime registerTime; // 注册时间
    private LocalDateTime updateTime;   // 更新时间

    // 构造函数 - 用于创建新用户
    public User(String userUID, String userName) {
        this.userUID = userUID;
        this.userName = userName;
        this.userAvatar = "/avatars/default.png";
        this.isPrivacyVisible = false;
        this.level = "Lv.1";
        this.gender = "未设置";
        this.signature = "这个人很懒，什么都没留下~";
        this.registerTime = LocalDateTime.now();
        this.updateTime = LocalDateTime.now();
    }
} 