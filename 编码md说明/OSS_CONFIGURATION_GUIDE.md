# OSS对象存储配置指南

## 概述

本项目已集成阿里云OSS对象存储服务，用于存储用户头像文件。所有头像文件现在都存储在OSS中，通过OSS URL直接访问，不再依赖本地文件存储。

## 配置步骤

### 1. 创建阿里云OSS Bucket

1. 登录阿里云控制台
2. 进入对象存储OSS服务
3. 创建一个新的Bucket
4. 设置Bucket权限为公共读（用于头像访问）
5. 记录Bucket名称和Endpoint

### 2. 创建AccessKey

1. 在阿里云控制台进入RAM访问控制
2. 创建用户并分配OSS权限
3. 创建AccessKey ID和AccessKey Secret
4. 记录AccessKey信息

### 3. 修改配置文件

编辑 `backend/MyApplication/src/main/resources/application.properties` 文件：

```properties
# 阿里云OSS配置
aliyun.oss.endpoint=oss-cn-hangzhou.aliyuncs.com
aliyun.oss.access-key-id=your-access-key-id
aliyun.oss.access-key-secret=your-access-key-secret
aliyun.oss.bucket-name=your-bucket-name
```

**配置说明：**
- `endpoint`: OSS服务的地域节点，根据你的Bucket所在地域选择
- `access-key-id`: 你的AccessKey ID
- `access-key-secret`: 你的AccessKey Secret
- `bucket-name`: 你的Bucket名称

### 4. 常见Endpoint配置

| 地域 | Endpoint |
|------|----------|
| 华东1（杭州） | oss-cn-hangzhou.aliyuncs.com |
| 华东2（上海） | oss-cn-shanghai.aliyuncs.com |
| 华北1（青岛） | oss-cn-qingdao.aliyuncs.com |
| 华北2（北京） | oss-cn-beijing.aliyuncs.com |
| 华北3（张家口） | oss-cn-zhangjiakou.aliyuncs.com |
| 华北5（呼和浩特） | oss-cn-huhehaote.aliyuncs.com |
| 华北6（乌兰察布） | oss-cn-wulanchabu.aliyuncs.com |
| 华南1（深圳） | oss-cn-shenzhen.aliyuncs.com |
| 华南2（河源） | oss-cn-heyuan.aliyuncs.com |
| 华南3（广州） | oss-cn-guangzhou.aliyuncs.com |

## 功能特性

### 1. 头像上传
- 支持文件上传和Base64上传
- 自动生成唯一文件名
- 文件存储在OSS的 `avatars/` 目录下

### 2. 头像访问
- 通过OSS URL直接访问
- 支持CDN加速
- 无需本地文件存储

### 3. 头像生成
- 随机色块头像生成
- 生成的头像直接上传到OSS
- 返回OSS访问URL

### 4. 前端显示
- 去掉默认头像显示
- 头像为空时显示占位符
- 支持头像查看器功能

## 安全配置

### 1. Bucket权限设置
```json
{
  "Version": "1",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "oss:GetObject",
      "Resource": "arn:aws:oss:::your-bucket-name/avatars/*"
    }
  ]
}
```

### 2. 防盗链设置（可选）
- 设置Referer白名单
- 限制访问来源域名
- 防止恶意盗用

### 3. 生命周期管理（可选）
- 设置文件过期时间
- 自动删除过期文件
- 节省存储成本

## 测试验证

### 1. 启动服务
```bash
cd backend/MyApplication
mvn spring-boot:run
```

### 2. 测试头像上传
```bash
curl -X POST \
  http://localhost:8081/api/user/test-user/avatar/base64 \
  -H 'Content-Type: application/json' \
  -d '{
    "imageData": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
  }'
```

### 3. 验证返回结果
```json
{
  "success": true,
  "message": "头像上传成功",
  "data": "https://your-bucket-name.oss-cn-hangzhou.aliyuncs.com/avatars/test-user_uuid.png",
  "timestamp": 1705312200000
}
```

## 故障排除

### 1. 常见错误
- **AccessDenied**: 检查AccessKey权限
- **NoSuchBucket**: 检查Bucket名称是否正确
- **InvalidEndpoint**: 检查Endpoint配置

### 2. 日志查看
```bash
# 查看应用日志
tail -f logs/application.log

# 查看OSS上传日志
grep "OSS" logs/application.log
```

### 3. 网络问题
- 检查服务器网络连接
- 确认OSS服务可用性
- 验证防火墙设置

## 性能优化

### 1. CDN加速
- 配置OSS CDN加速
- 提升头像访问速度
- 减少源站压力

### 2. 图片压缩
- 上传前压缩图片
- 设置合适的图片尺寸
- 优化存储空间

### 3. 缓存策略
- 设置浏览器缓存
- 配置CDN缓存规则
- 提升用户体验

## 成本控制

### 1. 存储费用
- 监控存储使用量
- 设置存储告警
- 定期清理无用文件

### 2. 流量费用
- 监控访问流量
- 优化图片大小
- 使用CDN减少回源

### 3. 请求费用
- 监控API调用次数
- 优化上传逻辑
- 避免重复上传

## 注意事项

1. **安全性**: 不要将AccessKey提交到代码仓库
2. **备份**: 定期备份重要头像文件
3. **监控**: 设置OSS使用量监控
4. **测试**: 在生产环境部署前充分测试
5. **文档**: 及时更新配置文档 