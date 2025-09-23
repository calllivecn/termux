#!/usr/bin/env python3
# vibrate_example.py
# 需要 pyjnius 已安装
# 用法: python vibrate_example.py

from jnius import autoclass, JavaException
import time

def get_application():
    """
    通过 ActivityThread.currentApplication() 获取 Application（Context）。
    Termux 进程通常可以通过这个方法拿到 Context。
    """
    ActivityThread = autoclass('android.app.ActivityThread')
    app = ActivityThread.currentApplication()
    if app is None:
        raise RuntimeError("无法获取 Application（ActivityThread.currentApplication() 返回 None）。")
    return app

def get_vibrator(app):
    Context = autoclass('android.content.Context')
    vib = app.getSystemService(Context.VIBRATOR_SERVICE)
    if vib is None:
        raise RuntimeError("无法获得 Vibrator 服务（getSystemService 返回 None）。")
    return vib

def sdk_int():
    VERSION = autoclass('android.os.Build$VERSION')
    return int(VERSION.SDK_INT)

def vibrate_once(ms=500):
    """
    单次振动 ms 毫秒
    """
    app = get_application()
    vib = get_vibrator(app)
    try:
        if sdk_int() >= 26:
            # Android O+ 使用 VibrationEffect
            VibrationEffect = autoclass('android.os.VibrationEffect')
            effect = VibrationEffect.createOneShot(int(ms), VibrationEffect.DEFAULT_AMPLITUDE)
            vib.vibrate(effect)
        else:
            # 旧 API
            vib.vibrate(int(ms))
    except JavaException as e:
        # 兜底尝试旧调用
        try:
            vib.vibrate(int(ms))
        except Exception as e2:
            raise RuntimeError("振动调用失败: %s / %s" % (e, e2))

def vibrate_pattern(pattern_ms, repeat=-1):
    """
    pattern_ms: Python 列表，例如 [0, 200, 100, 300]
      - 第一个元素为延迟（ms），接着是 振动/暂停/振动/暂停...
    repeat: 重复索引，-1 表示不重复
    """
    app = get_application()
    vib = get_vibrator(app)
    try:
        if sdk_int() >= 26:
            VibrationEffect = autoclass('android.os.VibrationEffect')
            # 直接传 Python list 给 createWaveform（pyjnius 通常会做转换）
            effect = VibrationEffect.createWaveform(pattern_ms, int(repeat))
            vib.vibrate(effect)
        else:
            # 旧 API 接受 long[] pattern, int repeat
            vib.vibrate(pattern_ms, int(repeat))
    except JavaException as e:
        # 有些环境下 pyjnius 对数组转换失败，尝试旧调用（若旧调用也不可用则抛错）
        try:
            vib.vibrate(pattern_ms, int(repeat))
        except Exception as e2:
            raise RuntimeError("振动波形调用失败: %s / %s" % (e, e2))

def cancel_vibration():
    app = get_application()
    vib = get_vibrator(app)
    try:
        vib.cancel()
    except Exception as e:
        # 部分实现可能没有 cancel，忽略
        print("取消振动时发生异常（可忽略）:", e)

if __name__ == '__main__':
    print("SDK_INT =", sdk_int())
    print("单次振动 500ms")
    vibrate_once(500)
    time.sleep(1)

    print("波形振动示例: [0, 200, 100, 300] -> 等待0ms, 振动200ms, 等待100ms, 振动300ms")
    pattern = [0, 200, 100, 300]
    vibrate_pattern(pattern, repeat=-1)  # repeat=-1 不重复
    time.sleep(5)

    print("取消振动")
    cancel_vibration()
    print("done")

