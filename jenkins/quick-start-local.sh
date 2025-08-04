#!/bin/bash
echo "本地Jenkins启动脚本"
echo "由于系统未安装Docker，将使用本地模式运行测试"
echo "启动Appium服务器..."
pkill -f appium || true
unset all_proxy && unset http_proxy && unset https_proxy
appium --allow-cors --base-path /wd/hub &
sleep 10
echo "运行移动端测试..."
cd .. && /opt/homebrew/bin/python3 run.py mobile
echo "测试完成，清理环境..."
pkill -f appium || true
echo "Jenkins本地测试完成！"
