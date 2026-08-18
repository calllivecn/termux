#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

# 默认需要捕获并复制的路径前缀
DEFAULT_TARGET_PREFIX = "/data/data/com.termux/files/"

# 匹配 ldd 输出的正则，形如：
#    libssl.so.3 => /data/data/com.termux/files/usr/lib/libssl.so.3 (0x7f...)
#    libcrypto.so.3 => /data/data/com.termux/files/usr/lib/libcrypto.so.3
LDD_LINE_RE = re.compile(r"^\s*(\S+)\s*=>\s*(\S+)(?:\s*\(0x[0-9a-fA-F]+\))?")


def find_so_files(target_dir: Path) -> list[Path]:
    """在指定目录递归查找所有的 *.so* 文件"""
    so_files = []
    for p in target_dir.rglob("*"):
        if p.is_file() and (".so" in p.name):
            so_files.append(p)
    return so_files


def run_ldd_on_file(so_path: Path, internal_dir: Path) -> list[str]:
    """
    对单个 .so 文件执行 ldd 命令，
    注入 LD_LIBRARY_PATH=internal_dir 环境变量，使 ldd 优先匹配已复制到 _internal/ 的库
    """
    env = os.environ.copy()
    internal_abs_path = str(internal_dir.resolve())

    # 将 _internal 路径置于 LD_LIBRARY_PATH 最前列
    original_ld_path = env.get("LD_LIBRARY_PATH", "")
    env["LD_LIBRARY_PATH"] = (
        f"{internal_abs_path}:{original_ld_path}"
        if original_ld_path
        else internal_abs_path
    )

    try:
        result = subprocess.run(
            ["ldd", str(so_path)],
            capture_output=True,
            text=True,
            check=False,
            env=env,
        )
        return result.stdout.splitlines()
    except Exception as e:
        print(f"[!] 执行 ldd 失败 ({so_path}): {e}", file=sys.stderr)
        return []


def parse_ldd_output(
    ldd_lines: list[str], target_prefix: str
) -> dict[str, Path]:
    """解析 ldd 输出，提取满足前缀条件的库名称及其绝对路径"""
    matched_deps = {}
    for line in ldd_lines:
        match = LDD_LINE_RE.search(line)
        if not match:
            continue

        lib_name, real_path_str = match.group(1), match.group(2)

        # 排除 invalid / not found 的依赖
        if not real_path_str.startswith("/"):
            continue

        # 检查右侧路径是否属于目标目录前缀 (如 Termux 路径)
        if real_path_str.startswith(target_prefix):
            real_path = Path(real_path_str).resolve()
            if real_path.exists():
                matched_deps[lib_name] = real_path
            else:
                print(
                    f"[!] 警告: 依赖文件不存在 -> {real_path}", file=sys.stderr
                )

    return matched_deps


def copy_dep_file(
    lib_name: str, src_path: Path, dest_dir: Path, dry_run: bool
) -> int:
    """
    复制依赖文件到 _internal/ 目录。
    同时确保 lib_name (如 libssl.so.3) 和 src_path.name (如 libssl.so.3.0.0) 均存在。
    """
    copied_count = 0
    # 集合去重，处理需要确保存在的所有文件名
    target_names = {lib_name, src_path.name}

    for name in target_names:
        target_path = dest_dir / name

        # 文件已存在且大小一致则跳过
        if target_path.exists() and target_path.is_file():
            if target_path.stat().st_size == src_path.stat().st_size:
                continue

        print(f" -> 补全动态库文件: {name}")
        print(f"    来源: {src_path}")
        print(f"    目标: {target_path}")

        if not dry_run:
            shutil.copy2(src_path, target_path)
            os.chmod(target_path, 0o644)

        copied_count += 1

    return copied_count


def get_internal_dir(check_dir: Path) -> Path:
    """确定最终存放 .so 的 _internal 目标路径"""
    if check_dir.name == "_internal":
        return check_dir

    internal_dir = check_dir / "_internal"
    if not internal_dir.exists():
        internal_dir.mkdir(parents=True, exist_ok=True)

    return internal_dir


def main():
    parser = argparse.ArgumentParser(
        description="自动扫描并补全 PyInstaller 打包目录中缺失的动态链接库 (.so)"
    )
    parser.add_argument(
        "-d",
        "--check-dir",
        type=Path,
        required=True,
        help="PyInstaller 打包生成的目录路径 (例如 dist/app 或 dist/app/_internal)",
    )
    parser.add_argument(
        "-p",
        "--prefix",
        type=str,
        default=DEFAULT_TARGET_PREFIX,
        help=f"需要捕获的共享库路径前缀 (默认: {DEFAULT_TARGET_PREFIX})",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="仅演练显示需要复制的文件，不执行实际复制操作",
    )

    args = parser.parse_args()

    check_dir: Path = args.check_dir.resolve()
    target_prefix: str = args.prefix
    dry_run: bool = args.dry_run

    if not check_dir.exists():
        print(f"[E] 指定的目录不存在: {check_dir}", file=sys.stderr)
        sys.exit(1)

    dest_dir = get_internal_dir(check_dir)
    print(f"[*] 检查目录: {check_dir}")
    print(f"[*] 目标复制目录: {dest_dir}")
    print(f"[*] 过滤路径前缀: {target_prefix}")
    if dry_run:
        print("[*] 提示: 正在运行于 Dry-Run 模式（不进行实际复制操作）")

    print("-" * 60)

    copied_total = 0
    iteration = 1

    # 多轮增量扫描，确保递归依赖完全收敛
    while True:
        print(f"\n[+] 第 {iteration} 轮扫描分析中...")
        all_so_files = find_so_files(check_dir)
        new_copies_in_this_round = 0

        deps_to_copy: dict[str, Path] = {}
        for so_file in all_so_files:
            # 关键修改：将 dest_dir 传入，以便在执行 ldd 时注入 LD_LIBRARY_PATH
            ldd_lines = run_ldd_on_file(so_file, dest_dir)
            matched = parse_ldd_output(ldd_lines, target_prefix)
            deps_to_copy.update(matched)

        # 执行复制
        for lib_name, src_path in deps_to_copy.items():
            copies = copy_dep_file(lib_name, src_path, dest_dir, dry_run)
            if copies > 0:
                new_copies_in_this_round += 1
                copied_total += copies

        print(f"[+] 本轮新补充文件/链接数: {new_copies_in_this_round}")

        # 若本轮未产生任何新的补全文件，说明依赖已经全部补齐，退出循环
        if new_copies_in_this_round == 0:
            break

        iteration += 1

    print("\n" + "=" * 60)
    print(f"[✓] 处理完成！共成功补全 {copied_total} 项动态库到 {dest_dir}")


if __name__ == "__main__":
    main()

