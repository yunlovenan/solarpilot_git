
from appium import webdriver
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException


class APPLoginLocator:
    """APP登录页面的元素定位"""
    # #点击Agree按钮
    agree_loc = (AppiumBy.ANDROID_UIAUTOMATOR, "new UiSelector().description(\"Agree\")")
    # 账号输入框
    username_loc = (AppiumBy.ANDROID_UIAUTOMATOR, "new UiSelector().className(\"android.widget.EditText\").instance(0)")
    # 密码输入框
    pwd_loc = (AppiumBy.ANDROID_UIAUTOMATOR, "new UiSelector().className(\"android.widget.EditText\").instance(1)")
    # 服务条款复选框 - 优化的定位策略
    service_loc = (AppiumBy.ANDROID_UIAUTOMATOR, "new UiSelector().textContains(\"I've read and agreed\")")
    # 点击登录按钮
    login_loc = (AppiumBy.ACCESSIBILITY_ID, "Log In")
    # 点击我是服务商
    me_service = (AppiumBy.XPATH, "//android.widget.ImageView[contains(@content-desc, \"I'm a service provider\")]")
    #登录成功验证——Me
    index_loc = (AppiumBy.XPATH, "//android.view.View[contains(@content-desc, 'Me')]")
    