#!/bin/bash

echo "🚀 简化版Appium启动脚本"
echo "========================"

# 设置环境变量
export APPIUM_URL="http://localhost:4723/wd/hub"
export PROJECT_ROOT="/Users/mayun/project/solarpilot/Appium_Solat"

echo "项目根目录: $PROJECT_ROOT"
echo "Appium URL: $APPIUM_URL"

# 检查Appium状态
echo "检查Appium服务器状态..."
if curl -s "$APPIUM_URL/status" > /dev/null; then
    echo "✅ Appium服务器已在运行"
    exit 0
fi

echo "⚠️ Appium服务器未运行，正在启动..."

# 切换到项目根目录
cd "$PROJECT_ROOT" || {
    echo "❌ 无法切换到项目根目录: $PROJECT_ROOT"
    exit 1
}

# 检查是否已有Appium进程
if pgrep -f "appium.*--base-path" > /dev/null; then
    echo "✅ 发现已有Appium进程，正在停止..."
    pkill -f "appium.*--base-path"
    sleep 2
fi

# 启动Appium服务器
echo "启动Appium服务器..."
appium --base-path /wd/hub --log-level debug > appium.log 2>&1 &
appium_pid=$!

# 等待启动
echo "等待Appium服务器启动..."
for i in {1..30}; do
    if curl -s "$APPIUM_URL/status" > /dev/null; then
        echo "✅ Appium服务器启动成功 (PID: $appium_pid)"
        echo "Appium日志文件: $PROJECT_ROOT/appium.log"
        exit 0
    fi
    sleep 2
    echo "   等待Appium启动... ($i/30)"
done

# 启动失败
echo "❌ Appium服务器启动失败"
echo "Appium日志:"
tail -20 appium.log
exit 1
