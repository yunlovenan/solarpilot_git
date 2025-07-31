#!/bin/bash

# Jenkins定时运行脚本
# 每天15:00自动运行移动端测试

# 设置日志文件
LOG_DIR="/Users/mayun/project/solarpilot/Appium_Solat/jenkins/logs"
LOG_FILE="$LOG_DIR/scheduled-run-$(date +%Y%m%d).log"
ERROR_LOG="$LOG_DIR/error-$(date +%Y%m%d).log"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 记录开始时间
echo "==========================================" >> "$LOG_FILE"
echo "定时任务开始执行 - $(date)" >> "$LOG_FILE"
echo "==========================================" >> "$LOG_FILE"

# 进入项目目录
cd /Users/mayun/project/solarpilot/Appium_Solat

# 检查Appium是否运行，如果没有则启动
if ! pgrep -f "appium --allow-cors" > /dev/null; then
    echo "$(date): 启动Appium服务器..." >> "$LOG_FILE"
    unset all_proxy && unset http_proxy && unset https_proxy
    appium --allow-cors --base-path /wd/hub > /dev/null 2>&1 &
    sleep 10
    echo "$(date): Appium服务器已启动" >> "$LOG_FILE"
else
    echo "$(date): Appium服务器已在运行" >> "$LOG_FILE"
fi

# 运行测试
echo "$(date): 开始执行移动端测试..." >> "$LOG_FILE"
cd jenkins && ./quick-start-local.sh >> "$LOG_FILE" 2>> "$ERROR_LOG"

# 检查测试结果
if [ $? -eq 0 ]; then
    echo "$(date): 测试执行成功" >> "$LOG_FILE"
else
    echo "$(date): 测试执行失败，错误日志已保存到 $ERROR_LOG" >> "$LOG_FILE"
fi

echo "$(date): 定时任务执行完成" >> "$LOG_FILE"
echo "==========================================" >> "$LOG_FILE"
