#!/usr/bin/env python3
# Validador de cobertura de glifos de fuentes (Bloque D, tarea 31 del
# backlog Ling-3.1-Flash).
#
# Uso:
#   python scripts/validar_glifos_fuentes.py [--json-dir DIR] [--po-dir DIR]
#                                            [--font-dir DIR] [--fonts F1,F2]
#
# Que hace (report-only, exit 0=todo cubierto / 1=glifos faltantes):
#   1. Extrae el conjunto de caracteres no-ASCII requeridos por los
#      catalogos (ES/EN/PT JSON + .po).
#   2. Parsea el cmap de cada fuente TTF/OTF (formatos 0/4/6/12,
#      stdlib pura — sin fontTools).
#   3. Reporta por fuente los caracteres requeridos NO cubiertos y
#      donde se usan (clave / msgid) los faltantes.
#
# Metodologia: Tanda 9 del canal Ling-3.1-Flash (2026-10-17).
# Los glifos faltantes en contenido runtime son deuda M88 (fuentes) —
# la correccion (anadir glifos, reemplazar caracteres o fallback de
# fuente) es decision del dueño de M88 / fundador.

import argparse
import json
import os
import re
import struct
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JSON_DIR = os.path.join(RAIZ, "game", "isla-ancestral", "data", "localizacion")
PO_DIR = os.path.join(RAIZ, "game", "isla-ancestral", "locales")
FONT_DIR = os.path.join(RAIZ, "game", "isla-ancestral", "assets", "fonts")
FUENTES = ("Nunito-Regular.ttf", "Nunito-Bold.ttf",
           "Nunito-Variable.ttf", "FredokaOne-Regular.ttf")


def parse_cmap(ruta):
    with open(ruta, "rb") as f:
        data = f.read()
    if data[:4] not in (b"\x00\x01\x00\x00", b"OTTO", b"true", b"typ1"):
        raise ValueError("no es TTF/OTF: %r" % data[:4])
    num_tables = struct.unpack(">H", data[4:6])[0]
    cmap_off = None
    for i in range(num_tables):
        off = 12 + i * 16
        if data[off:off+4] == b"cmap":
            cmap_off = struct.unpack(">I", data[off+8:off+12])[0]
            break
    if cmap_off is None:
        raise ValueError("sin tabla cmap")
    num_sub = struct.unpack(">H", data[cmap_off+2:cmap_off+4])[0]
    subtablas = []
    for i in range(num_sub):
        p = cmap_off + 4 + i * 8
        plat, enc = struct.unpack(">HH", data[p:p+4])
        sub_off = struct.unpack(">I", data[p+4:p+8])[0]
        subtablas.append((plat, enc, cmap_off + sub_off))

    cubiertos = set()

    def leer_formato4(off):
        (length, language, seg_x2, sr, es, rs) = struct.unpack(
            ">HHHHHH", data[off+2:off+14])
        seg = seg_x2 // 2
        base = off + 14
        end_codes = struct.unpack(">%dH" % seg, data[base:base+seg*2])
        base2 = base + seg*2 + 2
        start_codes = struct.unpack(">%dH" % seg, data[base2:base2+seg*2])
        base3 = base2 + seg*2
        deltas = struct.unpack(">%dh" % seg, data[base3:base3+seg*2])
        base4 = base3 + seg*2
        range_offs = struct.unpack(">%dH" % seg, data[base4:base4+seg*2])
        glyph_array_off = base4 + seg*2
        for i in range(seg):
            for c in range(start_codes[i], min(end_codes[i], 0xFFFF) + 1):
                if c == 0xFFFF:
                    continue
                if range_offs[i] == 0:
                    gid = (c + deltas[i]) & 0xFFFF
                else:
                    idx = i + (c - start_codes[i]) + range_offs[i] // 2
                    pos = glyph_array_off + idx * 2
                    if pos + 2 > off + length:
                        gid = 0
                    else:
                        gid = struct.unpack(">H", data[pos:pos+2])[0]
                if gid != 0:
                    cubiertos.add(c)

    def leer_formato12(off):
        (length, language, num_groups) = struct.unpack(">III", data[off+4:off+16])
        for g in range(num_groups):
            p = off + 16 + g * 12
            sc, ec, sg = struct.unpack(">III", data[p:p+12])
            for c in range(sc, ec + 1):
                cubiertos.add(c)

    def leer_formato0(off):
        for c in range(256):
            if data[off+6+c] != 0:
                cubiertos.add(c)

    def leer_formato6(off):
        (length, language, first, count) = struct.unpack(">HHHH", data[off+2:off+10])
        for i in range(count):
            gid = struct.unpack(">H", data[off+10+i*2:off+12+i*2])[0]
            if gid != 0:
                cubiertos.add(first + i)

    for plat, enc, off in subtablas:
        fmt = struct.unpack(">H", data[off:off+2])[0]
        try:
            if fmt == 0:
                leer_formato0(off)
            elif fmt == 4:
                leer_formato4(off)
            elif fmt == 6:
                leer_formato6(off)
            elif fmt == 12:
                leer_formato12(off)
        except Exception as e:
            print("  (subtabla plat=%d enc=%d fmt=%d no parseada: %s)"
                  % (plat, enc, fmt, e))
    return cubiertos


