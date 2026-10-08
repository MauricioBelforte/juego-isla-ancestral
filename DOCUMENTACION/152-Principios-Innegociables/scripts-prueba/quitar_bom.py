# -*- coding: utf-8 -*-
"""SB-01 - space-bunny-alpha - 2026-10-04

Quita el BOM (UTF-8 con BOM -> UTF-8 sin BOM) de un archivo de texto sin tocar
su contenido. AGENTS.md 28 exige UTF-8 **sin BOM**.

El bug lo detecto `auditar_encoding.py`: `Logs/NUMEROS_DISPONIBLES.txt` tiene
BOM en disco y NO lo tiene en HEAD, o sea que se introdujo durante la sesion.

Uso:  python quitar_bom.py <ruta> [<ruta> ...]
"""
import io
import sys

BOM = b"\xef\xbb\xbf"


def main():
    if len(sys.argv) < 2:
        print("uso: python quitar_bom.py <ruta> [<ruta> ...]")
        return 2
    cambiados = 0
    for p in sys.argv[1:]:
        with io.open(p, "rb") as f:
            b = f.read()
        if not b.startswith(BOM):
            print("OK (sin BOM)  %s" % p)
            continue
        with io.open(p, "wb") as f:
            f.write(b[len(BOM):])
        with io.open(p, "rb") as f:
            chk = f.read()
        if chk.startswith(BOM):
            print("ERROR: sigue con BOM %s" % p)
            return 2
        # el contenido debe ser identico salvo el BOM
        if chk != b[len(BOM):]:
            print("ERROR: el contenido cambio %s" % p)
            return 2
        cambiados += 1
        print("FIX BOM quitado  %s  (%d -> %d bytes, contenido identico)"
              % (p, len(b), len(chk)))
    print("---")
    print("archivos corregidos: %d" % cambiados)
    return 0


if __name__ == "__main__":
    sys.exit(main())