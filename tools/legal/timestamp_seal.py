#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
# -*- coding: utf-8 -*-
"""M127 iter. 3 -- Sellado de tiempo criptografico (SHA-256) sobre versiones maestras.

Produce un sello por corrida en `legal/sellos/`, encadenado con el sello anterior:

    hash_arbol   = sha256( concat ordenada de "ruta\\0sha256\\n" )
    hash_cadena  = sha256( hash_previo + hash_arbol )

El encadenado es lo que lo hace **a prueba de manipulacion**: si alguien edita un
sello viejo (o un archivo ya sellado), la cadena deja de cerrar y `--verificar`
lo detecta. Un SHA-256 suelto no probaria nada sobre el ORDEN de los sellos.

Determinismo: `--crear` dos veces sobre el mismo arbol da el MISMO `hash_arbol`
(lo unico que cambia es el timestamp y el hash de cadena). Eso es lo que se testea.

Uso:
    python tools/legal/timestamp_seal.py --crear
    python tools/legal/timestamp_seal.py --verificar              # ultimo sello
    python tools/legal/timestamp_seal.py --verificar --sello ID
    python tools/legal/timestamp_seal.py --listar
    python tools/legal/timestamp_seal.py --cadena                 # valida la cadena

Exit: 0 = OK / 1 = discrepancia, cadena rota o error de lectura.
"""

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(HERE, "..", ".."))
SELLOS = os.path.join(RAIZ, "legal", "sellos")
ALCANCE = os.path.join(HERE, "seal_scope.json")

BUF = 1 << 20
RE_SELLO = re.compile(r"^sello-(\d{8}T\d{6}Z(?:-\d+)?)\.json$")

EXCLUIR_DEFECTO = [
    ".git", "__pycache__", "node_modules", ".kilo", "PAPELERA", "Obsoletos",
    "legal/sellos", ".workbuddy-ai",
]


def cargar_alcance():
    """Rutas a sellar y exclusiones. Manifiesto opcional (seal_scope.json)."""
    try:
        with open(ALCANCE, "r", encoding="utf-8") as f:
            data = json.load(f)
        return list(data.get("rutas", [])), list(data.get("excluir", EXCLUIR_DEFECTO))
    except (OSError, json.JSONDecodeError):
        return [], list(EXCLUIR_DEFECTO)


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


def sha256_archivo(abs_p):
    h = hashlib.sha256()
    with open(abs_p, "rb") as f:
        while True:
            bloque = f.read(BUF)
            if not bloque:
                break
            h.update(bloque)
    return h.hexdigest()


def recolectar(rutas, excluir):
    """[(rel, abs, bytes)] ordenado por ruta relativa. Solo archivos regulares."""
    salida = []
    for item in rutas:
        abs_item = os.path.join(RAIZ, item.replace("/", os.sep))
        if os.path.isfile(abs_item):
            rel = _norm(item)
            if not es_excluido(rel, excluir):
                salida.append((rel, abs_item, os.path.getsize(abs_item)))
            continue
        if not os.path.isdir(abs_item):
            continue
        for base, dirs, files in os.walk(abs_item):
            dirs[:] = sorted(d for d in dirs if not es_excluido(
                _norm(os.path.relpath(os.path.join(base, d), RAIZ)), excluir))
            for nombre in sorted(files):
                abs_f = os.path.join(base, nombre)
                rel = _norm(os.path.relpath(abs_f, RAIZ))
                if es_excluido(rel, excluir):
                    continue
                try:
                    salida.append((rel, abs_f, os.path.getsize(abs_f)))
                except OSError:
                    continue
    salida.sort(key=lambda t: t[0])
    return salida


def hash_arbol(entradas):
    """sha256 determinista del conjunto (ruta + hash por archivo, ordenado)."""
    h = hashlib.sha256()
    for rel, abs_p, _ in entradas:
        h.update(("%s\0%s\n" % (rel, sha256_archivo(abs_p))).encode("utf-8"))
    return h.hexdigest()


