

import subprocess
from io import BytesIO

import numpy as np
import cv2

def get_screen(adb_shell=False):
    p = subprocess.run("adb -P 16666 shell screencap -p".split(), stdout=subprocess.PIPE)

    # 将数据转换为字节流
    img_stream = BytesIO(p.stdout)

    # 使用 OpenCV 读取图像数据并将其转换为 numpy 数组
    img = cv2.imdecode(np.frombuffer(img_stream.read(), np.uint8), cv2.IMREAD_COLOR)

    # 测试过了这样可以
    #cv2.imwrite("Image.png", img)

    return img



# 假设您已经从标准输出中获取了图像数据并将其存储在变量 stdout_data 中
#with open("t.png", "rb") as f:
	#stdout_data = f.read()

img = get_screen()



