# -*- mode: python ; coding: utf-8 -*-


from pathlib import Path


a = Analysis(
    ['disable-input-device.py'],
    pathex=[],
    binaries=[],
    datas=[("libevdev.so.2", ".")],
    hiddenimports=["libevdev"],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='disable-input-device',
    debug=False,
    bootloader_ignore_signals=False,
    strip=True,
    upx=True,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)


list_event_py = Path("list-event.py")

if list_event_py.exists():

	b = Analysis(
	    [str(list_event_py)],
	    pathex=[],
	    binaries=[],
	    datas=[],
	    hiddenimports=["libevdev"],
	    hookspath=[],
	    hooksconfig={},
	    runtime_hooks=[],
	    excludes=[],
	    noarchive=False,
	    optimize=0,
	)
	pyz2 = PYZ(b.pure)
	
	exe2 = EXE(
	    pyz2,
	    b.scripts,
	    [],
	    exclude_binaries=True,
	    name='list-event',
	    debug=False,
	    bootloader_ignore_signals=False,
	    strip=True,
	    upx=True,
	    console=True,
	    disable_windowed_traceback=False,
	    argv_emulation=False,
	    target_arch=None,
	    codesign_identity=None,
	    entitlements_file=None,
	)

	coll = COLLECT(
	    exe,
	    a.binaries,
	    a.datas,
	    exe2,
	    b.binaries,
	    b.datas,
	    strip=True,
	    upx=True,
	    upx_exclude=[],
	    name='disable-input-device',
	)

else:

	coll = COLLECT(
	    exe,
	    a.binaries,
	    a.datas,
	    strip=True,
	    upx=True,
	    upx_exclude=[],
	    name='disable-input-device',
	)

