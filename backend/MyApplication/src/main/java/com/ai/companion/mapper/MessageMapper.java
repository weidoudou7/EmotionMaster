package com.ai.companion.mapper;

import com.ai.companion.entity.Message;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface MessageMapper {
    // ========== 基础查询方法 ==========
    /**
     * 根据ID查询消息
     * 
     * @param id 消息ID
     * @return 消息对象
     */
    Message selectById(@Param("id") Long id);

    /**
     * 根据会话ID查询消息列表
     * 
     * @param conversationId 会话ID
     * @return 消息列表
     */
    List<Message> selectByConversationId(@Param("conversationId") Integer conversationId);

    /**
     * 查询所有消息
     * 
     * @return 消息列表
     */
    List<Message> selectAll();

    // ========== 分页与排序查询方法 ==========
    /**
     * 分页查询消息，按时间倒序
     * 
     * @param offset 偏移量
     * @param limit  查询数量
     * @return 消息列表
     */
    List<Message> selectByPage(@Param("offset") Integer offset, @Param("limit") Integer limit);

    /**
     * 按会话ID分页查询消息，按时间倒序
     * 
     * @param conversationId 会话ID
     * @param offset         偏移量
     * @param limit          查询数量
     * @return 消息列表
     */
    List<Message> selectByConversationIdWithPage(@Param("conversationId") Integer conversationId,
            @Param("offset") Integer offset, @Param("limit") Integer limit);

    // ========== 条件与模糊查询方法 ==========
    /**
     * 按发送者类型查询消息
     *
     * @param senderType 发送者类型
     * @return 消息列表
     */
    List<Message> selectBySenderType(@Param("senderType") String senderType);

    /**
     * 按情感分值区间查询消息
     *
     * @param minScore 最小情感分值
     * @param maxScore 最大情感分值
     * @return 消息列表
     */
    List<Message> selectBySentimentScoreRange(@Param("minScore") Integer minScore, @Param("maxScore") Integer maxScore);

    /**
     * 按话题标签模糊查询消息
     *
     * @param topicTag 话题标签关键字
     * @return 消息列表
     */
    List<Message> selectByTopicTagLike(@Param("topicTag") String topicTag);

    /**
     * 按内容模糊查询消息
     *
     * @param keyword 内容关键字
     * @return 消息列表
     */
    List<Message> selectByContentLike(@Param("keyword") String keyword);

    /**
     * 按时间范围查询消息
     *
     * @param startTime 开始时间
     * @param endTime   结束时间
     * @return 消息列表
     */
    List<Message> selectByTimeRange(@Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime);

    // ========== 批量操作 ==========
    /**
     * 批量查询消息
     *
     * @param ids 消息ID列表
     * @return 消息列表
     */
    List<Message> selectByIds(@Param("ids") List<Long> ids);

    /**
     * 批量插入消息
     *
     * @param messages 消息对象列表
     * @return 插入条数
     */
    int batchInsertMessages(@Param("messages") List<Message> messages);

    /**
     * 批量删除消息
     *
     * @param ids 消息ID列表
     * @return 删除条数
     */
    int batchDeleteMessages(@Param("ids") List<Long> ids);

    // ========== 插入与更新方法 ==========
    /**
     * 插入新消息
     *
     * @param message 消息对象
     * @return 插入条数
     */
    int insertMessage(Message message);

    /**
     * 更新消息信息
     *
     * @param message 消息对象
     * @return 更新条数
     */
    int updateMessage(Message message);

    /**
     * 批量更新情感分值
     *
     * @param ids            消息ID列表
     * @param sentimentScore 新的情感分值
     * @return 更新条数
     */
    int batchUpdateSentimentScore(@Param("ids") List<Long> ids, @Param("sentimentScore") Integer sentimentScore);

    // ========== 删除方法 ==========
    /**
     * 根据ID删除消息
     *
     * @param id 消息ID
     * @return 删除条数
     */
    int deleteMessage(@Param("id") Long id);

    // ========== 统计方法 ==========
    /**
     * 统计所有消息数量
     *
     * @return 消息总数
     */
    int countAll();

    /**
     * 统计某会话下消息数量
     *
     * @param conversationId 会话ID
     * @return 消息数量
     */
    int countByConversationId(@Param("conversationId") Integer conversationId);

    /**
     * 统计某发送者类型消息数量
     *
     * @param senderType 发送者类型
     * @return 消息数量
     */
    int countBySenderType(@Param("senderType") String senderType);

    /**
     * 统计某情感分值区间消息数量
     *
     * @param minScore 最小情感分值
     * @param maxScore 最大情感分值
     * @return 消息数量
     */
    int countBySentimentScoreRange(@Param("minScore") Integer minScore, @Param("maxScore") Integer maxScore);

    /**
     * 查询话题标签分布
     *
     * @param limit 返回标签数量上限
     * @return 话题标签列表
     */
    List<String> selectTopicTagDistribution(@Param("limit") Integer limit);

    /**
     * 获取某会话下最后一条消息
     *
     * @param conversationId 会话ID
     * @return 消息对象
     */
    Message selectLastMessageByConversationId(@Param("conversationId") Integer conversationId);

    /**
     * 获取某会话下指定发送者类型的最后一条消息
     *
     * @param conversationId 会话ID
     * @param senderType     发送者类型
     * @return 消息对象
     */
    Message selectLastMessageByConversationIdAndSenderType(@Param("conversationId") Integer conversationId,
            @Param("senderType") String senderType);

    /**
     * 获取某条消息的上下文窗口（前后N条）
     *
     * @param conversationId 会话ID
     * @param messageId      消息ID
     * @param windowSize     窗口大小
     * @return 消息列表
     */
    List<Message> selectContextWindow(@Param("conversationId") Integer conversationId,
            @Param("messageId") Long messageId, @Param("windowSize") Integer windowSize);

    /**
     * 按会话ID和时间区间查询消息
     *
     * @param conversationId 会话ID
     * @param startTime      开始时间
     * @param endTime        结束时间
     * @return 消息列表
     */
    List<Message> selectByConversationIdAndTimeRange(@Param("conversationId") Integer conversationId,
            @Param("startTime") LocalDateTime startTime, @Param("endTime") LocalDateTime endTime);

    /**
     * 按会话ID和发送者类型查询消息
     *
     * @param conversationId 会话ID
     * @param senderType     发送者类型
     * @return 消息列表
     */
    List<Message> selectByConversationIdAndSenderType(@Param("conversationId") Integer conversationId,
            @Param("senderType") String senderType);
}