package com.ai.companion.entity.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 预览头像响应
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PreviewAvatarResponse {
    
    /**
     * 预览头像的base64编码
     */
    private String previewImage;
    
    /**
     * 预览种子，用于重新生成相同的头像
     */
    private long previewSeed;
    
    /**
     * 生成时间戳
     */
    private long timestamp;
} 