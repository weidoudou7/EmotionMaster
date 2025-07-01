package com.ai.companion.controller;

import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.entity.vo.ImageUploadResponse;
import com.ai.companion.service.ImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/image")
@CrossOrigin(origins = "http://localhost:8080", allowCredentials = "true") // 允许跨域请求
public class ImageController {

    private final ImageService imageService;

    /**
     * 上传单张图片
     * @param userUID 用户UID
     * @param file 图片文件
     * @return 图片URL
     */
    @PostMapping("/upload/{userUID}")
    public ApiResponse<String> uploadImage(
            @PathVariable String userUID,
            @RequestParam("file") MultipartFile file) {
        try {
            String imageUrl = imageService.uploadImage(file, userUID);
            return ApiResponse.success("图片上传成功", imageUrl);
        } catch (Exception e) {
            return ApiResponse.error("图片上传失败: " + e.getMessage());
        }
    }

    /**
     * 批量上传图片
     * @param userUID 用户UID
     * @param files 图片文件列表
     * @return 图片上传响应
     */
    @PostMapping("/upload/batch/{userUID}")
    public ApiResponse<ImageUploadResponse> uploadImages(
            @PathVariable String userUID,
            @RequestParam("files") List<MultipartFile> files) {
        try {
            ImageUploadResponse response = imageService.uploadImages(files, userUID);
            return ApiResponse.success("批量图片上传成功", response);
        } catch (Exception e) {
            return ApiResponse.error("批量图片上传失败: " + e.getMessage());
        }
    }

    /**
     * 删除图片
     * @param userUID 用户UID
     * @param imageUrl 图片URL
     * @return 删除结果
     */
    @DeleteMapping("/delete/{userUID}")
    public ApiResponse<Boolean> deleteImage(
            @PathVariable String userUID,
            @RequestParam String imageUrl) {
        try {
            boolean success = imageService.deleteImage(imageUrl, userUID);
            if (success) {
                return ApiResponse.success("图片删除成功", true);
            } else {
                return ApiResponse.error("图片删除失败，图片可能不存在");
            }
        } catch (Exception e) {
            return ApiResponse.error("图片删除失败: " + e.getMessage());
        }
    }

    /**
     * 获取图片完整URL
     * @param imageUrl 图片相对路径
     * @return 完整图片URL
     */
    @GetMapping("/url")
    public ApiResponse<String> getImageUrl(@RequestParam String imageUrl) {
        try {
            String fullUrl = imageService.getImageUrl(imageUrl);
            return ApiResponse.success("获取图片URL成功", fullUrl);
        } catch (Exception e) {
            return ApiResponse.error("获取图片URL失败: " + e.getMessage());
        }
    }

    /**
     * 健康检查接口
     * @return 服务状态
     */
    @GetMapping("/health")
    public ApiResponse<String> health() {
        return ApiResponse.success("图片服务运行正常", "OK");
    }
} 