# 头像生成功能测试脚本
Write-Host "🎨 ========== 头像生成功能测试 ==========" -ForegroundColor Cyan

# 测试用户UID
$testUserUID = "100000000"
$baseUrl = "http://10.128.131.254:8081"

Write-Host "🔗 基础URL: $baseUrl" -ForegroundColor Yellow
Write-Host "👤 测试用户UID: $testUserUID" -ForegroundColor Yellow

# 步骤1: 健康检查
Write-Host "`n🏥 ========== 步骤1: 健康检查 ==========" -ForegroundColor Green
try {
    $healthUrl = "$baseUrl/api/user/health"
    Write-Host "发送GET请求到: $healthUrl" -ForegroundColor Gray
    
    $response = Invoke-RestMethod -Uri $healthUrl -Method Get -TimeoutSec 5
    Write-Host "✅ 健康检查成功" -ForegroundColor Green
    Write-Host "响应: $($response | ConvertTo-Json)" -ForegroundColor Gray
} catch {
    Write-Host "❌ 健康检查失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 步骤2: 头像生成测试
Write-Host "`n🎨 ========== 步骤2: 头像生成测试 ==========" -ForegroundColor Green
try {
    $avatarUrl = "$baseUrl/api/user/$testUserUID/avatar/generate"
    Write-Host "发送POST请求到: $avatarUrl" -ForegroundColor Gray
    Write-Host "请求时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    
    $response = Invoke-RestMethod -Uri $avatarUrl -Method Post -TimeoutSec 30
    Write-Host "✅ 头像生成成功" -ForegroundColor Green
    Write-Host "响应: $($response | ConvertTo-Json)" -ForegroundColor Gray
    
    if ($response.success) {
        $avatarPath = $response.data
        Write-Host "✅ 头像URL: $avatarPath" -ForegroundColor Green
        
        # 步骤3: 测试头像文件访问
        Write-Host "`n🖼️ ========== 步骤3: 头像文件访问测试 ==========" -ForegroundColor Green
        $fullAvatarUrl = $baseUrl + $avatarPath
        Write-Host "完整头像URL: $fullAvatarUrl" -ForegroundColor Gray
        
        try {
            $avatarResponse = Invoke-WebRequest -Uri $fullAvatarUrl -Method Get -TimeoutSec 10
            Write-Host "✅ 头像文件访问成功" -ForegroundColor Green
            Write-Host "文件大小: $($avatarResponse.Content.Length) 字节" -ForegroundColor Gray
        } catch {
            Write-Host "❌ 头像文件访问失败: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ 头像生成失败: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ 头像生成测试失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "错误详情: $($_.Exception)" -ForegroundColor Red
}

Write-Host "`n🎨 ========== 测试完成 ==========" -ForegroundColor Cyan
Write-Host "💡 请查看后端控制台日志以获取详细信息" -ForegroundColor Yellow 