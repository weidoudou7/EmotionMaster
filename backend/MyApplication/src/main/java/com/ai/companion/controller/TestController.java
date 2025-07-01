package com.ai.companion.controller;

import com.ai.companion.entity.User;
import com.ai.companion.entity.Planet;
import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.mapper.UserMapper;
import com.ai.companion.mapper.PlanetMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 测试控制器
 * 用于验证测试用户和系统功能
 */
@RestController
@RequestMapping("/test")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:8080", allowCredentials = "true")
public class TestController {

    private final UserMapper userMapper;
    private final PlanetMapper planetMapper;

    /**
     * 检查测试用户是否存在
     */
    @GetMapping("/user/check")
    public ApiResponse<Map<String, Object>> checkTestUser() {
        try {
            User testUser = userMapper.selectByUID("100000001");
            Planet testPlanet = null;
            
            if (testUser != null) {
                testPlanet = planetMapper.selectByUserId(testUser.getId());
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("userExists", testUser != null);
            result.put("planetExists", testPlanet != null);
            
            if (testUser != null) {
                Map<String, Object> userInfo = new HashMap<>();
                userInfo.put("id", testUser.getId());
                userInfo.put("userUID", testUser.getUserUID());
                userInfo.put("userName", testUser.getUserName());
                userInfo.put("gender", testUser.getGender());
                userInfo.put("email", testUser.getEmail());
                userInfo.put("level", testUser.getLevel());
                userInfo.put("userAvatar", testUser.getUserAvatar());
                result.put("userInfo", userInfo);
            }
            
            if (testPlanet != null) {
                Map<String, Object> planetInfo = new HashMap<>();
                planetInfo.put("id", testPlanet.getId());
                planetInfo.put("name", testPlanet.getName());
                planetInfo.put("level", testPlanet.getLevel());
                planetInfo.put("experience", testPlanet.getExperience());
                result.put("planetInfo", planetInfo);
            }
            
            return ApiResponse.success("测试用户检查完成", result);
            
        } catch (Exception e) {
            return ApiResponse.error("检查测试用户失败: " + e.getMessage());
        }
    }

    /**
     * 获取测试用户信息
     */
    @GetMapping("/user/info")
    public ApiResponse<User> getTestUserInfo() {
        try {
            User testUser = userMapper.selectByUID("100000001");
            if (testUser != null) {
                return ApiResponse.success("获取测试用户信息成功", testUser);
            } else {
                return ApiResponse.error("测试用户不存在");
            }
        } catch (Exception e) {
            return ApiResponse.error("获取测试用户信息失败: " + e.getMessage());
        }
    }

    /**
     * 健康检查
     */
    @GetMapping("/health")
    public ApiResponse<String> health() {
        return ApiResponse.success("测试控制器运行正常", "OK");
    }
} 