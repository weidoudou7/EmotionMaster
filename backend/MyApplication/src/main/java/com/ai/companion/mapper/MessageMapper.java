package com.ai.companion.mapper;

import com.ai.companion.entity.Message;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface MessageMapper {
    /**
     * 根据ID查询消息
     * 
     * @param id 消息ID
     * @return 消息实体
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
     * 插入新消息
     * 
     * @param message 消息实体
     * @return 影响的行数
     */
    int insertMessage(Message message);

    /**
     * 更新消息信息
     * 
     * @param message 消息实体
     * @return 影响的行数
     */
    int updateMessage(Message message);

    /**
     * 根据ID删除消息
     * 
     * @param id 消息ID
     * @return 影响的行数
     */
    int deleteMessage(@Param("id") Long id);

    /**
     * 查询所有消息
     * 
     * @return 消息列表
     */
    List<Message> selectAll();
}