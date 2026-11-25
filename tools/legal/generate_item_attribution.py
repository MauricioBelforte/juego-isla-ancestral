#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
# M159 legal-tools (encargo director #784): inyecta metadata/atribucion embebida
# (tEXt PNG: Copyright/Author) en los 300 PNG de assets/2d/items_m159/, usando el
# modelo LicenseProfile de asset_attribution_generator.gd (M83 item 1). Cierra el
# job legal-tools en verde (validate_asset_metadata.py --check).
#
# Uso:
#   python3 tools/legal/generate_item_attribution.py --aplicar    # inyecta en disco
#   python3 tools/legal/generate_item_attribution.py --check      # exit 1 si falta
#
import os, sys, zlib, argparse, struct

PROJ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
M159 = os.path.join(PROJ, "game", "isla-ancestral", "assets", "2d", "items_m159")

# Metadata tipo LicenseProfile por item (author / license / copyright).
AUTOR = "agnes-3-flash (Sapiens AI) / Kilo Code - Isla Ancestral Team"
LICENCIA = "LicenseRef-Propietaria (Isla Ancestral)"


def copyright_de(nombre):
    base = os.path.splitext(nombre)[0]
    return "(c) 2026 Isla Ancestral Team. M159 %s. %s" % (base, LICENCIA)


def texto_textr(nombre):
    """Datos tEXt (keyword NUL value NUL ...). El validador busca Copyright/Author."""
    datos = b""
    for kw, val in (("Copyright", copyright_de(nombre)),
                    ("Author", AUTOR),
                    ("Software", "Godot 4.7.2"),
                    ("Description", "M159 item icono (catalogo de objetos)")):
        datos += kw.encode("latin-1") + b"\x00" + val.encode("latin-1") + b"\x00"
    return datos


def chunks_textr(b):
    """Devuelve los tEXt existentes (texto crudo) de un PNG, para idempotencia."""
    ts, pos = [], 8
    while pos + 8 <= len(b):
        largo, tipo = struct.unpack(">I4s", b[pos:pos + 8])
        if tipo == b"IEND":
            break
        if tipo == b"tEXt":
            ts.append(b[pos + 8:pos + 8 + largo])
        pos += 12 + largo
    return ts


def tiene_atribucion(b):
    for t in chunks_textr(b):
        low = t.lower()
        if b"copyright" in low or b"author" in low or b"artist" in low:
            return True
    return False


def inyectar(ruta, aplicar=True):
    """(bool cambiado, str motivo). Inyecta el tEXt si no hay atribucion."""
    with open(ruta, "rb") as fh:
        b = fh.read()
    if b[:8] != b"\x89PNG\r\n\x1a\n":
        return False, "no-es-png"
    if tiene_atribucion(b):
        return False, "ya-tiene-atribucion"
    datos = texto_textr(os.path.basename(ruta))
    iend = b.rfind(b"IEND")
    if iend < 0:
        return False, "sin-iend"
    tipo = b"tEXt"
    crc = zlib.crc32(tipo + datos) & 0xFFFFFFFF
    chunk = struct.pack(">I", len(datos)) + tipo + datos + struct.pack(">I", crc)
    nuevo = b[:iend - 4] + chunk + b[iend - 4:]
    if aplicar:
        with open(ruta, "wb") as fh:
            fh.write(nuevo)
    return True, "inyectado"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--aplicar", action="store_true")
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()
    if not os.path.isdir(M159):
        print("[FALLO] falta %s" % M159); return 1
    pngs = sorted(n for n in os.listdir(M159) if n.lower().endswith(".png"))
    sin, ya = [], []
    for n in pngs:
        con = os.path.join(M159, n)
        c, motivo = inyectar(con, aplicar=args.aplicar)
        if c:
            sin.append(n) if args.check else None
            print("OK  %s -> %s" % (n, motivo))
        elif motivo == "ya-tiene-atribucion":
            ya.append(n)
        else:
            print("[FALLO] %s: %s" % (n, motivo)); return 1
    if args.check:
        # en --check no modifica; falla si hay PNG sin atribucion
        if sin:
            print("=== %d PNG sin atribucion (quedarian nuevos en --check) ===" % len(sin))
            return 1
    print("=== %d PNG | %d inyectados/ok | %d ya tenian ===" % (len(pngs), len(pngs) - len(ya), len(ya)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
