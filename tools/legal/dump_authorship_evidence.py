#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.

# M127 iter. 3 (item L140) - Volcado de commits y diffs para pruebas periciales
# de autoria. Complementa a timestamp_seal.py: el sello prueba QUE EXISTIA y
# CUANDO; este volcado prueba QUIEN lo escribio y QUE cambio.
#
# Que produce:
#   legal/evidencia/autoria-<slug>_<marca>.txt   -> el volcado legible
#   legal/evidencia/autoria-<slug>_<marca>.sha256 -> el digest del volcado
#
# Por que el digest importa: un volcado sin huella no prueba nada (cualquiera lo
# reescribe). El .sha256 fija el contenido: si alguien edita el .txt, --verificar
# lo detecta. El volcado lleva la marca de tiempo en el nombre y en la cabecera,
# pero el CUERPO es determinista para un rango fijo de commits, y es el cuerpo lo
# que se hashea.
#
# ⚠️ Determinismo: SOLO para un rango CERRADO. Un rango abierto (hasta hoy/HEAD)
# cambia mientras corre — en un worktree compartido otros agentes commitean, y
# generar() tarda segundos porque hace un `git show --numstat` por commit.
# Medido: 187 commits, dos corridas seguidas dieron cuerpos distintos porque
# entro un commit ajeno en el medio. Para un volcado reproducible, cerra el
# rango con --hasta.
#
# Uso:
#   python tools/legal/dump_authorship_evidence.py --generar
#   python tools/legal/dump_authorship_evidence.py --generar --rutas game/isla-ancestral/scripts/legal
#   python tools/legal/dump_authorship_evidence.py --generar --desde 2026-09-01 --hasta 2026-09-18
#   python tools/legal/dump_authorship_evidence.py --verificar legal/evidencia/autoria-...txt
#   python tools/legal/dump_authorship_evidence.py --listar
#   python tools/legal/dump_authorship_evidence.py --json
#
# Exit 0 si OK, 1 si falla el volcado o la verificacion.

import os
import re
import sys
import json
import hashlib
import argparse
import subprocess
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
EVIDENCIA_DIR = os.path.join(PROJECT_ROOT, "legal", "evidencia")

# Separadores de campo/registro: ASCII US (0x1f) y RS (0x1e). No aparecen en
# nombres de autor, mensajes de commit ni rutas, asi que no hay ambiguedad.
US = "\x1f"
RS = "\x1e"

FORMATO = "%H" + US + "%an" + US + "%ae" + US + "%aI" + US + "%cI" + US + "%s" + RS


def git(*args):
    """Ejecuta git y devuelve (rc, stdout). Nunca lanza por rc != 0."""
    try:
        p = subprocess.run(["git"] + list(args), cwd=PROJECT_ROOT,
                           capture_output=True, text=True, encoding="utf-8", errors="replace")
        return p.returncode, p.stdout
    except OSError as e:
        return 1, ""


def hay_git():
    rc, _ = git("rev-parse", "--git-dir")
    return rc == 0


def leer_commits(rutas=None, desde=None, hasta=None):
    """[(hash, autor, email, fecha_autor, fecha_commit, asunto)]."""
    args = ["log", "--date-order", "--pretty=format:" + FORMATO]
    if desde:
        args.append("--since=" + desde)
    if hasta:
        args.append("--until=" + hasta)
    if rutas:
        args.append("--")
        args.extend(rutas)
    rc, salida = git(*args)
    if rc != 0:
        return []
    commits = []
    for registro in salida.split(RS):
        registro = registro.strip("\n")
        if not registro:
            continue
        campos = registro.split(US)
        if len(campos) >= 6:
            commits.append(tuple(campos[:6]))
    return commits


def diffstat(commit, rutas=None):
    """(archivos, inserciones, borrados) del commit."""
    args = ["show", "--numstat", "--format=", commit]
    if rutas:
        args.append("--")
        args.extend(rutas)
    rc, salida = git(*args)
    if rc != 0:
        return 0, 0, 0
    archivos = ins = bor = 0
    for linea in salida.splitlines():
        partes = linea.split("\t")
        if len(partes) < 3:
            continue
        archivos += 1
        if partes[0].isdigit():
            ins += int(partes[0])
        if partes[1].isdigit():
            bor += int(partes[1])
    return archivos, ins, bor


