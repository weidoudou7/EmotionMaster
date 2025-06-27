package com.ai.companion.service;


import com.ai.companion.entity.Conversation;
import com.ai.companion.entity.Message;

import java.util.List;

/**
 * AI对话记录服务接口
 */
public interface ChatRecordService {
    /**
     * 获取或创建会话
     */
    Conversation getOrCreateConversation(Integer userId, Integer aiRoleId, String chatId, String title, String mode);

    /**
     * 保存一条消息（用户或AI）
     */
    Message saveMessage(Integer conversationId, String senderType, String content, String audioUrl, Byte sentimentScore, String topicTag);

    /**
     * 获取某会话的所有消息
     */
    List<Message> getMessagesByConversationId(Integer conversationId);
}
