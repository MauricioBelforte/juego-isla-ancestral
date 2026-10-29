#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
drift_checklist_global.py — Detector de drift entre CHECKLIST-GLOBAL y los 05-Checklist.md reales.

Lee la columna Progreso declarada en CHECKLIST-GLOBAL.md y la compara con el conteo real de [x]
sobre cada DOCUMENTACION/{ID}-*/plan-actual/05-Checklist.md. Reporta módulos con drift (declarado != real).

Uso:
    python scripts/drift_checklist_global.py                    # reporte completo
    python scripts/drift_checklist_global.py --maiores N        # top N con mayor drift positivo
    python scripts/drift_checklist_global.py --solo-editables   # excluye modulos sin 05-Checklist.md
    python scripts/drift_checklist_global.py --json             # salida JSON para integración

Salida por defecto (texto):
    ID | Modulo | Declarado | Real | Delta | Editado?
"""

import argparse
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
GLOBAL_PATH = REPO_ROOT / "CHECKLIST-GLOBAL.md"
DOCS_DIR = REPO_ROOT / "DOCUMENTACION"

CHECKLIST_ITEM_RE = re.compile(r'^\s*-\s*\[x\]\s', re.MULTILINE)
GLOBAL_ROW_RE = re.compile(
    r'^\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|\s*[^|]*\|\s*(\d+)/(\d+)\s*\|'
)


def leer_global(path):
    """Devuelve lista de dicts: {id, nombre, declarado, total}."""
    filas = []
    with open(path, "r", encoding="utf-8") as f:
        for linea in f:
            m = GLOBAL_ROW_RE.match(linea.rstrip("\n"))
            if m:
                filas.append({
                    "id": int(m.group(1)),
                    "nombre": m.group(2).strip(),
                    "declarado": int(m.group(3)),
                    "total": int(m.group(4)),
                })
    return filas


def contar_x_real(carpeta_modulo):
    """Cuenta líneas '- [x]' en el 05-Checklist.md del modulo."""
    checklist = carpeta_modulo / "plan-actual" / "05-Checklist.md"
    if not checklist.exists():
        return None, False  # (conteo, existe)
    texto = checklist.read_text(encoding="utf-8")
    conteo = len(CHECKLIST_ITEM_RE.findall(texto))
    return conteo, True


def main():
    parser = argparse.ArgumentParser(description="Detecta drift CHECKLIST-GLOBAL vs 05-Checklist.md reales.")
    parser.add_argument("--maiores", type=int, metavar="N", help="Mostrar top N con mayor drift positivo.")
    parser.add_argument("--solo-editables", action="store_true",
                        help="Excluir modulos sin 05-Checklist.md (sin plan-actual).")
    parser.add_argument("--json", action="store_true", help="Salida JSON.")
    args = parser.parse_args()

    filas = leer_global(GLOBAL_PATH)
    resultados = []

    for fila in filas:
        id_mod = fila["id"]
        # Buscar carpeta DOCUMENTACION/{ID}-*
        matches = list(DOCS_DIR.glob(f"{id_mod}-*"))
        if not matches:
            resultados.append({
                "id": id_mod,
                "nombre": fila["nombre"],
                "declarado": fila["declarado"],
                "total": fila["total"],
                "real": None,
                "delta": None,
                "existe_05": False,
                "carpeta": None,
            })
            continue
        carpeta = matches[0]
        real, existe_05 = contar_x_real(carpeta)
        delta = (real - fila["declarado"]) if real is not None else None
        resultados.append({
            "id": id_mod,
            "nombre": fila["nombre"],
            "declarado": fila["declarado"],
            "total": fila["total"],
            "real": real,
            "delta": delta,
            "existe_05": existe_05,
            "carpeta": str(carpeta.relative_to(REPO_ROOT)),
        })

    # Filtrar
    if args.solo_editables:
        resultados = [r for r in resultados if r["existe_05"] and r["real"] is not None]

    # Ordenar por delta descendente (mayor drift primero)
    resultados_ordenados = sorted(
        [r for r in resultados if r["delta"] is not None],
        key=lambda r: r["delta"],
        reverse=True,
    )

    if args.json:
        salida = {
            "total_modulos_global": len(filas),
            "modulos_sin_carpeta": [r for r in resultados if r["carpeta"] is None],
            "modulos_sin_05": [r for r in resultados if not r["existe_05"] and r["carpeta"] is not None],
            "drift_positivo": resultados_ordenados,
            "drift_cero": [r for r in resultados if r["delta"] == 0],
        }
        print(json.dumps(salida, ensure_ascii=False, indent=2))
        return

    # Salida texto
    print("=== DRIFT CHECKLIST-GLOBAL ===\n")
    print(f"Modulos en CHECKLIST-GLOBAL: {len(filas)}")

    sin_carpeta = [r for r in resultados if r["carpeta"] is None]
    sin_05 = [r for r in resultados if r["carpeta"] is not None and not r["existe_05"]]
    con_drift = [r for r in resultados_ordenados if r["delta"] != 0]

    print(f"Sin carpeta en DOCUMENTACION/: {len(sin_carpeta)}")
    for r in sin_carpeta:
        print(f"  ID {r['id']}: {r['nombre']}")
    print(f"Sin plan-actual/05-Checklist.md: {len(sin_05)}")
    for r in sin_05:
        print(f"  ID {r['id']}: {r['nombre']} ({r['carpeta']})")
    print(f"Con drift (declarado != real): {len(con_drift)}\n")

    top = resultados_ordenados if args.maiores is None else resultados_ordenados[:args.maiores]
    print(f"{'ID':>4} | {'Modulo':<45} | {'Declarado':>10} | {'Real':>6} | {'Delta':>6} | Editado?")
    print("-" * 90)
    for r in top:
        delta_str = f"{r['delta']:+d}" if r['delta'] is not None else "  N/A"
        editado = "Si" if (r["existe_05"] and r["real"] is not None) else "NO"
        real_str = str(r["real"]) if r["real"] is not None else "N/A"
        print(f"{r['id']:>4} | {r['nombre']:<45} | {r['declarado']:>5}/{str(r['total']):<3} | {real_str:>6} | {delta_str:>6} | {editado}")

    if args.maiores is None and con_drift:
        print(f"\nResumen: drift positivo total = {sum(r['delta'] for r in con_drift if r['delta'] > 0)}")


if __name__ == "__main__":
    main()
