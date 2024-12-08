
import supervisor
from pathlib import Path

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

