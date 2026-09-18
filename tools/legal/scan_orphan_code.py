#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
# -*- coding: utf-8 -*-
"""M127 iter. 3 -- Escaner de codigo huerfano SIN atribucion de autoria.

Un archivo es "huerfano" para efectos de evidencia de autoria cuando no se puede
probar quien lo escribio ni cuando:

  * SIN_HISTORIAL      -- no esta trackeado por git (no hay autor ni fecha).
  * SIN_CABECERA       -- no lleva cabecera de copyright (ver insert_copyright_headers.py).
  * AUTOR_PLACEHOLDER  -- el autor del commit es un marcador generico
                          ("unknown", "root", "user"...) que no sostiene autoría.

Se hace **UNA sola llamada a git** (`git log --format=... --name-only`) y se arma
un mapa archivo -> autores. Llamar a git una vez por archivo es O(n) procesos y
en este repo (858 logs, ~1500 fuentes) tarda minutos.

Uso:
    python tools/legal/scan_orphan_code.py --check      # exit 1 si hay huerfanos
    python tools/legal/scan_orphan_code.py --json
    python tools/legal/scan_orphan_code.py --detalle

Exit: 0 = sin huerfanos / 1 = hay huerfanos o error.
"""

import argparse
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(HERE, "..", ".."))
ALCANCE = os.path.join(HERE, "headers_scope.json")

MARCADOR = "SPDX-License-Identifier:"
PLACEHOLDERS = {"", "unknown", "root", "user", "admin", "desconocido",
                "n/a", "na", "none", "test", "bot"}

SEP = "\x01"


def cargar_alcance():
    try:
        with open(ALCANCE, "r", encoding="utf-8") as f:
            data = json.load(f)
        return ([e.lower() for e in data.get("extensiones", [".gd", ".cs", ".py"])],
                list(data.get("incluir", [])),
                list(data.get("excluir", [])))
    except (OSError, json.JSONDecodeError):
        return ([".gd", ".cs", ".py"], [], [])


def _norm(p):
    return p.replace("\\", "/")


def es_excluido(rel, excluir):
    rel = _norm(rel)
    partes = rel.split("/")
    for pat in excluir:
        pat = _norm(pat).rstrip("/")
        if not pat:
            continue
        if rel == pat or rel.startswith(pat + "/"):
            return True
        if "/" not in pat and pat in partes:
            return True
    return False


def archivos_en_alcance(ext, incluir, excluir):
    out = []
    for item in incluir:
        abs_item = os.path.join(RAIZ, item.replace("/", os.sep))
        if os.path.isfile(abs_item):
            out.append(_norm(item))
            continue
        if not os.path.isdir(abs_item):
            continue
        for base, dirs, files in os.walk(abs_item):
            dirs[:] = sorted(d for d in dirs if d != "__pycache__")
            for nombre in sorted(files):
                if os.path.splitext(nombre)[1].lower() not in ext:
                    continue
                rel = _norm(os.path.relpath(os.path.join(base, nombre), RAIZ))
                if not es_excluido(rel, excluir):
                    out.append(rel)
    vistos, salida = set(), []
    for r in out:
        if r not in vistos:
            vistos.add(r)
            salida.append(r)
    return sorted(salida)


def mapa_autores(raiz):
    """{archivo_relativo: {autores}} con UNA llamada a git.

    Formato: `git log --format=<SEP>%an --name-only`. Cada linea que empieza con
    SEP abre un commit con su autor; las siguientes lineas no vacias son archivos.
    """
    try:
        r = subprocess.run(
            ["git", "log", "--format=%s%%an" % SEP, "--name-only", "--no-merges"],
            capture_output=True, text=True, timeout=180, cwd=raiz,
            encoding="utf-8", errors="replace")
    except (OSError, subprocess.SubprocessError):
        return {}
    if r.returncode != 0:
        return {}
    mapa, autor = {}, None
    for linea in r.stdout.splitlines():
        if linea.startswith(SEP):
            autor = linea[1:].strip()
            continue
        rel = _norm(linea.strip())
        if rel and autor:
            mapa.setdefault(rel, set()).add(autor)
    return mapa


def archivos_trackeados(raiz):
    try:
        r = subprocess.run(["git", "ls-files"], capture_output=True, text=True,
                           timeout=120, cwd=raiz, encoding="utf-8", errors="replace")
        if r.returncode != 0:
            return set()
        return {_norm(l.strip()) for l in r.stdout.splitlines() if l.strip()}
    except (OSError, subprocess.SubprocessError):
        return set()


def tiene_cabecera(abs_p):
    try:
        with open(abs_p, "r", encoding="utf-8", errors="replace") as f:
            for i, linea in enumerate(f):
                if i > 15:
                    break
                if MARCADOR in linea or "Copyright (c)" in linea:
                    return True
    except OSError:
        return False
    return False


def escanear():
    ext, incluir, excluir = cargar_alcance()
    archivos = archivos_en_alcance(ext, incluir, excluir)
    trackeados = archivos_trackeados(RAIZ)
    autores = mapa_autores(RAIZ)
    hallazgos = {"sin_historial": [], "sin_cabecera": [], "autor_placeholder": []}
    detalle = []
    for rel in archivos:
        abs_p = os.path.join(RAIZ, rel.replace("/", os.sep))
        autores_archivo = sorted(autores.get(rel, set()))
        registro = {"ruta": rel, "autores": autores_archivo, "trackeado": rel in trackeados,
                    "cabecera": tiene_cabecera(abs_p)}
        if rel not in trackeados:
            hallazgos["sin_historial"].append(rel)
        if not registro["cabecera"]:
            hallazgos["sin_cabecera"].append(rel)
        if autores_archivo and all(a.strip().lower() in PLACEHOLDERS for a in autores_archivo):
            hallazgos["autor_placeholder"].append(rel)
        detalle.append(registro)
    return archivos, hallazgos, detalle


def main():
    p = argparse.ArgumentParser(description="Escaner de codigo sin atribucion de autoria")
    p.add_argument("--check", action="store_true", help="exit 1 si hay huerfanos")
    p.add_argument("--json", action="store_true")
    p.add_argument("--detalle", action="store_true", help="una linea por archivo")
    a = p.parse_args()

    archivos, hallazgos, detalle = escanear()
    total = sum(len(v) for v in hallazgos.values())

    if a.json:
        print(json.dumps({"en_alcance": len(archivos), "total_hallazgos": total,
                          "hallazgos": hallazgos, "detalle": detalle},
                         indent=2, ensure_ascii=False))
        return 1 if (a.check and total) else 0

    print("[huerfanos] alcance=%d archivos" % len(archivos))
    if a.detalle:
        for d in detalle:
            print("  %-60s trackeado=%-5s cabecera=%-5s autores=%s"
                  % (d["ruta"], d["trackeado"], d["cabecera"], ",".join(d["autores"]) or "-"))
    for clase, lista in hallazgos.items():
        if lista:
            print("  [%s] %d archivo(s)" % (clase.upper(), len(lista)))
            for rel in lista:
                print("      %s" % rel)
    if total == 0:
        print("  OK: 0 archivos huerfanos (todos con historial, cabecera y autor real)")
        return 0
    print("  TOTAL: %d hallazgo(s)" % total)
    return 1 if a.check else 0


if __name__ == "__main__":
    sys.exit(main())