def hash_cadena(hash_previo, hash_actual):
    return hashlib.sha256((("%s|%s" % (hash_previo or "", hash_actual))).encode("utf-8")).hexdigest()


def git_dato(args):
    try:
        r = subprocess.run(["git"] + args, capture_output=True, text=True,
                           timeout=20, cwd=RAIZ)
        return r.stdout.strip() if r.returncode == 0 else None
    except (OSError, subprocess.SubprocessError):
        return None


def _clave_orden(nombre):
    """Ordena por (marca de tiempo, sufijo numerico).

    OJO: ordenar por nombre NO sirve. `sello-...Z-2.json` ordena ANTES que
    `sello-...Z.json` porque '-' (0x2D) < '.' (0x2E) — y eso invertiria la cadena.
    """
    m = RE_SELLO.match(nombre)
    sid = m.group(1)
    if "-" in sid:
        ts, suf = sid.split("-", 1)
        return (ts, int(suf))
    return (sid, 0)


def listar_sellos():
    if not os.path.isdir(SELLOS):
        return []
    nombres = [n for n in os.listdir(SELLOS) if RE_SELLO.match(n)]
    return [(RE_SELLO.match(n).group(1), os.path.join(SELLOS, n))
            for n in sorted(nombres, key=_clave_orden)]


def leer_sello(ruta):
    with open(ruta, "r", encoding="utf-8") as f:
        return json.load(f)


def crear(rutas, excluir):
    entradas = recolectar(rutas, excluir)
    if not entradas:
        print("[sello] alcance vacio: no hay nada que sellar (revisar seal_scope.json)")
        return 1
    previos = listar_sellos()
    hash_previo = leer_sello(previos[-1][1]).get("hash_cadena") if previos else None
    ahora = dt.datetime.now(dt.timezone.utc)
    sello_id = ahora.strftime("%Y%m%dT%H%M%SZ")
    h_arbol = hash_arbol(entradas)
    registro = {
        "version": 1,
        "sello_id": sello_id,
        "creado_utc": ahora.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "algoritmo": "sha256",
        "archivos": len(entradas),
        "bytes_totales": sum(e[2] for e in entradas),
        "hash_arbol": h_arbol,
        "hash_previo": hash_previo,
        "hash_cadena": hash_cadena(hash_previo, h_arbol),
        "git_commit": git_dato(["rev-parse", "HEAD"]),
        "git_branch": git_dato(["rev-parse", "--abbrev-ref", "HEAD"]),
        "arbol": [{"ruta": rel, "sha256": sha256_archivo(abs_p), "bytes": n}
                  for rel, abs_p, n in entradas],
    }
    os.makedirs(SELLOS, exist_ok=True)
    # Dos sellos en el MISMO segundo colisionan de id. No se sobrescribe nunca un
    # sello (es evidencia): si el existente ya registra este mismo arbol, la corrida
    # es idempotente; si no, se desambigua con sufijo -2, -3...
    destino = os.path.join(SELLOS, "sello-%s.json" % sello_id)
    n = 1
    while os.path.exists(destino):
        try:
            existente = leer_sello(destino)
        except (OSError, json.JSONDecodeError):
            existente = {}
        if (existente.get("hash_arbol") == h_arbol
                and existente.get("hash_previo") == hash_previo):
            print("[sello] idempotente: %s ya registra este mismo arbol"
                  % os.path.relpath(destino, RAIZ))
            return 0
        n += 1
        destino = os.path.join(SELLOS, "sello-%s-%d.json" % (sello_id, n))
    with open(destino, "w", encoding="utf-8", newline="") as f:
        json.dump(registro, f, indent=2, ensure_ascii=False, sort_keys=True)
        f.write("\n")
    print("[sello] creado %s" % os.path.relpath(destino, RAIZ))
    print("  archivos=%d bytes=%d" % (registro["archivos"], registro["bytes_totales"]))
    print("  hash_arbol=%s" % h_arbol)
    print("  hash_previo=%s" % (hash_previo or "(primer sello)"))
    print("  hash_cadena=%s" % registro["hash_cadena"])
    return 0


