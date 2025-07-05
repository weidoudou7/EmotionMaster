package com.ai.companion.mapper;

import com.ai.companion.entity.User;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
@Rollback
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class UserMapperTest {

    @Autowired
    private UserMapper userMapper;

    private static final String TEST_USER_UID = "test_user_" + System.currentTimeMillis();
    private User testUser;
    private List<User> testUsers;

    @BeforeEach
    void setUp() {
        // 创建测试用户
        testUser = buildTestUser();
        userMapper.insertUser(testUser);
        assertNotNull(testUser.getId(), "用户ID在插入后不应为空");

        // 创建多个测试用户
        testUsers = Arrays.asList(
                buildTestUser("user1", "user1@example.com", 1, "男", false),
                buildTestUser("user2", "user2@gmail.com", 2, "女", true),
                buildTestUser("张三", "zhangsan@example.com", 1, "男", false),
                buildTestUser("李四", "lisi@gmail.com", 3, "女", false),
                buildTestUser("王五", "wangwu@test.com", 2, "男", true));

        for (User user : testUsers) {
            userMapper.insertUser(user);
        }
    }

    private User buildTestUser() {
        return buildTestUser("testuser", "test@example.com", 1, "未设置", false);
    }

    private User buildTestUser(String userName, String email, Integer level, String gender, Boolean privacyVisible) {
        User user = new User(TEST_USER_UID + "_" + userName, userName);
        user.setEmail(email);
        user.setLevel(level);
        user.setGender(gender);
        user.setPrivacyVisible(privacyVisible);
        user.setSignature("测试用户签名：" + userName);
        user.setRegisterTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        user.setUserAvatar("/avatars/default.png");
        return user;
    }

    // ========== 基础查询方法测试 ==========

    @Test
    @Order(1)
    public void testSelectByUID() {
        User found = userMapper.selectByUID(testUser.getUserUID());
        assertNotNull(found);
        assertEquals("testuser", found.getUserName());
        assertEquals("test@example.com", found.getEmail());
    }

    @Test
    @Order(2)
    public void testSelectById() {
        User found = userMapper.selectById(testUser.getId());
        assertNotNull(found);
        assertEquals("testuser", found.getUserName());
    }

    @Test
    @Order(3)
    public void testSelectByEmail() {
        User found = userMapper.selectByEmail("test@example.com");
        assertNotNull(found);
        assertEquals("testuser", found.getUserName());
    }

    @Test
    @Order(4)
    public void testSelectByUserName() {
        User found = userMapper.selectByUserName("testuser");
        assertNotNull(found);
        assertEquals("test@example.com", found.getEmail());
    }

    @Test
    @Order(5)
    public void testSelectAll() {
        List<User> allUsers = userMapper.selectAll();
        assertFalse(allUsers.isEmpty());
        assertTrue(allUsers.size() >= 6); // 包括setUp中创建的用户
    }

    // ========== 分页和模糊查询方法测试 ==========

    @Test
    @Order(6)
    public void testSelectByPage() {
        List<User> page1 = userMapper.selectByPage(0, 3);
        assertEquals(3, page1.size());

        // 验证按注册时间倒序排列
        assertTrue(page1.get(0).getRegisterTime().isAfter(page1.get(1).getRegisterTime()) ||
                page1.get(0).getRegisterTime().isEqual(page1.get(1).getRegisterTime()));

        // 测试第二页
        List<User> page2 = userMapper.selectByPage(3, 3);
        assertTrue(page2.size() <= 3);
    }

    @Test
    @Order(7)
    public void testSelectByUserNameLike() {
        List<User> users = userMapper.selectByUserNameLike("user");
        assertFalse(users.isEmpty());
        assertTrue(users.stream().allMatch(user -> user.getUserName().contains("user")));
    }

    @Test
    @Order(8)
    public void testSelectByEmailLike() {
        List<User> users = userMapper.selectByEmailLike("gmail");
        assertFalse(users.isEmpty());
        assertTrue(users.stream().allMatch(user -> user.getEmail().contains("gmail")));
    }

    // ========== 条件查询方法测试 ==========

    @Test
    @Order(9)
    public void testSelectByLevel() {
        List<User> level1Users = userMapper.selectByLevel(1);
        assertFalse(level1Users.isEmpty());
        assertTrue(level1Users.stream().allMatch(user -> user.getLevel() == 1));

        List<User> level2Users = userMapper.selectByLevel(2);
        assertFalse(level2Users.isEmpty());
        assertTrue(level2Users.stream().allMatch(user -> user.getLevel() == 2));
    }

    @Test
    @Order(10)
    public void testSelectByGender() {
        List<User> maleUsers = userMapper.selectByGender("男");
        assertFalse(maleUsers.isEmpty());
        assertTrue(maleUsers.stream().allMatch(user -> "男".equals(user.getGender())));

        List<User> femaleUsers = userMapper.selectByGender("女");
        assertFalse(femaleUsers.isEmpty());
        assertTrue(femaleUsers.stream().allMatch(user -> "女".equals(user.getGender())));
    }

    @Test
    @Order(11)
    public void testSelectByPrivacy() {
        List<User> publicUsers = userMapper.selectByPrivacy(false);
        assertFalse(publicUsers.isEmpty());
        assertTrue(publicUsers.stream().allMatch(user -> !user.isPrivacyVisible()));

        List<User> privateUsers = userMapper.selectByPrivacy(true);
        assertFalse(privateUsers.isEmpty());
        assertTrue(privateUsers.stream().allMatch(user -> user.isPrivacyVisible()));
    }

    @Test
    @Order(12)
    public void testSelectByConditions() {
        // 测试按等级查询
        List<User> level1Users = userMapper.selectByConditions(null, null, 1, null, null);
        assertFalse(level1Users.isEmpty());
        assertTrue(level1Users.stream().allMatch(user -> user.getLevel() == 1));

        // 测试按性别查询
        List<User> maleUsers = userMapper.selectByConditions(null, null, null, "男", null);
        assertFalse(maleUsers.isEmpty());
        assertTrue(maleUsers.stream().allMatch(user -> "男".equals(user.getGender())));

        // 测试按隐私设置查询
        List<User> publicUsers = userMapper.selectByConditions(null, null, null, null, false);
        assertFalse(publicUsers.isEmpty());
        assertTrue(publicUsers.stream().allMatch(user -> !user.isPrivacyVisible()));

        // 测试复合条件查询
        List<User> complexUsers = userMapper.selectByConditions("user", null, 1, "男", false);
        assertFalse(complexUsers.isEmpty());
        assertTrue(complexUsers.stream().allMatch(user -> user.getUserName().contains("user") &&
                user.getLevel() == 1 &&
                "男".equals(user.getGender()) &&
                !user.isPrivacyVisible()));
    }

    // ========== 时间相关查询方法测试 ==========

    @Test
    @Order(13)
    public void testSelectLatestUsers() {
        List<User> latestUsers = userMapper.selectLatestUsers(3);
        assertEquals(3, latestUsers.size());

        // 验证按注册时间倒序排列
        assertTrue(latestUsers.get(0).getRegisterTime().isAfter(latestUsers.get(1).getRegisterTime()) ||
                latestUsers.get(0).getRegisterTime().isEqual(latestUsers.get(1).getRegisterTime()));
    }

    @Test
    @Order(14)
    public void testSelectByRegisterTimeRange() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime startTime = now.minusDays(1);
        LocalDateTime endTime = now.plusDays(1);

        List<User> users = userMapper.selectByRegisterTimeRange(
                startTime.toString(), endTime.toString());
        assertFalse(users.isEmpty());
    }

    // ========== 搜索方法测试 ==========

    @Test
    @Order(15)
    public void testSearchUsers() {
        // 测试按用户名搜索
        List<User> nameResults = userMapper.searchUsers("user", 5);
        assertFalse(nameResults.isEmpty());
        assertTrue(nameResults.stream().anyMatch(user -> user.getUserName().contains("user")));

        // 测试按邮箱搜索
        List<User> emailResults = userMapper.searchUsers("gmail", 5);
        assertFalse(emailResults.isEmpty());
        assertTrue(emailResults.stream().anyMatch(user -> user.getEmail().contains("gmail")));

        // 测试不存在的关键词
        List<User> notFoundResults = userMapper.searchUsers("不存在的关键词", 5);
        assertEquals(0, notFoundResults.size());
    }

    // ========== 批量查询方法测试 ==========

    @Test
    @Order(16)
    public void testSelectByIds() {
        List<Integer> ids = Arrays.asList(
                testUsers.get(0).getId(),
                testUsers.get(1).getId(),
                testUsers.get(2).getId());

        List<User> users = userMapper.selectByIds(ids);
        assertEquals(3, users.size());

        // 验证返回的用户ID都在请求列表中
        List<Integer> returnedIds = users.stream()
                .map(User::getId)
                .toList();
        assertTrue(returnedIds.containsAll(ids));
    }

    // ========== 插入和更新方法测试 ==========

    @Test
    @Order(17)
    public void testInsertUser() {
        User newUser = buildTestUser("新用户", "newuser@example.com", 1, "男", false);
        int rows = userMapper.insertUser(newUser);
        assertEquals(1, rows);
        assertNotNull(newUser.getId());
    }

    @Test
    @Order(18)
    public void testUpdateUser() {
        User toUpdate = userMapper.selectById(testUser.getId());
        toUpdate.setUserName("更新后的用户名");
        toUpdate.setLevel(5);
        toUpdate.setGender("女");

        int rows = userMapper.updateUser(toUpdate);
        assertEquals(1, rows);

        User updated = userMapper.selectById(testUser.getId());
        assertEquals("更新后的用户名", updated.getUserName());
        assertEquals(5, updated.getLevel());
        assertEquals("女", updated.getGender());
    }

    // ========== 删除方法测试 ==========

    @Test
    @Order(19)
    public void testDeleteUser() {
        int rows = userMapper.deleteUser(testUser.getUserUID());
        assertEquals(1, rows);

        User deleted = userMapper.selectByUID(testUser.getUserUID());
        assertNull(deleted);
    }

    @Test
    @Order(20)
    public void testDeleteUserById() {
        int rows = userMapper.deleteUserById(testUsers.get(0).getId());
        assertEquals(1, rows);

        User deleted = userMapper.selectById(testUsers.get(0).getId());
        assertNull(deleted);
    }

    @Test
    @Order(21)
    public void testBatchDeleteUsers() {
        List<Integer> idsToDelete = Arrays.asList(
                testUsers.get(0).getId(),
                testUsers.get(1).getId());

        int rows = userMapper.batchDeleteUsers(idsToDelete);
        assertEquals(2, rows);

        // 验证删除成功
        for (Integer id : idsToDelete) {
            assertNull(userMapper.selectById(id));
        }
    }

    // ========== 批量更新方法测试 ==========

    @Test
    @Order(22)
    public void testBatchUpdateUserLevel() {
        List<Integer> idsToUpdate = Arrays.asList(
                testUsers.get(0).getId(),
                testUsers.get(1).getId());

        int rows = userMapper.batchUpdateUserLevel(idsToUpdate, 10);
        assertEquals(2, rows);

        // 验证更新成功
        for (Integer id : idsToUpdate) {
            User updated = userMapper.selectById(id);
            assertEquals(10, updated.getLevel());
        }
    }

    // ========== 数据验证方法测试 ==========

    @Test
    @Order(23)
    public void testExistsByUserName() {
        // 测试存在的用户名
        boolean exists = userMapper.existsByUserName("testuser", null);
        assertTrue(exists);

        // 测试不存在的用户名
        boolean notExists = userMapper.existsByUserName("不存在的用户名", null);
        assertFalse(notExists);

        // 测试排除当前记录的情况
        boolean existsExcluding = userMapper.existsByUserName("testuser", testUser.getId());
        assertFalse(existsExcluding);
    }

    @Test
    @Order(24)
    public void testExistsByEmail() {
        // 测试存在的邮箱
        boolean exists = userMapper.existsByEmail("test@example.com", null);
        assertTrue(exists);

        // 测试不存在的邮箱
        boolean notExists = userMapper.existsByEmail("notexist@example.com", null);
        assertFalse(notExists);

        // 测试排除当前记录的情况
        boolean existsExcluding = userMapper.existsByEmail("test@example.com", testUser.getId());
        assertFalse(existsExcluding);
    }

    @Test
    @Order(25)
    public void testExistsByUserUID() {
        // 测试存在的UID
        boolean exists = userMapper.existsByUserUID(testUser.getUserUID());
        assertTrue(exists);

        // 测试不存在的UID
        boolean notExists = userMapper.existsByUserUID("不存在的UID");
        assertFalse(notExists);
    }

    // ========== 统计方法测试 ==========

    @Test
    @Order(26)
    public void testCountAll() {
        int totalCount = userMapper.countAll();
        assertTrue(totalCount >= 6); // 包括setUp中创建的用户
    }

    @Test
    @Order(27)
    public void testCountByLevel() {
        int level1Count = userMapper.countByLevel(1);
        int level2Count = userMapper.countByLevel(2);
        int level3Count = userMapper.countByLevel(3);

        assertTrue(level1Count >= 2);
        assertTrue(level2Count >= 2);
        assertTrue(level3Count >= 1);
    }

    @Test
    @Order(28)
    public void testCountByGender() {
        int maleCount = userMapper.countByGender("男");
        int femaleCount = userMapper.countByGender("女");

        assertTrue(maleCount >= 3);
        assertTrue(femaleCount >= 2);
    }

    @Test
    @Order(29)
    public void testCountTodayRegistered() {
        int todayCount = userMapper.countTodayRegistered();
        assertTrue(todayCount >= 6); // 包括setUp中创建的用户
    }

    @Test
    @Order(30)
    public void testSelectUserLevelDistribution() {
        List<User> distribution = userMapper.selectUserLevelDistribution();
        assertFalse(distribution.isEmpty());
        // 验证返回的是等级分布数据
        assertTrue(distribution.size() <= 10); // 假设等级不会超过10个
    }

    // ========== 边界条件测试 ==========

    @Test
    @Order(31)
    public void testSelectByPageWithInvalidParams() {
        // 测试零限制
        List<User> zeroLimitUsers = userMapper.selectByPage(0, 0);
        assertNotNull(zeroLimitUsers);
        assertEquals(0, zeroLimitUsers.size());

        // 测试大偏移量（应该返回空列表）
        List<User> largeOffsetUsers = userMapper.selectByPage(1000, 5);
        assertNotNull(largeOffsetUsers);
        assertEquals(0, largeOffsetUsers.size());

        // 测试正常参数
        List<User> normalUsers = userMapper.selectByPage(0, 5);
        assertNotNull(normalUsers);
        assertTrue(normalUsers.size() <= 5);
    }

    @Test
    @Order(32)
    public void testSelectByConditionsWithNullParams() {
        // 测试所有参数都为null的情况
        List<User> users = userMapper.selectByConditions(null, null, null, null, null);
        assertNotNull(users);
        assertFalse(users.isEmpty());
    }

    @Test
    @Order(33)
    public void testSearchUsersWithEmptyKeyword() {
        List<User> users = userMapper.searchUsers("", 5);
        assertNotNull(users);
        // 空关键词应该返回用户，但受LIMIT限制
        assertEquals(5, users.size());

        // 测试更大的limit
        List<User> moreUsers = userMapper.searchUsers("", 10);
        assertNotNull(moreUsers);
        assertTrue(moreUsers.size() >= 6); // 应该能返回所有用户
    }

    @Test
    @Order(34)
    public void testSearchUsersWithSpecialCharacters() {
        // 测试中文字符搜索
        List<User> users = userMapper.searchUsers("张", 5);
        assertNotNull(users);
        assertTrue(users.stream().anyMatch(user -> user.getUserName().contains("张")));

        // 测试不存在的关键词
        List<User> notFoundUsers = userMapper.searchUsers("不存在的关键词123456", 5);
        assertNotNull(notFoundUsers);
        assertEquals(0, notFoundUsers.size());
    }

    // ========== 性能测试 ==========

    @Test
    @Order(35)
    public void testPerformanceWithLargeDataset() {
        // 创建多个用户进行性能测试
        for (int i = 0; i < 10; i++) {
            User user = buildTestUser("性能测试用户" + i, "perf" + i + "@example.com", i % 3 + 1, "男", false);
            userMapper.insertUser(user);
        }

        // 测试分页查询性能
        long startTime = System.currentTimeMillis();
        List<User> users = userMapper.selectByPage(0, 20);
        long endTime = System.currentTimeMillis();

        assertTrue(endTime - startTime < 1000); // 应该在1秒内完成
        assertTrue(users.size() <= 20);
    }

    // ========== 业务场景测试 ==========

    @Test
    @Order(36)
    public void testUserManagementScenario() {
        // 模拟用户管理后台的场景

        // 1. 分页查询用户列表
        List<User> page1 = userMapper.selectByPage(0, 5);
        assertTrue(page1.size() <= 5);

        // 2. 按条件筛选用户
        List<User> level1Users = userMapper.selectByConditions(null, null, 1, null, null);
        assertFalse(level1Users.isEmpty());

        // 3. 搜索用户
        List<User> searchResults = userMapper.searchUsers("user", 10);
        assertFalse(searchResults.isEmpty());

        // 4. 统计用户数量
        int totalUsers = userMapper.countAll();
        assertTrue(totalUsers >= 6);

        // 5. 获取最新用户
        List<User> latestUsers = userMapper.selectLatestUsers(3);
        assertEquals(3, latestUsers.size());
    }
}