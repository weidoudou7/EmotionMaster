package com.ai.companion.mapper;

import com.ai.companion.entity.UserBehavior;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户行为记录Mapper接口
 * 定义对user_behavior表的数据库操作
 */
@Mapper
public interface UserBehaviorMapper {

    /**
     * 插入用户行为记录
     * @param userBehavior 用户行为记录
     * @return 影响的行数
     */
    int insertUserBehavior(UserBehavior userBehavior);

    /**
     * 根据ID查询用户行为记录
     * @param id 记录ID
     * @return 用户行为记录
     */
    UserBehavior selectById(Integer id);

    /**
     * 根据用户ID查询用户行为记录
     * @param userId 用户ID
     * @return 用户行为记录列表
     */
    List<UserBehavior> selectByUserId(Integer userId);

    /**
     * 根据角色ID查询用户行为记录
     * @param roleId 角色ID
     * @return 用户行为记录列表
     */
    List<UserBehavior> selectByRoleId(Integer roleId);

    /**
     * 根据用户ID和角色ID查询用户行为记录
     * @param userId 用户ID
     * @param roleId 角色ID
     * @return 用户行为记录列表
     */
    List<UserBehavior> selectByUserIdAndRoleId(@Param("userId") Integer userId, @Param("roleId") Integer roleId);

    /**
     * 根据行为类型查询用户行为记录
     * @param actionType 行为类型
     * @return 用户行为记录列表
     */
    List<UserBehavior> selectByActionType(String actionType);

    /**
     * 根据时间范围查询用户行为记录
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 用户行为记录列表
     */
    List<UserBehavior> selectByTimeRange(@Param("startTime") LocalDateTime startTime, @Param("endTime") LocalDateTime endTime);

    /**
     * 查询用户对特定角色的行为统计
     * @param userId 用户ID
     * @param roleId 角色ID
     * @return 行为统计信息
     */
    List<UserBehavior> selectUserRoleBehaviorStats(@Param("userId") Integer userId, @Param("roleId") Integer roleId);

    /**
     * 查询热门角色（基于行为次数）
     * @param limit 限制数量
     * @return 角色ID和行为次数
     */
    List<UserBehavior> selectPopularRoles(@Param("limit") Integer limit);

    /**
     * 查询活跃用户（基于行为次数）
     * @param limit 限制数量
     * @return 用户ID和行为次数
     */
    List<UserBehavior> selectActiveUsers(@Param("limit") Integer limit);

    /**
     * 根据ID删除用户行为记录
     * @param id 记录ID
     * @return 影响的行数
     */
    int deleteById(Integer id);

    /**
     * 根据用户ID删除用户行为记录
     * @param userId 用户ID
     * @return 影响的行数
     */
    int deleteByUserId(Integer userId);

    /**
     * 根据角色ID删除用户行为记录
     * @param roleId 角色ID
     * @return 影响的行数
     */
    int deleteByRoleId(Integer roleId);

    /**
     * 更新用户行为记录
     * @param userBehavior 用户行为记录
     * @return 影响的行数
     */
    int updateUserBehavior(UserBehavior userBehavior);

    /**
     * 查询所有用户行为记录
     * @return 所有用户行为记录
     */
    List<UserBehavior> selectAll();

    /**
     * 查询用户行为记录总数
     * @return 记录总数
     */
    int countAll();

    /**
     * 根据用户ID查询行为记录总数
     * @param userId 用户ID
     * @return 记录总数
     */
    int countByUserId(Integer userId);

    /**
     * 根据角色ID查询行为记录总数
     * @param roleId 角色ID
     * @return 记录总数
     */
    int countByRoleId(Integer roleId);
} 