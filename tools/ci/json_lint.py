#!/usr/bin/env python3
# M118 iter 10 (minimax-3): Linter de JSONs data-driven.
# Verifica que cada JSON en data/ cumple:
#   - Indentacion consistente (2 espacios)
#   - Sin trailing commas antes de } o ]
#   - UTF-8 sin BOM
#   - Llaves consistentes (todas con comillas dobles)
# Exit 0 si todo OK, 1 si hay errores.
# Uso: python tools/ci/json_lint.py [--data-dir game/isla-ancestral/data]

import os
import sys
import argparse
import json
import re
import glob
from typing import List, Tuple

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def _walk_json_files(data_dir: str) -> List[str]:
    if not os.path.isdir(data_dir):
        return []
    data_dir_norm = data_dir.replace(os.sep, "/")
    return sorted(glob.glob(os.path.join(data_dir_norm, "**", "*.json"), recursive=True))


def _lint_one(path: str) -> List[str]:
    """Devuelve lista de issues (vacia si OK)."""
    issues: List[str] = []
    # Leer como bytes para detectar BOM
    try:
        with open(path, "rb") as f:
            raw = f.read()
    except OSError as e:
        return [f"no se pudo leer: {e}"]
    if raw.startswith(b"\xef\xbb\xbf"):
        issues.append("BOM UTF-8 al inicio (usar UTF-8 sin BOM)")
    # Decodificar
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as e:
        return [f"UTF-8 invalido: {e}"]
    # Verificar que es JSON valido
    try:
        json.loads(text)
    except json.JSONDecodeError as e:
        return [f"JSON invalido: {e}"]
    # Verificar indentacion consistente (2 espacios)
    lines = text.split("\n")
    for i, line in enumerate(lines, 1):
        stripped = line.lstrip(" ")
        indent = len(line) - len(stripped)
        if indent % 2 != 0 and stripped != "":
            issues.append(f"L{i}: indentacion no multiplo de 2 ({indent} espacios)")
    # Verificar trailing commas (simple check: regex que busca ,[\n ]*[\]}])
    trailing = re.findall(r",(\s*[\]}])", text)
    if trailing:
        issues.append(f"trailing comma detectado antes de }} o ] ({len(trailing)} ocurrencias)")
    # Verificar comillas dobles consistentes (no comillas simples en JSON keys)
    for m in re.finditer(r"'(\w+)':", text):
        issues.append(f"comilla simple detectada en key JSON: '{m.group(1)}'")
    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description="Linter de JSONs data-driven")
    parser.add_argument("--data-dir", default=os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data"))
    args = parser.parse_args()
    if not os.path.isdir(args.data_dir):
        print(f"[json_lint] {args.data_dir} no existe")
        return 0
    paths = _walk_json_files(args.data_dir)
    if not paths:
        print(f"[json_lint] no JSONs en {args.data_dir}")
        return 0
    print(f"[json_lint] {len(paths)} JSONs en {args.data_dir}")
    total_issues = 0
    files_with_issues = 0
    for p in paths:
        issues = _lint_one(p)
        if issues:
            files_with_issues += 1
            rel = os.path.relpath(p, PROJECT_ROOT)
            print(f"  [FAIL] {rel}:")
            for i in issues:
                print(f"    - {i}")
            total_issues += len(issues)
    print(f"[json_lint] {total_issues} issues en {files_with_issues} archivos")
    if total_issues == 0:
        print("[json_lint] Todos los JSONs OK.")
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
