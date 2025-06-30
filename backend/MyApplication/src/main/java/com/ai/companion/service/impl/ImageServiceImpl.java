package com.ai.companion.service.impl;

import com.ai.companion.entity.vo.ImageUploadResponse;
import com.ai.companion.service.ImageService;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class ImageServiceImpl implements ImageService {

    // 图片存储路径
    private static final String IMAGE_UPLOAD_PATH = "uploads/images/";
    private static final String IMAGE_ACCESS_PREFIX = "/images/";

    @Override
    public String uploadImage(MultipartFile file, String userUID) {
        if (file.isEmpty()) {
            throw new RuntimeException("上传的文件为空");
        }

        // 检查文件类型
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new RuntimeException("只能上传图片文件");
        }

        // 检查文件大小（限制为10MB）
        if (file.getSize() > 10 * 1024 * 1024) {
            throw new RuntimeException("图片文件大小不能超过10MB");
        }

        // 生成唯一文件名
        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        String filename = userUID + "_" + UUID.randomUUID().toString() + extension;

        try {
            // 保存文件
            Path uploadPath = Paths.get(IMAGE_UPLOAD_PATH);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            Path filePath = uploadPath.resolve(filename);
            Files.copy(file.getInputStream(), filePath);

            return IMAGE_ACCESS_PREFIX + filename;
        } catch (IOException e) {
            throw new RuntimeException("图片上传失败: " + e.getMessage());
        }
    }

    @Override
    public ImageUploadResponse uploadImages(List<MultipartFile> files, String userUID) {
        if (files == null || files.isEmpty()) {
            throw new RuntimeException("没有选择图片文件");
        }

        // 检查文件数量（最多9张）
        if (files.size() > 9) {
            throw new RuntimeException("最多只能上传9张图片");
        }

        List<String> imageUrls = new ArrayList<>();
        int successCount = 0;
        int totalCount = files.size();

        for (MultipartFile file : files) {
            try {
                String imageUrl = uploadImage(file, userUID);
                imageUrls.add(imageUrl);
                successCount++;
            } catch (Exception e) {
                // 记录错误但继续处理其他文件
                System.err.println("图片上传失败: " + e.getMessage());
            }
        }

        return new ImageUploadResponse(imageUrls, successCount, totalCount);
    }

    @Override
    public boolean deleteImage(String imageUrl, String userUID) {
        if (imageUrl == null || imageUrl.isEmpty()) {
            return false;
        }

        try {
            // 从URL中提取文件名
            String filename = imageUrl.replace(IMAGE_ACCESS_PREFIX, "");
            
            // 验证文件是否属于该用户
            if (!filename.startsWith(userUID + "_")) {
                throw new RuntimeException("无权删除此图片");
            }

            Path filePath = Paths.get(IMAGE_UPLOAD_PATH, filename);
            if (Files.exists(filePath)) {
                Files.delete(filePath);
                return true;
            }
            return false;
        } catch (IOException e) {
            throw new RuntimeException("删除图片失败: " + e.getMessage());
        }
    }

    @Override
    public String getImageUrl(String imageUrl) {
        if (imageUrl == null || imageUrl.isEmpty()) {
            return "";
        }
        
        // 如果已经是完整URL，直接返回
        if (imageUrl.startsWith("http://") || imageUrl.startsWith("https://")) {
            return imageUrl;
        }
        
        // 如果是相对路径，添加服务器地址前缀
        // 这里可以根据实际部署情况配置
        return "http://localhost:8080" + imageUrl;
    }
} 