def extraer_requeridos(json_dir, po_dir):
    req = set()
    for nombre in ("es", "en", "pt"):
        ruta = os.path.join(json_dir, "strings_%s.json" % nombre)
        d = json.loads(open(ruta, "rb").read().decode("utf-8"))

        def walk(o):
            if isinstance(o, dict):
                for v in o.values():
                    walk(v)
            elif isinstance(o, str):
                for ch in o:
                    if ord(ch) > 127:
                        req.add(ch)
        walk(d)
    for nombre in ("es", "en"):
        ruta = os.path.join(po_dir, "%s.po" % nombre)
        texto = open(ruta, "rb").read().decode("utf-8")
        for m in re.finditer(r'msgstr "(.*)"', texto):
            for ch in m.group(1):
                if ord(ch) > 127:
                    req.add(ch)
    return req


def safe(s):
    return "".join(ch if ord(ch) < 128 else "<U+%04X>" % ord(ch) for ch in s)


def usar_en(req_faltantes, json_dir, po_dir):
    uso = {}
    for nombre in ("es", "en", "pt"):
        ruta = os.path.join(json_dir, "strings_%s.json" % nombre)
        d = json.loads(open(ruta, "rb").read().decode("utf-8"))

        def walk(o, prefix):
            if isinstance(o, dict):
                for k, v in o.items():
                    walk(v, prefix + k + ".")
            elif isinstance(o, str):
                for ch in req_faltantes:
                    if ch in o:
                        uso.setdefault(ch, []).append(
                            "%s[%s]" % (nombre, prefix.rstrip(".")))
        walk(d, "")
    for nombre in ("es", "en"):
        ruta = os.path.join(po_dir, "%s.po" % nombre)
        texto = open(ruta, "rb").read().decode("utf-8")
        for m in re.finditer(r'msgid "(.*)"\s*\nmsgstr "(.*)"', texto):
            for ch in req_faltantes:
                if ch in m.group(1) or ch in m.group(2):
                    uso.setdefault(ch, []).append(
                        "%s.po msgid=%s" % (nombre, safe(m.group(1))[:40]))
    return uso


def main():
    ap = argparse.ArgumentParser(description="Validador de glifos de fuentes")
    ap.add_argument("--json-dir", default=JSON_DIR)
    ap.add_argument("--po-dir", default=PO_DIR)
    ap.add_argument("--font-dir", default=FONT_DIR)
    ap.add_argument("--fonts", default=",".join(FUENTES))
    args = ap.parse_args()

    requeridos = extraer_requeridos(args.json_dir, args.po_dir)
    print("=== Validador de glifos (M88, tarea 31) ===")
    print("caracteres no-ASCII requeridos por los catalogos (%d):"
          % len(requeridos))
    print("  " + " ".join("U+%04X" % ord(c) for c in sorted(requeridos)))
    print()

    errores = 0
    for fuente in args.fonts.split(","):
        ruta = os.path.join(args.font_dir, fuente)
        if not os.path.exists(ruta):
            print("%s: NO EXISTE" % fuente)
            errores += 1
            continue
        cubiertos = parse_cmap(ruta)
        faltantes = sorted(requeridos - {chr(c) for c in cubiertos})
        print("%s: %d/%d cubiertos"
              % (fuente, len(requeridos) - len(faltantes), len(requeridos)))
        if faltantes:
            errores += len(faltantes)
            print("  FALTAN: " + " ".join("U+%04X" % ord(c) for c in faltantes))
            uso = usar_en(faltantes, args.json_dir, args.po_dir)
            for ch in faltantes:
                hits = uso.get(ch, [])
                print("    U+%04X usado en %d lugar(es):" % (ord(ch), len(hits)))
                for h in hits[:10]:
                    print("      %s" % safe(h)[:70])
                if len(hits) > 10:
                    print("      ... y %d mas" % (len(hits) - 10))
        else:
            print("  OK: todos los glifos requeridos presentes")
        print()

    print("=== VEREDICTO ===")
    if errores:
        print("ERROR: %d glifo(s) requerido(s) no cubierto(s) por las fuentes"
              % errores)
        return 1
    print("LIMPIO: todas las fuentes cubren los caracteres requeridos")
    return 0


if __name__ == "__main__":
    sys.exit(main())