def construir_cuerpo(commits, rutas, desde, hasta):
    """Cuerpo determinista del volcado (sin marca de generacion)."""
    lineas = []
    lineas.append("EVIDENCIA DE AUTORIA - Isla Ancestral")
    lineas.append("=" * 72)
    lineas.append("Alcance   : %s" % (", ".join(rutas) if rutas else "TODO el repositorio"))
    lineas.append("Rango     : %s .. %s" % (desde or "inicio", hasta or "HEAD"))
    lineas.append("Commits   : %d" % len(commits))
    autores = sorted({(c[1], c[2]) for c in commits})
    lineas.append("Autores   : %d" % len(autores))
    lineas.append("")
    lineas.append("-" * 72)
    lineas.append("1. AUTORES")
    lineas.append("-" * 72)
    for nombre, email in autores:
        n = sum(1 for c in commits if c[1] == nombre and c[2] == email)
        lineas.append("  %-32s <%s>  %d commit(s)" % (nombre, email, n))
    lineas.append("")
    lineas.append("-" * 72)
    lineas.append("2. COMMITS (hash | autor | fecha_autor | fecha_commit | archivos | +/- | asunto)")
    lineas.append("-" * 72)
    tot_a = tot_i = tot_b = 0
    for c in commits:
        a, i, b = diffstat(c[0], rutas)
        tot_a += a
        tot_i += i
        tot_b += b
        lineas.append("%s | %s <%s> | %s | %s | %d | +%d/-%d | %s" % (
            c[0][:12], c[1], c[2], c[3], c[4], a, i, b, c[5]))
    lineas.append("")
    lineas.append("-" * 72)
    lineas.append("3. TOTALES")
    lineas.append("-" * 72)
    lineas.append("  archivos tocados : %d" % tot_a)
    lineas.append("  lineas agregadas : %d" % tot_i)
    lineas.append("  lineas borradas  : %d" % tot_b)
    if commits:
        lineas.append("  primer commit    : %s (%s)" % (commits[-1][0][:12], commits[-1][3]))
        lineas.append("  ultimo commit    : %s (%s)" % (commits[0][0][:12], commits[0][3]))
    lineas.append("")
    lineas.append("Nota: el CUERPO de este volcado es determinista para un rango fijo de")
    lineas.append("commits; la huella SHA-256 del archivo .sha256 cubre el archivo completo,")
    lineas.append("incluida la cabecera de generacion.")
    return "\n".join(lineas) + "\n"


def slug(texto):
    s = re.sub(r"[^a-z0-9]+", "-", texto.lower()).strip("-")
    return s[:48] or "repo"


def generar(rutas, desde, hasta, out_dir):
    if not hay_git():
        print("[FALLO] no hay repositorio git en %s" % PROJECT_ROOT)
        return None
    commits = leer_commits(rutas, desde, hasta)
    cuerpo = construir_cuerpo(commits, rutas, desde, hasta)
    marca = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    base = "autoria-%s_%s" % (slug(rutas[0]) if rutas and len(rutas) == 1 else "repo", marca)
    os.makedirs(out_dir, exist_ok=True)
    ruta_txt = os.path.join(out_dir, base + ".txt")
    ruta_sha = os.path.join(out_dir, base + ".sha256")

    cabecera = "Generado (UTC): %s\nHerramienta    : tools/legal/dump_authorship_evidence.py\n\n" % marca
    contenido = cabecera + cuerpo
    datos = contenido.encode("utf-8")
    digest = hashlib.sha256(datos).hexdigest()

    with open(ruta_txt, "wb") as fh:
        fh.write(datos)
    with open(ruta_sha, "w", encoding="ascii", newline="\n") as fh:
        fh.write("%s  %s\n" % (digest, os.path.basename(ruta_txt)))
    return {"txt": ruta_txt, "sha256": ruta_sha, "digest": digest,
            "commits": len(commits), "bytes": len(datos)}


def verificar(ruta_txt):
    """Recalcula el digest y lo compara con el .sha256 hermano."""
    if not os.path.isfile(ruta_txt):
        return False, "no existe %s" % ruta_txt
    ruta_sha = os.path.splitext(ruta_txt)[0] + ".sha256"
    if not os.path.isfile(ruta_sha):
        return False, "falta el .sha256 hermano (%s)" % ruta_sha
    with open(ruta_sha, "r", encoding="ascii") as fh:
        esperado = fh.read().split()[0].strip()
    with open(ruta_txt, "rb") as fh:
        real = hashlib.sha256(fh.read()).hexdigest()
    if real == esperado:
        return True, "huella intacta (%s)" % real[:16]
    return False, "HUELLA NO COINCIDE: esperado %s, real %s (el volcado fue alterado)" % (
        esperado[:16], real[:16])


def listar(out_dir):
    if not os.path.isdir(out_dir):
        return []
    return sorted(f for f in os.listdir(out_dir) if f.endswith(".txt"))


def main(argv=None):
    ap = argparse.ArgumentParser(description="Volcado de evidencia de autoria (M127 L140)")
    ap.add_argument("--generar", action="store_true")
    ap.add_argument("--verificar", metavar="ARCHIVO")
    ap.add_argument("--listar", action="store_true")
    ap.add_argument("--rutas", nargs="*", default=None)
    ap.add_argument("--desde")
    ap.add_argument("--hasta")
    ap.add_argument("--out-dir", default=EVIDENCIA_DIR)
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args(argv)

    if args.listar:
        archivos = listar(args.out_dir)
        if args.json:
            print(json.dumps({"out_dir": args.out_dir, "volcados": archivos}, ensure_ascii=False, indent=2))
        else:
            print("=== volcados de evidencia en %s (%d) ===" % (args.out_dir, len(archivos)))
            for f in archivos:
                print("   %s" % f)
        return 0

    if args.verificar:
        ok, msg = verificar(args.verificar)
        print("[%s] %s" % ("OK" if ok else "FALLO", msg))
        return 0 if ok else 1

    if args.generar:
        r = generar(args.rutas, args.desde, args.hasta, args.out_dir)
        if r is None:
            return 1
        if args.json:
            print(json.dumps(r, ensure_ascii=False, indent=2))
        else:
            print("=== dump_authorship_evidence (M127 / L140) ===")
            print("commits volcados : %d" % r["commits"])
            print("bytes            : %d" % r["bytes"])
            print("sha256           : %s" % r["digest"])
            print("volcado          : %s" % os.path.relpath(r["txt"], PROJECT_ROOT))
            print("huella           : %s" % os.path.relpath(r["sha256"], PROJECT_ROOT))
        return 0

    ap.print_help()
    return 0


if __name__ == "__main__":
    sys.exit(main())
