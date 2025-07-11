-- 1. 用户表：存储用户账户信息
CREATE TABLE users (
                       id INT AUTO_INCREMENT PRIMARY KEY COMMENT '用户唯一ID',
                       uid VARCHAR(50) NOT NULL UNIQUE COMMENT '全局唯一用户标识符',
                       username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名(唯一)',
                       gender VARCHAR(10) NOT NULL DEFAULT '私有' COMMENT '用户性别',
                       is_private BOOLEAN DEFAULT 0 COMMENT '隐私可见性(0:公开/1:隐私)',
                       signature VARCHAR(100) COMMENT '用户个性签名',
                       email VARCHAR(100) NOT NULL UNIQUE COMMENT '用户邮箱(唯一)',
                       level INT NOT NULL DEFAULT 0 COMMENT '用户等级',
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '账户创建时间',
                       last_login TIMESTAMP NULL COMMENT '最后登录时间',
                       profile_image VARCHAR(255) COMMENT '用户个人资料图片URL'
);

-- 2. AI角色表：存储系统预设和用户自定义AI角色
CREATE TABLE ai_roles (
                          id INT AUTO_INCREMENT PRIMARY KEY COMMENT '角色唯一ID',
                          user_id INT NULL COMMENT '所属用户ID(null表示系统预设)',
                          role_name VARCHAR(50) NOT NULL COMMENT '角色名称',
                          role_description TEXT COMMENT '角色详细描述',
                          role_type VARCHAR(50) NOT NULL COMMENT '角色类型',
                          role_author VARCHAR(100) COMMENT '角色作者',
                          view_count INT DEFAULT 0 COMMENT '角色浏览量',
                          avatar_url TEXT NOT NULL COMMENT '角色形象URL(用户上传或系统生成)',
                          is_template BOOLEAN DEFAULT 0 COMMENT '是否为模板角色(1=是,0=否)',
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                          INDEX idx_ai_roles_user (user_id) COMMENT '用户ID索引',
                          INDEX idx_ai_roles_type (role_type) COMMENT '角色类型索引',
                          INDEX idx_ai_roles_views (view_count) COMMENT '浏览量索引'
);

-- 3. 对话会话表：存储每次对话的上下文
CREATE TABLE conversations (
                               id INT AUTO_INCREMENT PRIMARY KEY COMMENT '会话唯一ID',
                               user_id INT NOT NULL COMMENT '所属用户ID',
                               ai_role_id INT NOT NULL COMMENT '使用的AI角色ID',
                               turns INT NOT NULL DEFAULT 0 COMMENT '对话轮数',
                               title VARCHAR(100) DEFAULT '新对话' COMMENT '对话标题',
                               start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
                               last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后活跃时间',
                               mood_tag VARCHAR(50) COMMENT '情绪标签(自动分析)',
                               FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                               FOREIGN KEY (ai_role_id) REFERENCES ai_roles(id) ON DELETE CASCADE,
                               INDEX idx_conversations_user (user_id) COMMENT '用户ID索引'
);

-- 4. 消息记录表：存储每次对话的具体消息
CREATE TABLE messages (
                          id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '消息唯一ID',
                          conversation_id INT NOT NULL COMMENT '所属会话ID',
                          sender_type ENUM('user', 'ai') NOT NULL COMMENT '发送者类型',
                          content TEXT COMMENT '消息文本内容(语音对话存放ASR结果)',
                          audio_url VARCHAR(255) COMMENT '语音消息存储路径',
                          sentiment_score TINYINT COMMENT '情感分值(-10至10)',
                          topic_tag VARCHAR(50) COMMENT '话题标签(自动分析)',
                          timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
                          FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
                          INDEX idx_messages_conversation (conversation_id) COMMENT '会话ID索引',
                          INDEX idx_messages_sentiment (sentiment_score) COMMENT '情感分值索引',
                          INDEX idx_messages_topic (topic_tag) COMMENT '话题标签索引'
);

