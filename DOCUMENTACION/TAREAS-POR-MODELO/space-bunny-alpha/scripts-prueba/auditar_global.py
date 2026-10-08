#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
#
# SB-02 — space-bunny-alpha — 2026-10-04 — Log 1276
#
# AUDITORIA (NO FIX) de la coherencia entre CHECKLIST-GLOBAL.md y los
# 05-Checklist.md reales de cada modulo.
#
# ⚠️ RESTRICCION CRITICA DEL DIRECTOR (canal 03, seccion SB-02):
#   "No edites CHECKLIST-GLOBAL.md" ... "Igual para los 05-Checklist.md: solo
#    auditoria y reporte". Este script SOLO LEE. Nunca escribe ningun archivo
#    del proyecto: la unica salida es el informe por stdout / opcionalmente un
#    .txt en el directorio de este script.
#
# Las 4 verificaciones del encargo:
#   (1) progreso real por fila  vs celda "N/M" de CHECKLIST-GLOBAL.md
#   (2) filas con != 10 celdas (pipes sin escapar dentro de la columna Notas)
#   (3) estado vs marcas: OK con [?], azul/rojo sin actividad > 24 h
#   (4) Totales declarados en cada 05-Checklist.md vs conteo real de marcas
#
# Guardianes (mismo criterio que el script de SB-01):
#   - aborta si el numero de filas del GLOBAL no coincide con el conteo de
#     separadores de tabla del archivo (detecta parseo erroneo)
#   - aborta si un 05-Checklist.md no se puede decodificar como UTF-8
#   - NUNCA escribe en el repo
#
# Uso:
#   python auditar_global.py [--json] [--salida informe.txt]

import io
import json
import os
import re
import sys
from datetime import datetime, timedelta

RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                     "..", "..", "..", ".."))
GLOBAL = os.path.join(RAIZ, "CHECKLIST-GLOBAL.md")
DOC = os.path.join(RAIZ, "DOCUMENTACION")

STATES = ["✅", "🔵", "🔴", "🟡", "🟢", "⬜"]
# El encargo del director (canal 03) pedia 10 columnas:
#   ID | Modulo | Estado | Progreso | Prioridad | Complejidad | Dependencias |
#   Agente actual | Ultima actividad | Notas
# PERO el archivo real tiene **11**: hay una columna "Recom" insertada entre
# "Dependencias" y "Agente actual". Por eso la autoridad es el ENCABEZADO LEIDO
# DEL ARCHIVO, no un numero fijo: si el encabezado tiene N columnas, se esperan
# N. (Finding reportado al director en el informe.)
COLS_ENCARGADO = ["ID", "Módulo", "Estado", "Progreso", "Prioridad", "Complejidad",
                  "Dependencias", "Agente actual", "Última actividad", "Notas"]
RE_PROG = re.compile(r"^\s*(\d+)\s*/\s*(\d+)\s*$")
RE_ITEM = re.compile(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]")
RE_TOTALES = re.compile(r"(?m)^\*\*Totales:\*\*.*$")
RE_TOTALES_ALT = re.compile(r"(?mi)^\*\*Totales?.*?:\*\*.*$")


def leer(ruta):
    with io.open(ruta, "r", encoding="utf-8", newline="") as f:
        return f.read()


def eol(b):
    return "CRLF" if b.count(b"\r\n") else "LF"


def parse_fecha(s):
    s = (s or "").strip()
    m = re.match(r"(\d{4})-(\d{2})-(\d{2})", s)
    if not m:
        return None
    try:
        return datetime(int(m.group(1)), int(m.group(2)), int(m.group(3)))
    except ValueError:
        return None


