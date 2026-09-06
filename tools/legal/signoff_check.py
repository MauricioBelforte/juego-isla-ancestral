#!/usr/bin/env python3
# M127 iter 4 (minimax-3): Validador pre-release de documentos legales.
# Verifica que NOTICE.md, LICENSE, AUTHORS.md, CONTRIBUTING.md existen,
# tienen contenido valido, y los placeholders de copyright estan actualizados.
# Uso: python tools/legal/signoff_check.py [--strict]
# Exit 0 si todo OK, 1 si falta algo o esta desactualizado.

import os
import sys
import json
import argparse
import re
from datetime import datetime
from typing import List, Tuple

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))

# Documentos requeridos
DOCS = [
    {"path": "NOTICE.md", "min_size": 200, "required_patterns": ["Copyright", "Attribut"]},
    {"path": "LICENSE", "min_size": 500, "required_patterns": ["Copyright", "Propietaria"]},
    {"path": "AUTHORS.md", "min_size": 200, "required_patterns": ["## Contribuidores", "commits"]},
    {"path": "CONTRIBUTING.md", "min_size": 300, "required_patterns": ["## Como", "## Convenciones"]},
]


def _check_doc(doc: dict, strict: bool) -> Tuple[bool, List[str]]:
    """Valida un documento. Devuelve (ok, lista_de_errores)."""
    errors: List[str] = []
    path = os.path.join(PROJECT_ROOT, doc["path"])
    if not os.path.exists(path):
        errors.append(f"  - {doc['path']}: no existe")
        return False, errors
    # Tamanio
    try:
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
    except OSError as e:
        errors.append(f"  - {doc['path']}: no se pudo leer: {e}")
        return False, errors
    if len(content) < doc["min_size"]:
        errors.append(f"  - {doc['path']}: muy pequeno ({len(content)} bytes, minimo {doc['min_size']})")
    # Patrones requeridos
    for pattern in doc["required_patterns"]:
        if pattern.lower() not in content.lower():
            errors.append(f"  - {doc['path']}: falta patron '{pattern}'")
    # Strict: verificar que el year sea el actual
    if strict:
        year = str(datetime.now().year)
        if year not in content:
            errors.append(f"  - {doc['path']}: no contiene el year actual ({year})")
    return len(errors) == 0, errors


def _check_copyright_json() -> Tuple[bool, List[str]]:
    """Verifica que data/legal/copyright.json exista y tenga los elementos basicos."""
    errors: List[str] = []
    path = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "legal", "copyright.json")
    if not os.path.exists(path):
        errors.append(f"  - data/legal/copyright.json: no existe")
        return False, errors
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        errors.append(f"  - data/legal/copyright.json: error: {e}")
        return False, errors
    if "elementos" not in data or not isinstance(data["elementos"], list):
        errors.append("  - data/legal/copyright.json: falta clave 'elementos' o no es array")
        return False, errors
    if len(data["elementos"]) < 3:
        errors.append(f"  - data/legal/copyright.json: solo {len(data['elementos'])} elementos (minimo 3)")
    # Verificar elementos tengan year
    for e in data["elementos"]:
        if "year" not in e:
            errors.append(f"  - data/legal/copyright.json: elemento '{e.get('id', '?')}' sin 'year'")
    return len(errors) == 0, errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Validador pre-release de documentos legales")
    parser.add_argument("--strict", action="store_true", help="Requiere year actual en todos los docs")
    args = parser.parse_args()

    all_errors: List[str] = []

    # Verificar docs de texto
    print("[signoff] Verificando documentos legales...")
    for doc in DOCS:
        ok, errors = _check_doc(doc, args.strict)
        status = "OK" if ok else "FAIL"
        print(f"  [{status}] {doc['path']}")
        all_errors.extend(errors)

    # Verificar copyright.json
    print("[signoff] Verificando data/legal/copyright.json...")
    ok, errors = _check_copyright_json()
    status = "OK" if ok else "FAIL"
    print(f"  [{status}] data/legal/copyright.json")
    all_errors.extend(errors)

    # Resumen
    if all_errors:
        print(f"\n[signoff] {len(all_errors)} errores:")
        for e in all_errors:
            print(e)
        return 1
    print("\n[signoff] Todos los docs legales OK. Listo para release.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
