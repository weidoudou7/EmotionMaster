-- 初始化测试用户数据
-- 这个脚本会在应用启动时自动执行，确保测试用户始终存在

-- 插入测试用户（如果不存在）
INSERT IGNORE INTO users (
    uid, 
    username, 
    gender, 
    is_private, 
    signature, 
    email, 
    level, 
    profile_image
) VALUES (
    '100000001',           -- UID
    '测试1',               -- 用户名
    '男',                  -- 性别
    0,                     -- 隐私可见性（0=公开）
    '这是一个测试用户',     -- 个性签名
    'test1@example.com',   -- 邮箱
    1,                     -- 用户等级
    '/avatars/default.png' -- 默认头像
);

-- 为测试用户创建对应的星球
INSERT IGNORE INTO planets (
    user_id,
    level,
    experience,
    name,
    appearance,
    unlocked_items
) SELECT 
    u.id,
    1,
    0,
    '测试星球',
    '{"type": "default", "color": "#4A90E2"}',
    '[]'
FROM users u 
WHERE u.uid = '100000001';

-- 显示插入结果
SELECT '测试用户初始化完成' as message;
SELECT 
    uid,
    username,
    gender,
    email,
    level,
    profile_image
FROM users 
WHERE uid = '100000001'; 