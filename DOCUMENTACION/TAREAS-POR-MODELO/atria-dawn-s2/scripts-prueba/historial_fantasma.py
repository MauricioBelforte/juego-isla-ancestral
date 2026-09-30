# -*- coding: utf-8 -*-
"""Verifica si los 3 archivos fantasma de M07 existieron alguna vez en git."""
import subprocess

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
NOMBRES = ["thread_pool", "game_state", "voxel_world"]

for n in NOMBRES:
    print("=" * 60)
    print("patron:", n)
    # git log --all --oneline tocando cualquier ruta que contenga el patron
    for flag in ["--all"]:
        try:
            out = subprocess.check_output(
                ["git", "-C", ROOT, "log", flag, "--oneline", "--all",
                 "--name-only", "--format=%h %ad %s", "--date=short",
                 "--", "*" + n + "*"],
                stderr=subprocess.STDOUT).decode("utf-8", "replace")
        except subprocess.CalledProcessError as e:
            out = e.output.decode("utf-8", "replace")
        if out.strip():
            print(out[:1500])
        else:
            print("  (sin commits en toda la historia que toquen *" + n + "*)")
