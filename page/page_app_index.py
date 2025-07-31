
from common.base_page import BasePage
from locator.locator_app_login import APPLoginLocator as app_loc


class APPIndexPage(BasePage):
    """登录成功验证Me"""

    def get_me_info(self):
        """获取Me信息"""
        try:
            self.get_element(app_loc.index_loc, 'Me')
        except: # 如果找不到元素，则返回登录失败
            return '登录失败'
        else:
            return '登录成功'

   



    

