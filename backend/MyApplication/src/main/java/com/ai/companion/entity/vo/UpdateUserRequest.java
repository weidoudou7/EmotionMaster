package com.ai.companion.entity.vo;

public class UpdateUserRequest {
    private String userName;           // 用户名称
    private String userAvatar;        // 用户头像路径
    private boolean isPrivacyVisible; // 隐私是否可见
    private String gender;            // 性别
    private String signature;         // 个性签名

    // 默认构造函数
    public UpdateUserRequest() {}

    // 全参构造函数
    public UpdateUserRequest(String userName, String userAvatar, boolean isPrivacyVisible, 
                            String gender, String signature) {
        this.userName = userName;
        this.userAvatar = userAvatar;
        this.isPrivacyVisible = isPrivacyVisible;
        this.gender = gender;
        this.signature = signature;
    }

    // Getter和Setter方法
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserAvatar() { return userAvatar; }
    public void setUserAvatar(String userAvatar) { this.userAvatar = userAvatar; }

    public boolean isPrivacyVisible() { return isPrivacyVisible; }
    public void setPrivacyVisible(boolean privacyVisible) { isPrivacyVisible = privacyVisible; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getSignature() { return signature; }
    public void setSignature(String signature) { this.signature = signature; }
} 