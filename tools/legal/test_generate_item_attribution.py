#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# M159 legal-tools (encargo director #784): test headless del
# generate_item_attribution.py (inyeccion de tEXt Copyright/Author en los 300 PNG
# de M159). Valida: inyecta, idempotente, validador queda en verde.
# Exit 0 si todo OK, 1 si falla.

import os, sys, struct

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import generate_item_attribution as G

CHECKS = 0
FALLOS = 0


def check(msg, cond):
    global CHECKS, FALLOS
    CHECKS += 1
    if cond:
        print("OK   " + msg)
    else:
        FALLOS += 1
        print("FAIL " + msg)


def main():
    print("=== [M159 legal-tools] test generate_item_attribution ===")
    pngs = sorted(n for n in os.listdir(G.M159) if n.lower().endswith(".png"))
    check("hay 300 PNG en items_m159", len(pngs) == 300)

    # Todos los PNG ya tienen atribucion embebida (tras --aplicar).
    sin = 0
    for n in pngs:
        with open(os.path.join(G.M159, n), "rb") as fh:
            b = fh.read()
        if b[:8] != b"\x89PNG\r\n\x1a\n":
            check("magic PNG de " + n, False)
            return 1
        if not G.tiene_atribucion(b):
            sin += 1
    check("0 PNG sin atribucion embebida", sin == 0)

    # Un PNG inyectado lleva Copyright + Author en tEXt.
    m = os.path.join(G.M159, pngs[0])
    with open(m, "rb") as fh:
        b = fh.read()
    t = G.chunks_textr(b)
    keys = []
    for ch in t:
        parts = ch.split(b"\x00")
        keys += [k.decode("latin-1", "replace").lower() for k in parts[0::2]]
    check("tEXt lleva 'copyright'", "copyright" in keys)
    check("tEXt lleva 'author'", "author" in keys)

    # Idempotencia: re-inyectar en uno ya con atribucion no lo modifica.
    before = open(m, "rb").read()
    c, motivo = G.inyectar(m, aplicar=True)
    after = open(m, "rb").read()
    check("idempotente (no re-inyecta)", c is False and motivo == "ya-tiene-atribucion")
    check("archivo sin cambios tras re-inyeccion", before == after)

    # El validador queda en verde (0 hallazgos nuevos).
    import subprocess
    r = subprocess.run([sys.executable, os.path.join(HERE, "validate_asset_metadata.py"), "--check"],
                       capture_output=True, text=True)
    check("validate_asset_metadata.py --check exit 0 (gate legal-tools verde)", r.returncode == 0)

    print("=== [M159 legal-tools] %d checks, %d fallos ===" % (CHECKS, FALLOS))
    return 1 if FALLOS else 0


if __name__ == "__main__":
    sys.exit(main())
