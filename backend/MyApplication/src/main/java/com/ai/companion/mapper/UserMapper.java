package com.ai.companion.mapper;

import com.ai.companion.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserMapper {

    // ========== 基础查询方法 ==========

    /**
     * 根据用户UID查询用户信息
     * 
     * @param userUID 用户唯一标识符
     * @return 用户实体
     */
    User selectByUID(@Param("userUID") String userUID);

    /**
     * 根据用户ID查询用户信息
     * 
     * @param id 用户ID
     * @return 用户实体
     */
    User selectById(@Param("id") Integer id);

    /**
     * 根据邮箱查询用户信息
     * 
     * @param email 邮箱地址
     * @return 用户实体
     */
    User selectByEmail(@Param("email") String email);

    /**
     * 根据用户名查询用户信息
     * 
     * @param userName 用户名
     * @return 用户实体
     */
    User selectByUserName(@Param("userName") String userName);

    /**
     * 查询所有用户
     * 
     * @return 用户列表
     */
    List<User> selectAll();

    // ========== 分页和模糊查询方法 ==========

    /**
     * 分页查询用户列表
     * 
     * 注意事项：！！，在代码中要判断offest
     * 1. offset参数必须 >= 0，否则MySQL会报SQL语法错误
     * 2. limit建议为正整数，避免全表扫描
     * 
     * @param offset 偏移量（必须 >= 0）
     * @param limit  限制数量（建议 > 0）
     * @return 用户列表
     * 
     *         使用示例：
     *         查询第1页，每页10条数据：List<User> page1 = userMapper.selectByPage(0, 10);
     *         查询第2页，每页10条数据：List<User> page2 = userMapper.selectByPage(10, 10);
     *         查询第3页，每页10条数据：List<User> page3 = userMapper.selectByPage(20, 10);
     */
    List<User> selectByPage(@Param("offset") Integer offset, @Param("limit") Integer limit);

    /**
     * 根据用户名模糊查询
     * 
     * @param userName 用户名（支持模糊匹配）
     * @return 用户列表
     */
    List<User> selectByUserNameLike(@Param("userName") String userName);

    /**
     * 根据邮箱模糊查询
     * 
     * @param email 邮箱（支持模糊匹配）
     * @return 用户列表
     */
    List<User> selectByEmailLike(@Param("email") String email);

    // ========== 条件查询方法 ==========

    /**
     * 根据用户等级查询
     * 
     * @param level 用户等级
     * @return 用户列表
     */
    List<User> selectByLevel(@Param("level") Integer level);

    /**
     * 根据性别查询用户
     * 
     * @param gender 性别
     * @return 用户列表
     */
    List<User> selectByGender(@Param("gender") String gender);

    /**
     * 根据隐私设置查询用户
     * 
     * @param privacyVisible 是否公开
     * @return 用户列表
     */
    List<User> selectByPrivacy(@Param("privacyVisible") Boolean privacyVisible);

    /**
     * 复合条件查询用户
     * 
     * @param userName       用户名（可选）
     * @param email          邮箱（可选）
     * @param level          等级（可选）
     * @param gender         性别（可选）
     * @param privacyVisible 隐私设置（可选）
     * @return 用户列表
     * 
     *         使用时，如果某个条件为null，则不进行查询
     *         例：selectByConditions(null, "test@example.com", null, null, null)
     */
    List<User> selectByConditions(@Param("userName") String userName,
            @Param("email") String email,
            @Param("level") Integer level,
            @Param("gender") String gender,
            @Param("privacyVisible") Boolean privacyVisible);

    // ========== 时间相关查询方法 ==========

    /**
     * 获取最新注册的用户
     * 
     * @param limit 限制数量
     * @return 用户列表
     */
    List<User> selectLatestUsers(@Param("limit") Integer limit);

    /**
     * 根据注册时间范围查询用户
     * 
     * @param startTime 开始时间
     * @param endTime   结束时间
     * @return 用户列表
     */
    List<User> selectByRegisterTimeRange(@Param("startTime") String startTime,
            @Param("endTime") String endTime);

    // ========== 搜索方法 ==========

    /**
     * 搜索用户（支持用户名和邮箱的模糊搜索）
     * 
     * @param keyword 搜索关键词
     * @param limit   限制数量
     * @return 用户列表
     */
    List<User> searchUsers(@Param("keyword") String keyword, @Param("limit") Integer limit);

    // ========== 批量查询方法 ==========

    /**
     * 根据多个ID查询用户
     * 
     * @param ids 用户ID列表
     * @return 用户列表
     */
    List<User> selectByIds(@Param("ids") List<Integer> ids);

    // ========== 插入和更新方法 ==========

    /**
     * 插入新用户
     * 
     * @param user 用户实体
     * @return 影响的行数
     */
    int insertUser(User user);

    /**
     * 更新用户信息
     * 
     * @param user 用户实体
     * @return 影响的行数
     */
    int updateUser(User user);

    // ========== 删除方法 ==========

    /**
     * 根据用户UID删除用户
     * 
     * @param userUID 用户唯一标识符
     * @return 影响的行数
     */
    int deleteUser(@Param("userUID") String userUID);

    /**
     * 根据用户ID删除用户
     * 
     * @param id 用户ID
     * @return 影响的行数
     */
    int deleteUserById(@Param("id") Integer id);

    /**
     * 批量删除用户
     * 
     * @param ids 用户ID列表
     * @return 影响的行数
     */
    int batchDeleteUsers(@Param("ids") List<Integer> ids);

    // ========== 批量更新方法 ==========

    /**
     * 批量更新用户等级
     * 
     * @param ids   用户ID列表
     * @param level 新的等级
     * @return 影响的行数
     */
    int batchUpdateUserLevel(@Param("ids") List<Integer> ids, @Param("level") Integer level);

    // ========== 数据验证方法 ==========

    /**
     * 检查用户名是否存在
     * 
     * @param userName  用户名
     * @param excludeId 排除的用户ID（用于更新时检查）
     * @return 是否存在
     */
    boolean existsByUserName(@Param("userName") String userName, @Param("excludeId") Integer excludeId);

    /**
     * 检查邮箱是否存在
     * 
     * @param email     邮箱
     * @param excludeId 排除的用户ID（用于更新时检查）
     * @return 是否存在
     */
    boolean existsByEmail(@Param("email") String email, @Param("excludeId") Integer excludeId);

    /**
     * 检查用户UID是否存在
     * 
     * @param userUID 用户UID
     * @return 是否存在
     */
    boolean existsByUserUID(@Param("userUID") String userUID);

    // ========== 统计方法 ==========

    /**
     * 统计总用户数量
     * 
     * @return 总用户数量
     */
    int countAll();

    /**
     * 统计各等级用户数量
     * 
     * @param level 用户等级
     * @return 用户数量
     */
    int countByLevel(@Param("level") Integer level);

    /**
     * 统计各性别用户数量
     * 
     * @param gender 性别
     * @return 用户数量
     */
    int countByGender(@Param("gender") String gender);

    /**
     * 统计今日注册用户数量
     * 
     * @return 今日注册用户数量
     */
    int countTodayRegistered();

    /**
     * 获取用户等级分布统计
     * 
     * @return 用户等级分布
     */
    List<User> selectUserLevelDistribution();
}