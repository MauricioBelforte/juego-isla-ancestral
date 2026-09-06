#!/usr/bin/env python3
# M118: CI/CD - Cron cleanup de artefactos viejos (iter 2 minimax-m3).
# Borra artefactos de builds > N dias. Uso:
#   python tools/ci/cron-cleanup.py [--days 30] [--dry-run] [--path out/]
# Puede correr en un cron semanal/mensual via GitHub Actions.

import os
import sys
import argparse
import time
from typing import List

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def _collect_files(root: str, max_age_days: int) -> List[str]:
    """Devuelve archivos en `root` mas viejos que `max_age_days` dias."""
    if not os.path.isdir(root):
        return []
    now = time.time()
    cutoff = now - (max_age_days * 86400)
    viejos: List[str] = []
    for dirpath, _, filenames in os.walk(root):
        for f in filenames:
            full = os.path.join(dirpath, f)
            try:
                mtime = os.path.getmtime(full)
                if mtime < cutoff:
                    viejos.append(full)
            except OSError:
                pass
    return viejos


def main() -> int:
    parser = argparse.ArgumentParser(description="Limpieza periodica de artefactos de CI")
    parser.add_argument("--path", default=os.path.join(PROJECT_ROOT, "out"), help="Directorio a limpiar")
    parser.add_argument("--days", type=int, default=30, help="Edad maxima en dias (default: 30)")
    parser.add_argument("--dry-run", action="store_true", help="Solo listar, no borrar")
    args = parser.parse_args()

    target = args.path
    if not os.path.isdir(target):
        print(f"[cron-cleanup] {target} no existe; nada que limpiar")
        return 0

    viejos = _collect_files(target, args.days)
    total_size = 0
    for f in viejos:
        try:
            total_size += os.path.getsize(f)
        except OSError:
            pass
    print(f"[cron-cleanup] {len(viejos)} archivos > {args.days} dias en {target} ({total_size / 1024 / 1024:.1f} MB)")

    if args.dry_run:
        for f in viejos[:10]:
            print(f"  DRY: {f}")
        if len(viejos) > 10:
            print(f"  ... y {len(viejos) - 10} mas")
        return 0

    borrados = 0
    for f in viejos:
        try:
            os.remove(f)
            borrados += 1
        except OSError as e:
            print(f"  WARN: no se pudo borrar {f}: {e}", file=sys.stderr)
    print(f"[cron-cleanup] {borrados} archivos borrados")
    return 0


if __name__ == "__main__":
    sys.exit(main())
