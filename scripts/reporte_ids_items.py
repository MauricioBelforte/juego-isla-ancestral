# -*- coding: utf-8 -*-
"""
Reporte de ids de items — herramienta auxiliar del proyecto (M39/M149).

Motivo (BUG-028): el catalogo de tiendas (`catalogo_tiendas.gd`) referencia ids
de item, y `ItemDatabase` carga los `data/items/*.tres`. Cuando el id del
catalogo no existe en la base, el precio cae a 0 y los tests dan **falso verde**.
Esta herramienta produce el mapa archivo -> id real para corregir el desajuste
sin adivinar.

Uso:
    python scripts/reporte_ids_items.py
    python scripts/reporte_ids_items.py --json

Salida:
    - MAPA: archivo .tres -> id declarado (campo `id`)
    - IDs duplicados (dos .tres con el mismo id)
    - Archivos sin campo id
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
ITEMS_DIR = RAIZ / "game" / "isla-ancestral" / "data" / "items"
ECON_PRICES = RAIZ / "game" / "isla-ancestral" / "data" / "economy" / "econ_prices.tres"

# `id = "OBJ-CUA-007"` en los .tres de Godot
RE_ID = re.compile(r'^\s*id\s*=\s*"([^"]*)"', re.MULTILINE)
# `item_id = "madera_roble"` en econ_prices.tres
RE_ECO = re.compile(r'^\s*item_id\s*=\s*"([^"]*)"', re.MULTILINE)


def recopilar(items_dir: Path) -> list[dict]:
    filas: list[dict] = []
    for tres in sorted(items_dir.glob("*.tres")):
        texto = tres.read_text(encoding="utf-8", errors="strict")
        m = RE_ID.search(texto)
        filas.append({
            "archivo": tres.name,
            "id": (m.group(1) if m else ""),
        })
    return filas


def main() -> int:
    ap = argparse.ArgumentParser(description="Mapa archivo -> id de data/items")
    ap.add_argument("--json", action="store_true", help="salida JSON")
    args = ap.parse_args()

    if not ITEMS_DIR.is_dir():
        print(f"ERROR: no existe {ITEMS_DIR}", file=sys.stderr)
        return 2

    filas = recopilar(ITEMS_DIR)

    if args.json:
        print(json.dumps(filas, ensure_ascii=False, indent=2))
        return 0

    print(f"=== MAPA .tres -> id  ({len(filas)} archivos en {ITEMS_DIR.name}/) ===")
    for f in filas:
        marca = "" if f["id"] else "   <-- SIN CAMPO id"
        print(f"{f['archivo']:<34} {f['id']}{marca}")

    vistos: dict[str, list[str]] = {}
    for f in filas:
        if f["id"]:
            vistos.setdefault(f["id"], []).append(f["archivo"])

    dup = {k: v for k, v in vistos.items() if len(v) > 1}
    if dup:
        print("\n=== IDs DUPLICADOS ===")
        for k, v in sorted(dup.items()):
            print(f"{k}: {', '.join(v)}")

    sin_id = [f["archivo"] for f in filas if not f["id"]]
    if sin_id:
        print("\n=== ARCHIVOS SIN id ===")
        for a in sin_id:
            print(a)

    # Cruce con econ_prices.tres (precios M38): qué item_id de economía
    # tienen .tres en ItemDatabase y cuáles no (falso-verde BUG-028).
    if ECON_PRICES.is_file():
        eco = RE_ECO.findall(ECON_PRICES.read_text(encoding="utf-8", errors="strict"))
        reales = {f["id"] for f in filas if f["id"]}
        print(f"\n=== CRUCE econ_prices.tres ({len(eco)} item_id) vs items/ ===")
        for eid in eco:
            print(f"{'OK    ' if eid in reales else 'FALTA '} {eid}")
        print(f"\n=== total .tres con id: {len(reales)} ===")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
