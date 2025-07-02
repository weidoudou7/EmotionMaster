package com.ai.companion.entity.vo;

import    lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ImageUploadResponse {
    private List<String> imageUrls; // 上传后的图片URL列表
    private Integer successCount; // 成功上传的图片数量
    private Integer totalCount; // 总图片数量
} 