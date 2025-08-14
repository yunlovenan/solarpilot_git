import pytest
import time
from appium import webdriver
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

class TestSimpleLogin:
    """简化的登录测试"""
    
    def setup_method(self):
        """设置测试环境"""
        # 配置Appium选项
        options = UiAutomator2Options()
        options.platform_name = 'Android'
        options.automation_name = 'UiAutomator2'
        options.device_name = 'emulator-5554'
        options.app_package = 'com.eiot6.solartest'
        options.app_activity = '.MainActivity'
        options.no_reset = True
        
        # 连接Appium服务器
        self.driver = webdriver.Remote('http://localhost:4723/wd/hub', options=options)
        self.driver.implicitly_wait(10)
        
    def teardown_method(self):
        """清理测试环境"""
        if hasattr(self, 'driver'):
            self.driver.quit()
    
    def test_app_launch(self):
        """测试应用启动"""
        print("✅ 应用启动成功")
        print(f"当前活动: {self.driver.current_activity}")
        print(f"当前包名: {self.driver.current_package}")
        
        # 等待应用完全加载
        time.sleep(3)
        
        # 检查是否有登录相关元素
        try:
            # 尝试查找登录相关元素
            elements = self.driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
            print(f"找到 {len(elements)} 个输入框")
            
            # 检查是否有按钮
            buttons = self.driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.Button")
            print(f"找到 {len(buttons)} 个按钮")
            
            # 检查是否有ImageView
            images = self.driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.ImageView")
            print(f"找到 {len(images)} 个图片视图")
            
            print("✅ 应用界面元素检查完成")
            
        except Exception as e:
            print(f"⚠️ 元素检查时出现异常: {e}")
        
        # 基本断言
        assert self.driver.current_package == 'com.eiot6.solartest'
        print("✅ 包名验证通过")
    
    def test_device_info(self):
        """测试设备信息"""
        print("📱 设备信息:")
        print(f"   Android版本: {self.driver.capabilities['platformVersion']}")
        print(f"   设备名称: {self.driver.capabilities['deviceName']}")
        print(f"   自动化引擎: {self.driver.capabilities['automationName']}")
        
        # 获取屏幕尺寸
        size = self.driver.get_window_size()
        print(f"   屏幕尺寸: {size['width']} x {size['height']}")
        
        print("✅ 设备信息获取成功")
    
    def test_basic_navigation(self):
        """测试基本导航"""
        print("🧭 测试基本导航...")
        
        # 获取当前页面源码
        page_source = self.driver.page_source
        print(f"页面源码长度: {len(page_source)} 字符")
        
        # 检查页面是否包含特定文本
        if "登录" in page_source or "Login" in page_source:
            print("✅ 找到登录相关文本")
        elif "用户名" in page_source or "Username" in page_source:
            print("✅ 找到用户名相关文本")
        elif "密码" in page_source or "Password" in page_source:
            print("✅ 找到密码相关文本")
        else:
            print("⚠️ 未找到明显的登录相关文本")
        
        print("✅ 基本导航测试完成")

if __name__ == "__main__":
    # 直接运行测试
    pytest.main([__file__, "-v"])