-- 5. 星球系统表：存储用户游戏化星球数据
CREATE TABLE planets (
                         id INT AUTO_INCREMENT PRIMARY KEY COMMENT '星球唯一ID',
                         user_id INT NOT NULL UNIQUE COMMENT '所属用户ID(1:1关系)',
                         level INT DEFAULT 1 COMMENT '星球等级',
                         experience BIGINT DEFAULT 0 COMMENT '累计经验值',
                         name VARCHAR(50) DEFAULT '我的星球' COMMENT '星球名称',
                         appearance JSON NOT NULL COMMENT '外观配置JSON',
                         unlocked_items JSON COMMENT '已解锁物品JSON数组',
                         last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
                         FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 6. 用户动态表：存储用户发布的动态内容
CREATE TABLE user_dynamics (
                               id INT AUTO_INCREMENT PRIMARY KEY COMMENT '动态唯一ID',
                               user_id INT NOT NULL COMMENT '发布用户ID',
                               content TEXT COMMENT '动态文本内容',
                               images JSON COMMENT '图片内容JSON数组(存储图片URL列表)',
                               topic_tags JSON COMMENT '话题标签JSON数组',
                               visibility ENUM('public', 'private', 'friends') NOT NULL DEFAULT 'public' COMMENT '可见性(public:公开/private:私密/friends:仅好友可见)',
                               created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                               updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                               like_count INT DEFAULT 0 COMMENT '点赞数',
                               FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                               INDEX idx_dynamics_user (user_id) COMMENT '用户ID索引',
                               INDEX idx_dynamics_visibility (visibility) COMMENT '可见性索引',
                               INDEX idx_dynamics_created (created_at) COMMENT '创建时间索引',
                               INDEX idx_dynamics_likes (like_count) COMMENT '点赞数索引'
);

-- 7. 评论表：统一存储评论和回复（单表设计）
CREATE TABLE comments (
                          id INT AUTO_INCREMENT PRIMARY KEY COMMENT '评论唯一ID',
                          ai_role_id INT NOT NULL COMMENT '被评论的AI角色ID',
                          user_id INT NOT NULL COMMENT '评论用户ID',
                          content TEXT NOT NULL COMMENT '评论内容',
                          like_count INT DEFAULT 0 COMMENT '点赞数',
                          reply_count INT DEFAULT 0 COMMENT '回复数',
                          root_comment_id INT NULL COMMENT '根评论ID(null表示顶级评论，否则为回复)',
                          to_comment_id INT NULL COMMENT '回复目标评论ID(null表示回复根评论，否则为回复某条回复)',
                          reply_to_user_id INT NULL COMMENT '回复目标用户ID',
                          reply_to_username VARCHAR(50) NULL COMMENT '回复目标用户昵称(静态存储，不随用户昵称变化)',
                          is_top BOOLEAN DEFAULT 0 COMMENT '是否置顶(0:否/1:是)',
                          is_author BOOLEAN DEFAULT 0 COMMENT '是否为作者评论(0:否/1:是)',
                          status ENUM('normal', 'hidden', 'deleted') DEFAULT 'normal' COMMENT '评论状态(normal:正常/hidden:隐藏/deleted:已删除)',
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '评论创建时间',
                          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '评论更新时间',
                          FOREIGN KEY (ai_role_id) REFERENCES ai_roles(id) ON DELETE CASCADE,
                          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                          FOREIGN KEY (root_comment_id) REFERENCES comments(id) ON DELETE CASCADE,
                          FOREIGN KEY (to_comment_id) REFERENCES comments(id) ON DELETE CASCADE,
                          FOREIGN KEY (reply_to_user_id) REFERENCES users(id) ON DELETE SET NULL,
                          INDEX idx_comments_ai_role (ai_role_id) COMMENT 'AI角色ID索引',
                          INDEX idx_comments_user (user_id) COMMENT '用户ID索引',
                          INDEX idx_comments_root (root_comment_id) COMMENT '根评论ID索引',
                          INDEX idx_comments_to (to_comment_id) COMMENT '回复目标评论ID索引',
                          INDEX idx_comments_status (status) COMMENT '评论状态索引',
                          INDEX idx_comments_created (created_at) COMMENT '创建时间索引',
                          INDEX idx_comments_likes (like_count) COMMENT '点赞数索引',
                          INDEX idx_comments_top (is_top) COMMENT '置顶索引'
);

-- 8. 评论点赞记录表：记录用户对评论的点赞状态
CREATE TABLE comment_likes (
                               id INT AUTO_INCREMENT PRIMARY KEY COMMENT '点赞记录唯一ID',
                               user_id INT NOT NULL COMMENT '点赞用户ID',
                               comment_id INT NOT NULL COMMENT '被点赞的评论ID',
                               created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
                               FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                               FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE,
                               UNIQUE KEY unique_user_comment (user_id, comment_id) COMMENT '用户评论点赞唯一约束',
                               INDEX idx_likes_user (user_id) COMMENT '用户ID索引',
                               INDEX idx_likes_comment (comment_id) COMMENT '评论ID索引'
);

-- 创建触发器：更新评论回复数
DELIMITER //
CREATE TRIGGER update_comment_reply_count_insert
    AFTER INSERT ON comments
    FOR EACH ROW
BEGIN
    -- 如果是回复评论，更新根评论的回复数
    IF NEW.root_comment_id IS NOT NULL THEN
    UPDATE comments
    SET reply_count = reply_count + 1
    WHERE id = NEW.root_comment_id;
END IF;
END//

CREATE TRIGGER update_comment_reply_count_delete
    AFTER DELETE ON comments
    FOR EACH ROW
BEGIN
    -- 如果是回复评论，减少根评论的回复数
    IF OLD.root_comment_id IS NOT NULL THEN
    UPDATE comments
    SET reply_count = GREATEST(reply_count - 1, 0)
    WHERE id = OLD.root_comment_id;
END IF;
END//
DELIMITER ;

-- 创建触发器：更新评论点赞数
DELIMITER //
CREATE TRIGGER update_comment_like_count_insert
    AFTER INSERT ON comment_likes
    FOR EACH ROW
BEGIN
    UPDATE comments
    SET like_count = like_count + 1
    WHERE id = NEW.comment_id;
END//

CREATE TRIGGER update_comment_like_count_delete
    AFTER DELETE ON comment_likes
    FOR EACH ROW
BEGIN
    UPDATE comments
    SET like_count = GREATEST(like_count - 1, 0)
    WHERE id = OLD.comment_id;
END//
DELIMITER ;
---------------------------