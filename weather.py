#!/usr/bin/env python3
# coding=utf-8
# date 2019-12-03 09:28:27
# author calllivecn <c-all@qq.com>


import time
import json
import pprint
import urllib
from urllib import request

潜江=101201701
武汉=101200101
深圳=101280601



class Weather:
    """
    none
    """

    URL="http://t.weather.sojson.com/api/weather/city/"

    def __init__(self, cityId):

        self._cityId = cityId
    
        self.__weather()

    def __weather(self):

        url = self.URL + "/" + str(self._cityId)

        req = request.Request(url)

        req.add_header("User-Agent", "Personal use. If you send an email, please put the word Weather-zx in the subject. E-mail: c-all@qq.com")
    
        jd = request.urlopen(req).read().decode()
    
        jd = json.loads(jd)

        if jd["status"] != 200:
            raise Exception(f"请求出错：status: {jd.status} message: {jd.message}")
    
        self.jd = jd

        self.cityinfo = self.jd["cityInfo"]

        self._data = self.jd["data"]

        self.updatetime = time.strptime(self.jd["time"], "%Y-%m-%d %H:%M:%S")

        self.air = {}
        self.air["wendu"] = self._data["wendu"]
        self.air["shidu"] = self._data["shidu"]
        self.air["pm25"] = self._data["pm25"]
        self.air["pm10"] = self._data["pm10"]

        self.air["quality"] = self._data["quality"]

        self.yesterday = self._data["yesterday"]

        self.forecast = self._data["forecast"]

    
    def __str__(self):
        return json.dumps(self.jd, ensure_ascii=False, indent=4)

    def update(self):
        self.__weather()

    def savefile(self, filename):
        with open("filename", "w") as f:
           f.write(json.dumps(jd, ensure_ascii=False, indent=4))

    def show(self, days=3):
        print(f'地区：{self.cityinfo["parent"]} {self.cityinfo["city"]}')
        print(f'更新时间：{self.jd["time"]}')
        print(f'当前温度:{self.air["wendu"]}℃  湿度:{self.air["shidu"]} PM2.5:{self.air["pm25"]} PM10:{self.air["pm10"]} 空气:{self.air["quality"]}')
        print("#"*40)
        
        for fc in self.forecast:
            print(f'日期：{fc["ymd"]} {fc["week"]} 空气:{fc["type"]}\n'
            f'最{fc["high"]}  最{fc["low"]}\n'
            f'风速:{fc["fl"]} 风向:{fc["fx"]}\n'
            f'日出 {fc["sunrise"]} 日落 {fc["sunset"]}\n'
            f'{fc["notice"]}'
            )

            print("-"*40)

            days -= 1
            if days == 0:
                break


shenzhen = Weather(深圳)

shenzhen.show()
