#!/bin/bash

echo "🔧 Jenkins Allure兼容性修复脚本"
echo "=============================="

# 清理代理环境变量
unset all_proxy http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
echo "✅ 代理环境变量已清理"

# 激活虚拟环境
if [ -d "venv" ]; then
    source venv/bin/activate
    echo "虚拟环境已激活"
else
    echo "❌ 虚拟环境不存在"
    exit 1
fi

echo ""
echo "📦 检查当前版本..."
PYTEST_VERSION=$(pip show pytest | grep Version | awk '{print $2}')
echo "当前pytest版本: $PYTEST_VERSION"

if [[ "$PYTEST_VERSION" == 8.* ]]; then
    echo "⚠️  检测到不兼容的pytest版本，开始修复..."
    
    echo ""
    echo "🔄 降级pytest到兼容版本..."
    pip install "pytest<8.0" --force-reinstall
    
    echo ""
    echo "📋 安装Jenkins专用依赖..."
    pip install -r jenkins/requirements-jenkins.txt -i https://mirrors.aliyun.com/pypi/simple/
    
    echo ""
    echo "✅ 版本修复完成！"
    echo "新版本信息:"
    pytest --version
    pip show pytest | grep Version
else
    echo "✅ pytest版本已兼容，无需修复"
fi

echo ""
echo "🎯 验证修复结果..."
echo "=================="

# 运行快速测试验证
echo "运行快速兼容性测试..."
python -c "
import pytest
import allure
print(f'✅ pytest版本: {pytest.__version__}')
print(f'✅ allure-pytest版本: {allure.__version__}')
print('✅ 导入成功，兼容性正常')
"

echo ""
echo "🎉 Allure兼容性修复完成！"
echo "💡 现在可以正常运行Jenkins测试了"
