package com.ai.companion.controller;

import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.service.OssService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * OSS对象存储控制器
 * 处理图片上传到阿里云OSS
 */
@RestController
@RequestMapping("/api/oss")
public class OSSController {

    @Autowired
    private OssService ossService;

    /**
     * 上传图片到OSS
     * @param request 包含用户ID、图片数据和文件名的请求
     * @return 上传结果，包含OSS访问URL
     */
    @PostMapping("/upload")
    public ApiResponse<Map<String, String>> uploadImage(@RequestBody Map<String, Object> request) {
        try {
            String userId = (String) request.get("userId");
            String imageData = (String) request.get("imageData");
            String fileName = (String) request.get("fileName");

            if (userId == null || imageData == null || fileName == null) {
                return ApiResponse.error("参数不完整");
            }

            // 上传到OSS
            String ossUrl = ossService.uploadBytes(
                java.util.Base64.getDecoder().decode(imageData), 
                fileName, 
                getContentType(fileName)
            );

            return ApiResponse.success(Map.of("ossUrl", ossUrl));
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error("上传失败: " + e.getMessage());
        }
    }

    /**
     * 通过文件上传到OSS
     * @param file 图片文件
     * @param userId 用户ID
     * @return 上传结果
     */
    @PostMapping("/upload/file")
    public ApiResponse<Map<String, String>> uploadImageFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") String userId) {
        try {
            if (file.isEmpty()) {
                return ApiResponse.error("文件为空");
            }

            // 生成文件名
            String fileName = userId + "_" + System.currentTimeMillis() + "_" + file.getOriginalFilename();
            
            // 上传到OSS
            String ossUrl = ossService.uploadBytes(
                file.getBytes(), 
                fileName, 
                file.getContentType()
            );

            return ApiResponse.success(Map.of("ossUrl", ossUrl));
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error("上传失败: " + e.getMessage());
        }
    }

    /**
     * 删除OSS中的图片
     * @param request 包含图片URL的请求
     * @return 删除结果
     */
    @DeleteMapping("/delete")
    public ApiResponse<String> deleteImage(@RequestBody Map<String, String> request) {
        try {
            String imageUrl = request.get("imageUrl");
            if (imageUrl == null) {
                return ApiResponse.error("图片URL不能为空");
            }

            // 从URL中提取对象名称
            String objectName = extractObjectNameFromUrl(imageUrl);
            boolean deleted = ossService.deleteFile(objectName);
            
            if (deleted) {
                return ApiResponse.success("删除成功");
            } else {
                return ApiResponse.error("删除失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error("删除失败: " + e.getMessage());
        }
    }

    /**
     * 根据文件名获取Content-Type
     */
    private String getContentType(String fileName) {
        if (fileName == null) {
            return "image/jpeg";
        }
        
        String extension = fileName.toLowerCase();
        if (extension.endsWith(".png")) {
            return "image/png";
        } else if (extension.endsWith(".gif")) {
            return "image/gif";
        } else if (extension.endsWith(".webp")) {
            return "image/webp";
        } else {
            return "image/jpeg";
        }
    }

    /**
     * 从OSS URL中提取对象名称
     */
    private String extractObjectNameFromUrl(String imageUrl) {
        // 假设URL格式为: https://bucket.endpoint/objectName
        try {
            String[] parts = imageUrl.split("/");
            if (parts.length >= 4) {
                // 跳过协议、域名等，取对象名称部分
                StringBuilder objectName = new StringBuilder();
                for (int i = 3; i < parts.length; i++) {
                    if (i > 3) {
                        objectName.append("/");
                    }
                    objectName.append(parts[i]);
                }
                return objectName.toString();
            }
        } catch (Exception e) {
            System.err.println("解析OSS URL失败: " + e.getMessage());
        }
        return imageUrl; // 如果解析失败，返回原URL
    }
} 