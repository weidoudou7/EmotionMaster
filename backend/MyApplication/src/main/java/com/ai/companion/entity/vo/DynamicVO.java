package com.ai.companion.entity.vo;

import com.ai.companion.entity.Dynamic;
import com.ai.companion.entity.User;
import com.ai.companion.entity.vo.UserInfoVO;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DynamicVO {
    private String id; // 动态唯一ID (转换为字符串)
    private String userUID; // 发布用户UID (转换为字符串)
    private String userName; // 用户名
    private String userAvatar; // 用户头像
    private String content; // 动态文本内容
    private List<String> images; // 图片内容JSON数组
    private List<String> topicTags; // 话题标签JSON数组
    private String visibility; // 可见性
    private String createTime; // 创建时间 (ISO字符串)
    private String updateTime; // 更新时间 (ISO字符串)
    private Integer likeCount; // 点赞数
    private Integer commentCount; // 评论数 (默认为0)
    private Boolean isPrivate; // 是否私密

    // 从 Dynamic 实体转换为 DynamicVO
    public static DynamicVO fromDynamic(Dynamic dynamic, UserInfoVO userInfoVO) {
        DynamicVO vo = new DynamicVO();
        vo.setId(dynamic.getId() != null ? dynamic.getId().toString() : null);
        vo.setUserUID(userInfoVO != null ? userInfoVO.getUserUID() : null);
        vo.setUserName(userInfoVO != null ? userInfoVO.getUserName() : null);
        vo.setUserAvatar(userInfoVO != null ? userInfoVO.getUserAvatar() : null);
        vo.setContent(dynamic.getContent());
        vo.setImages(dynamic.getImages());
        vo.setTopicTags(dynamic.getTopicTags());
        vo.setVisibility(dynamic.getVisibility());
        vo.setCreateTime(dynamic.getCreatedAt() != null ? dynamic.getCreatedAt().toString() : null);
        vo.setUpdateTime(dynamic.getUpdatedAt() != null ? dynamic.getUpdatedAt().toString() : null);
        vo.setLikeCount(dynamic.getLikeCount());
        vo.setCommentCount(0); // 默认评论数为0
        vo.setIsPrivate("private".equals(dynamic.getVisibility()));
        return vo;
    }

    // 从 Dynamic 实体转换为 DynamicVO (兼容 User 参数)
    public static DynamicVO fromDynamic(Dynamic dynamic, User user) {
        DynamicVO vo = new DynamicVO();
        vo.setId(dynamic.getId() != null ? dynamic.getId().toString() : null);
        vo.setUserUID(user != null ? user.getUserUID() : null);
        vo.setUserName(user != null ? user.getUserName() : null);
        vo.setUserAvatar(user != null ? user.getUserAvatar() : null);
        vo.setContent(dynamic.getContent());
        vo.setImages(dynamic.getImages());
        vo.setTopicTags(dynamic.getTopicTags());
        vo.setVisibility(dynamic.getVisibility());
        vo.setCreateTime(dynamic.getCreatedAt() != null ? dynamic.getCreatedAt().toString() : null);
        vo.setUpdateTime(dynamic.getUpdatedAt() != null ? dynamic.getUpdatedAt().toString() : null);
        vo.setLikeCount(dynamic.getLikeCount());
        vo.setCommentCount(0); // 默认评论数为0
        vo.setIsPrivate("private".equals(dynamic.getVisibility()));
        return vo;
    }

    // 从 Dynamic 实体转换为 DynamicVO (不包含用户信息)
    public static DynamicVO fromDynamic(Dynamic dynamic) {
        DynamicVO vo = new DynamicVO();
        vo.setId(dynamic.getId() != null ? dynamic.getId().toString() : null);
        vo.setUserUID(null); // 需要单独设置
        vo.setUserName(null); // 需要单独设置
        vo.setUserAvatar(null); // 需要单独设置
        vo.setContent(dynamic.getContent());
        vo.setImages(dynamic.getImages());
        vo.setTopicTags(dynamic.getTopicTags());
        vo.setVisibility(dynamic.getVisibility());
        vo.setCreateTime(dynamic.getCreatedAt() != null ? dynamic.getCreatedAt().toString() : null);
        vo.setUpdateTime(dynamic.getUpdatedAt() != null ? dynamic.getUpdatedAt().toString() : null);
        vo.setLikeCount(dynamic.getLikeCount());
        vo.setCommentCount(0); // 默认评论数为0
        vo.setIsPrivate("private".equals(dynamic.getVisibility()));
        return vo;
    }
} 