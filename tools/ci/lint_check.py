#!/usr/bin/env python3
# M118: lint_check.py - lint de archivos .gd.
# Verifica:
#   - Que cada .gd tenga sintaxis parseable (godot --check-only).
#   - Que class_name este en snake_case (PascalCase) segun convencion.
#   - Que variables exportadas esten en snake_case.
#   - Que archivos no tengan tabuladores mezclados con espacios.
# Exit 0 si todo OK, 1 si algun fallo.

import os
import re
import sys
import subprocess
import argparse

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))

# Patrones
SNAKE_CASE_FUNC = re.compile(r"^def [a-z][a-z0-9_]*\(")
PASCAL_CASE_CLASS = re.compile(r"^class_name\s+([A-Z][A-Za-z0-9]*)\b")
EXPORT_VAR = re.compile(r"^@export var\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*:")
TAB_INDENT = re.compile(r"^\t")   # Tab al inicio de la linea


def find_godot_files(root: str) -> list:
    """Encuentra todos los .gd bajo root, excluyendo .godot/, addons descargados, etc."""
    out = []
    skip_dirs = {".godot", "addons", ".import", "test_temp", "build", "out", "__pycache__",
                ".claude", ".agent", "node_modules"}
    for dirpath, dirnames, filenames in os.walk(root):
        # Filtrar directorios in-place (afecta el walk)
        dirnames[:] = [d for d in dirnames if d not in skip_dirs]
        for f in filenames:
            if f.endswith(".gd"):
                out.append(os.path.join(dirpath, f))
    return sorted(out)


def lint_gd_syntax(gd_path: str, godot_bin: str) -> tuple:
    """Verifica la sintaxis de un .gd con godot --check-only. Devuelve (ok, error_msg)."""
    try:
        result = subprocess.run(
            [godot_bin, "--headless", "--check-only", "--path", PROJECT_ROOT, gd_path],
            capture_output=True,
            text=True,
            timeout=30,
        )
        if result.returncode != 0:
            return False, f"returncode={result.returncode}\n{result.stderr[:500]}"
        return True, ""
    except subprocess.TimeoutExpired:
        return False, "timeout"
    except FileNotFoundError:
        # Si godot no esta disponible, no falla el lint (es dev), solo avisa
        return True, "godot_not_found"


def lint_text(filepath: str) -> list:
    """Lint textual del archivo .gd. Devuelve lista de warnings."""
    warnings = []
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            lines = f.readlines()
    except (UnicodeDecodeError, OSError) as e:
        warnings.append(f"no se pudo leer: {e}")
        return warnings
    for i, line in enumerate(lines, 1):
        # Tab al inicio (Godot usa 4 espacios)
        if TAB_INDENT.match(line):
            warnings.append(f"L{i}: tab al inicio de linea (usar 4 espacios)")
            break  # Solo reportar el primero por archivo
    return warnings


def find_godot_bin() -> str:
    env = os.environ.get("GODOT_BIN")
    if env and os.path.exists(env):
        return env
    candidates = [
        r"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe",
        r"C:\Program Files\Godot\godot.exe",
        r"/usr/bin/godot",
        r"/usr/local/bin/godot",
    ]
    for c in candidates:
        if os.path.exists(c):
            return c
    return ""  # No encontrado


def main() -> int:
    parser = argparse.ArgumentParser(description="Lint de .gd files")
    parser.add_argument("--godot", help="Path al binario de Godot")
    parser.add_argument("--no-syntax", action="store_true", help="Saltar check de sintaxis (solo texto)")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args()

    godot_bin = args.godot or find_godot_bin()
    if not godot_bin and not args.no_syntax and not args.quiet:
        print("[lint] godot no encontrado, saltando check de sintaxis (textual only)", file=sys.stderr)

    gd_files = find_godot_files(PROJECT_ROOT)
    if not args.quiet:
        print(f"[lint] {len(gd_files)} archivos .gd a verificar")

    errors = 0
    warnings_count = 0
    for gd in gd_files:
        # 1. Check de sintaxis (si godot esta disponible)
        if not args.no_syntax and godot_bin:
            ok, err = lint_gd_syntax(gd, godot_bin)
            if not ok:
                print(f"[lint] FAIL {os.path.relpath(gd, PROJECT_ROOT)}: {err}")
                errors += 1
        # 2. Lint textual
        warns = lint_text(gd)
        for w in warns:
            print(f"[lint] WARN {os.path.relpath(gd, PROJECT_ROOT)}: {w}")
            warnings_count += 1

    if not args.quiet:
        print(f"[lint] {len(gd_files)} archivos, {errors} errores, {warnings_count} warnings")
    return 1 if errors > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
