#!/bin/bash

echo "🚀 快速启动Android测试环境..."

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

# 进入Jenkins目录
cd "$(dirname "$0")"

# 启动Jenkins
echo "🔨 构建并启动Jenkins容器..."
./start-jenkins-with-android.sh

# 等待Jenkins完全启动
echo "⏳ 等待Jenkins完全启动..."
sleep 60

# 启动Android虚拟机
echo "📱 启动Android虚拟机..."
./manage-android-vm.sh start

echo ""
echo "✅ Android测试环境已启动！"
echo ""
echo "🌐 Jenkins地址: http://localhost:8080"
echo "📱 Appium地址: http://localhost:4723"
echo "📊 测试报告: http://localhost:8080/job/your-job/lastSuccessfulBuild/artifact/"
echo ""
echo "🔧 管理命令:"
echo "  ./manage-android-vm.sh list     # 列出虚拟机"
echo "  ./manage-android-vm.sh start    # 启动虚拟机"
echo "  ./manage-android-vm.sh stop     # 停止虚拟机"
echo "  ./manage-android-vm.sh test     # 运行测试"
echo ""
echo "📁 项目文件已挂载到容器中"
echo "🔍 查看容器日志: docker-compose logs -f" 