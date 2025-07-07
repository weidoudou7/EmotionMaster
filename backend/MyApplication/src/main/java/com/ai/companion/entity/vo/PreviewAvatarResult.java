package com.ai.companion.entity.vo;

/**
 * 预览头像结果
 */
public class PreviewAvatarResult {
    private String previewImage; // base64编码的预览图片
    private long previewSeed;    // 预览种子
    private long timestamp;      // 时间戳

    public PreviewAvatarResult() {
    }

    public PreviewAvatarResult(String previewImage, long previewSeed, long timestamp) {
        this.previewImage = previewImage;
        this.previewSeed = previewSeed;
        this.timestamp = timestamp;
    }

    public String getPreviewImage() {
        return previewImage;
    }

    public void setPreviewImage(String previewImage) {
        this.previewImage = previewImage;
    }

    public long getPreviewSeed() {
        return previewSeed;
    }

    public void setPreviewSeed(long previewSeed) {
        this.previewSeed = previewSeed;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    @Override
    public String toString() {
        return "PreviewAvatarResult{" +
                "previewImage='" + (previewImage != null ? previewImage.substring(0, Math.min(50, previewImage.length())) + "..." : "null") + '\'' +
                ", previewSeed=" + previewSeed +
                ", timestamp=" + timestamp +
                '}';
    }
} 