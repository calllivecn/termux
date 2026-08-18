

import subprocess
import re

def get_localized_app_label():
    # 获取本地包列表和路径
    cmd = "pm list packages -f"
    try:
        lines = subprocess.check_output(cmd, shell=True).decode('utf-8').splitlines()
    except Exception as e:
        raise e

    for line in lines:
        try:
            pkg_info = line.replace("package:", "")
            apk_path, pkg_name = pkg_info.rsplit('=', 1)

            # 执行 aapt 获取所有 label 信息
            aapt_cmd = f"aapt dump badging {apk_path} 2>/dev/null"
            output = subprocess.check_output(aapt_cmd, shell=True).decode('utf-8')

            # --- 策略解析 ---
            # 1. 尝试匹配简体中文
            label_zh = re.search(r"application-label-zh-CN:'(.*?)'", output)
            # 2. 尝试匹配通用中文
            label_zh_gen = re.search(r"application-label-zh:'(.*?)'", output)
            # 3. 尝试匹配默认名称
            label_default = re.search(r"application-label:'(.*?)'", output)
            # 4. 兜底方案：从 application 标签提取
            label_app = re.search(r"application: label='(.*?)'", output)

            # 按优先级选择
            final_label = "Unknown"
            if label_zh:
                final_label = label_zh.group(1)
            elif label_zh_gen:
                final_label = label_zh_gen.group(1)
            elif label_default:
                final_label = label_default.group(1)
            elif label_app:
                final_label = label_app.group(1)

            print(f"{final_label:<20}|{pkg_name}")

        except:
            continue

if __name__ == "__main__":
    get_localized_app_label()