def verificar(sello_id=None):
    sellos = listar_sellos()
    if not sellos:
        print("[sello] no hay sellos en legal/sellos/")
        return 1
    if sello_id:
        elegido = [(i, p) for i, p in sellos if i == sello_id]
        if not elegido:
            print("[sello] sello %s no encontrado" % sello_id)
            return 1
        sid, ruta = elegido[0]
    else:
        sid, ruta = sellos[-1]
    reg = leer_sello(ruta)
    discrepancias, faltantes = [], []
    for item in reg.get("arbol", []):
        abs_p = os.path.join(RAIZ, item["ruta"].replace("/", os.sep))
        if not os.path.isfile(abs_p):
            faltantes.append(item["ruta"])
            continue
        real = sha256_archivo(abs_p)
        if real != item["sha256"]:
            discrepancias.append((item["ruta"], item["sha256"], real))
    ok = not discrepancias and not faltantes
    print("[sello] verificando %s (%d archivos)" % (sid, len(reg.get("arbol", []))))
    for ruta, esp, real in discrepancias:
        print("  [ALTERADO] %s" % ruta)
        print("      esperado %s" % esp)
        print("      real     %s" % real)
    for ruta in faltantes:
        print("  [FALTA] %s" % ruta)
    if ok:
        print("  OK: %d archivos intactos (hash_arbol=%s)" % (len(reg.get("arbol", [])), reg.get("hash_arbol")))
        return 0
    print("  %d alterado(s), %d faltante(s)" % (len(discrepancias), len(faltantes)))
    return 1


def validar_cadena():
    sellos = listar_sellos()
    if not sellos:
        print("[sello] no hay sellos")
        return 1
    previo = None
    roto = 0
    for sid, ruta in sellos:
        reg = leer_sello(ruta)
        esperado = hash_cadena(previo, reg.get("hash_arbol", ""))
        if reg.get("hash_previo") != previo:
            print("  [CADENA-ROTA] %s: hash_previo=%s, esperado=%s"
                  % (sid, reg.get("hash_previo"), previo))
            roto += 1
        elif reg.get("hash_cadena") != esperado:
            print("  [CADENA-ROTA] %s: hash_cadena no cierra" % sid)
            roto += 1
        previo = reg.get("hash_cadena")
    print("[sello] cadena de %d sello(s): %s" % (len(sellos), "ROTA" if roto else "INTACTA"))
    return 1 if roto else 0


def main():
    p = argparse.ArgumentParser(description="Sellado SHA-256 de versiones maestras")
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument("--crear", action="store_true")
    g.add_argument("--verificar", action="store_true")
    g.add_argument("--listar", action="store_true")
    g.add_argument("--cadena", action="store_true")
    p.add_argument("--sello", default=None, help="ID de sello (YYYYMMDDTHHMMSSZ)")
    p.add_argument("--paths", nargs="*", default=None, help="rutas a sellar (override)")
    a = p.parse_args()

    if a.listar:
        sellos = listar_sellos()
        for sid, ruta in sellos:
            reg = leer_sello(ruta)
            print("  %s  archivos=%-5d bytes=%-9d hash_arbol=%s"
                  % (sid, reg.get("archivos", 0), reg.get("bytes_totales", 0),
                     str(reg.get("hash_arbol"))[:16]))
        print("Total: %d sello(s)" % len(sellos))
        return 0
    if a.cadena:
        return validar_cadena()
    if a.verificar:
        return verificar(a.sello)

    rutas, excluir = cargar_alcance()
    if a.paths is not None:
        rutas = a.paths
    if not rutas:
        print("[sello] sin rutas: definí seal_scope.json o pasá --paths")
        return 1
    return crear(rutas, excluir)


if __name__ == "__main__":
    sys.exit(main())
