

from typing import (
    Tuple,
    List,
)


import subprocess
from io import BytesIO
from pathlib import Path

import numpy as np
import cv2

class AdbCmd:

    def __init__(self, adb=Path("adb")):

        self.input_prefix = ["input"]

        self.screenshot = ["screencap", "-p"]

        if adb is not None:
            self.screenshot = [adb, "shell"] + self.screenshot

            self.input_prefix = [adb] + self.input_prefix


    def get_screen(self):
        p = subprocess.run(self.screenshot, stdout=subprocess.PIPE, check=True)

        img_stream = BytesIO(p.stdout)

        img = cv2.imdecode(np.frombuffer(img_stream.read(), np.uint8), cv2.IMREAD_COLOR)

        img_stream.close()

        return img


    
    def click(self, x: int, y: int):
        """
        屏幕点击
        """
        subprocess.run(self.input_prefix + ["tap", str(x), str(y)], check=True)
    

# cmd = AdbCmd()
# test ok
# cv2.imwrite("/tmp/test-01.png", cmd.get_screen())


class MatchTemplate:

    def __init__(self, template, threshold=0.7):

        self.template = template

        self.temp_w, self.temp_h = template.shape[1], template.shape[0]

        self.threshold = threshold



    def search_picture(self, target):

        result = cv2.matchTemplate(target, self.template, cv2.TM_CCOEFF_NORMED)

        loc = np.where(result >= self.threshold)
        # loc: (y: array([...]), x: array[...])

        dedup_loc = self.__deduplication(loc, temp_size=(self.temp_w, self.temp_h))
        # self.__draw_loction(target, temp_w, temp_h, dedup_loc)
    
        return dedup_loc
    

    def location(self, target) -> List[Tuple[int, int]]:
        """
        返回找到的模板的左上角相对于target的坐标
        """

        loc = self.search_picture(target)

        locations = []
        for x, y in zip(*loc[::-1]):
            locations.append((x, y))
        
        return locations


    def location_center(self, target) -> List[Tuple[int, int]]:
        """
        返回找到的模板的中心相对于target的坐标
        """
        loc = self.search_picture(target)

        locations = []
        w2, h2 = self.temp_w//2, self.temp_h//2
        for x, y in zip(*loc[::-1]):
            locations.append((x + w2, y + h2))
        
        return locations
    

    def location_one_center(self, target) -> Tuple[int, int]:
        """
        如果只找到一匹配对象，就返回这个对象的中心在target中的坐标。
        如果，找到多个匹配对象，报错。
        """
        loc = self.location_center(target)
        
        if  0 != len(loc) or 1 != len(loc):
            raise ValueError("找到多个匹配对象.")
        
        return loc[0]


    def draw_loction(self, target, loc):
        draw_target = target.copy()
        # 使用灰度图像中的坐标对原始RGB图像进行标记(把找到的位置用矩形框出来)
        for x, y in zip(*loc[::-1]):
            cv2.rectangle(draw_target, (x, y), (x + self.temp_w, y + self.temp_h), color=(7, 249, 151), thickness=1)
        
        return draw_target


    def __deduplication(self, loc, temp_size):
        """
        找出位置后，还需要去除重复的位置，因为步长是1个像素，所以可能会重复。
        拿到第一个位置，只要接下来的位置在（w+temp_w, h+temp_h）这个范围内就说明是重复的。
        """

        loc_dedup_x = [loc[1][0]]
        loc_dedup_y = [loc[0][0]]

        print(f"{loc_dedup_x=} {loc_dedup_y=}")
        for x, y in zip(*loc[::-1]):
            if (x - loc_dedup_x[-1]) <= temp_size[0] and (y - loc_dedup_y[-1]) <= temp_size[1]:
                pass
            else:

                loc_dedup_x.append(x)
                loc_dedup_y.append(y)

        return (loc_dedup_y, loc_dedup_x)



