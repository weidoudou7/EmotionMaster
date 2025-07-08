package com.ai.companion.service;

import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;

public interface OssService {
    
    /**
     * 上传文件到OSS
     * @param file 文件对象
     * @param objectName OSS对象名称
     * @return 文件访问URL
     */
    String uploadFile(MultipartFile file, String objectName);
    
    /**
     * 上传字节数组到OSS
     * @param data 字节数组
     * @param objectName OSS对象名称
     * @param contentType 内容类型
     * @return 文件访问URL
     */
    String uploadBytes(byte[] data, String objectName, String contentType);
    
    /**
     * 上传输入流到OSS
     * @param inputStream 输入流
     * @param objectName OSS对象名称
     * @param contentType 内容类型
     * @return 文件访问URL
     */
    String uploadStream(InputStream inputStream, String objectName, String contentType);
    
    /**
     * 删除OSS文件
     * @param objectName OSS对象名称
     * @return 是否删除成功
     */
    boolean deleteFile(String objectName);
    
    /**
     * 检查文件是否存在
     * @param objectName OSS对象名称
     * @return 是否存在
     */
    boolean doesObjectExist(String objectName);
    
    /**
     * 生成文件访问URL
     * @param objectName OSS对象名称
     * @return 文件访问URL
     */
    String generateUrl(String objectName);
} 