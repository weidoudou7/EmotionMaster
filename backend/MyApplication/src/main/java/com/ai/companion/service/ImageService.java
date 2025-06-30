package com.ai.companion.service;

import com.ai.companion.entity.vo.ImageUploadResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface ImageService {
    
    /**
     * 上传单张图片
     * @param file 图片文件
     * @param userUID 用户UID
     * @return 图片URL
     */
    String uploadImage(MultipartFile file, String userUID);
    
    /**
     * 批量上传图片
     * @param files 图片文件列表
     * @param userUID 用户UID
     * @return 图片上传响应
     */
    ImageUploadResponse uploadImages(List<MultipartFile> files, String userUID);
    
    /**
     * 删除图片
     * @param imageUrl 图片URL
     * @param userUID 用户UID
     * @return 是否删除成功
     */
    boolean deleteImage(String imageUrl, String userUID);
    
    /**
     * 获取图片访问URL
     * @param imageUrl 图片相对路径
     * @return 完整的图片访问URL
     */
    String getImageUrl(String imageUrl);
} 