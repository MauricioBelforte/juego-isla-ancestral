#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Validador de naming de archivos — Módulo 149 (Isla Ancestral).

Verifica las convenciones de `code-conventions.md` sobre el árbol del juego:
  - .gd  -> snake_case
  - .tscn -> PascalCase para entidades (lista blanca: test_*, preview_*, main*)
  - .tres/.json -> snake_case
  - backups con fecha (YYYY-MM-DD_) prohibidos dentro de scripts/ y scenes/

Uso:
  python validar_nombres.py [--root RUTA]          # árbol completo (manual)
  python validar_nombres.py --staged               # solo archivos staged (pre-commit hook)

Salida: OK (exit 0) o lista de violaciones (exit 1). Herramienta de apoyo
ejecutable manualmente; integrable como pre-commit hook (ver operativa/pre-commit-naming).

Fix BUG-058 (hy3, Log 1092, 2026-09-19): se excluyen los directorios de runtime
de Godot y de terceros (`Godot/`, `app_userdata/`, `addons/`) que inundaban el
validador con ~1127 falsos positivos (salida de telemetría en tiempo de ejecución
y gdUnit4). Se añade modo `--staged` para el hook pre-commit (verifica solo lo
que se va a commitear, no la deuda histórica del árbol).
"""
import argparse
import re
import subprocess
import sys
from pathlib import Path

SNAKE = re.compile(r"^[a-z0-9]+(_[a-z0-9]+)*$")
PASCAL = re.compile(r"^[A-Z][A-Za-z0-9]*$")
BACKUP = re.compile(r"^\d{4}-\d{2}-\d{2}_")

# Escenas legacy/main y de prueba permitidas fuera de PascalCase (deuda documentada)
WHITELIST_TSCN_PREFIXES = ("main", "test", "preview", "simple", "minimal")

# Directorios que NO son fuente del repo: runtime de Godot, userdata y addons de terceros.
EXCLUDE_DIRS = ("Godot", "app_userdata", "addons")


def es_violacion(path: Path, root: Path) -> str:
    rel = path.relative_to(root)
    name = path.stem
    if "Obsoletos" in rel.parts:
        return ""  # archivados por diseno (regla 5 de AGENTS.md): sin convencion
    if any(p in EXCLUDE_DIRS for p in rel.parts):
        return ""  # runtime de Godot / userdata / addons de terceros: no fuente del repo
    if BACKUP.match(name) and any(p in rel.parts for p in ("scripts", "scenes")):
        return "backup con fecha dentro del arbol de codigo (usar Obsoletos/)"
    if path.suffix == ".gd":
        if not SNAKE.match(name):
            return f".gd debe ser snake_case: {name}.gd"
    elif path.suffix == ".tscn":
        if SNAKE.match(name):
            # entidades deberian ser PascalCase; whitelist para legacy/pruebas
            if not name.startswith(WHITELIST_TSCN_PREFIXES):
                return f".tscn de entidad debe ser PascalCase: {name}.tscn"
        elif not PASCAL.match(name):
            return f".tscn con nombre no conforme (PascalCase o whitelist): {name}.tscn"
    elif path.suffix in (".tres", ".json"):
        if not SNAKE.match(name):
            return f"{path.suffix} debe ser snake_case: {name}{path.suffix}"
    return ""


def _staged_files(root: Path):
    """Devuelve Paths (relativos a `root`) de los archivos staged bajo isla-ancestral."""
    out = subprocess.run(
        ["git", "diff", "--cached", "--name-only", "--diff-filter=ACMR"],
        capture_output=True, text=True,
    )
    repo_root = root.parent.parent  # .../game/isla-ancestral -> repo
    result = []
    for line in out.stdout.splitlines():
        line = line.strip()
        if not line or "isla-ancestral" not in line.split("/"):
            continue
        p = Path(line)
        if p.suffix in (".gd", ".tscn", ".tres", ".json"):
            full = repo_root / p
            try:
                full.relative_to(root)
            except ValueError:
                continue
            result.append(full)
    return result


def _default_root():
    here = Path(__file__).resolve()
    for parent in here.parents:
        candidate = parent / "game" / "isla-ancestral"
        if candidate.exists():
            return candidate
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description="Validador de naming M149")
    parser.add_argument("--root", default=None, help="raiz del proyecto Godot")
    parser.add_argument("--staged", action="store_true",
                        help="validar solo archivos staged (modo pre-commit hook)")
    args = parser.parse_args()

    root = Path(args.root) if args.root else _default_root()
    if root is None or not root.exists():
        print("ERROR: no se encontro la raiz del juego (game/isla-ancestral). "
              "Usa --root RUTA.")
        return 2

    if args.staged:
        paths = _staged_files(root)
        scope = "STAGED"
    else:
        paths = [p for pat in ("*.gd", "*.tscn", "*.tres", "*.json")
                 for p in root.rglob(pat)]
        scope = "arbol completo"

    violations = []
    for path in paths:
        msg = es_violacion(path, root)
        if msg:
            violations.append(f"{path.relative_to(root)} -> {msg}")

    if violations:
        print(f"VIOLACIONES DE NAMING ({scope}, {len(violations)}):")
        for v in sorted(violations):
            print(f"  - {v}")
        return 1
    print(f"OK: naming conforme a las convenciones de M149 ({scope}).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
