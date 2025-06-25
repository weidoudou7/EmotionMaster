package com.ai.companion;

import com.ai.companion.controller.UserController;
import com.ai.companion.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class UserControllerTest {

    @Autowired
    private UserController userController;

    @Autowired
    private UserService userService;

    @Test
    public void testHealthCheck() {
        var response = userController.health();
        assertTrue(response.isSuccess());
        assertEquals("用户服务运行正常", response.getMessage());
        assertEquals("OK", response.getData());
    }

    @Test
    public void testGetUserInfo() {
        var response = userController.getUserInfo("100000000");
        assertTrue(response.isSuccess());
        assertNotNull(response.getData());
        assertEquals("100000000", response.getData().getUserUID());
    }

    @Test
    public void testCreateUser() {
        var response = userController.createUser("test123", "测试用户");
        assertTrue(response.isSuccess());
        assertNotNull(response.getData());
        assertEquals("test123", response.getData().getUserUID());
        assertEquals("测试用户", response.getData().getUserName());
    }
} 