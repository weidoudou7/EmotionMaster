package com.ai.companion.service;

import java.awt.image.BufferedImage;
import com.ai.companion.entity.vo.PreviewAvatarResult;

public interface AvatarGeneratorService {
    
    /**
     * 生成随机色块头像
     * @param userUID 用户UID，用于生成种子
     * @return 生成的头像图片
     */
    BufferedImage generateRandomAvatar(String userUID);
    
    /**
     * 生成随机色块头像并保存为文件
     * @param userUID 用户UID
     * @return 保存的头像文件路径
     */
    String generateAndSaveAvatar(String userUID);
    
    /**
     * 生成预览头像（不保存文件）
     * @param userUID 用户UID
     * @return 预览头像的base64编码和种子信息
     */
    PreviewAvatarResult generatePreviewAvatar(String userUID);
    
    /**
     * 确认并保存预览的头像
     * @param userUID 用户UID
     * @param previewSeed 预览种子（用于重新生成相同的头像）
     * @return 保存的头像文件路径
     */
    String confirmAndSaveAvatar(String userUID, long previewSeed);
    
    /**
     * 删除旧头像文件
     * @param userUID 用户UID
     */
    void deleteOldAvatar(String userUID);
} 