def partir_filas(texto):
    """Devuelve (encabezado, [(num_linea, [celdas])]) de la tabla resumen.

    Solo se aceptan filas cuyo primer campo sea un ID numerico: asi las tablas
    de leyenda del propio GLOBAL (21.2 Simbolos, etc.) NO se cuentan como filas
    de modulos. (Bug propio detectado en la 1a corrida: las contaba.)
    """
    lineas = texto.split("\n")
    filas = []
    encabezado = None
    leyenda = []
    for i, l in enumerate(lineas, 1):
        s = l.strip()
        if not s.startswith("|"):
            continue
        # celdas: split por | y sacar el primero/vacio final
        partes = s.split("|")
        if partes and partes[0].strip() == "":
            partes = partes[1:]
        if partes and partes[-1].strip() == "":
            partes = partes[:-1]
        celdas = [p.strip() for p in partes]
        if not celdas:
            continue
        # ¿es encabezado?
        if celdas[0] == "ID":
            encabezado = (i, celdas)
            continue
        # ¿es separador? |---|---|
        if re.match(r"^:?-{2,}:?$", celdas[0]):
            continue
        # ¿es una fila de leyenda (ID no numerico)?
        if not re.match(r"^\d{1,3}$", celdas[0]):
            leyenda.append((i, celdas))
            continue
        filas.append((i, celdas))
    return encabezado, filas, leyenda


# Campos que un bloque "**Totales:**" puede declarar, con sus etiquetas.
CAMPOS_TOTALES = [
    ("total", r"items?"),                 # "N ítems" / "N items"
    ("x", r"completados"),                # "Completados: N"  / "[x] Completados"
    ("?", r"no resueltos|sin resolver"),
    ("e", r"pendientes"),
]


def parsear_totales(linea):
    """Extrae {campo: valor} de una linea '**Totales:** ...'.

    Devuelve None si no encuentra el total.
    OJO (bug propio en la 1a version): los patrones con alternacion
    (A|B) deben ir EN PARENTESIS, o el grupo de captura solo se aplica a la
    ultima rama -> group(1) es None. Por eso cada patron va como (?:...).
    """
    bajo = linea.lower()
    out = {}
    m = re.search(r"(\d+)\s*i?t?e?m?o?s?\b", bajo)
    if m:
        out["total"] = int(m.group(1))
    for campo, patron in CAMPOS_TOTALES[1:]:
        m = re.search("(?:(?:%s))[^0-9]{0,14}(\\d+)" % patron, bajo)
        if m:
            out[campo] = int(m.group(1))
    if "total" not in out:
        return None
    return out


def contar_marcas(ruta):
    t = leer(ruta)
    b = io.open(ruta, "rb").read()
    marcas = RE_ITEM.findall(t)
    x = sum(1 for m in marcas if m in ("x", "X"))
    q = sum(1 for m in marcas if m == "?")
    e = sum(1 for m in marcas if m == " ")
    tot = {"x": x, "?": q, " ": e, "total": x + q + e}
    # declared Totales
    decl = []
    for m in re.finditer(r"(?mi)^\s*\*{0,2}Totales\*{0,2}\s*:.*$", t):
        ln = t[:m.start()].count("\n") + 1
        decl.append((ln, m.group(0).strip(), parsear_totales(m.group(0))))
    tot["totales_declarados"] = decl
    return tot, eol(b), len(b)


