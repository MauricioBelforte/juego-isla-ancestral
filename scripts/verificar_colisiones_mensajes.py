# -*- coding: utf-8 -*-
"""verificar_colisiones_mensajes.py — detecta problemas de numeracion en los pools
de mensajes de los canales (`Mensajes entre modelos/*/NUMEROS_DISPONIBLES.txt`).

Detecta, por canal:
  1. COLISION      : dos archivos .md con el mismo numero de prefijo (pool tomado 2 veces)
  2. DESINCRONIZADO: numero que sigue en el pool pero ya tiene archivo (doble asignador)
  3. HUECO         : numero faltante dentro del rango usado (perdido o nunca escrito)
  4. HUECO GRANDE  : hueco de >= HUECO_MIN numeros (posible borrado masivo)
  5. DUPLICADO DE PLANTILLA: dos archivos reservados sin cuerpo (mismo numero)

READ-ONLY: no escribe nada. Exit 1 si hay problemas graves.

Uso:
    python scripts/verificar_colisiones_mensajes.py
    python scripts/verificar_colisiones_mensajes.py --json
    python scripts/verificar_colisiones_mensajes.py --canal <nombre>

Modelo: step-5-kilocode | Plataforma: Kilo Code | Fecha: 2026-10-11
"""
from __future__ import annotations

import argparse
import glob
import json
import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MENSAJES = os.path.join(RAIZ, "Mensajes entre modelos")
HUECO_MIN = 5  # huecos de 5 o mas numeros se reportan como grandes

# Colisiones cerradas por decision del director (mimo msg 277): son dos mensajes
# REALES con el mismo numero, ambos historicos. Renumerarlos romperia citas
# cruzadas, asi que quedan intactos y se excluyen del total de alertas.
COLISIONES_RESUELTAS = {
    ("step-5-kilocode", 95): "dos mensajes reales historicos; reasignar romperia citas",
    ("step-5-kilocode", 96): "dos mensajes reales historicos; reasignar romperia citas",
}


def pipes_sin_escapar(s):
    return len([i for i, c in enumerate(s) if c == "|" and (i == 0 or s[i - 1] != "\\")])


def es_plantilla(ruta):
    """True si el archivo es una plantilla reservada sin cuerpo."""
    try:
        with io_open(ruta) as f:
            t = f.read()
    except Exception:
        return False
    return ("PLANTILLA RESERVADA" in t) or ("<cuerpo del mensaje aca>" in t)


def io_open(ruta):
    import io
    return io.open(ruta, encoding="utf-8")


def auditar_canal(canal_dir):
    nombre = os.path.basename(canal_dir.rstrip("/\\"))
    pool_path = os.path.join(canal_dir, "NUMEROS_DISPONIBLES.txt")

    # archivos .md del canal
    mds = [f for f in os.listdir(canal_dir) if f.endswith(".md")]
    por_num = {}
    for f in mds:
        m = re.match(r"^(\d+)-", f)
        if m:
            por_num.setdefault(int(m.group(1)), []).append(f)

    pool = []
    if os.path.isfile(pool_path):
        try:
            with io_open(pool_path) as f:
                pool = [int(l.strip()) for l in f.read().split("\n")
                        if l.strip().isdigit()]
        except Exception:
            pool = []

    usados = sorted(por_num.keys())

    # 1) colisiones: misnumero numero con >1 archivo
    colisiones = {n: v for n, v in por_num.items() if len(v) > 1}

    # 2) desincronizado: en el pool Y con archivo
    desinc = sorted(set(pool) & set(usados))

    # 3/4) huecos dentro del rango usado
    huecos = []
    huecos_grandes = []
    if usados:
        s = set(usados)
        run = []
        for n in range(min(usados), max(usados) + 1):
            if n not in s:
                run.append(n)
            else:
                if run:
                    huecos.append(run)
                    if len(run) >= HUECO_MIN:
                        huecos_grandes.append(run)
                run = []
        if run:
            huecos.append(run)
            if len(run) >= HUECO_MIN:
                huecos_grandes.append(run)

    # 5) plantillas sin cuerpo
    plantillas = []
    for n, fs in sorted(por_num.items()):
        for f in fs:
            if es_plantilla(os.path.join(canal_dir, f)):
                plantillas.append((n, f))

    return {
        "canal": nombre,
        "archivos_md": len(mds),
        "numeros_usados": len(usados),
        "min": usados[0] if usados else None,
        "max": usados[-1] if usados else None,
        "pool": len(pool),
        "colisiones": {str(n): v for n, v in sorted(colisiones.items())},
        "desincronizados": desinc,
        "huecos": huecos,
        "huecos_grandes": huecos_grandes,
        "plantillas_sin_cuerpo": plantillas,
    }


def main():
    ap = argparse.ArgumentParser(
        description="Detecta problemas de numeracion en pools de mensajes")
    ap.add_argument("--canal", help="auditar solo este canal")
    ap.add_argument("--json", action="store_true", help="salida en JSON")
    args = ap.parse_args()

    canales = sorted(
        d for d in glob.glob(os.path.join(MENSAJES, "*"))
        if os.path.isdir(d)
    )
    if args.canal:
        canales = [c for c in canales if os.path.basename(c) == args.canal]

    res = [auditar_canal(c) for c in canales]

    # Excluir colisiones cerradas por decision del director (mensaje 277)
    for r in res:
        cerradas = {str(n) for (c, n) in COLISIONES_RESUELTAS if c == r["canal"]}
        if r["colisiones"] and cerradas:
            r["colisiones"] = {
                n: v for n, v in r["colisiones"].items() if n not in cerradas
            }

    if args.json:
        print(json.dumps(res, ensure_ascii=False, indent=2))
        graves = any(r["colisiones"] or r["desincronizados"] for r in res)
        return 1 if graves else 0

    total_col = total_des = total_pl = 0
    for r in res:
        alertas = []
        if r["colisiones"]:
            alertas.append("%d colision/es" % len(r["colisiones"]))
            total_col += len(r["colisiones"])
        if r["desincronizados"]:
            alertas.append("%d desincronizado/s" % len(r["desincronizados"]))
            total_des += len(r["desincronizados"])
        if r["plantillas_sin_cuerpo"]:
            alertas.append("%d plantilla/s sin cuerpo" % len(r["plantillas_sin_cuerpo"]))
            total_pl += len(r["plantillas_sin_cuerpo"])
        if r["huecos_grandes"]:
            alertas.append("%d hueco/s grande/s" % len(r["huecos_grandes"]))
        marca = "  <<< " + ", ".join(alertas) if alertas else ""
        print("%-28s mds=%-4d usados=%-4d rango=%s..%s pool=%-4d%s"
              % (r["canal"][:28], r["archivos_md"], r["numeros_usados"],
                 r["min"], r["max"], r["pool"], marca))
        for n, fs in r["colisiones"].items():
            for f in fs:
                print("      COLISION %s: %s" % (n, f))
        for n in r["desincronizados"]:
            print("      DESINCRONIZADO %d: en pool y con archivo" % n)
        for n, f in r["plantillas_sin_cuerpo"]:
            print("      PLANTILLA %d: %s" % (n, f))
        for run in r["huecos_grandes"]:
            print("      HUECO GRANDE: %d..%d (%d numeros)"
                  % (run[0], run[-1], len(run)))

    print("")
    print("TOTALES: %d colisiones, %d desincronizados, %d plantillas sin cuerpo"
          % (total_col, total_des, total_pl))
    return 1 if (total_col or total_des) else 0


if __name__ == "__main__":
    sys.exit(main())
