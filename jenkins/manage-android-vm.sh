#!/bin/bash

# Android虚拟机管理脚本

CONTAINER_NAME="jenkins-mobile-test"

# 检查容器是否运行
check_container() {
    if ! docker ps | grep -q $CONTAINER_NAME; then
        echo "❌ Jenkins容器未运行，请先启动容器"
        exit 1
    fi
}

# 列出可用的AVD
list_avds() {
    echo "📱 列出可用的Android虚拟机..."
    docker exec $CONTAINER_NAME $ANDROID_HOME/cmdline-tools/latest/bin/emulator -list-avds
}

# 启动Android虚拟机
start_avd() {
    local avd_name=${1:-"test_device"}
    echo "🚀 启动Android虚拟机: $avd_name"
    
    # 在后台启动模拟器
    docker exec -d $CONTAINER_NAME $ANDROID_HOME/emulator/emulator \
        -avd $avd_name \
        -no-audio \
        -no-window \
        -gpu swiftshader_indirect \
        -memory 2048 \
        -cores 2
    
    echo "⏳ 等待模拟器启动..."
    sleep 30
    
    # 检查模拟器状态
    echo "📊 检查模拟器状态..."
    docker exec $CONTAINER_NAME $ANDROID_HOME/platform-tools/adb devices
}

# 停止Android虚拟机
stop_avd() {
    echo "🛑 停止Android虚拟机..."
    docker exec $CONTAINER_NAME $ANDROID_HOME/platform-tools/adb emu kill
}

# 创建新的AVD
create_avd() {
    local avd_name=${1:-"test_device"}
    local api_level=${2:-"33"}
    
    echo "🔨 创建新的Android虚拟机: $avd_name (API $api_level)"
    
    docker exec $CONTAINER_NAME bash -c "
        echo 'no' | $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd \
        -n '$avd_name' \
        -k 'system-images;android-$api_level;google_apis;x86_64' \
        --force
    "
}

# 安装APK
install_apk() {
    local apk_path=$1
    echo "📦 安装APK: $apk_path"
    docker exec $CONTAINER_NAME $ANDROID_HOME/platform-tools/adb install $apk_path
}

# 运行Appium测试
run_appium_test() {
    echo "🧪 运行Appium测试..."
    docker exec $CONTAINER_NAME bash -c "
        cd /var/jenkins_home/workspace && \
        python3 -m pytest testcase/ -v --html=report.html
    "
}

# 显示帮助信息
show_help() {
    echo "📱 Android虚拟机管理脚本"
    echo ""
    echo "用法: $0 [命令] [参数]"
    echo ""
    echo "命令:"
    echo "  list                   列出可用的AVD"
    echo "  start [avd_name]       启动Android虚拟机"
    echo "  stop                   停止Android虚拟机"
    echo "  create [name] [api]    创建新的AVD"
    echo "  install <apk_path>     安装APK"
    echo "  test                   运行Appium测试"
    echo "  help                   显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 list"
    echo "  $0 start test_device"
    echo "  $0 create my_device 33"
    echo "  $0 install /path/to/app.apk"
}

# 主函数
main() {
    check_container
    
    case "${1:-help}" in
        "list")
            list_avds
            ;;
        "start")
            start_avd $2
            ;;
        "stop")
            stop_avd
            ;;
        "create")
            create_avd $2 $3
            ;;
        "install")
            if [ -z "$2" ]; then
                echo "❌ 请提供APK路径"
                exit 1
            fi
            install_apk $2
            ;;
        "test")
            run_appium_test
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

main "$@" 