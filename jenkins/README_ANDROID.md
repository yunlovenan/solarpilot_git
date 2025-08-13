# Jenkins Android测试环境

这个项目在Jenkins容器中集成了Android Studio、SDK和虚拟机，用于自动化移动端测试。

## 🚀 快速开始

### 1. 启动环境
```bash
cd jenkins
./quick-start-android.sh
```

### 2. 访问Jenkins
- 地址: http://localhost:8080
- 获取初始密码: `docker-compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

## 📱 Android虚拟机管理

### 列出可用虚拟机
```bash
./manage-android-vm.sh list
```

### 启动虚拟机
```bash
./manage-android-vm.sh start test_device
```

### 停止虚拟机
```bash
./manage-android-vm.sh stop
```

### 创建新虚拟机
```bash
./manage-android-vm.sh create my_device 33
```

### 安装APK
```bash
./manage-android-vm.sh install /path/to/app.apk
```

### 运行测试
```bash
./manage-android-vm.sh test
```

## 🔧 环境配置

### 已安装的组件
- **Android SDK**: API 30-33
- **Build Tools**: 30.0.3, 31.0.0, 32.0.0, 33.0.0
- **System Images**: Google APIs x86_64
- **Emulator**: Android模拟器
- **Appium**: 最新版本
- **Python**: 测试框架和依赖

### 环境变量
```bash
ANDROID_HOME=/opt/android-sdk
ANDROID_SDK_ROOT=/opt/android-sdk
PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
```

## 📊 测试报告

### 生成的报告类型
- **HTML报告**: `test_reports/report_*.html`
- **JSON报告**: `test_reports/report_*.json`
- **Allure报告**: `allure_report/html/`

### 查看报告
1. 在Jenkins中查看构建结果
2. 下载测试报告文件
3. 访问Allure报告: `allure serve allure_report`

## 🐳 Docker配置

### 容器特性
- **特权模式**: 支持硬件加速
- **KVM支持**: 虚拟机性能优化
- **USB设备**: 支持真机测试
- **X11显示**: 支持GUI界面
- **共享内存**: 2GB内存分配

### 端口映射
- **8080**: Jenkins Web界面
- **4723**: Appium服务器

## 🔍 故障排除

### 常见问题

#### 1. 模拟器启动失败
```bash
# 检查KVM支持
docker exec jenkins-mobile-test cat /proc/cpuinfo | grep -i kvm

# 检查可用内存
docker exec jenkins-mobile-test free -h
```

#### 2. Appium连接失败
```bash
# 检查设备连接
docker exec jenkins-mobile-test adb devices

# 重启ADB服务
docker exec jenkins-mobile-test adb kill-server && adb start-server
```

#### 3. 权限问题
```bash
# 重新构建容器
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 日志查看
```bash
# 查看容器日志
docker-compose logs -f jenkins

# 查看模拟器日志
docker exec jenkins-mobile-test adb logcat
```

## 📝 Jenkins Pipeline

### 自动化流程
1. **检出代码**: 从Git仓库拉取最新代码
2. **环境设置**: 检查Android SDK和AVD
3. **启动模拟器**: 启动Android虚拟机
4. **安装依赖**: 安装Python包和Appium
5. **运行测试**: 执行Appium测试
6. **生成报告**: 创建HTML和Allure报告
7. **清理环境**: 停止模拟器和Appium

### Pipeline文件
- 位置: `jenkins/Jenkinsfile`
- 支持: 多阶段构建、并行测试、报告生成

## 🛠️ 自定义配置

### 修改Android SDK版本
编辑 `Dockerfile` 中的 `sdkmanager` 命令：
```dockerfile
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    "platforms;android-34" \
    "system-images;android-34;google_apis;x86_64"
```

### 添加新的AVD
```bash
./manage-android-vm.sh create new_device 34
```

### 修改模拟器配置
编辑 `manage-android-vm.sh` 中的启动参数：
```bash
$ANDROID_HOME/emulator/emulator \
    -avd $avd_name \
    -memory 4096 \
    -cores 4 \
    -gpu host
```

## 📚 相关文档

- [Android SDK文档](https://developer.android.com/studio/command-line)
- [Appium文档](http://appium.io/docs/en/about-appium/intro/)
- [Jenkins Pipeline语法](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Allure报告](https://docs.qameta.io/allure/)

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个项目！

## �� 许可证

MIT License 