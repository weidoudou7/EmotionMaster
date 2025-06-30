-- 为ai_roles表添加personality和specialty字段
ALTER TABLE ai_roles 
ADD COLUMN personality TEXT COMMENT '角色性格特征(JSON格式)' AFTER role_description,
ADD COLUMN specialty TEXT COMMENT '角色专长领域(JSON数组格式)' AFTER personality; 