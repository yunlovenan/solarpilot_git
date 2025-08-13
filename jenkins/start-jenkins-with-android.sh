#!/bin/bash

echo "🚀 启动包含Android Studio的Jenkins容器..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

# 停止并删除现有容器
echo "🛑 停止现有容器..."
docker-compose down

# 构建新镜像
echo "🔨 构建包含Android Studio的Jenkins镜像..."
docker-compose build --no-cache

# 启动容器
echo "🚀 启动Jenkins容器..."
docker-compose up -d

# 等待Jenkins启动
echo "⏳ 等待Jenkins启动..."
sleep 30

# 检查容器状态
echo "📊 检查容器状态..."
docker-compose ps

# 显示Jenkins初始密码
echo "🔑 获取Jenkins初始密码..."
docker-compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Jenkins还在初始化中，请稍后查看密码"

echo "✅ Jenkins已启动！"
echo "🌐 访问地址: http://localhost:8080"
echo "📱 Appium端口: http://localhost:4723"
echo "📁 项目目录: $(pwd)"

# 显示容器日志
echo "📋 容器日志:"
docker-compose logs --tail=20 