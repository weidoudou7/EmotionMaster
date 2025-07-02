package com.ai.companion.config;

import com.ai.companion.entity.User;
import com.ai.companion.service.UserService;
import com.ai.companion.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 测试用户初始化器
 * 在应用启动时创建测试用户，在应用关闭时删除
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class TestUserInitializer implements ApplicationRunner, DisposableBean {

    private final UserService userService;
    private final UserMapper userMapper;
    private static final String TEST_UID = "test-uid-101";
    private static final String TEST_USERNAME = "测试用户101";

    @Override
    public void run(ApplicationArguments args) throws Exception {
        try {
            log.info("开始创建测试用户: {}", TEST_UID);
            
            // 创建测试用户
            User testUser = new User();
            testUser.setUserUID(TEST_UID);
            testUser.setUserName(TEST_USERNAME);
            testUser.setGender("男");
            testUser.setPrivacyVisible(false);
            testUser.setSignature("我是测试用户101，用于功能测试");
            testUser.setEmail("testuser101@example.com");
            testUser.setLevel(1);
            testUser.setRegisterTime(LocalDateTime.now());
            testUser.setUpdateTime(LocalDateTime.now());
            testUser.setUserAvatar("/avatars/default.png");

            // 检查用户是否已存在（直接使用Mapper避免触发调试日志）
            try {
                User existingUser = userMapper.selectByUID(TEST_UID);
                if (existingUser != null) {
                    log.info("✅ 测试用户已存在: {} - {}", TEST_UID, TEST_USERNAME);
                } else {
                    // 用户不存在，创建新用户
                    int result = userService.insertUser(testUser);
                    
                    if (result > 0) {
                        log.info("✅ 测试用户创建成功: {} - {}", TEST_UID, TEST_USERNAME);
                    } else {
                        log.warn("⚠️ 测试用户创建失败: {}", TEST_UID);
                    }
                }
            } catch (Exception e) {
                log.error("❌ 检查测试用户状态失败: {}", e.getMessage());
            }
            
        } catch (Exception e) {
            log.error("❌ 创建测试用户失败: {}", e.getMessage(), e);
        }
    }

    /**
     * 应用关闭时删除测试用户
     */
    @Override
    public void destroy() throws Exception {
        try {
            log.info("开始清理测试用户: {}", TEST_UID);
            
            // 删除测试用户
            boolean deleted = userService.deleteUser(TEST_UID);
            
            if (deleted) {
                log.info("✅ 测试用户删除成功: {}", TEST_UID);
            } else {
                log.warn("⚠️ 测试用户删除失败或不存在: {}", TEST_UID);
            }
            
        } catch (Exception e) {
            log.error("❌ 清理测试用户失败: {}", e.getMessage(), e);
        }
    }
} 