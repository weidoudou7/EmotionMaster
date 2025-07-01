package com.ai.companion.entity.vo;

public class AvatarUploadRequest {
    private String imageData; // base64格式的图片数据

    // 默认构造函数
    public AvatarUploadRequest() {}

    // 全参构造函数
    public AvatarUploadRequest(String imageData) {
        this.imageData = imageData;
    }

    // Getter和Setter方法
    public String getImageData() {
        return imageData;
    }

    public void setImageData(String imageData) {
        this.imageData = imageData;
    }
} 