package com.ai.companion.entity.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserInfoVO {
    private String userName; // 用户名称
    private String userUID; // 用户UID
    private String userAvatar; // 用户头像路径
    private boolean isPrivacyVisible; // 隐私是否可见
    private Integer level; // 用户等级
    private String gender; // 性别
    private String signature; // 个性签名
    private LocalDateTime registerTime; // 注册时间
    private LocalDateTime updateTime; // 更新时间
}