package com.ai.companion.mapper;

import com.ai.companion.entity.AiRole;
import com.ai.companion.entity.User;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@SpringBootTest
@Transactional
@Rollback
public class AiRoleMapperTest {

    @Autowired
    private AiRoleMapper aiRoleMapper;

    @Autowired
    private UserMapper userMapper;

    private Integer testUserId;

    @BeforeEach
    void setUp() {
        // 使用 User.java 中存在的构造函数和字段
        User user = new User("test_user_for_airole", "test_user_for_airole");
        user.setEmail("testuser_for_airole_test@example.com");
        // user.setPassword("password"); // User.java中没有此字段
        userMapper.insertUser(user);
        // 假设insertUser后, mybatis会把自增id回填到user对象
        Assertions.assertNotNull(user.getId(), "用户ID在插入后不应为空");
        testUserId = user.getId();
    }

    private AiRole buildTestAiRole() {
        AiRole aiRole = new AiRole();
        aiRole.setUserId(testUserId);
        aiRole.setRoleName("测试角色");
        aiRole.setRoleDescription("测试描述");
        aiRole.setPersonality("{\"type\":\"friendly\"}");
        aiRole.setSpecialty("[\"AI\",\"NLP\"]");
        aiRole.setAvatarUrl("/avatars/airole.png");
        aiRole.setIsTemplate(false);
        aiRole.setCreatedAt(LocalDateTime.now());
        return aiRole;
    }

    @Test
    public void testInsertAiRole() {
        AiRole aiRole = buildTestAiRole();
        int rows = aiRoleMapper.insertAiRole(aiRole);
        Assertions.assertEquals(1, rows);
        Assertions.assertNotNull(aiRole.getId());
    }

    @Test
    public void testSelectByUserId() {
        AiRole aiRole = buildTestAiRole();
        aiRoleMapper.insertAiRole(aiRole);
        List<AiRole> roles = aiRoleMapper.selectByUserId(testUserId);
        Assertions.assertFalse(roles.isEmpty());
        Assertions.assertEquals("测试角色", roles.get(0).getRoleName());
    }

    @Test
    public void testSelectById() {
        AiRole aiRole = buildTestAiRole();
        aiRoleMapper.insertAiRole(aiRole);
        Assertions.assertNotNull(aiRole.getId());
        AiRole found = aiRoleMapper.selectById(aiRole.getId());
        Assertions.assertNotNull(found);
        Assertions.assertEquals("测试角色", found.getRoleName());
    }

    @Test
    public void testUpdateAiRole() {
        AiRole aiRole = buildTestAiRole();
        aiRoleMapper.insertAiRole(aiRole);
        Assertions.assertNotNull(aiRole.getId());

        AiRole toUpdate = aiRoleMapper.selectById(aiRole.getId());
        toUpdate.setRoleName("新角色名");
        toUpdate.setRoleDescription("新描述");
        int rows = aiRoleMapper.updateAiRole(toUpdate);
        Assertions.assertEquals(1, rows);

        AiRole updated = aiRoleMapper.selectById(toUpdate.getId());
        Assertions.assertEquals("新角色名", updated.getRoleName());
        Assertions.assertEquals("新描述", updated.getRoleDescription());
    }

    @Test
    public void testSelectAll() {
        AiRole aiRole = buildTestAiRole();
        aiRoleMapper.insertAiRole(aiRole);
        List<AiRole> all = aiRoleMapper.selectAll();
        Assertions.assertTrue(all.stream().anyMatch(r -> r.getUserId().equals(testUserId)));
    }

    @Test
    public void testDeleteAiRole() {
        AiRole aiRole = buildTestAiRole();
        aiRoleMapper.insertAiRole(aiRole);
        Assertions.assertNotNull(aiRole.getId());
        Integer id = aiRole.getId();

        int rows = aiRoleMapper.deleteAiRole(id);
        Assertions.assertEquals(1, rows);

        AiRole deleted = aiRoleMapper.selectById(id);
        Assertions.assertNull(deleted);
    }
}