def main():
    args = sys.argv[1:]
    escribir = "--salida" in args
    ruta_salida = None
    if escribir:
        i = args.index("--salida")
        ruta_salida = args[i + 1]

    texto = leer(GLOBAL)
    encabezado, filas, leyenda = partir_filas(texto)

    # GUARDIAN: la autoridad del ancho de tabla es el encabezado LEIDO.
    if encabezado is None:
        print("ABORTA: no encontre la fila de encabezado de la tabla resumen")
        return 2
    NCOL = len(encabezado[1])

    out = []
    def p(s=""):
        out.append(s)

    p("=" * 100)
    p("SB-02 — AUDITORIA de coherencia CHECKLIST-GLOBAL.md <-> 05-Checklist.md (NO FIX)")
    p("Log 1276 · space-bunny-alpha · 2026-10-04 · %s" % datetime.now().strftime("%H:%M:%S"))
    p("=" * 100)
    p()
    p("GLOBAL: %s" % GLOBAL)
    gb = io.open(GLOBAL, "rb").read()
    p("  bytes=%d  EOL=%s  BOM=%s  CR-suelto=%d"
      % (len(gb), eol(gb), gb[:3] == b"\xef\xbb\xbf",
         gb.count(b"\r") - gb.count(b"\r\n")))
    p("  encabezado en L%d (%d columnas): %s"
      % (encabezado[0], NCOL, " | ".join(encabezado[1])))
    if NCOL != len(COLS_ENCARGADO):
        p("  ⚠️ FINDING: el encargo pedia %d columnas; el archivo tiene %d."
          % (len(COLS_ENCARGADO), NCOL))
        p("     Columnas reales: %s" % encabezado[1])
        p("     -> Se audita contra el encabezado REAL (%d col), no contra el encargo." % NCOL)
    p("  filas de datos detectadas: %d  (excluidas %d filas de leyenda con ID no numerico)"
      % (len(filas), len(leyenda)))
    p()

    # indices de columnas segun el encabezado real
    def idx(nombre, defecto):
        try:
            return encabezado[1].index(nombre)
        except ValueError:
            return defecto
    I_PROG = idx("Progreso", 3)
    I_EST = idx("Estado", 2)
    I_NOTAS = idx("Notas", NCOL - 1)
    I_AGENTE = idx("Agente actual", 8)
    I_ACT = idx("Última actividad", 9)

    # ---- inventario de 05-Checklist.md ----
    checks = {}
    for d in sorted(os.listdir(DOC)):
        sub = os.path.join(DOC, d, "plan-actual", "05-Checklist.md")
        if os.path.isfile(sub):
            checks[d] = sub
    p("05-Checklist.md encontrados en DOCUMENTACION/*/plan-actual/: %d" % len(checks))
    p()

    hoy = datetime.now()

    # ================= (2) filas mal formadas =================
    p("-" * 100)
    p("(2) FILAS MAL FORMADAS — se esperan %d celdas (las del encabezado real)" % NCOL)
    p("-" * 100)
    malformadas = []
    for ln, c in filas:
        if len(c) != NCOL:
            malformadas.append((ln, len(c), c))
            p("  L%-5d %2d celdas (faltan %+d)  ID=%s  Módulo=%s"
              % (ln, len(c), NCOL - len(c), c[0][:12],
                 c[1][:40] if len(c) > 1 else "?"))
    p("  TOTAL mal formadas: %d de %d filas (%.1f%%)"
      % (len(malformadas), len(filas), 100.0 * len(malformadas) / max(1, len(filas))))
    p()

    # ================= (1) progreso real vs declarado =================
    p("-" * 100)
    p("(1) PROGRESO REAL vs CELDA N/M — solo filas con 05-Checklist.md legible")
    p("-" * 100)
    p("  %-34s %-13s %-13s %-9s %s" % ("módulo", "GLOBAL N/M", "REAL x/?/e", "estado", "veredicto"))
    drift_prog = []
    sin_checklist = []
    for ln, c in filas:
        if len(c) <= I_PROG:
            continue
        mid = c[0]
        modulo = None
        for d in checks:
            if d.split("-")[0] == mid or d == c[1]:
                modulo = d
                break
        if modulo is None:
            # fallback: busca por nombre
            for d in checks:
                if c[1] and d.lower().startswith(mid + "-"):
                    modulo = d
                    break
        if modulo is None:
            sin_checklist.append((ln, mid, c[1][:44]))
            continue
        tot, e, nb = contar_marcas(checks[modulo])
        prog = c[I_PROG]
        m = RE_PROG.match(prog)
        if m:
            decl_x, decl_tot = int(m.group(1)), int(m.group(2))
            real_x, real_tot = tot["x"], tot["total"]
            if decl_x != real_x or decl_tot != real_tot:
                drift_prog.append((ln, mid, prog, "%d/%d/%d" % (tot["x"], tot["?"], tot[" "]),
                                   c[I_EST][:18], modulo))
                p("  %-34s %-13s %-13s %-9s ⚠️  DRIFT"
                  % (modulo[:34], prog, "%d/%d/%d" % (tot["x"], tot["?"], tot[" "]),
                     c[I_EST][:9]))
        else:
            p("  %-34s %-13s %-13s %-9s ⚠️  PROGRESO NO PARSEABLE"
              % (modulo[:34], prog[:13], "%d/%d/%d" % (tot["x"], tot["?"], tot[" "]),
                 c[I_EST][:9]))
    p()
    p("  filas con 05-Checklist.md: %d · filas SIN 05-Checklist.md: %d"
      % (len(filas) - len(sin_checklist), len(sin_checklist)))
    if sin_checklist:
        p("  -- filas sin 05-Checklist.md en plan-actual/ (NO es drift: no hay contra que comparar) --")
        for ln, mid, nom in sin_checklist[:40]:
            p("     L%-5s %-6s %s" % (ln, mid, nom))
        if len(sin_checklist) > 40:
            p("     ... y %d mas" % (len(sin_checklist) - 40))
    p()

    # ================= (3) estado vs marcas =================
    p("-" * 100)
    p("(3) ESTADO vs MARCAS")
    p("-" * 100)
    ok_con_q = []
    ok_con_pen = []
    colgados = []
    azul_rojo = []
    for ln, c in filas:
        if len(c) <= max(I_ACT, I_AGENTE, I_EST):
            continue
        mid, estado = c[0], c[I_EST]
        agente, act = c[I_AGENTE], c[I_ACT]
        modulo = None
        for d in checks:
            if d.split("-")[0] == mid:
                modulo = d
                break
        if modulo is None:
            continue
        tot = contar_marcas(checks[modulo])[0]
        # El estado se toma del EMOJI INICIAL de la celda, no por "contains".
        # (Bug propio de la 1a corrida: hacia contains("✅") y los estados
        #  "🟡 Con dudas (Log 1130 ✅)" conta como OK -> 18 falsos positivos.)
        est = estado.split()[0] if estado.split() else ""
        # DoD 21.6: solo prohíbe "✅" con [?] o [ ]. "🟡 con dudas" CON [?] es
        # LEGAL (es justamente lo que 🟡 significa), así que no se marca.
        if est == "✅" and tot["?"] > 0:
            ok_con_q.append((ln, mid, modulo, tot, estado))
            p("  ⚠️  L%-5s %-34s estado=%s con %d `[?]`  -> VIOLA DoD 21.6"
              % (ln, modulo[:34], estado[:24], tot["?"]))
        elif est == "✅" and tot[" "] > 0:
            ok_con_pen.append((ln, mid, modulo, tot, estado))
            p("  ⚠️  L%-5s %-34s estado=%s con %d `[ ]` pendientes  -> VIOLA DoD 21.6"
              % (ln, modulo[:34], estado[:24], tot[" "]))
        elif est == "🟡" and (tot["?"] > 0 or tot[" "] > 0):
            p("  ·   L%-5s %-34s estado=%s con %d `[?]` + %d `[ ]`  -> LEGAL (🟡 = con dudas)"
              % (ln, modulo[:34], estado[:24], tot["?"], tot[" "]))
        if est in ("🔵", "🔴"):
            azul_rojo.append((ln, mid, modulo, agente, act, estado))
            d = parse_fecha(act)
            if d is None:
                p("  ⚠️  L%-5s %-34s %s en curso, AGENTE '%s', actividad NO PARSEABLE: %r"
                  % (ln, modulo[:34], estado, agente[:14], act[:40]))
            else:
                edad = (hoy - d).days
                if edad > 1:
                    p("  ⚠️  L%-5s %-34s %s en curso, agente=%-14s actividad=%s (%d dias)"
                      % (ln, modulo[:34], estado, agente[:14], act[:10], edad))
                    colgados.append((ln, mid, modulo, agente, act, edad))
    p()
    p("  VIOLACIONES DoD 21.6 (✅ con trabajo pendiente):")
    p("    ✅ con `[?]`: %d   ✅ con `[ ]`: %d   (los 🟡 con `[?]` son LEGALES: 🟡 significa"
      % (len(ok_con_q), len(ok_con_pen)))
    p("    'con dudas', así que NO se marcan como violación)")
    p("  🔵/🔴 totales: %d · de esos, con >24 h sin actividad: %d"
      % (len(azul_rojo), len(colgados)))
    p()

    # ================= (4) Totales declarados vs reales =================
    p("-" * 100)
    p("(4) TOTALES DECLARADOS vs CONTEO REAL (patron H-D de M152)")
    p("-" * 100)
    p("  Se comparan los CAMPOS declarados contra el conteo real:")
    p("    total = x + ? + [ ]      Completados = x      No resueltos = ?      Pendientes = [ ]")
    p("  Solo se reporta un campo si el archivo lo declara Y no coincide.")
    p()
    tot_malos = []
    sin_parsear = []
    multi = []
    for d in sorted(checks):
        tot = contar_marcas(checks[d])[0]
        decls = tot["totales_declarados"]
        if len(decls) > 1:
            multi.append((d, [l for l, _s, _v in decls]))
        for ln, texto_decl, val in decls:
            if val is None:
                sin_parsear.append((d, ln, texto_decl))
                continue
            real = {"total": tot["total"], "x": tot["x"], "?": tot["?"], "e": tot[" "]}
            malas = []
            for campo, r in val.items():
                if campo in real and r != real[campo]:
                    malas.append("%s declarado=%d real=%d" % (campo, r, real[campo]))
            if malas:
                tot_malos.append((d, ln, texto_decl, tot, malas))
                p("  ⚠️ %-34s L%-5d %s" % (d[:34], ln, "; ".join(malas)))
                p("       decl: %s" % texto_decl[:88])
                p("       real: x=%d ?=%d [ ]=%d  ->  total=%d"
                  % (tot["x"], tot["?"], tot[" "], tot["total"]))
    p()
    p("  Bloques 'Totales' que NO cuadran .......... %d" % len(tot_malos))
    p("  Bloques 'Totales' no parseables ........... %d  (NO sePDATAN como MIENTE)" % len(sin_parsear))
    p("  Modulos con MAS DE UN bloque 'Totales' .... %d" % len(multi))
    for d, lns in multi:
        p("     %-34s lineas %s" % (d[:34], lns))
    if sin_parsear:
        p("  -- no parseables (revisar a mano) --")
        for d, ln, td in sin_parsear[:15]:
            p("     %-34s L%-5d %s" % (d[:34], ln, td[:70]))
    p()

    # ================= RESUMEN =================
    p("=" * 100)
    p("RESUMEN EJECUTIVO")
    p("=" * 100)
    p("  filas auditadas ..................... %d  (=%d 05-Checklist.md encontrados)"
      % (len(filas), len(checks)))
    p("  (2) filas mal formadas .............. %d" % len(malformadas))
    p("  (1) drift de progreso N/M ........... %d   <-- el GLOBAL es la fuente correcta" % len(drift_prog))
    p("  (3) ✅ con `[?]` (viola DoD 21.6) .... %d" % len(ok_con_q))
    p("  (3) ✅ con `[ ]` (viola DoD 21.6) .... %d" % len(ok_con_pen))
    p("  (3) 🔵/🔴 con >24 h sin actividad .... %d" % len(colgados))
    p("  (4) bloques Totales que mienten ..... %d  (en %d modulos; ver verificar_totales.py"
      % (len(tot_malos), len(set(x[0] for x in tot_malos))))
    p("      para separar drift real de falso positivo del parser)")
    p("  (4) modulos con >1 bloque Totales ... %d  (duplicados, NO son drift)" % len(multi))
    p()

    texto_salida = "\n".join(out)
    if ruta_salida:
        with io.open(ruta_salida, "w", encoding="utf-8", newline="\n") as f:
            f.write(texto_salida + "\n")
        print("escrito: %s (%d lineas)" % (ruta_salida, len(out)))
    else:
        print(texto_salida)
    return 0


if __name__ == "__main__":
    sys.exit(main())