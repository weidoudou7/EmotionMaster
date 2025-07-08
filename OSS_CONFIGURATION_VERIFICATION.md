# OSS配置验证指南

## 配置信息

您的OSS配置已成功添加到系统中：

### 配置详情
- **Endpoint**: `oss-cn-beijing.aliyuncs.com` (华北2-北京)
- **Bucket**: `xpf-bucket`
- **Access Key ID**: `LTAI5tRByewQaXVG4KkhyZrn`
- **URL Prefix**: `https://xpf-bucket.oss-cn-beijing.aliyuncs.com`

### 配置文件位置
- 后端配置: `backend/MyApplication/src/main/resources/application.properties`

## 验证步骤

### 1. 检查OSS Bucket
确保在阿里云控制台中：
- [ ] Bucket `xpf-bucket` 已创建
- [ ] Bucket 位于 `oss-cn-beijing` 区域
- [ ] Bucket 权限设置为公共读（用于头像访问）

### 2. 检查Access Key权限
确保Access Key具有以下权限：
- [ ] OSS读写权限
- [ ] 对 `xpf-bucket` 的完全访问权限

### 3. 运行测试脚本
```bash
cd backend
python test_oss_config.py
```

### 4. 手动测试
1. 启动后端服务
2. 访问头像上传接口
3. 检查返回的URL格式是否正确

## 预期结果

### 成功配置后，头像URL格式应为：
```
https://xpf-bucket.oss-cn-beijing.aliyuncs.com/avatars/userUID_uuid.png
```

### 测试脚本输出示例：
```
==================================================
OSS配置测试
==================================================
Endpoint: oss-cn-beijing.aliyuncs.com
Bucket: xpf-bucket
URL Prefix: https://xpf-bucket.oss-cn-beijing.aliyuncs.com
Access Key ID: LTAI5tRB...

==================================================
后端连接测试
==================================================
✅ 后端服务连接正常

==================================================
头像上传测试
==================================================
✅ 头像上传成功
头像URL: https://xpf-bucket.oss-cn-beijing.aliyuncs.com/avatars/test_user_123_uuid.png

==================================================
URL访问测试
==================================================
✅ URL访问正常
```

## 故障排除

### 常见问题

1. **Bucket不存在**
   - 在阿里云OSS控制台创建bucket
   - 确保bucket名称和区域正确

2. **权限不足**
   - 检查Access Key权限
   - 确保有OSS读写权限

3. **网络连接问题**
   - 检查网络连接
   - 确认防火墙设置

4. **配置错误**
   - 检查application.properties中的配置
   - 确保没有多余的空格或特殊字符

### 调试命令

```bash
# 检查后端服务状态
curl http://localhost:8080/actuator/health

# 测试OSS连接（需要Java环境）
cd backend/MyApplication
mvn spring-boot:run
```

## 安全注意事项

1. **Access Key安全**
   - 不要在代码中硬编码Access Key
   - 使用环境变量或配置文件
   - 定期轮换Access Key

2. **Bucket权限**
   - 只设置必要的权限
   - 考虑使用STS临时凭证

3. **网络安全**
   - 使用HTTPS访问
   - 配置适当的CORS策略

## 下一步

配置验证成功后：
1. 测试头像上传功能
2. 测试头像生成功能
3. 验证前端显示效果
4. 部署到生产环境 