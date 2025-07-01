package com.ai.companion.config;

import com.ai.companion.entity.User;
import com.ai.companion.mapper.UserMapper;
import com.ai.companion.mapper.PlanetMapper;
import com.ai.companion.entity.Planet;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 测试用户初始化器
 * 在应用启动时自动创建测试用户
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class TestUserInitializer implements CommandLineRunner {

    private final UserMapper userMapper;
    private final PlanetMapper planetMapper;

    @Override
    public void run(String... args) throws Exception {
        log.info("开始初始化测试用户...");
        
        try {
            // 检查测试用户是否已存在
            User existingUser = userMapper.selectByUID("100000001");
            
            if (existingUser == null) {
                // 创建测试用户
                User testUser = new User();
                testUser.setUserUID("100000001");
                testUser.setUserName("测试1");
                testUser.setGender("男");
                testUser.setPrivacyVisible(false);
                testUser.setSignature("这是一个测试用户");
                testUser.setEmail("test1@example.com");
                testUser.setLevel(1);
                testUser.setUserAvatar("/avatars/default.png");
                testUser.setRegisterTime(LocalDateTime.now());
                testUser.setUpdateTime(LocalDateTime.now());
                
                // 插入用户
                userMapper.insertUser(testUser);
                log.info("测试用户创建成功: {}", testUser.getUserName());
                
                // 为测试用户创建星球
                Planet testPlanet = new Planet();
                testPlanet.setUserId(testUser.getId());
                testPlanet.setLevel(1);
                testPlanet.setExperience(0L);
                testPlanet.setName("测试星球");
                testPlanet.setAppearance("{\"type\": \"default\", \"color\": \"#4A90E2\"}");
                testPlanet.setUnlockedItems("[]");
                testPlanet.setLastUpdated(LocalDateTime.now());
                
                planetMapper.insertPlanet(testPlanet);
                log.info("测试用户星球创建成功: {}", testPlanet.getName());
                
            } else {
                log.info("测试用户已存在: {}", existingUser.getUserName());
            }
            
        } catch (Exception e) {
            log.error("初始化测试用户失败", e);
        }
        
        log.info("测试用户初始化完成");
    }
} 