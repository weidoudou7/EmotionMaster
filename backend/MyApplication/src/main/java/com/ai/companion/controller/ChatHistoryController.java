package com.ai.companion.controller;

import com.ai.companion.entity.AiRole;
import com.ai.companion.entity.Conversation;
import com.ai.companion.entity.vo.ApiResponse;
import com.ai.companion.entity.vo.MessageVO;
import com.ai.companion.mapper.AiRoleMapper;
import com.ai.companion.mapper.ConversationMapper;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.messages.Message;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping(value="/ai/history")
public class ChatHistoryController {

    private final ChatMemory chatMemory;
    private final ConversationMapper conversationMapper;
    private final AiRoleMapper aiRoleMapper;

    @Autowired
    public ChatHistoryController(ChatMemory chatMemory, ConversationMapper conversationMapper, AiRoleMapper aiRoleMapper) {
        this.chatMemory = chatMemory;
        this.conversationMapper = conversationMapper;
        this.aiRoleMapper = aiRoleMapper;
    }

    /**
     * @param type 传入AI对话类型
     * @return 返回对话ID列表
     */
    @GetMapping(value = "{type}")
    public List<String> getChatId(@PathVariable("type") String type) {

        return List.of();
    }

    /**
     * @param type   传入AI对话类型
     * @param chatId 传入AI对话ID
     * @return 返回消息（角色+内容）列表
     */
    @GetMapping(value = "{type}/{chatId}")
    public List<MessageVO> getHistory(@PathVariable("type") String type, @PathVariable("chatId") String chatId) {
        List<Message> history = chatMemory.get(chatId + "_" + type);
        if (history == null) {
            return List.of();
        }
        return history.stream().map(m -> new MessageVO(m)).toList();
    }

    /**
     * 创建对话
     * POST /ai/history/conversation/create
     */
    @PostMapping("/conversation/create")
    public ApiResponse<Conversation> createConversation(@RequestBody CreateConversationRequest request) {
        try {
            // 验证必填字段
            if (request.getUserId() == null) {
                return ApiResponse.error("用户ID不能为空");
            }
            if (request.getAiRoleId() == null) {
                return ApiResponse.error("AI角色ID不能为空");
            }
            if (request.getTitle() == null || request.getTitle().trim().isEmpty()) {
                return ApiResponse.error("对话标题不能为空");
            }

            // 创建新的对话
            Conversation newConversation = new Conversation();
            newConversation.setUserId(request.getUserId());
            newConversation.setAiRoleId(request.getAiRoleId());
            newConversation.setTitle(request.getTitle().trim());
            newConversation.setTurns(0); // 初始对话轮数为0
            newConversation.setStartTime(LocalDateTime.now());
            newConversation.setLastActive(LocalDateTime.now());
            newConversation.setMoodTag(request.getMoodTag()); // 可以为null

            // 保存到数据库
            int result = conversationMapper.insertConversation(newConversation);
            if (result > 0) {
                return ApiResponse.success("对话创建成功", newConversation);
            } else {
                return ApiResponse.error("对话创建失败");
            }

        } catch (Exception e) {
            return ApiResponse.error("创建对话时发生错误: " + e.getMessage());
        }
    }

    /**
     * 创建对话的请求体
     */
    public static class CreateConversationRequest {
        private Integer userId;
        private Integer aiRoleId;
        private String title;
        private String moodTag;

        // Getters and Setters
        public Integer getUserId() {
            return userId;
        }

        public void setUserId(Integer userId) {
            this.userId = userId;
        }

        public Integer getAiRoleId() {
            return aiRoleId;
        }

        public void setAiRoleId(Integer aiRoleId) {
            this.aiRoleId = aiRoleId;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getMoodTag() {
            return moodTag;
        }

        public void setMoodTag(String moodTag) {
            this.moodTag = moodTag;
        }
    }

    /**
     * 根据userId查询全部对话
     * GET /ai/history/conversation/list?userId=372
     */
    @GetMapping("/conversation/list")
    public ApiResponse<List<Conversation>> getConversationsByUserId(@RequestParam Integer userId) {
        try {
            if (userId == null) {
                return ApiResponse.error("用户ID不能为空");
            }
            List<Conversation> conversations = conversationMapper.selectByUserId(userId);
            return ApiResponse.success("查询成功", conversations);
        } catch (Exception e) {
            return ApiResponse.error("查询对话时发生错误: " + e.getMessage());
        }
    }

    /**
     * 根据用户ID和AI角色ID查找对话
     * GET /ai/history/conversation/find?userId=372&aiRoleId=1
     */
    @GetMapping("/conversation/find")
    public ApiResponse<Conversation> findConversationByUserAndRole(@RequestParam Integer userId, @RequestParam Integer aiRoleId) {
        try {
            if (userId == null) {
                return ApiResponse.error("用户ID不能为空");
            }
            if (aiRoleId == null) {
                return ApiResponse.error("AI角色ID不能为空");
            }

            Conversation conversation = conversationMapper.selectByUserIdAndAiRoleId(userId, aiRoleId);
            if (conversation != null) {
                return ApiResponse.success("查找对话成功", conversation);
            } else {
                return ApiResponse.error("未找到对应的对话");
            }
        } catch (Exception e) {
            return ApiResponse.error("查找对话时发生错误: " + e.getMessage());
        }
    }

    /**
     * 删除对话
     * DELETE /ai/history/conversation/delete
     */
    @DeleteMapping("/conversation/delete")
    public ApiResponse<Boolean> deleteConversation(@RequestBody DeleteConversationRequest request) {
        try {
            if (request.getId() == null) {
                return ApiResponse.error("对话ID不能为空");
            }

            // 先检查对话是否存在
            Conversation conversation = conversationMapper.selectById(request.getId());
            if (conversation == null) {
                return ApiResponse.error("对话不存在");
            }

            // 删除对话
            int result = conversationMapper.deleteConversation(request.getId());
            if (result > 0) {
                return ApiResponse.success("对话删除成功", true);
            } else {
                return ApiResponse.error("对话删除失败");
            }
        } catch (Exception e) {
            return ApiResponse.error("删除对话时发生错误: " + e.getMessage());
        }
    }

    /**
     * 删除对话的请求体
     */
    public static class DeleteConversationRequest {
        private Integer id;

        public Integer getId() {
            return id;
        }

        public void setId(Integer id) {
            this.id = id;
        }
    }
}

