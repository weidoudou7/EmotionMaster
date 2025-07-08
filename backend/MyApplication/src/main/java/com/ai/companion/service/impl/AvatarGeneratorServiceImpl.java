package com.ai.companion.service.impl;

import com.ai.companion.service.AvatarGeneratorService;
import com.ai.companion.service.OssService;
import com.ai.companion.entity.vo.PreviewAvatarResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.Random;
import java.util.UUID;

@Service
public class AvatarGeneratorServiceImpl implements AvatarGeneratorService {

    @Autowired
    private OssService ossService;

    private static final String AVATAR_UPLOAD_PATH = "uploads/avatars/";
    private static final int AVATAR_SIZE = 80; // 80x80像素
    private static final int MIN_BLOCKS = 2; // 最少色块数
    private static final int MAX_BLOCKS = 8; // 最多色块数
    private static final int BLOCK_SIZE = 20; // 每个色块20x20像素

    // 预设的两种颜色方案
    private static final Color[][] COLOR_SCHEMES = {
        // 方案1：温暖色调
        {
            new Color(255, 99, 132),   // 粉红
            new Color(255, 159, 64),   // 橙色
            new Color(255, 205, 86),   // 黄色
            new Color(75, 192, 192),   // 青色
            new Color(54, 162, 235),   // 蓝色
            new Color(153, 102, 255),  // 紫色
            new Color(255, 99, 132),   // 粉红
            new Color(255, 159, 64)    // 橙色
        },
        // 方案2：冷色调
        {
            new Color(54, 162, 235),   // 蓝色
            new Color(75, 192, 192),   // 青色
            new Color(153, 102, 255),  // 紫色
            new Color(255, 99, 132),   // 粉红
            new Color(255, 159, 64),   // 橙色
            new Color(255, 205, 86),   // 黄色
            new Color(54, 162, 235),   // 蓝色
            new Color(75, 192, 192)    // 青色
        }
    };

