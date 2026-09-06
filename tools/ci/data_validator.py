#!/usr/bin/env python3
# M118 iter 6 (minimax-3): Validador de JSONs en data/ con esquemas.
# Recorre recursivamente game/isla-ancestral/data/ y valida:
#   - JSON valido
#   - Version presente (si la tiene)
#   - Claves requeridas segun el path del archivo (esquema basico)
#   - Tipos de datos consistentes (arrays son arrays, etc.)
# Exit 0 si todo OK, 1 si hay errores.
# Uso: python tools/ci/data_validator.py [--data-dir game/isla-ancestral/data] [--strict]

import os
import sys
import json
import argparse
import glob
from typing import List, Tuple, Dict, Set

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
DEFAULT_DATA_DIR = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data")

# Esquema basico por nombre de archivo
# Cada entrada: claves_requeridas (set), tipo_raiz (dict|list)
SCHEMAS: Dict[str, Dict] = {
    "creditos.json": {
        "required_keys": {"secciones", "idiomas", "version"},
        "root_type": "dict",
    },
    "copyright.json": {
        "required_keys": {"elementos", "version"},
        "root_type": "dict",
    },
    "licencias.json": {
        "required_keys": {"licencias", "version"},
        "root_type": "dict",
    },
    "postlaunch_checks.json": {
        "required_keys": {"checks", "politicas", "version"},
        "root_type": "dict",
    },
    "commit_conventions.json": {
        "required_keys": {"version", "categorias"},
        "root_type": "dict",
    },
    "platforms.json": {
        "required_keys": set(),  # variable, no validar estricto
        "root_type": "dict",
    },
    "ores.json": {
        "required_keys": set(),
        "root_type": "array",
    },
    "catalog.json": {
        "required_keys": set(),
        "root_type": "array",
    },
}


def _walk_json_files(data_dir: str) -> List[str]:
    """Recorre recursivamente data_dir y devuelve paths a .json."""
    if not os.path.isdir(data_dir):
        return []
    data_dir_norm = data_dir.replace(os.sep, "/")
    return sorted(glob.glob(os.path.join(data_dir_norm, "**", "*.json"), recursive=True))


def _validate_one(path: str, strict: bool) -> Tuple[bool, List[str]]:
    """Valida un JSON contra su esquema (si tiene). Devuelve (ok, errors)."""
    errors: List[str] = []
    name = os.path.basename(path)
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        return False, [f"JSON invalido: {e}"]
    # Esquema especifico
    schema = SCHEMAS.get(name)
    if schema is None and strict:
        errors.append(f"sin esquema registrado (strict)")
        return False, errors
    if schema is None:
        # Sin esquema: solo verifica JSON valido
        return True, errors
    # Tipo raiz
    root_type = schema.get("root_type")
    if root_type == "dict" and not isinstance(data, dict):
        errors.append(f"raiz no es dict (es {type(data).__name__})")
    elif root_type == "array" and not isinstance(data, list):
        errors.append(f"raiz no es array (es {type(data).__name__})")
    # Claves requeridas
    if isinstance(data, dict):
        for key in schema.get("required_keys", set()):
            if key not in data:
                errors.append(f"falta clave requerida: '{key}'")
    return len(errors) == 0, errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Validador de JSONs en data/")
    parser.add_argument("--data-dir", default=DEFAULT_DATA_DIR, help="Directorio de data")
    parser.add_argument("--strict", action="store_true", help="Falla si un JSON no tiene esquema registrado")
    args = parser.parse_args()

    if not os.path.isdir(args.data_dir):
        print(f"[data_validator] {args.data_dir} no existe")
        return 0
    paths = _walk_json_files(args.data_dir)
    if not paths:
        print(f"[data_validator] no JSONs encontrados en {args.data_dir}")
        return 0
    print(f"[data_validator] {len(paths)} JSONs en {args.data_dir}")
    ok = 0
    errors: List[Tuple[str, List[str]]] = []
    for p in paths:
        valid, msgs = _validate_one(p, args.strict)
        if valid:
            ok += 1
        else:
            errors.append((p, msgs))
    # Resumen
    print(f"[data_validator] {ok}/{len(paths)} OK")
    if errors:
        print(f"[data_validator] {len(errors)} errores:")
        for p, msgs in errors:
            rel = os.path.relpath(p, PROJECT_ROOT)
            print(f"  {rel}:")
            for m in msgs:
                print(f"    - {m}")
        return 1
    print("[data_validator] Todos los JSONs OK.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
