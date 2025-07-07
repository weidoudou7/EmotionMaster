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
        try {
            // 尝试将chatId解析为整数（数据库ID）
            Integer id = Integer.parseInt(chatId);
            Conversation conversation = conversationMapper.selectById(id);
            if (conversation != null) {
                return conversation;
            }
        } catch (NumberFormatException e) {
            // chatId不是有效的数据库ID，可能是时间戳或其他格式
            System.out.println("chatId不是有效的数据库ID: " + chatId + ", 将创建新对话");
        }
        
        // 如果找不到现有对话或chatId无效，创建新对话
        Conversation newConversation = new Conversation();
        newConversation.setUserId(userId != null ? userId : 405); // 默认用户ID
        newConversation.setAiRoleId(364); // 默认AI角色ID，这里应该根据实际情况设置
        newConversation.setTitle(title != null ? title : "新对话");
        newConversation.setStartTime(LocalDateTime.now());
        newConversation.setLastActive(LocalDateTime.now());
        newConversation.setMoodTag("normal");
        newConversation.setTurns(0);
        
        int result = conversationMapper.insertConversation(newConversation);
        if (result > 0) {
            System.out.println("成功创建新对话，ID: " + newConversation.getId());
        } else {
            System.out.println("创建对话失败");
        }
        return newConversation;
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
        
        // 更新conversation的最后活跃时间
        conversationMapper.updateLastActive(conversationId);
        
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
