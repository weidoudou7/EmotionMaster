package com.ai.companion.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Message {
    private Long id; // 消息唯一ID
    private Integer conversationId; // 所属会话ID
    private String senderType; // 发送者类型（user/ai）
    private String content; // 消息文本内容
    private String audioUrl; // 语音消息存储路径
    private Byte sentimentScore; // 情感分值
    private String topicTag; // 话题标签
    private LocalDateTime timestamp; // 发送时间
}