#!/usr/bin/env python3
# M118 iter 10 (minimax-3): Diff legible entre dos JSONs.
# Muestra cambios con flechas +/- y colores (en terminal) para diffs
# de archivos data-driven durante PRs.
# Uso: python tools/ci/json_diff.py <archivo1.json> <archivo2.json>

import os
import sys
import argparse
import json
import re
from typing import List, Tuple, Dict, Any

# ANSI color codes (desactivados si no es terminal)
def _supports_color():
    return sys.stdout.isatty() and os.environ.get("TERM", "") != "dumb"


class _Colors:
    def __init__(self):
        if _supports_color():
            self.GREEN = "\033[32m"
            self.RED = "\033[31m"
            self.YELLOW = "\033[33m"
            self.CYAN = "\033[36m"
            self.RESET = "\033[0m"
        else:
            self.GREEN = self.RED = self.YELLOW = self.CYAN = self.RESET = ""


COLORS = _Colors()


def _serialize(obj, indent: int = 0) -> str:
    """Serializa un dict/list en formato legible (una linea por nivel)."""
    pad = "  " * indent
    if isinstance(obj, dict):
        if not obj:
            return "{}"
        lines = ["{"]
        items = list(obj.items())
        for i, (k, v) in enumerate(items):
            comma = "," if i < len(items) - 1 else ""
            v_repr = _serialize(v, indent + 1)
            lines.append(f"{pad}  {json.dumps(k, ensure_ascii=False)}: {v_repr}{comma}")
        lines.append(f"{pad}}}")
        return "\n".join(lines)
    elif isinstance(obj, list):
        if not obj:
            return "[]"
        lines = ["["]
        for i, v in enumerate(obj):
            comma = "," if i < len(obj) - 1 else ""
            v_repr = _serialize(v, indent + 1)
            lines.append(f"{pad}  {v_repr}{comma}")
        lines.append(f"{pad}]")
        return "\n".join(lines)
    else:
        return json.dumps(obj, ensure_ascii=False)


def diff(left: dict, right: dict, path: str = "") -> List[str]:
    """Recursivo: devuelve lista de lineas con diferencias."""
    lines: List[str] = []
    if isinstance(left, dict) and isinstance(right, dict):
        all_keys = set(left.keys()) | set(right.keys())
        for k in sorted(all_keys):
            sub = f"{path}.{k}" if path else k
            if k not in left:
                v_repr = _serialize(right[k])
                lines.append(f"{COLORS.GREEN}+ {sub}: {v_repr}{COLORS.RESET}")
            elif k not in right:
                v_repr = _serialize(left[k])
                lines.append(f"{COLORS.RED}- {sub}: {v_repr}{COLORS.RESET}")
            else:
                lines.extend(diff(left[k], right[k], sub))
    elif isinstance(left, list) and isinstance(right, list):
        if left == right:
            return []
        max_len = max(len(left), len(right))
        for i in range(max_len):
            sub = f"{path}[{i}]"
            if i >= len(left):
                v_repr = _serialize(right[i])
                lines.append(f"{COLORS.GREEN}+ {sub}: {v_repr}{COLORS.RESET}")
            elif i >= len(right):
                v_repr = _serialize(left[i])
                lines.append(f"{COLORS.RED}- {sub}: {v_repr}{COLORS.RESET}")
            else:
                lines.extend(diff(left[i], right[i], sub))
    else:
        if left != right:
            lines.append(f"{COLORS.RED}- {path}: {_serialize(left)}{COLORS.RESET}")
            lines.append(f"{COLORS.GREEN}+ {path}: {_serialize(right)}{COLORS.RESET}")
    return lines


def main() -> int:
    parser = argparse.ArgumentParser(description="Diff legible entre dos JSONs")
    parser.add_argument("left", help="Archivo JSON izquierdo")
    parser.add_argument("right", help="Archivo JSON derecho")
    parser.add_argument("--quiet", action="store_true", help="Exit 0 si son iguales, 1 si difieren")
    args = parser.parse_args()
    if not os.path.exists(args.left):
        print(f"[json_diff] {args.left} no existe")
        return 1
    if not os.path.exists(args.right):
        print(f"[json_diff] {args.right} no existe")
        return 1
    try:
        with open(args.left, "r", encoding="utf-8") as f:
            left = json.load(f)
        with open(args.right, "r", encoding="utf-8") as f:
            right = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        print(f"[json_diff] error al cargar: {e}")
        return 1
    diffs = diff(left, right)
    if not diffs:
        print(f"[json_diff] {args.left} == {args.right} (sin diferencias)")
        return 0
    print(f"[json_diff] {len(diffs)} diferencias:")
    for d in diffs:
        print(d)
    return 1


if __name__ == "__main__":
    sys.exit(main())
