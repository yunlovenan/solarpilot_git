#!/bin/bash

echo "🚀 Appium本地测试脚本"
echo "===================="

# 设置环境变量
export PROJECT_ROOT="/Users/mayun/project/solarpilot/Appium_Solat"
export EMULATOR_NAME="emulator-5554"
export APPIUM_URL="http://localhost:4723/wd/hub"

echo "项目根目录: $PROJECT_ROOT"
echo "模拟器: $EMULATOR_NAME"
echo "Appium URL: $APPIUM_URL"

# 切换到项目根目录
cd "$PROJECT_ROOT" || { echo "❌ 无法切换到项目根目录: $PROJECT_ROOT"; exit 1; }

# 显示基本信息
echo "当前目录: $(pwd)"
echo "Python版本: $(python3 --version)"
echo "模拟器状态:"
adb devices

# 检查Appium版本并启动服务器
echo "启动Appium服务器..."
if curl -s "$APPIUM_URL/status" > /dev/null 2>&1; then
    echo "✅ Appium服务器已在运行"
else
    # 停止现有进程
    pkill -f "appium.*server" 2>/dev/null
    pkill -f "appium.*--base-path" 2>/dev/null
    sleep 2
    
    # 检查Appium版本并选择启动命令
    APPIUM_VERSION=$(appium --version)
    echo "检测到Appium版本: $APPIUM_VERSION"
    
    if [[ $APPIUM_VERSION == 2.* ]]; then
        echo "使用Appium 2.x启动命令"
        nohup appium server --base-path /wd/hub --port 4723 --log-level debug > appium.log 2>&1 &
    else
        echo "使用Appium 1.x启动命令"
        nohup appium --base-path /wd/hub --log-level debug > appium.log 2>&1 &
    fi
    
    appium_pid=$!
    
    # 等待启动
    for i in {1..20}; do
        if curl -s "$APPIUM_URL/status" > /dev/null 2>&1; then
            echo "✅ Appium启动成功 (PID: $appium_pid)"
            break
        fi
        sleep 2
        echo "等待Appium启动... ($i/20)"
    done
fi
