#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Prueba de regresion del filtro por linea de scripts/diagnosticar_mojibake.py.

Por que existe: el verificador ignora las lineas que DOCUMENTAN el mojibake
(banners de los BACKLOG-MASTER, tablas de los reparadores, volcados de bytes
en las guias). Sin esta prueba, un filtro demasiado laxo podria dejar de
detectar corrupcion REAL y el verificador pasaria a dar un falso verde
permanente -- exactamente el modo de fallo que AGENTS.md §21.4 manda evitar.

Cada caso lleva mojibake autentico (UTF-8 releido como cp1252), no texto sin
acentos: un caso sin marcador no probaria nada.

Uso:
    python scripts/test_diagnosticar_mojibake.py
    echo $?   # 0 = filtro correcto, 1 = filtro roto
"""
import importlib.util
import os
import sys


def cargar_diagnosticador():
    aqui = os.path.dirname(os.path.abspath(__file__))
    ruta = os.path.join(aqui, 'diagnosticar_mojibake.py')
    spec = importlib.util.spec_from_file_location('diag', ruta)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


# 'Ã³'    = U+00C3 U+00B3                 -> mojibake real de 'ó'
# 'ðŸŸ¢'  = U+00F0 U+0178 U+0178 U+00A2   -> mojibake real de un emoji
# (descripcion, linea, el filtro debe ocultarla?)
CASOS = [
    ("mojibake REAL: acento en frase normal",
     "El n\u00c3\u00bacleo del motor esta en game/", False),
    ("mojibake REAL: emoji del protocolo",
     "\u00f0\u0178\u0178\u00a2 Modulo M116 listo", False),
    ("mojibake REAL: raya y comilla",
     "Rango \u00e2\u20ac\u201c admite \u00c3\u00b3", False),
    ("banner de backlog (doc)",
     "> Los caracteres rotos (\u00c3\u00b3, \u00e2\u20ac\u009d, "
     "\u00f0\u0178\u0178\u00a2) RETRASAN", True),
    ("banner CHECKLIST-GLOBAL (doc)",
     "Este archivo sufrio doble encoding (cp1252 \u2192 UTF-8) \u00c3\u00b3",
     True),
    ("comentario de reparador (doc)",
     "    # \u00f0\u0178\u0178\u00a1 (U+00F0 U+0178) emojis mojibake", True),
    ("volcado de bytes (doc)",
     "1. Bytes crudos: `C3 B0 C5 B8 C5 B8 C2 A1` \u2192 \u00f0\u0178\u0178\u00a1",
     True),
]


def main():
    diag = cargar_diagnosticador()
    fallos = 0
    for desc, linea, debe_ocultarse in CASOS:
        oculta = bool(diag.PAT_LINEA_DOC.search(linea))
        tiene = bool(diag.PAT.search(linea))
        # TODO caso debe tener marcador: si no lo tiene, la prueba no prueba.
        ok = (oculta == debe_ocultarse) and tiene
        if not ok:
            fallos += 1
        print("%-5s %-40s marcador=%-5s filtrada=%-5s (esperado %s)" % (
            "OK" if ok else "FALLO", desc, tiene, oculta, debe_ocultarse))
    print("")
    if fallos:
        print("FALLOS: %d -- el filtro deja de detectar corrupcion real" % fallos)
        return 1
    print("OK: el filtro distingue documentacion de corrupcion real.")
    return 0


if __name__ == '__main__':
    sys.exit(main())
