#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Sonda EN ROJO de la suite `test_auditar_indice_m01.py` (bloques K/L/M).

Un guardia que nunca se probo en rojo es un guardia que puede estar muerto.
Esta sonda inyecta tres regresiones distintas en COPIAS del auditor (nunca en
`scripts/`) y verifica que la suite las caza, cada una con el check que le
corresponde:

  P1  el clasificador de dependencias devuelve siempre `sin_senal`
  P2  se elimina el filtro de auto-referencia (un modulo se cuenta como su
      propia dependencia)
  P3  el piso `CHECKS_MINIMOS` se sube por encima del total real medido

Uso:  python scripts/probar_auditor_indice_m01.py
Salida: N checks / M fallos, exit 0 si 0 fallos.
"""

import os
import shutil
import subprocess
import sys
import tempfile

AQUI = os.path.dirname(os.path.abspath(__file__))
AUD = os.path.join(AQUI, "auditar_indice_m01.py")
SUI = os.path.join(AQUI, "test_auditar_indice_m01.py")
PY = sys.executable

checks = 0
fallos = 0


def chequear(cond, desc):
    global checks, fallos
    checks += 1
    print(("[OK]    " if cond else "[FALLO] ") + desc)
    if not cond:
        fallos += 1


def correr_probe(nombre, transformar, en_suite=False):
    """Copia auditor+suite a un temporal, inyecta y corre la suite."""
    base = tempfile.mkdtemp(prefix="m01_probe_")
    try:
        aud = os.path.join(base, "auditar_indice_m01.py")
        sui = os.path.join(base, "test_auditar_indice_m01.py")
        # Los DOS originales se leen de su ruta real: si el que se inyecta es la
        # suite, el auditor copiado tiene que ser el auditor de verdad (si no, el
        # "auditor" del arbol sintetico es la suite y se llama a si misma sin fin).
        with open(AUD, "rb") as f:
            orig_aud = f.read()
        with open(SUI, "rb") as f:
            orig_sui = f.read()
        nuevo = transformar(orig_sui if en_suite else orig_aud)
        if nuevo == (orig_sui if en_suite else orig_aud):
            chequear(False, "%s: la inyeccion NO encontro su ancla" % nombre)
            return None
        with open(aud, "wb") as f:
            f.write(orig_aud)
        with open(sui, "wb") as f:
            f.write(nuevo if en_suite else orig_sui)
        r = subprocess.run([PY, sui], capture_output=True, text=True, encoding="utf-8",
                           cwd=base, timeout=180)
        return r.returncode, r.stdout
    finally:
        shutil.rmtree(base, ignore_errors=True)


def iny_clasificador_ciego(b):
    return b.replace(
        b'    return (matched[0] if matched else TIPO_RESIDUAL), matched, evidencia',
        b'    return TIPO_RESIDUAL, [], ""',
        1,
    )


def iny_sin_filtro_autoref(b):
    return b.replace(b"if x != propio_id", b"if True", 1)


def iny_piso(b):
    return b.replace(b"CHECKS_MINIMOS = 54", b"CHECKS_MINIMOS = 99", 1)


def main():
    # 1) clasificador ciego: todo cae a sin_senal
    r = correr_probe("clasificador ciego", iny_clasificador_ciego)
    if r:
        rc, out = r
        chequear(rc == 1, "P1: con el clasificador ciego la suite sale EXIT 1")
        chequear("[FALLO] K: 1 item en asset" in out,
                 "P1: falla el check de asset (nombra el tipo que desaparecio)")
        chequear("la precedencia pone asset antes que trabajo_propio" in out,
                 "P1: falla tambien el check de precedencia")

    # 2) sin filtro de auto-referencia
    r = correr_probe("sin filtro de auto-referencia", iny_sin_filtro_autoref)
    if r:
        rc, out = r
        chequear(rc == 1, "P2: sin el filtro de auto-referencia la suite sale EXIT 1")
        chequear("[FALLO] L: la auto-referencia a M01 NO cuenta como otro_modulo" in out,
                 "P2: falla exactamente el check de la auto-referencia")

    # 3) piso de checks
    r = correr_probe("piso de checks", iny_piso, en_suite=True)
    if r:
        rc, out = r
        chequear(rc == 1, "P3: con el piso en 99 la suite sale EXIT 1")
        chequear("solo 54 checks ejecutados (minimo 99)" in out,
                 "P3: el piso nombra el conteo real medido (54)")

    print("")
    print("=== Sonda: %d checks, %d fallos ===" % (checks, fallos))
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
