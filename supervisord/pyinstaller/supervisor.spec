# -*- mode: python ; coding: utf-8 -*-

import sys

sys.path.append(".")

from depends import (
        get_datas,
        get_supervisor,
)
d, ctl = get_supervisor()
print(f"{d=} {ctl=}")

a = Analysis(
    [d, ctl],
    pathex=[],
    binaries=[],
    datas=get_datas(),
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)

print(f"{a.scripts=}")
#sys.exit(1)

pyz = PYZ(a.pure)

exe1 = EXE(
    pyz,
    [script for script in a.scripts if script[1] == str(ctl)],
    [],
    exclude_binaries=True,
    name='supervisorctl',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)

exe2 = EXE(
    pyz,
    [script for script in a.scripts if script[1] == str(d)],
    [],
    exclude_binaries=True,
    name='supervisord',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)

coll = COLLECT(
    exe1, exe2,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='supervisor',
)
