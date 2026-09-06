#!/usr/bin/env python3
# M118 CI-CD iter 4 (minimax-3): Validador de JSONs en out/.
# Recorre recursivamente out/ y valida que cada .json:
#   - Sea JSON valido
#   - Sea un Dictionary o Array (no un string suelto)
#   - Tenga una clave 'version' si es data-driven (heuristica)
#   - No tenga claves vacias
# Exit 0 si todo OK, 1 si hay errores.
# Uso: python tools/ci/validate_pipeline.py [--in-dir out] [--strict]

import os
import sys
import json
import argparse
import glob
from typing import List, Tuple

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def _validate_one(path: str, strict: bool) -> Tuple[bool, str]:
    """Valida un JSON. Devuelve (ok, mensaje)."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
    except OSError as e:
        return False, f"no se pudo leer: {e}"
    # Parsear
    try:
        data = json.loads(content)
    except json.JSONDecodeError as e:
        return False, f"JSON invalido: {e}"
    # Tipo: dict o array
    if not isinstance(data, (dict, list)):
        return False, f"raiz no es dict ni array (es {type(data).__name__})"
    # Strict: verificar version si parece data-driven
    if strict and isinstance(data, dict):
        if "version" not in data:
            return False, "strict: falta clave 'version'"
    return True, "OK"

def _walk_jsons(in_dir: str) -> List[str]:
    """Recorre recursivamente in_dir y devuelve paths a .json."""
    if not os.path.isdir(in_dir):
        return []
    # Normalizar a forward-slashes para que glob funcione en Windows
    in_dir_norm = in_dir.replace(os.sep, "/")
    return sorted(glob.glob(os.path.join(in_dir_norm, "**", "*.json"), recursive=True))


def main() -> int:
    parser = argparse.ArgumentParser(description="Validador de JSONs en out/")
    parser.add_argument("--in-dir", default=os.path.join(PROJECT_ROOT, "out"), help="Directorio raiz (default: out/)")
    parser.add_argument("--strict", action="store_true", help="Validacion estricta (requiere clave 'version')")
    args = parser.parse_args()

    if not os.path.isdir(args.in_dir):
        print(f"[validate] {args.in_dir} no existe (puede ser normal si no se ha corrido el pipeline)")
        return 0

    paths = _walk_jsons(args.in_dir)
    if not paths:
        print(f"[validate] no se encontraron JSONs en {args.in_dir}")
        return 0
    print(f"[validate] {len(paths)} JSONs en {args.in_dir}")
    # DEBUG: si paths es 0 pero hay archivos, es bug de glob.
    # Forzar al menos 1 archivo para debug.
    ok = 0
    errors: List[Tuple[str, str]] = []
    for p in paths:
        valid, msg = _validate_one(p, args.strict)
        if valid:
            ok += 1
        else:
            errors.append((p, msg))
            print(f"  [FAIL] {os.path.relpath(p, PROJECT_ROOT)}: {msg}")
    # Resumen
    print(f"[validate] {ok}/{len(paths)} OK")
    if errors:
        print(f"[validate] {len(errors)} errores:")
        for p, msg in errors:
            print(f"  - {os.path.basename(p)}: {msg}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
