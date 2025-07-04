package com.ai.companion.service.impl;

import com.ai.companion.entity.Conversation;
import com.ai.companion.entity.Message;
import com.ai.companion.mapper.ConversationMapper;
import com.ai.companion.mapper.MessageMapper;
import com.ai.companion.service.ChatRecordService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatRecordServiceImpl implements ChatRecordService {

    private final ConversationMapper conversationMapper;
    private final MessageMapper messageMapper;

    @Override
    @Transactional   // 该注解表示该方法/类中的所有数据库操作要么全部成功（提交），要么全部失败（回滚），保证数据一致性。
    public Conversation getOrCreateConversation(Integer userId, String chatId, String title, String mode) {
        // ConservationId 为 ChatId
        Conversation conversation = null;
        Integer id = Integer.parseInt(chatId);
        conversation = conversationMapper.selectById(id);
        return conversation;
    }

    @Override
    @Transactional
    public Message saveMessage(Integer conversationId, String senderType, String content, String audioUrl, Byte sentimentScore, String topicTag) {
        Message message = new Message();
        message.setConversationId(conversationId);
        message.setSenderType(senderType);
        message.setContent(content);
        message.setAudioUrl(audioUrl);
        message.setSentimentScore(sentimentScore);
        message.setTopicTag(topicTag);
        message.setTimestamp(LocalDateTime.now());
        messageMapper.insertMessage(message);
        return message;
    }

    @Override
    public List<Message> getMessagesByConversationId(Integer conversationId) {
        return messageMapper.selectByConversationId(conversationId);
    }

    @Override
    @Transactional
    public boolean updateConversationMoodTag(Integer conversationId, String moodTag) {
        try {
            int result = conversationMapper.updateMoodTag(conversationId, moodTag);
            return result > 0;
        } catch (Exception e) {
            // 记录错误日志
            System.err.println("更新会话情绪标签失败: " + e.getMessage());
            return false;
        }
    }
}
