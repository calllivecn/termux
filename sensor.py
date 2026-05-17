import subprocess
import json
import time
import sys

class TermuxSensorHub:
    def __init__(self, sensor_map=None, delay=1000):
        self.sensor_map = sensor_map or {}
        self.delay = delay
        self.process = None
        self.decoder = json.JSONDecoder()
        self.buffer = ""

    def _start_process(self):
        self._stop_process()
        if not self.sensor_map: return

        sensors_str = ",".join(self.sensor_map.keys())
        cmd = ["termux-sensor", "-s", sensors_str, "-d", str(self.delay)]
        
        # 关键改进：增加 bufsize=1 (行缓冲)，方便实时读取
        self.process = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1
        )
        print(f"\n[*] 进程已启动: {sensors_str} ({self.delay}ms)")

    def _stop_process(self):
        if self.process:
            print("[*] 正在停止旧进程...")
            self.process.terminate()
            try:
                self.process.wait(timeout=2) # 等待退出
            except subprocess.TimeoutExpired:
                self.process.kill() # 强杀
            self.process = None
        subprocess.run(["termux-sensor", "-c"], stderr=subprocess.DEVNULL)

    def update_config(self, new_map=None, new_delay=None):
        self.sensor_map = new_map if new_map is not None else self.sensor_map
        self.delay = new_delay if new_delay is not None else self.delay
        self._start_process()
        self.buffer = "" # 清空旧缓冲区，防止残留数据干扰解析

    def stream(self):
        if not self.process:
            self._start_process()

        while True:
            # 关键：如果进程被 update_config 重置了，我们需要感知并继续
            if not self.process:
                time.sleep(0.1)
                continue

            # 使用 readline 配合 JSONDecoder 通常在 Termux 环境下更稳定
            line = self.process.stdout.readline()
            if not line:
                # 如果读取不到内容且进程已退出，说明需要重启或等待
                if self.process and self.process.poll() is not None:
                    time.sleep(0.1)
                continue

            self.buffer += line.strip()
            
            # 尝试从缓冲区解析
            while self.buffer:
                try:
                    obj, index = self.decoder.raw_decode(self.buffer)
                    self.buffer = self.buffer[index:].strip()
                    
                    # 映射名称
                    result = {self.sensor_map.get(k, k): v for k, v in obj.items()}
                    yield result
                except json.JSONDecodeError:
                    # 数据没传完，跳出等待下一行
                    break

    def close(self):
        self._stop_process()

# --- 测试逻辑 ---
if __name__ == "__main__":
    # 使用你之前的传感器名称
    s0 = {"TMD3719ALSPRX Ambient Light Sensor Non-wakeup": "亮度"}
    s1 = {"TMD3719ALSPRX Ambient Light Sensor Non-wakeup": "亮度", "linear_acceleration": "加速度"}
    s2 = {"TMD3719ALSPRX Ambient Light Sensor Non-wakeup": "亮度", "linear_acceleration": "加速度", "Elliptic Proximity": "距离"}

    hub = TermuxSensorHub(s0, delay=1000)
    try:
        count = 0
        for data in hub.stream():
            count += 1
            # 原地刷新，防止刷屏
            print(f"[#{count}] {data}")

            if count == 5:
                hub.update_config(new_map=s1, new_delay=500)
            if count == 15:
                hub.update_config(new_map=s2, new_delay=200)

    except KeyboardInterrupt:
        print("\n用户退出")
    finally:
        hub.close()
