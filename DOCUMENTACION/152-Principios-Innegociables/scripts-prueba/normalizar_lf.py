#!/usr/bin/env python3
# SB-01 - space-bunny-alpha - 2026-10-04
# Normaliza finales de linea de un archivo de texto a LF, preservando el
# contenido y el BOM/encoding. Util para dejar el diff minimo y compatible con
# lo que git tiene en HEAD (AGENTS.md 28.3: no re-en-codear un archivo existente).
#
# Uso:  python normalizar_lf.py <ruta> [<ruta> ...]      (sin args = dry-run)

import io
import sys


def report(ruta, escribir):
    with io.open(ruta, "rb") as f:
        b = f.read()
    bom = b[:3] == b"\xef\xbb\xbf"
    n = b.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    if n == b:
        print("OK   (sin CRLF)  %s" % ruta)
        return 0
    if escribir:
        with io.open(ruta, "wb") as f:
            f.write(n)
        with io.open(ruta, "rb") as f:
            chk = f.read()
        if chk[:3] == b"\xef\xbb\xbf" and not bom:
            print("ERROR: aparecio BOM en %s" % ruta)
            return 2
    print("FIX  %-5d -> %-5d bytes  BOM=%s  %s"
          % (len(b), len(n), bom, ruta))
    return 1


def main():
    args = sys.argv[1:]
    escribir = bool(args)
    if not args:
        print("dry-run: sin rutas, nada que hacer")
        return 0
    cambios = 0
    for r in args:
        cambios += report(r, escribir)
    print("---")
    print("archivos con CRLF corregidos: %d" % cambios)
    return 0


if __name__ == "__main__":
    sys.exit(main())