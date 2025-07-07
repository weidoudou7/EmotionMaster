-- 用户行为记录表
-- 用于存储用户的各种行为数据，为推荐算法提供学习数据

CREATE TABLE IF NOT EXISTS user_behavior (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL COMMENT '用户ID',
    role_id INT NOT NULL COMMENT 'AI角色ID',
    action_type VARCHAR(50) NOT NULL COMMENT '行为类型：view(查看), click(点击), chat(聊天), like(点赞), share(分享)',
    score DOUBLE DEFAULT 1.0 COMMENT '行为评分',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '行为发生时间',
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id),
    INDEX idx_action_type (action_type),
    INDEX idx_created_at (created_at),
    INDEX idx_user_role (user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户行为记录表';

-- 插入一些示例数据
INSERT INTO user_behavior (user_id, role_id, action_type, score) VALUES
(574, 364, 'view', 0.3),
(574, 364, 'click', 0.5),
(574, 364, 'chat', 1.0),
(574, 365, 'view', 0.3),
(574, 366, 'view', 0.3),
(574, 367, 'click', 0.5),
(574, 368, 'chat', 1.0); 