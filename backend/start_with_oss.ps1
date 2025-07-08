# OSS配置启动脚本
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OSS配置启动脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "正在设置OSS环境变量..." -ForegroundColor Green

# 设置OSS环境变量
$env:OSS_ENDPOINT = "oss-cn-beijing.aliyuncs.com"
$env:OSS_ACCESS_KEY_ID = "LTAI5tRByewQaXVG4KkhyZrn"
$env:OSS_ACCESS_KEY_SECRET = "bqIAI4zxKtnu1VkftLoAupw7QkPGna"
$env:OSS_BUCKET_NAME = "xpf-bucket"
$env:OSS_URL_PREFIX = "https://xpf-bucket.oss-cn-beijing.aliyuncs.com"

Write-Host "环境变量设置完成" -ForegroundColor Green
Write-Host "OSS_ENDPOINT: $env:OSS_ENDPOINT" -ForegroundColor Yellow
Write-Host "OSS_BUCKET_NAME: $env:OSS_BUCKET_NAME" -ForegroundColor Yellow
Write-Host "OSS_ACCESS_KEY_ID: $env:OSS_ACCESS_KEY_ID" -ForegroundColor Yellow
Write-Host ""

Write-Host "正在启动Spring Boot应用..." -ForegroundColor Green
Set-Location MyApplication
mvn spring-boot:run

Read-Host "按任意键退出" 