    @Override
    public BufferedImage generateRandomAvatar(String userUID) {
        System.out.println("🎨 ========== AvatarGenerator.generateRandomAvatar() 开始 ==========");
        System.out.println("🎨 [AvatarGenerator] 开始生成随机头像图片");
        System.out.println("🎨 [AvatarGenerator] 用户UID: " + userUID);
        
        // 使用用户UID生成随机种子，确保同一用户每次生成的头像都相同
        long seed = userUID.hashCode();
        Random random = new Random(seed);
        System.out.println("🎨 [AvatarGenerator] 使用种子: " + seed + " (来自UID哈希码)");
        
        // 随机选择颜色方案
        int schemeIndex = random.nextInt(COLOR_SCHEMES.length);
        Color[] colorScheme = COLOR_SCHEMES[schemeIndex];
        System.out.println("🎨 [AvatarGenerator] 选择颜色方案: " + (schemeIndex + 1) + " (共" + COLOR_SCHEMES.length + "个方案)");
        
        // 创建80x80的图片
        System.out.println("🎨 [AvatarGenerator] 创建BufferedImage，尺寸: " + AVATAR_SIZE + "x" + AVATAR_SIZE);
        BufferedImage image = new BufferedImage(AVATAR_SIZE, AVATAR_SIZE, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = image.createGraphics();
        
        // 设置背景色（随机选择）
        Color backgroundColor = colorScheme[random.nextInt(colorScheme.length)];
        g2d.setColor(backgroundColor);
        g2d.fillRect(0, 0, AVATAR_SIZE, AVATAR_SIZE);
        System.out.println("🎨 [AvatarGenerator] 设置背景色: RGB(" + backgroundColor.getRed() + "," + backgroundColor.getGreen() + "," + backgroundColor.getBlue() + ")");
        
        // 随机生成2-8个色块
        int numBlocks = MIN_BLOCKS + random.nextInt(MAX_BLOCKS - MIN_BLOCKS + 1);
        System.out.println("🎨 [AvatarGenerator] 生成色块数量: " + numBlocks + " (范围: " + MIN_BLOCKS + "-" + MAX_BLOCKS + ")");
        
        for (int i = 0; i < numBlocks; i++) {
            // 随机选择颜色（不包括背景色）
            Color blockColor;
            do {
                blockColor = colorScheme[random.nextInt(colorScheme.length)];
            } while (blockColor.equals(backgroundColor));
            
            // 随机位置（4x4网格，每个网格20x20像素）
            int gridX = random.nextInt(4);
            int gridY = random.nextInt(4);
            
            // 计算实际像素位置
            int pixelX = gridX * BLOCK_SIZE;
            int pixelY = gridY * BLOCK_SIZE;
            
            // 绘制色块
            g2d.setColor(blockColor);
            g2d.fillRect(pixelX, pixelY, BLOCK_SIZE, BLOCK_SIZE);
            
            System.out.println("🎨 [AvatarGenerator] 色块 " + (i + 1) + ": 位置(" + gridX + "," + gridY + "), 像素(" + pixelX + "," + pixelY + "), 颜色RGB(" + blockColor.getRed() + "," + blockColor.getGreen() + "," + blockColor.getBlue() + ")");
        }
        
        g2d.dispose();
        System.out.println("🎨 [AvatarGenerator] 头像图片生成完成");
        System.out.println("🎨 [AvatarGenerator] 最终图片尺寸: " + image.getWidth() + "x" + image.getHeight());
        System.out.println("🎨 ========== AvatarGenerator.generateRandomAvatar() 完成 ==========");
        
        return image;
    }

    @Override
    public String generateAndSaveAvatar(String userUID) {
        System.out.println("🎨 ========== AvatarGenerator.generateAndSaveAvatar() 开始 ==========");
        System.out.println("🎨 [AvatarGenerator] 开始为用户生成头像");
        System.out.println("🎨 [AvatarGenerator] 用户UID: " + userUID);
        System.out.println("🎨 [AvatarGenerator] 处理时间: " + java.time.LocalDateTime.now());
        
        try {
            // 1. 生成头像图片
            System.out.println("🎨 [AvatarGenerator] 步骤1: 生成随机头像图片");
            BufferedImage avatar = generateRandomAvatar(userUID);
            System.out.println("🎨 [AvatarGenerator] 头像图片生成成功");
            System.out.println("🎨 [AvatarGenerator] 图片尺寸: " + avatar.getWidth() + "x" + avatar.getHeight());
            System.out.println("🎨 [AvatarGenerator] 图片类型: " + avatar.getType());
            
            // 2. 生成OSS对象名称
            System.out.println("🎨 [AvatarGenerator] 步骤2: 生成OSS对象名称");
            String objectName = ((OssServiceImpl) ossService).generateObjectName(userUID, "avatar.png");
            System.out.println("🎨 [AvatarGenerator] OSS对象名称: " + objectName);
            
            // 3. 将BufferedImage转换为字节数组
            System.out.println("🎨 [AvatarGenerator] 步骤3: 转换图片为字节数组");
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            boolean writeSuccess = ImageIO.write(avatar, "PNG", baos);
            System.out.println("🎨 [AvatarGenerator] ImageIO.write() 返回值: " + writeSuccess);
            
            byte[] imageBytes = baos.toByteArray();
            System.out.println("🎨 [AvatarGenerator] 图片字节数: " + imageBytes.length);
            
            // 4. 上传到OSS
            System.out.println("🎨 [AvatarGenerator] 步骤4: 上传头像到OSS");
            String avatarUrl = ossService.uploadBytes(imageBytes, objectName, "image/png");
            System.out.println("🎨 [AvatarGenerator] OSS上传成功，URL: " + avatarUrl);
            
            System.out.println("🎨 ========== AvatarGenerator.generateAndSaveAvatar() 成功完成 ==========");
            
            return avatarUrl;
            
        } catch (IOException e) {
            System.err.println("❌ [AvatarGenerator] 生成头像过程中发生IO异常");
            System.err.println("❌ [AvatarGenerator] 异常类型: " + e.getClass().getSimpleName());
            System.err.println("❌ [AvatarGenerator] 异常消息: " + e.getMessage());
            System.err.println("❌ [AvatarGenerator] 异常堆栈:");
            e.printStackTrace();
            System.err.println("❌ ========== AvatarGenerator.generateAndSaveAvatar() 失败 ==========");
            
            throw new RuntimeException("生成头像失败: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("❌ [AvatarGenerator] 生成头像过程中发生未知异常");
            System.err.println("❌ [AvatarGenerator] 异常类型: " + e.getClass().getSimpleName());
            System.err.println("❌ [AvatarGenerator] 异常消息: " + e.getMessage());
            System.err.println("❌ [AvatarGenerator] 异常堆栈:");
            e.printStackTrace();
            System.err.println("❌ ========== AvatarGenerator.generateAndSaveAvatar() 失败 ==========");
            
            throw new RuntimeException("生成头像失败: " + e.getMessage());
        }
    }

    @Override
    public PreviewAvatarResult generatePreviewAvatar(String userUID) {
        System.out.println("👁️ ========== AvatarGenerator.generatePreviewAvatar() 开始 ==========");
        System.out.println("👁️ [AvatarGenerator] 开始生成预览头像");
        System.out.println("👁️ [AvatarGenerator] 用户UID: " + userUID);
        System.out.println("👁️ [AvatarGenerator] 处理时间: " + java.time.LocalDateTime.now());
        
        try {
            // 生成预览种子（基于用户UID和时间戳）
            long previewSeed = userUID.hashCode() + System.currentTimeMillis();
            System.out.println("🌱 [AvatarGenerator] 生成预览种子: " + previewSeed);
            
            // 使用预览种子生成头像
            Random random = new Random(previewSeed);
            
            // 随机选择颜色方案
            int schemeIndex = random.nextInt(COLOR_SCHEMES.length);
            Color[] colorScheme = COLOR_SCHEMES[schemeIndex];
            
            // 创建80x80的图片
            BufferedImage image = new BufferedImage(AVATAR_SIZE, AVATAR_SIZE, BufferedImage.TYPE_INT_RGB);
            Graphics2D g2d = image.createGraphics();
            
            // 设置背景色（随机选择）
            Color backgroundColor = colorScheme[random.nextInt(colorScheme.length)];
            g2d.setColor(backgroundColor);
            g2d.fillRect(0, 0, AVATAR_SIZE, AVATAR_SIZE);
            
            // 随机生成2-8个色块
            int numBlocks = MIN_BLOCKS + random.nextInt(MAX_BLOCKS - MIN_BLOCKS + 1);
            
            for (int i = 0; i < numBlocks; i++) {
                // 随机选择颜色（不包括背景色）
                Color blockColor;
                do {
                    blockColor = colorScheme[random.nextInt(colorScheme.length)];
                } while (blockColor.equals(backgroundColor));
                
                // 随机位置（4x4网格，每个网格20x20像素）
                int gridX = random.nextInt(4);
                int gridY = random.nextInt(4);
                
                // 计算实际像素位置
                int pixelX = gridX * BLOCK_SIZE;
                int pixelY = gridY * BLOCK_SIZE;
                
                // 绘制色块
                g2d.setColor(blockColor);
                g2d.fillRect(pixelX, pixelY, BLOCK_SIZE, BLOCK_SIZE);
            }
            
            g2d.dispose();
            
            System.out.println("👁️ [AvatarGenerator] 预览头像生成成功");
            System.out.println("👁️ [AvatarGenerator] 图片尺寸: " + image.getWidth() + "x" + image.getHeight());
            
            // 转换为base64编码
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(image, "PNG", baos);
            byte[] imageBytes = baos.toByteArray();
            String base64Image = Base64.getEncoder().encodeToString(imageBytes);
            
            System.out.println("👁️ [AvatarGenerator] 预览头像转换为base64成功");
            System.out.println("👁️ [AvatarGenerator] base64长度: " + base64Image.length());
            
            // 创建结果对象
            PreviewAvatarResult result = new PreviewAvatarResult();
            result.setPreviewImage("data:image/png;base64," + base64Image);
            result.setPreviewSeed(previewSeed);
            
            System.out.println("👁️ [AvatarGenerator] 预览结果创建成功");
            System.out.println("👁️ ========== AvatarGenerator.generatePreviewAvatar() 成功完成 ==========");
            
            return result;
            
        } catch (IOException e) {
            System.err.println("❌ [AvatarGenerator] 生成预览头像过程中发生IO异常");
            System.err.println("❌ [AvatarGenerator] 异常类型: " + e.getClass().getSimpleName());
            System.err.println("❌ [AvatarGenerator] 异常消息: " + e.getMessage());
            System.err.println("❌ [AvatarGenerator] 异常堆栈:");
            e.printStackTrace();
            System.err.println("❌ ========== AvatarGenerator.generatePreviewAvatar() 失败 ==========");
            throw new RuntimeException("生成预览头像失败: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("❌ [AvatarGenerator] 生成预览头像过程中发生未知异常");
            System.err.println("❌ [AvatarGenerator] 异常类型: " + e.getClass().getSimpleName());
            System.err.println("❌ [AvatarGenerator] 异常消息: " + e.getMessage());
            System.err.println("❌ [AvatarGenerator] 异常堆栈:");
            e.printStackTrace();
            System.err.println("❌ ========== AvatarGenerator.generatePreviewAvatar() 失败 ==========");
            throw new RuntimeException("生成预览头像失败: " + e.getMessage());
        }
    }

    @Override
    public String confirmAndSaveAvatar(String userUID, long previewSeed) {
        System.out.println("💾 ========== AvatarGenerator.confirmAndSaveAvatar() 开始 ==========");
        System.out.println("💾 [AvatarGenerator] 开始确认并保存头像");
        System.out.println("💾 [AvatarGenerator] 用户UID: " + userUID);
        System.out.println("💾 [AvatarGenerator] 预览种子: " + previewSeed);
        System.out.println("💾 [AvatarGenerator] 处理时间: " + java.time.LocalDateTime.now());
        
        try {
            // 使用预览种子重新生成相同的头像
            Random random = new Random(previewSeed);
            
            // 随机选择颜色方案
            int schemeIndex = random.nextInt(COLOR_SCHEMES.length);
            Color[] colorScheme = COLOR_SCHEMES[schemeIndex];
            
            // 创建80x80的图片
            BufferedImage image = new BufferedImage(AVATAR_SIZE, AVATAR_SIZE, BufferedImage.TYPE_INT_RGB);
            Graphics2D g2d = image.createGraphics();
            
            // 设置背景色（随机选择）
            Color backgroundColor = colorScheme[random.nextInt(colorScheme.length)];
            g2d.setColor(backgroundColor);
            g2d.fillRect(0, 0, AVATAR_SIZE, AVATAR_SIZE);
            
            // 随机生成2-8个色块
            int numBlocks = MIN_BLOCKS + random.nextInt(MAX_BLOCKS - MIN_BLOCKS + 1);
            
            for (int i = 0; i < numBlocks; i++) {
                // 随机选择颜色（不包括背景色）
                Color blockColor;
                do {
                    blockColor = colorScheme[random.nextInt(colorScheme.length)];
                } while (blockColor.equals(backgroundColor));
                
                // 随机位置（4x4网格，每个网格20x20像素）
                int gridX = random.nextInt(4);
                int gridY = random.nextInt(4);
                
                // 计算实际像素位置
                int pixelX = gridX * BLOCK_SIZE;
                int pixelY = gridY * BLOCK_SIZE;
                
                // 绘制色块
                g2d.setColor(blockColor);
                g2d.fillRect(pixelX, pixelY, BLOCK_SIZE, BLOCK_SIZE);
            }
            
            g2d.dispose();
            
            // 生成OSS对象名称
            String objectName = ((OssServiceImpl) ossService).generateObjectName(userUID, "avatar.png");
            System.out.println("💾 [AvatarGenerator] OSS对象名称: " + objectName);
            
            // 将BufferedImage转换为字节数组
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(image, "PNG", baos);
            byte[] imageBytes = baos.toByteArray();
            System.out.println("💾 [AvatarGenerator] 图片字节数: " + imageBytes.length);
            
            // 上传到OSS
            String avatarUrl = ossService.uploadBytes(imageBytes, objectName, "image/png");
            System.out.println("💾 [AvatarGenerator] OSS上传成功，URL: " + avatarUrl);
            
            System.out.println("💾 ========== AvatarGenerator.confirmAndSaveAvatar() 成功完成 ==========");
            
            return avatarUrl;
            
        } catch (Exception e) {
            System.err.println("❌ [AvatarGenerator] 确认并保存头像过程中发生异常");
            System.err.println("❌ [AvatarGenerator] 异常类型: " + e.getClass().getSimpleName());
            System.err.println("❌ [AvatarGenerator] 异常消息: " + e.getMessage());
            System.err.println("❌ [AvatarGenerator] 异常堆栈:");
            e.printStackTrace();
            System.err.println("❌ ========== AvatarGenerator.confirmAndSaveAvatar() 失败 ==========");
            throw new RuntimeException("确认并保存头像失败: " + e.getMessage());
        }
    }

    @Override
    public void deleteOldAvatar(String userUID) {
        System.out.println("🗑️ ========== AvatarGenerator.deleteOldAvatar() 开始 ==========");
        System.out.println("🗑️ [AvatarGenerator] 开始删除用户旧头像");
        System.out.println("🗑️ [AvatarGenerator] 用户UID: " + userUID);
        System.out.println("🗑️ [AvatarGenerator] 处理时间: " + java.time.LocalDateTime.now());
        
        try {
            // 注意：由于现在使用OSS存储，本地文件删除功能保留用于兼容性
            // 但主要功能已经迁移到OSS，这里不再需要删除本地文件
            System.out.println("ℹ️ [AvatarGenerator] 当前使用OSS存储，本地文件删除功能已弃用");
            System.out.println("ℹ️ [AvatarGenerator] 如需删除OSS中的旧头像，请在用户服务中实现");
            
            System.out.println("🗑️ ========== AvatarGenerator.deleteOldAvatar() 完成 ==========");
        } catch (Exception e) {
            System.err.println("❌ [AvatarGenerator] 删除旧头像过程中发生异常");
            System.err.println("❌ [AvatarGenerator] 异常类型: " + e.getClass().getSimpleName());
            System.err.println("❌ [AvatarGenerator] 异常消息: " + e.getMessage());
            System.err.println("❌ [AvatarGenerator] 异常堆栈:");
            e.printStackTrace();
            System.err.println("❌ ========== AvatarGenerator.deleteOldAvatar() 失败 ==========");
        }
    }
} 