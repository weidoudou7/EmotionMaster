@echo off
echo ========================================
echo OSS配置启动脚本
echo ========================================
echo.

echo 正在设置OSS环境变量...

:: 设置OSS环境变量
set OSS_ENDPOINT=oss-cn-beijing.aliyuncs.com
set OSS_ACCESS_KEY_ID=LTAI5tRByewQaXVG4KkhyZrn
set OSS_ACCESS_KEY_SECRET=bqIAI4zxKtnu1VkftLoAupw7QkPGna
set OSS_BUCKET_NAME=xpf-bucket
set OSS_URL_PREFIX=https://xpf-bucket.oss-cn-beijing.aliyuncs.com

echo 环境变量设置完成
echo OSS_ENDPOINT: %OSS_ENDPOINT%
echo OSS_BUCKET_NAME: %OSS_BUCKET_NAME%
echo OSS_ACCESS_KEY_ID: %OSS_ACCESS_KEY_ID%
echo.

echo 正在启动Spring Boot应用...
cd MyApplication
mvn spring-boot:run

pause 