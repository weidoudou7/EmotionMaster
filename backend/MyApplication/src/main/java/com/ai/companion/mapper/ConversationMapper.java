package com.ai.companion.mapper;

import com.ai.companion.entity.Conversation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ConversationMapper {
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
     * 根据ID删除会话
     * 
     * @param id 会话ID
     * @return 影响的行数
     */
    int deleteConversation(@Param("id") Integer id);

    /**
     * 查询所有会话
     * 
     * @return 会话列表
     */
    List<Conversation> selectAll();
}