-- 插入默认AI角色
INSERT INTO ai_roles (id, user_id, role_name, role_description, role_type, role_author, view_count, avatar_url, is_template, created_at) 
VALUES (1, NULL, '默认助手', '一个友好的AI助手，擅长聊天和回答问题', '助手', '系统', 0, 'https://example.com/default-avatar.png', true, NOW())
ON DUPLICATE KEY UPDATE 
    role_name = VALUES(role_name),
    role_description = VALUES(role_description),
    role_type = VALUES(role_type),
    role_author = VALUES(role_author),
    avatar_url = VALUES(avatar_url),
    is_template = VALUES(is_template);

-- 插入默认用户（如果不存在）
INSERT INTO users (id, uid, username, gender, is_private, signature, email, level, created_at, profile_image)
VALUES (405, 'user_405', '默认用户', '私有', 0, '这是一个默认用户', 'default@example.com', 1, NOW(), 'https://example.com/default-avatar.png')
ON DUPLICATE KEY UPDATE 
    username = VALUES(username),
    email = VALUES(email); 