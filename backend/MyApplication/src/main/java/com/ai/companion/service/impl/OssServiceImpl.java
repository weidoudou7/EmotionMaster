package com.ai.companion.service.impl;

import com.ai.companion.config.OssConfig;
import com.ai.companion.service.OssService;
import com.aliyun.oss.OSS;
import com.aliyun.oss.model.ObjectMetadata;
import com.aliyun.oss.model.PutObjectRequest;
import com.aliyun.oss.model.PutObjectResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class OssServiceImpl implements OssService {

    private final OSS ossClient;
    private final OssConfig ossConfig;

    @Override
    public String uploadFile(MultipartFile file, String objectName) {
        try {
            log.info("开始上传文件到OSS: {}", objectName);
            
            // 创建对象元数据
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentType(file.getContentType());
            metadata.setContentLength(file.getSize());
            
            PutObjectRequest putObjectRequest = new PutObjectRequest(
                ossConfig.getBucketName(), 
                objectName, 
                file.getInputStream(),
                metadata
            );
            
            PutObjectResult result = ossClient.putObject(putObjectRequest);
            log.info("文件上传成功: {}, ETag: {}", objectName, result.getETag());
            
            return generateUrl(objectName);
        } catch (IOException e) {
            log.error("文件上传失败: {}", objectName, e);
            throw new RuntimeException("文件上传失败: " + e.getMessage());
        }
    }

    @Override
    public String uploadBytes(byte[] data, String objectName, String contentType) {
        try {
            log.info("开始上传字节数组到OSS: {}", objectName);
            
            ByteArrayInputStream inputStream = new ByteArrayInputStream(data);
            
            // 创建对象元数据
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentType(contentType);
            metadata.setContentLength(data.length);
            
            PutObjectRequest putObjectRequest = new PutObjectRequest(
                ossConfig.getBucketName(), 
                objectName, 
                inputStream,
                metadata
            );
            
            PutObjectResult result = ossClient.putObject(putObjectRequest);
            log.info("字节数组上传成功: {}, ETag: {}", objectName, result.getETag());
            
            return generateUrl(objectName);
        } catch (Exception e) {
            log.error("字节数组上传失败: {}", objectName, e);
            throw new RuntimeException("字节数组上传失败: " + e.getMessage());
        }
    }

    @Override
    public String uploadStream(InputStream inputStream, String objectName, String contentType) {
        try {
            log.info("开始上传输入流到OSS: {}", objectName);
            
            // 创建对象元数据
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentType(contentType);
            
            PutObjectRequest putObjectRequest = new PutObjectRequest(
                ossConfig.getBucketName(), 
                objectName, 
                inputStream,
                metadata
            );
            
            PutObjectResult result = ossClient.putObject(putObjectRequest);
            log.info("输入流上传成功: {}, ETag: {}", objectName, result.getETag());
            
            return generateUrl(objectName);
        } catch (Exception e) {
            log.error("输入流上传失败: {}", objectName, e);
            throw new RuntimeException("输入流上传失败: " + e.getMessage());
        }
    }

    @Override
    public boolean deleteFile(String objectName) {
        try {
            log.info("开始删除OSS文件: {}", objectName);
            
            if (doesObjectExist(objectName)) {
                ossClient.deleteObject(ossConfig.getBucketName(), objectName);
                log.info("文件删除成功: {}", objectName);
                return true;
            } else {
                log.warn("文件不存在，无需删除: {}", objectName);
                return false;
            }
        } catch (Exception e) {
            log.error("文件删除失败: {}", objectName, e);
            return false;
        }
    }

    @Override
    public boolean doesObjectExist(String objectName) {
        try {
            return ossClient.doesObjectExist(ossConfig.getBucketName(), objectName);
        } catch (Exception e) {
            log.error("检查文件是否存在失败: {}", objectName, e);
            return false;
        }
    }

    @Override
    public String generateUrl(String objectName) {
        // 使用配置的URL前缀生成OSS文件访问URL
        String urlPrefix = ossConfig.getUrlPrefix();
        if (urlPrefix != null && !urlPrefix.trim().isEmpty()) {
            return urlPrefix + "/" + objectName;
        } else {
            // 如果没有配置URL前缀，使用默认格式
            return "https://" + ossConfig.getBucketName() + "." + ossConfig.getEndpoint() + "/" + objectName;
        }
    }

    /**
     * 生成唯一的对象名称
     * @param userUID 用户UID
     * @param originalFilename 原始文件名
     * @return 唯一的对象名称
     */
    public String generateObjectName(String userUID, String originalFilename) {
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        return "avatars/" + userUID + "_" + UUID.randomUUID().toString() + extension;
    }
} 