

from typing import (
    Tuple,
    List,
    TypeVar,
    Any,
    Optional,
)


import time
import enum
import subprocess
from io import BytesIO
from pathlib import Path

import numpy as np
import cv2

# CV2IMG = TypeVar("T")
CV2IMG = Any

class KeyEvent(enum.IntEnum):


    HOME = 3

    # 返回键
    BACK = 4

    # 电源键
    POWER = 26

    # 224: 键码常量：唤醒键。唤醒设备。行为有点像 KEYCODE_POWER 但如果设备已经唤醒则没有任何效果。
    WAKEUP = 224



class AdbCmd:
    """
    通过 adb 执行，
    或者 直接在手机上通过root执行。 
    """

    def __init__(self, adb=Optional[str], serial=Optional[str]):
        """
        在adb 情况下，有多个设备时，可以指定serial
        """

        self.input_prefix = ["input"]

        self.screenshot = ["screencap", "-p"]

        if adb is not None:
            if serial is not None:
                self.screenshot = [adb, "-s", serial, "shell"] + self.screenshot
                self.input_prefix = [adb, "-s", serial, "shell"] + self.input_prefix

            self.screenshot = [adb, "shell"] + self.screenshot
            self.input_prefix = [adb, "shell"] + self.input_prefix
        

        self.interval = 1

    def get_screen(self) -> CV2IMG:
        p = subprocess.run(self.screenshot, stdout=subprocess.PIPE, check=True)

        with BytesIO(p.stdout) as img_stream:
            img = cv2.imdecode(np.frombuffer(img_stream.read(), np.uint8), cv2.IMREAD_COLOR)

        return img

    
    def click(self, x: int, y: int):
        """
        屏幕点击
        """
        subprocess.run(self.input_prefix + ["tap", str(x), str(y)], check=True)
        self.sleep(self.interval)
    
    def keyevent(self, code: KeyEvent):
        subprocess.run(self.input_prefix + ["keyevent", str(code.value)], check=True)
        self.sleep(self.interval)

    def swipe(self, x1, y1, x2, y2):
        subprocess.run(self.input_prefix + ["swipe", str(x1), str(y1), str(x2), str(y2)], check=True)
        self.sleep(self.interval)
    
    def text(self, text: str):
        subprocess.run(self.input_prefix + ["text", text], check=True)
        self.sleep(self.interval)


    def sleep(self, s):
        time.sleep(s)
    

# cmd = AdbCmd()
# test ok
# cv2.imwrite("/tmp/test-01.png", cmd.get_screen())


class MatchTemplate:

    def __init__(self, template: Path, threshold=0.7):

        self.template = cv2.imread(str(template))

        self.template_gray = cv2.cvtColor(self.template, cv2.COLOR_BGR2GRAY)

        self.temp_w, self.temp_h = self.template.shape[1], self.template.shape[0]

        self.threshold = threshold



    def search_picture(self, target: CV2IMG):

        target_gray = cv2.cvtColor(target, cv2.COLOR_BGR2GRAY)

        result = cv2.matchTemplate(target_gray, self.template_gray, cv2.TM_CCOEFF_NORMED)

        loc = np.where(result >= self.threshold)
        # loc: (y: array([...], dtype=int64), x: array([...], dtype=int64))

        if len(loc[0]) > 1:
            dedup_loc = self.__deduplication(loc, temp_size=(self.temp_w, self.temp_h))
            return dedup_loc
        else:
            return loc
    

    def location(self, target: CV2IMG) -> List[Tuple[int, int]]:
        """
        返回找到的模板的左上角相对于target的坐标
        """

        loc = self.search_picture(target)

        locations = []
        for x, y in zip(*loc[::-1]):
            locations.append((x, y))
        
        return locations


    def location_one(self, target: CV2IMG) -> Tuple[int, int]:
        """
        如果只找到一匹配对象，就返回这个对象的 左上角 在target中的坐标。
        如果，找到多个匹配对象，报错。
        """
        loc = self.location_center(target)
        
        if  0 == len(loc):
            return []

        elif 1 == len(loc):
            return loc[0]

        else:
            raise ValueError("找到多个匹配对象.")
        


    def location_center(self, target: CV2IMG) -> List[Tuple[int, int]]:
        """
        返回找到的模板的中心相对于target的坐标
        """
        loc = self.search_picture(target)

        locations = []
        w2, h2 = self.temp_w//2, self.temp_h//2
        for x, y in zip(*loc[::-1]):
            locations.append((x + w2, y + h2))
        
        return locations
    

    def location_one_center(self, target: CV2IMG) -> Tuple[int, int]:
        """
        如果只找到一匹配对象，就返回这个对象的中心在target中的坐标。
        如果，找到多个匹配对象，报错。
        """
        loc = self.location_center(target)
        
        if  0 == len(loc):
            return ()
            
        elif 1 == len(loc):
            return loc[0]
        
        else:
            raise ValueError("找到多个匹配对象.")


    def draw_loction(self, target: CV2IMG, loc: Tuple[np.ndarray, np.ndarray]):
        draw_target = target.copy()
        # 使用灰度图像中的坐标对原始RGB图像进行标记(把找到的位置用矩形框出来)
        for x, y in zip(*loc[::-1]):
            cv2.rectangle(draw_target, (x, y), (x + self.temp_w, y + self.temp_h), color=(7, 249, 151), thickness=1)
        
        return draw_target


    def __deduplication(self, loc, temp_size: CV2IMG):
        """
        找出位置后，还需要去除重复的位置，因为步长是1个像素，所以可能会重复。
        拿到第一个位置，只要接下来的位置在（w+temp_w, h+temp_h）这个范围内就说明是重复的。
        """

        loc_dedup_x = [loc[1][0]]
        loc_dedup_y = [loc[0][0]]

        # print(f"{loc_dedup_x=} {loc_dedup_y=}")
        for x, y in zip(*loc[::-1]):
            if (x - loc_dedup_x[-1]) <= temp_size[0] and (y - loc_dedup_y[-1]) <= temp_size[1]:
                pass
            else:

                loc_dedup_x.append(x)
                loc_dedup_y.append(y)

        return (loc_dedup_y, loc_dedup_x)





class Workflow:
    """
    1. 启动时加载所有模板
    2. 抽象操作流程为：operate(), MatchTemplate(), waitMatchTemplate()
    3. 类的使用：
        1. 加载(建议)当前任务需要用到的所有模板图片。
        2. 以operate() 或 MatchTemplate() 开始。
        3.  wait interval, wait timeout
    """

    # def __init__(self, temps_dir: Path = Path("temps")):
    def __init__(self, adbcmd: Optional[AdbCmd] = None):
        self._temps = {}

        # self._temps_dir = temps_dir


        self.operate_inteval = 1

        self.timeout = 60

        if adbcmd is None:
            self.adb = AdbCmd()
        else:
            self.adb = adbcmd


    def add_template(self, png: Path):
        self._temps[png.name] = MatchTemplate(png)
    

    def click(self, x: int, y: int):
        """
        执行点击操作
        """
        self.adb.click(x, y)
    

    def wait_template(self, MT: MatchTemplate) -> Tuple[int, int]:

        start = end = time.time()

        while True:
            target = MT.location_one_center(self.adb.get_screen())
            if target != ():
                return target

            if (end - start) > self.timeout:
                raise TimeoutError("没有等到目标出现")

            self.__interval()

            end = time.time()
    

    def wait_click(self, MT: MatchTemplate):

        location = self.wait_template(MT)
        self.__interval()
        self.adb.click(*location)
    

    def __interval(self):
        time.sleep(self.operate_inteval)
    

        



