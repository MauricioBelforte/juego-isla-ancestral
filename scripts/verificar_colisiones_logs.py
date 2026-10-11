# -*- coding: utf-8 -*-
"""verificar_colisiones_logs.py — detecta colisiones de numeracion en Logs/.

Dos archivos con el mismo numero de prefijo (ej. 1290-a.md y 1290-b.md) indican
que dos agentes tomaron el mismo numero del pool NUMEROS_DISPONIBLES.txt:
la ventana entre la lectura y el borrado permite la colision.

READ-ONLY: no escribe nada, solo informa. Exit 1 si hay colisiones.

Uso:
    python scripts/verificar_colisiones_logs.py
    python scripts/verificar_colisiones_logs.py --json

Modelo: stepfun-step-5-preview | Plataforma: Kilo Code | Fecha: 2026-10-11
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from collections import defaultdict

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOGS = os.path.join(RAIZ, "Logs")
RX_NUM = re.compile(r"^(\d+)-")


def recolectar() -> dict[str, list[str]]:
    """Devuelve {numero: [archivos...]} solo para numeros con mas de un archivo."""
    por_numero: dict[str, list[str]] = defaultdict(list)
    if not os.path.isdir(LOGS):
        return {}
    for nombre in sorted(os.listdir(LOGS)):
        if not nombre.endswith(".md"):
            continue
        m = RX_NUM.match(nombre)
        if m:
            por_numero[m.group(1)].append(nombre)
    return {k: v for k, v in por_numero.items() if len(v) > 1}


def main() -> int:
    ap = argparse.ArgumentParser(description="Detecta colisiones de numeracion en Logs/")
    ap.add_argument("--json", action="store_true", help="salida en JSON")
    args = ap.parse_args()

    total = sum(1 for f in os.listdir(LOGS) if f.endswith(".md")) if os.path.isdir(LOGS) else 0
    colisiones = recolectar()

    if args.json:
        print(json.dumps({
            "total_logs": total,
            "colisiones": len(colisiones),
            "detalle": {k: v for k, v in sorted(colisiones.items(), key=lambda kv: int(kv[0]))},
        }, ensure_ascii=False, indent=2))
        return 1 if colisiones else 0

    if not colisiones:
        print("OK: %d logs revisados, 0 colisiones de numeracion." % total)
        return 0

    print("COLISIONES DE NUMERACION: %d (sobre %d logs)" % (len(colisiones), total))
    print()
    for num in sorted(colisiones, key=lambda s: int(s)):
        print("  Log %s:" % num)
        for f in sorted(colisiones[num]):
            print("     %s" % f)
    print()
    print("Causa probable: dos agentes tomaron el mismo numero del pool")
    print("Logs/NUMEROS_DISPONIBLES.txt (ventana lectura->borrado).")
    print("Referencia: AGENTS.md 6.1.d 'Colision residual'.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
