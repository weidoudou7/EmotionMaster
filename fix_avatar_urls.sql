-- 修复头像URL的SQL脚本
-- 将错误的 /images/ 路径修正为 /avatars/ 路径

-- 1. 首先查看当前的头像URL情况
SELECT userUID, userName, userAvatar, updateTime 
FROM users 
WHERE userAvatar LIKE '/images/%' 
   OR userAvatar LIKE '/avatars/%'
ORDER BY updateTime DESC;

-- 2. 修复错误的 /images/ 路径为 /avatars/ 路径
UPDATE users 
SET userAvatar = REPLACE(userAvatar, '/images/', '/avatars/'),
    updateTime = NOW()
WHERE userAvatar LIKE '/images/%';

-- 3. 验证修复结果
SELECT userUID, userName, userAvatar, updateTime 
FROM users 
WHERE userAvatar LIKE '/avatars/%'
ORDER BY updateTime DESC;

-- 4. 检查是否还有错误的路径
SELECT COUNT(*) as wrong_path_count
FROM users 
WHERE userAvatar LIKE '/images/%';

-- 5. 显示修复后的统计信息
SELECT 
    CASE 
        WHEN userAvatar LIKE '/avatars/%' THEN '正确路径'
        WHEN userAvatar LIKE '/images/%' THEN '错误路径'
        WHEN userAvatar = '/avatars/default.png' THEN '默认头像'
        ELSE '其他路径'
    END as path_type,
    COUNT(*) as count
FROM users 
GROUP BY path_type; 