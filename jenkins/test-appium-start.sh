#!/bin/bash

echo "🧪 Appium启动测试脚本"
echo "======================"

# 设置环境变量
export APPIUM_URL="http://localhost:4723/wd/hub"
export PROJECT_ROOT="/Users/mayun/project/solarpilot/Appium_Solat"

echo "项目根目录: $PROJECT_ROOT"
echo "Appium URL: $APPIUM_URL"

# 检查环境
echo ""
echo "=== 环境检查 ==="
echo "当前用户: $(whoami)"
echo "当前目录: $(pwd)"
echo "PATH: $PATH"
echo "Shell: $SHELL"

# 检查Appium命令
echo ""
echo "=== Appium命令检查 ==="
which appium || echo "❌ appium命令未找到"
appium --version || echo "❌ 无法获取appium版本"

# 检查端口
echo ""
echo "=== 端口检查 ==="
echo "端口4723占用情况:"
lsof -i :4723 2>/dev/null || echo "端口4723未被占用"

# 切换到项目根目录
echo ""
echo "=== 切换到项目根目录 ==="
cd "$PROJECT_ROOT" || {
    echo "❌ 无法切换到项目根目录: $PROJECT_ROOT"
    exit 1
}
echo "当前目录: $(pwd)"

# 检查现有进程
echo ""
echo "=== 检查现有进程 ==="
if pgrep -f "appium.*--base-path" > /dev/null; then
    echo "✅ 发现已有Appium进程:"
    pgrep -f "appium.*--base-path"
    echo "正在停止..."
    pkill -f "appium.*--base-path"
    sleep 3
else
    echo "没有发现Appium进程"
fi

# 测试前台启动（短时间）
echo ""
echo "=== 测试前台启动（5秒） ==="
echo "启动Appium（前台模式，5秒后停止）..."
timeout 5s appium --base-path /wd/hub --log-level debug &
test_pid=$!
echo "测试进程ID: $test_pid"

sleep 6
echo "前台启动测试完成"

# 测试后台启动
echo ""
echo "=== 测试后台启动 ==="
echo "启动Appium（后台模式）..."
nohup appium --base-path /wd/hub --log-level debug > appium_test.log 2>&1 &
appium_pid=$!
echo "后台进程ID: $appium_pid"

# 等待启动
echo "等待Appium服务器启动..."
for i in {1..15}; do
    echo "   检查Appium状态... ($i/15)"
    
    # 检查进程是否还在运行
    if ! kill -0 $appium_pid 2>/dev/null; then
        echo "❌ Appium进程已退出"
        echo "Appium日志:"
        tail -20 appium_test.log
        exit 1
    fi
    
    # 检查服务器状态
    if curl -s "$APPIUM_URL/status" > /dev/null 2>&1; then
        echo "✅ Appium服务器启动成功 (PID: $appium_pid)"
        echo "服务器状态:"
        curl -s "$APPIUM_URL/status" | python3 -m json.tool 2>/dev/null || curl -s "$APPIUM_URL/status"
        break
    fi
    
    sleep 2
done

# 最终检查
if ! curl -s "$APPIUM_URL/status" > /dev/null 2>&1; then
    echo "❌ Appium服务器启动失败"
    echo "Appium进程状态:"
    ps aux | grep appium
    echo "Appium日志:"
    tail -30 appium_test.log
    echo "端口占用情况:"
    lsof -i :4723 2>/dev/null || echo "端口4723未被占用"
    exit 1
fi

echo ""
echo "✅ Appium启动测试成功！"
echo "进程ID: $appium_pid"
echo "日志文件: $PROJECT_ROOT/appium_test.log"

# 清理测试进程
echo ""
echo "=== 清理测试进程 ==="
kill $appium_pid
sleep 2
echo "测试完成"
