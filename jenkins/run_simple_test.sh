#!/bin/bash

echo "🚀 运行简化Appium测试"
echo "======================"

# 设置环境变量
export EMULATOR_NAME="emulator-5554"
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

# 检查环境
print_status "INFO" "检查环境..."
if adb devices | grep -q "$EMULATOR_NAME"; then
    print_status "SUCCESS" "模拟器 $EMULATOR_NAME 已连接"
else
    print_status "ERROR" "模拟器 $EMULATOR_NAME 未连接"
    exit 1
fi

if curl -s "$APPIUM_URL/status" > /dev/null 2>&1; then
    print_status "SUCCESS" "Appium服务器运行正常"
else
    print_status "ERROR" "Appium服务器未运行"
    exit 1
fi

# 激活虚拟环境
print_status "INFO" "激活虚拟环境..."
source venv/bin/activate

# 创建测试结果目录
mkdir -p ALLURE-RESULTS
mkdir -p allure_report

# 运行简化测试
print_status "INFO" "运行简化测试..."
echo "测试命令: pytest testcase/test_simple_login.py -v --alluredir=ALLURE-RESULTS --junitxml=junit.xml"

if pytest testcase/test_simple_login.py -v --alluredir=ALLURE-RESULTS --junitxml=junit.xml; then
    print_status "SUCCESS" "测试执行成功"
    
    # 生成报告
    print_status "INFO" "生成测试报告..."
    if command -v allure &> /dev/null; then
        allure generate ALLURE-RESULTS --clean -o allure_report
        print_status "SUCCESS" "Allure报告生成成功"
    else
        print_status "WARNING" "allure命令不可用，跳过报告生成"
    fi
    
    # 显示结果
    echo ""
    print_status "SUCCESS" "测试完成！"
    echo "📁 测试结果: ALLURE-RESULTS/"
    echo "📊 报告目录: allure_report/"
    echo "📄 JUnit报告: junit.xml"
    
else
    print_status "ERROR" "测试执行失败"
    exit 1
fi

# 退出虚拟环境
deactivate
print_status "INFO" "已退出虚拟环境"
