-- 动态表创建脚本
-- 用于存储用户的动态信息

-- 如果表已存在则删除
DROP TABLE IF EXISTS dynamics;

CREATE TABLE dynamics (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '动态ID',
    user_uid VARCHAR(50) NOT NULL COMMENT '用户UID',
    content TEXT COMMENT '动态文字内容',
    images JSON COMMENT '动态图片列表（JSON格式）',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    comment_count INT DEFAULT 0 COMMENT '评论数',
    
    -- 索引
    INDEX idx_user_uid (user_uid),
    INDEX idx_create_time (create_time),
    
    -- 外键约束（可选，如果用户表存在）
    -- FOREIGN KEY (user_uid) REFERENCES users(user_uid) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户动态表';

-- 插入一些测试数据
INSERT INTO dynamics (user_uid, content, images, like_count, comment_count) VALUES
('test_user_001', '今天天气真好，心情愉快！', '["https://example.com/image1.jpg"]', 5, 2),
('test_user_001', '分享一张美食照片', '["https://example.com/food1.jpg", "https://example.com/food2.jpg"]', 12, 8),
('test_user_001', '这是一条普通动态', '[]', 0, 0),
('test_user_002', 'Hello World!', '[]', 3, 1);

-- 显示创建结果
SELECT 'Dynamic table created successfully!' as result; 