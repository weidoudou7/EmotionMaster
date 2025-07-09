# 服务器连接配置指南

## 🔗 服务器地址配置位置

### 主要配置文件
**文件路径**: `MyApplication/entry/src/main/ets/common/config.ets`

```typescript
// 当前环境 (修改这里切换环境)
private static readonly CURRENT_ENV = 'DEV'; // 'DEV' | 'TEST' | 'PROD'

// 开发环境配置
private static readonly DEV_CONFIG = {
  API_BASE_URL: 'http://localhost:8080/api',
  TIMEOUT: 10000,
  DEBUG: true
};
```

## 🌍 不同环境的配置

### 1. 本地开发环境 (DEV)
```typescript
API_BASE_URL: 'http://localhost:8080/api'
```
**适用场景**: 前端和后端在同一台机器上运行

### 2. 局域网环境 (TEST)
```typescript
API_BASE_URL: 'http://192.168.1.100:8080/api'
```
**适用场景**: 前端在手机/模拟器，后端在电脑上运行

### 3. 生产环境 (PROD)
```typescript
API_BASE_URL: 'https://your-domain.com/api'
```
**适用场景**: 正式部署环境

## 📱 如何修改服务器地址

### 步骤1: 确定您的网络环境

#### 本地开发
- 前端和后端都在同一台电脑上
- 使用 `localhost` 或 `127.0.0.1`

#### 局域网开发
- 前端在手机/模拟器上
- 后端在电脑上
- 需要找到电脑的局域网IP地址

#### 查找电脑IP地址的方法

**Windows**:
```bash
ipconfig
```
查找 "IPv4 地址" 字段

**Mac/Linux**:
```bash
ifconfig
# 或
ip addr
```

### 步骤2: 修改配置文件

1. 打开 `MyApplication/entry/src/main/ets/common/config.ets`
2. 修改 `CURRENT_ENV` 为对应环境
3. 修改对应环境的 `API_BASE_URL`

**示例 - 局域网环境**:
```typescript
// 当前环境
private static readonly CURRENT_ENV = 'TEST';

// 测试环境配置
private static readonly TEST_CONFIG = {
  API_BASE_URL: 'http://192.168.1.100:8080/api', // 替换为您的IP
  TIMEOUT: 15000,
  DEBUG: true
};
```

### 步骤3: 启动后端服务

```bash
cd backend/MyApplication
mvn spring-boot:run
```

### 步骤4: 测试连接

1. 启动前端应用
2. 点击 "⚙️ 服务器配置" 按钮
3. 点击 "测试服务器连接" 按钮

## 🔧 常见问题解决

### 1. 连接失败 - 网络问题

**症状**: 显示 "连接失败 ❌"

**解决方案**:
- 检查后端服务是否正在运行
- 确认IP地址是否正确
- 检查防火墙设置
- 确保前端和后端在同一网络

### 2. 连接超时

**症状**: 请求长时间无响应

**解决方案**:
- 增加超时时间配置
- 检查网络延迟
- 确认服务器性能

### 3. CORS错误

**症状**: 浏览器控制台显示CORS错误

**解决方案**:
- 后端已配置CORS，通常不需要额外设置
- 检查请求URL是否正确

### 4. 端口被占用

**症状**: 后端启动失败

**解决方案**:
```bash
# 查找占用8080端口的进程
netstat -ano | findstr :8080

# 杀死进程 (Windows)
taskkill /PID <进程ID> /F

# 或者修改后端端口
# 在 application.yml 中修改
server:
  port: 8081
```

## 📋 配置检查清单

- [ ] 后端服务正在运行
- [ ] 配置文件中的IP地址正确
- [ ] 前端和后端在同一网络
- [ ] 防火墙允许8080端口
- [ ] 网络连接正常

## 🚀 快速测试

### 使用浏览器测试后端
在浏览器中访问: `http://localhost:8080/api/user/health`

应该返回:
```json
{
  "success": true,
  "message": "用户服务运行正常",
  "data": "OK",
  "timestamp": 1705312200000
}
```

### 使用curl测试
```bash
curl http://localhost:8080/api/user/health
```

## 📞 获取帮助

如果遇到连接问题，请检查:

1. **网络连接**: 确保设备能访问互联网
2. **IP地址**: 确认使用正确的IP地址
3. **端口**: 确认8080端口没有被占用
4. **防火墙**: 检查防火墙设置
5. **后端日志**: 查看后端控制台输出

## 🔄 环境切换示例

### 开发环境
```typescript
private static readonly CURRENT_ENV = 'DEV';
```

### 测试环境
```typescript
private static readonly CURRENT_ENV = 'TEST';
```

### 生产环境
```typescript
private static readonly CURRENT_ENV = 'PROD';
```

修改后重新编译和运行前端应用即可生效。 