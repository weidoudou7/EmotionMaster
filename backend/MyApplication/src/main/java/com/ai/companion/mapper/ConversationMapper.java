package com.ai.companion.mapper;

import com.ai.companion.entity.Conversation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ConversationMapper {

        // ========== 基础查询方法 ==========

        /**
         * 根据ID查询会话
         * 
         * @param id 会话ID
         * @return 会话实体
         */
        Conversation selectById(@Param("id") Integer id);

        /**
         * 根据用户ID查询会话列表
         * 
         * @param userId 用户ID
         * @return 会话列表
         */
        List<Conversation> selectByUserId(@Param("userId") Integer userId);

        /**
         * 根据AI角色ID查询会话列表
         * 
         * @param aiRoleId AI角色ID
         * @return 会话列表
         */
        List<Conversation> selectByAiRoleId(@Param("aiRoleId") Integer aiRoleId);

        /**
         * 根据用户ID和AI角色ID查询会话
         * 
         * @param userId   用户ID
         * @param aiRoleId AI角色ID
         * @return 会话实体
         */
        Conversation selectByUserIdAndAiRoleId(@Param("userId") Integer userId, @Param("aiRoleId") Integer aiRoleId);

        /**
         * 查询所有会话
         * 
         * @return 会话列表
         */
        List<Conversation> selectAll();

        // ========== 分页和排序查询方法 ==========

        /**
         * 分页查询会话列表
         * 
         * 注意事项：
         * 1. offset参数必须 >= 0，否则MySQL会报SQL语法错误
         * 2. limit建议为正整数，避免全表扫描
         * 
         * @param offset 偏移量（必须 >= 0）
         * @param limit  限制数量（建议 > 0）
         * @return 会话列表
         */
        List<Conversation> selectByPage(@Param("offset") Integer offset, @Param("limit") Integer limit);

        /**
         * 根据用户ID分页查询会话
         * 
         * @param userId 用户ID
         * @param offset 偏移量
         * @param limit  限制数量
         * @return 会话列表
         */
        List<Conversation> selectByUserIdWithPage(@Param("userId") Integer userId,
                        @Param("offset") Integer offset,
                        @Param("limit") Integer limit);

        /**
         * 获取用户最新的会话
         * 
         * @param userId 用户ID
         * @param limit  限制数量
         * @return 会话列表
         */
        List<Conversation> selectLatestByUserId(@Param("userId") Integer userId, @Param("limit") Integer limit);

        /**
         * 获取最活跃的会话（按最后活跃时间排序）
         * 
         * @param limit 限制数量
         * @return 会话列表
         */
        List<Conversation> selectMostActive(@Param("limit") Integer limit);

        // ========== 条件查询方法 ==========

        /**
         * 根据心情标签查询
         * 
         * @param moodTag 心情标签
         * @return 会话列表
         */
        List<Conversation> selectByMoodTag(@Param("moodTag") String moodTag);

        /**
         * 根据对话轮数范围查询
         * 
         * @param minTurns 最小轮数
         * @param maxTurns 最大轮数
         * @return 会话列表
         */
        List<Conversation> selectByTurnsRange(@Param("minTurns") Integer minTurns, @Param("maxTurns") Integer maxTurns);

        /**
         * 复合条件查询会话
         * 
         * @param userId   用户ID（可选）
         * @param aiRoleId AI角色ID（可选）
         * @param mode     会话模式（可选）
         * @param moodTag  心情标签（可选）
         * @param minTurns 最小轮数（可选）
         * @param maxTurns 最大轮数（可选）
         * @return 会话列表
         *
         *         使用时，如果某个条件为null，则不进行查询
         *         例如：selectByConditions(null, "test@example.com", null, null, null)
         */
        List<Conversation> selectByConditions(@Param("userId") Integer userId,
                        @Param("aiRoleId") Integer aiRoleId,
                        @Param("mode") String mode,
                        @Param("moodTag") String moodTag,
                        @Param("minTurns") Integer minTurns,
                        @Param("maxTurns") Integer maxTurns);

        // ========== 时间相关查询方法 ==========

        /**
         * 根据开始时间范围查询
         * 
         * @param startTime 开始时间
         * @param endTime   结束时间
         * @return 会话列表
         */
        List<Conversation> selectByStartTimeRange(@Param("startTime") String startTime,
                        @Param("endTime") String endTime);

        /**
         * 根据最后活跃时间范围查询
         * 
         * @param startTime 开始时间
         * @param endTime   结束时间
         * @return 会话列表
         */
        List<Conversation> selectByLastActiveRange(@Param("startTime") String startTime,
                        @Param("endTime") String endTime);

        /**
         * 获取今日活跃的会话
         * 
         * @return 会话列表
         */
        List<Conversation> selectTodayActive();

        /**
         * 获取本周活跃的会话
         * 
         * @return 会话列表
         */
        List<Conversation> selectThisWeekActive();

        // ========== 搜索方法 ==========

        /**
         * 搜索会话（支持标题模糊搜索）
         * 
         * @param keyword 搜索关键词
         * @param limit   限制数量
         * @return 会话列表
         */
        List<Conversation> searchConversations(@Param("keyword") String keyword, @Param("limit") Integer limit);

        // ========== 批量查询方法 ==========

        /**
         * 根据多个ID查询会话
         * 
         * @param ids 会话ID列表
         * @return 会话列表
         */
        List<Conversation> selectByIds(@Param("ids") List<Integer> ids);

        /**
         * 根据多个用户ID查询会话
         * 
         * @param userIds 用户ID列表
         * @return 会话列表
         */
        List<Conversation> selectByUserIds(@Param("userIds") List<Integer> userIds);

        // ========== 插入和更新方法 ==========

        /**
         * 插入新会话
         *
         * @param conversation 会话实体
         * @return 影响的行数
         */
        int insertConversation(Conversation conversation);

        /**
         * 更新会话信息
         * 
         * @param conversation 会话实体
         * @return 影响的行数
         */
        int updateConversation(Conversation conversation);

        /**
         * 更新会话最后活跃时间
         * 
         * @param id 会话ID
         * @return 影响的行数
         */
        int updateLastActive(@Param("id") Integer id);

        /**
         * 更新会话轮数
         * 
         * @param id    会话ID
         * @param turns 新的轮数
         * @return 影响的行数
         */
        int updateTurns(@Param("id") Integer id, @Param("turns") Integer turns);

        /**
         * 更新会话标题
         * 
         * @param id    会话ID
         * @param title 新标题
         * @return 影响的行数
         */
        int updateTitle(@Param("id") Integer id, @Param("title") String title);

        /**
         * 更新心情标签
         * 
         * @param id      会话ID
         * @param moodTag 新心情标签
         * @return 影响的行数
         */
        int updateMoodTag(@Param("id") Integer id, @Param("moodTag") String moodTag);

        // ========== 删除方法 ==========

        /**
         * 根据ID删除会话
         * 
         * @param id 会话ID
         * @return 影响的行数
         */
        int deleteConversation(@Param("id") Integer id);

        /**
         * 根据用户ID删除会话
         * 
         * @param userId 用户ID
         * @return 影响的行数
         */
        int deleteByUserId(@Param("userId") Integer userId);

        /**
         * 批量删除会话
         * 
         * @param ids 会话ID列表
         * @return 影响的行数
         */
        int batchDeleteConversations(@Param("ids") List<Integer> ids);

        // ========== 数据验证方法 ==========

        /**
         * 检查会话是否存在
         * 
         * @param id 会话ID
         * @return 是否存在
         */
        boolean existsById(@Param("id") Integer id);

        /**
         * 检查用户是否有指定AI角色的会话
         * 
         * @param userId   用户ID
         * @param aiRoleId AI角色ID
         * @return 是否存在
         */
        boolean existsByUserIdAndAiRoleId(@Param("userId") Integer userId, @Param("aiRoleId") Integer aiRoleId);

        // ========== 统计方法 ==========

        /**
         * 统计总会话数量
         * 
         * @return 总会话数量
         */
        int countAll();

        /**
         * 统计用户会话数量
         * 
         * @param userId 用户ID
         * @return 会话数量
         */
        int countByUserId(@Param("userId") Integer userId);

        /**
         * 统计AI角色会话数量
         * 
         * @param aiRoleId AI角色ID
         * @return 会话数量
         */
        int countByAiRoleId(@Param("aiRoleId") Integer aiRoleId);

        /**
         * 统计各心情标签会话数量
         * 
         * @param moodTag 心情标签
         * @return 会话数量
         */
        int countByMoodTag(@Param("moodTag") String moodTag);

        /**
         * 统计今日新增会话数量
         * 
         * @return 今日新增会话数量
         */
        int countTodayCreated();

        /**
         * 统计今日活跃会话数量
         * 
         * @return 今日活跃会话数量
         */
        int countTodayActive();

        /**
         * 获取平均对话轮数
         * 
         * @return 平均对话轮数
         */
        Double getAverageTurns();

        /**
         * 获取心情标签分布统计
         * 
         * @return 心情标签分布
         */
        List<Conversation> selectMoodTagDistribution();
}