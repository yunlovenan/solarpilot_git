#!/bin/bash

# Appium管理脚本
# 用法: ./manage-appium.sh [start|stop|status|restart|logs]

set -e

# 配置
APPIUM_URL="http://localhost:4723/wd/hub"
PROJECT_ROOT="/Users/mayun/project/solarpilot/Appium_Solat"
APPIUM_LOG="$PROJECT_ROOT/appium.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 打印函数
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查Appium状态
check_status() {
    if curl -s "$APPIUM_URL/status" > /dev/null 2>&1; then
        print_success "Appium服务器运行正常"
        echo "服务器状态:"
        curl -s "$APPIUM_URL/status" | python3 -m json.tool 2>/dev/null || curl -s "$APPIUM_URL/status"
        return 0
    else
        print_warning "Appium服务器未运行"
        return 1
    fi
}

# 启动Appium
start_appium() {
    print_info "启动Appium服务器..."
    
    # 切换到项目根目录
    cd "$PROJECT_ROOT" || {
        print_error "无法切换到项目根目录: $PROJECT_ROOT"
        exit 1
    }
    
    # 检查是否已有Appium进程
    if pgrep -f "appium.*--base-path" > /dev/null; then
        print_warning "发现已有Appium进程，正在停止..."
        pkill -f "appium.*--base-path"
        sleep 3
    fi
    
    # 启动Appium服务器
    nohup appium --base-path /wd/hub --log-level debug > "$APPIUM_LOG" 2>&1 &
    appium_pid=$!
    print_info "Appium进程ID: $appium_pid"
    
    # 等待启动
    print_info "等待Appium服务器启动..."
    for i in {1..30}; do
        echo "   检查Appium状态... ($i/30)"
        
        # 检查进程是否还在运行
        if ! kill -0 $appium_pid 2>/dev/null; then
            print_error "Appium进程已退出"
            print_info "Appium日志:"
            tail -20 "$APPIUM_LOG"
            exit 1
        fi
        
        # 检查服务器状态
        if curl -s "$APPIUM_URL/status" > /dev/null 2>&1; then
            print_success "Appium服务器启动成功 (PID: $appium_pid)"
            check_status
            return 0
        fi
        
        sleep 2
    done
    
    # 启动失败
    print_error "Appium服务器启动失败"
    print_info "Appium进程状态:"
    ps aux | grep appium
    print_info "Appium日志:"
    tail -30 "$APPIUM_LOG"
    print_info "端口占用情况:"
    lsof -i :4723 2>/dev/null || echo "端口4723未被占用"
    exit 1
}

# 停止Appium
stop_appium() {
    print_info "停止Appium服务器..."
    
    if pgrep -f "appium.*--base-path" > /dev/null; then
        pkill -f "appium.*--base-path"
        sleep 2
        print_success "Appium服务器已停止"
    else
        print_warning "没有发现运行中的Appium进程"
    fi
}

# 重启Appium
restart_appium() {
    print_info "重启Appium服务器..."
    stop_appium
    sleep 2
    start_appium
}

# 显示日志
show_logs() {
    if [ -f "$APPIUM_LOG" ]; then
        print_info "Appium日志 (最后50行):"
        tail -50 "$APPIUM_LOG"
    else
        print_warning "Appium日志文件不存在: $APPIUM_LOG"
    fi
}

# 主函数
main() {
    case "${1:-status}" in
        start)
            start_appium
            ;;
        stop)
            stop_appium
            ;;
        restart)
            restart_appium
            ;;
        status)
            check_status
            ;;
        logs)
            show_logs
            ;;
        *)
            echo "用法: $0 [start|stop|status|restart|logs]"
            echo ""
            echo "命令:"
            echo "  start   - 启动Appium服务器"
            echo "  stop    - 停止Appium服务器"
            echo "  restart - 重启Appium服务器"
            echo "  status  - 检查Appium服务器状态"
            echo "  logs    - 显示Appium日志"
            echo ""
            echo "默认命令: status"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
