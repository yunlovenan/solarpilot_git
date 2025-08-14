#!/bin/bash

echo "🚀 本地模拟器Appium测试脚本 (优化版)"
echo "=========================================="

# 设置环境变量
export EMULATOR_NAME="emulator-5554"
export ANDROID_VERSION="13"
export DEVICE_MODEL="sdk_gphone64_arm64"
export APPIUM_URL="http://localhost:4723/wd/hub"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 函数：打印带颜色的消息
print_status() {
    local status=$1
    local message=$2
    case $status in
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
    esac
}

# 函数：创建必要的目录
create_directories() {
    print_status "INFO" "创建必要的目录..."
    
    # 创建日志目录
    mkdir -p result/logs
    mkdir -p result/screenshots
    mkdir -p result/reports
    
    # 创建测试结果目录
    mkdir -p ALLURE-RESULTS
    mkdir -p allure_report
    
    # 设置权限
    chmod -R 755 result/
    chmod -R 755 ALLURE-RESULTS/
    
    print_status "SUCCESS" "目录创建完成"
}

# 函数：检查环境
check_environment() {
    print_status "INFO" "检查环境..."
    
    # 显示当前目录
    echo "当前工作目录: $(pwd)"
    ls -la
    
    # 显示Python版本
    echo "Python版本:"
    python3 --version
    
    # 检查模拟器状态
    if adb devices | grep -q "$EMULATOR_NAME"; then
        print_status "SUCCESS" "模拟器 $EMULATOR_NAME 已连接"
        local version=$(adb -s $EMULATOR_NAME shell getprop ro.build.version.release)
        local model=$(adb -s $EMULATOR_NAME shell getprop ro.product.model)
        echo "   Android版本: $version"
        echo "   设备型号: $model"
    else
        print_status "ERROR" "模拟器 $EMULATOR_NAME 未连接"
        return 1
    fi
    
    # 检查Appium服务器
    if curl -s "$APPIUM_URL/status" > /dev/null 2>&1; then
        print_status "SUCCESS" "Appium服务器运行正常"
    else
        print_status "ERROR" "Appium服务器未运行"
        return 1
    fi
    
    return 0
}

# 函数：设置虚拟环境
setup_virtualenv() {
    print_status "INFO" "设置虚拟环境..."
    
    # 检查虚拟环境是否存在
    if [ ! -d "venv" ]; then
        print_status "INFO" "创建虚拟环境..."
        python3 -m venv venv
    fi
    
    # 激活虚拟环境
    print_status "INFO" "激活虚拟环境..."
    source venv/bin/activate
    
    # 升级pip
    print_status "INFO" "升级pip..."
    python3 -m pip install --upgrade pip
    
    # 检查requirements.txt
    if [ -f "requirements.txt" ]; then
        print_status "INFO" "安装依赖包..."
        
        # 尝试使用阿里云镜像安装
        if pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/; then
            print_status "SUCCESS" "依赖安装成功"
        else
            print_status "WARNING" "阿里云镜像安装失败，尝试其他方法..."
            
            # 尝试使用清华镜像
            if pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/; then
                print_status "SUCCESS" "使用清华镜像安装成功"
            else
                print_status "WARNING" "镜像安装失败，尝试直接安装..."
                
                # 直接安装核心包
                pip install pytest==8.4.1
                pip install selenium
                pip install appium-python-client
                pip install requests
                pip install allure-pytest
                
                print_status "SUCCESS" "核心包安装完成"
            fi
        fi
    else
        print_status "WARNING" "requirements.txt不存在，安装核心包..."
        pip install pytest==8.4.1
        pip install selenium
        pip install appium-python-client
        pip install requests
        pip install allure-pytest
    fi
    
    # 显示已安装的包
    echo "已安装的包:"
    pip list | grep -E "(pytest|selenium|appium|requests|allure)"
}

# 函数：运行测试
run_tests() {
    print_status "INFO" "运行Appium测试..."
    
    # 清理之前的测试结果
    rm -f junit.xml
    rm -rf ALLURE-RESULTS/*
    
    # 检查测试文件
    if [ ! -f "testcase/test_app_01_login.py" ]; then
        print_status "ERROR" "测试文件不存在: testcase/test_app_01_login.py"
        return 1
    fi
    
    # 运行测试
    print_status "INFO" "开始执行测试..."
    echo "测试命令: pytest testcase/test_app_01_login.py -v --alluredir=ALLURE-RESULTS --junitxml=junit.xml"
    
    if pytest testcase/test_app_01_login.py -v --alluredir=ALLURE-RESULTS --junitxml=junit.xml; then
        print_status "SUCCESS" "测试执行成功"
        return 0
    else
        print_status "ERROR" "测试执行失败"
        return 1
    fi
}

# 函数：生成报告
generate_report() {
    print_status "INFO" "生成测试报告..."
    
    # 检查Allure结果
    if [ -d "ALLURE-RESULTS" ] && [ "$(ls -A ALLURE-RESULTS)" ]; then
        print_status "SUCCESS" "找到测试结果"
        
        if command -v allure &> /dev/null; then
            print_status "INFO" "生成Allure HTML报告..."
            if allure generate ALLURE-RESULTS --clean -o allure_report; then
                print_status "SUCCESS" "Allure报告生成成功"
                echo "报告路径: $(pwd)/allure_report/"
            else
                print_status "ERROR" "Allure报告生成失败"
            fi
        else
            print_status "WARNING" "allure命令不可用，跳过报告生成"
        fi
    else
        print_status "WARNING" "没有找到测试结果"
    fi
    
    # 检查JUnit XML
    if [ -f "junit.xml" ]; then
        print_status "SUCCESS" "JUnit XML报告已生成"
        echo "JUnit报告: $(pwd)/junit.xml"
    fi
}

# 函数：清理环境
cleanup() {
    print_status "INFO" "清理环境..."
    
    # 退出虚拟环境
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
        print_status "INFO" "已退出虚拟环境"
    fi
    
    print_status "SUCCESS" "清理完成"
}

# 主函数
main() {
    echo ""
    print_status "INFO" "开始本地模拟器Appium测试..."
    echo ""
    
    # 设置信号处理
    trap cleanup EXIT
    
    # 创建目录
    create_directories
    
    # 检查环境
    if ! check_environment; then
        print_status "ERROR" "环境检查失败"
        exit 1
    fi
    
    # 设置虚拟环境
    setup_virtualenv
    
    # 运行测试
    if run_tests; then
        echo ""
        generate_report
        echo ""
        print_status "SUCCESS" "所有测试完成！"
    else
        echo ""
        print_status "ERROR" "测试执行失败！"
        exit 1
    fi
}

# 运行主函数
main "$@"
