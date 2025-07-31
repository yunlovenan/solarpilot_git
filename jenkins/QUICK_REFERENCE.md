# 📋 Jenkins快速参考卡片

## 🚀 一键启动
```bash
cd jenkins
./start-web.sh                    # 启动Web界面
./manage-schedule.sh status       # 检查状态
./manage-schedule.sh test         # 手动测试
```

## 🌐 访问地址
- **测试页面**: http://localhost:8080/test.html
- **主页面**: http://localhost:8080/index.html
- **根目录**: http://localhost:8080/

## 📊 管理命令
```bash
./manage-schedule.sh status       # 查看定时任务状态
./manage-schedule.sh install      # 安装定时任务
./manage-schedule.sh uninstall    # 卸载定时任务
./manage-schedule.sh test         # 手动测试运行
./manage-schedule.sh logs         # 查看详细日志
```

## �� 故障排除
```bash
# 检查端口占用
lsof -i :8080
lsof -i :4723

# 重启服务
pkill -f "python3 -m http.server"
pkill -f appium

# 重新启动
./start-web.sh
appium --base-path /wd/hub &
```

## 📈 监控命令
```bash
# 查看日志
tail -f logs/scheduled-run-$(date +%Y%m%d).log
tail -f logs/error-$(date +%Y%m%d).log

# 检查进程
ps aux | grep appium
ps aux | grep "python3 -m http.server"

# 检查设备
adb devices
```

## ⏰ 定时任务
- **运行时间**: 每天15:00
- **日志位置**: `jenkins/logs/`
- **配置文件**: `conf/config.ini`
- **测试脚本**: `testcase/`

## 📁 重要文件
- `jenkins/quick-start-local.sh` - 本地启动脚本
- `jenkins/scheduled-run.sh` - 定时任务脚本
- `jenkins/manage-schedule.sh` - 管理脚本
- `jenkins/start-web.sh` - Web界面脚本
- `conf/config.ini` - 测试数据配置
- `run.py` - 主运行脚本

## 🎯 成功标志
✅ **定时任务**: 每天15:00自动运行  
✅ **Web界面**: http://localhost:8080 可访问  
✅ **测试执行**: 移动端测试可正常执行  
✅ **日志记录**: 日志文件正常生成  
✅ **报告生成**: Allure报告正常生成  

## 📞 紧急联系
- **日志位置**: `jenkins/logs/`
- **配置文件**: `conf/config.ini`
- **测试脚本**: `testcase/`
- **Web界面**: http://localhost:8080

---
**Jenkins持续集成系统** - 移动端自动化测试
