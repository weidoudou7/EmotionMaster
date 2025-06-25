package com.ai.companion.mapper;

import com.ai.companion.entity.User;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@SpringBootTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@Transactional
@Rollback
public class UserMapperTest {

    @Autowired
    private UserMapper userMapper;

    private static final String TEST_UID = "test_uid_001";

    private User buildTestUser() {
        User user = new User();
        user.setUserUID(TEST_UID);
        user.setUserName("测试用户");
        user.setGender("男");
        user.setPrivacyVisible(false);
        user.setSignature("测试签名");
        user.setEmail("test@example.com");
        user.setLevel(1);
        user.setRegisterTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        user.setUserAvatar("/avatars/test.png");
        return user;
    }

    @Test
    @Order(1)
    public void testInsertUser() {
        User user = buildTestUser();
        int rows = userMapper.insertUser(user);
        Assertions.assertEquals(1, rows);
    }

    @Test
    @Order(2)
    public void testSelectByUID() {
        User user = buildTestUser();
        userMapper.insertUser(user);
        User found = userMapper.selectByUID(TEST_UID);
        Assertions.assertNotNull(found);
        Assertions.assertEquals("测试用户", found.getUserName());
    }

    @Test
    @Order(3)
    public void testUpdateUser() {
        User user = buildTestUser();
        userMapper.insertUser(user);
        user.setUserName("新用户名");
        user.setSignature("新签名");
        int rows = userMapper.updateUser(user);
        Assertions.assertEquals(1, rows);
        User updated = userMapper.selectByUID(TEST_UID);
        Assertions.assertEquals("新用户名", updated.getUserName());
        Assertions.assertEquals("新签名", updated.getSignature());
    }

    @Test
    @Order(4)
    public void testSelectAll() {
        User user = buildTestUser();
        userMapper.insertUser(user);
        List<User> users = userMapper.selectAll();
        Assertions.assertTrue(users.size() > 0);
    }

    @Test
    @Order(5)
    public void testDeleteUser() {
        User user = buildTestUser();
        userMapper.insertUser(user);
        int rows = userMapper.deleteUser(TEST_UID);
        Assertions.assertEquals(1, rows);
        User deleted = userMapper.selectByUID(TEST_UID);
        Assertions.assertNull(deleted);
    }
}