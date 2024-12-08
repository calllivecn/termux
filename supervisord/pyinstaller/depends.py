
import os
from pathlib import Path

import supervisor


# 找到 supervisord supervisorctl
def get_supervisor():
    paths = os.environ["PATH"]

    d_flag = False
    for path in paths.split(os.pathsep):
        d = Path(path) / "supervisord"
        if d.exists():
            #print("找到了:", d)
            d_flag = True
            break


    ctl_flag = False
    for path in paths.split(os.pathsep):
        ctl = Path(path) / "supervisorctl"
        if ctl.exists():
            #print("找到了:", ctl)
            ctl_flag = True
            break

    if d_flag and ctl_flag:
        #return str(d), str(ctl)
        return d, ctl
    else:
        raise ValueError("没有找到supervisord, supervisorctl 脚本。")


def get_datas():
    supervisor_dir = Path(supervisor.__file__).parent

    version_txt = supervisor_dir / "version.txt"
    # 目录结尾不能有"/"吗？
    scripts_dir = supervisor_dir / "scripts"
    skel_dir = supervisor_dir / "skel"
    ui_dir = supervisor_dir / "ui"

    datas = [
    	(version_txt, "supervisor/"),
    	(scripts_dir, "supervisor/scripts/"),
    	(skel_dir, "supervisor/skel/"),
    	(ui_dir, "supervisor/ui/"),
    ]

    return datas


if __name__ == "__main__":
    get_supervisor()
    get_datas()
