
import time

from jnius import autoclass

def vibrate_phone(duration_ms):
    """使用 Android Vibrator 服务振动设备指定时长"""
    try:
        Vibrator = autoclass('android.os.Vibrator')
        context = autoclass('org.kivy.android.PythonActivity').mActivity
        vibrator_service = context.getSystemService(context.VIBRATOR_SERVICE)

        if Vibrator.VERSION.SDK_INT >= 26:  # Android 8.0 (Oreo) 及以上
            vibrator_service.vibrate(duration_ms) # 新的 vibrate(Duration) 方法 (API 26+)
        else:
            vibrator_service.vibrate(duration_ms) # 旧的 vibrate(long milliseconds) 方法

    except Exception as e:
        print(f"振动失败: {e}")

if __name__ == "__main__":
    vibration_duration = 2000  # 振动时长 2000 毫秒 (2 秒)
    print(f"开始振动 {vibration_duration} 毫秒...")
    vibrate_phone(vibration_duration)
    time.sleep(vibration_duration / 1000 + 1) #  等待振动结束 (多等待 1 秒)
    print("振动结束。")

