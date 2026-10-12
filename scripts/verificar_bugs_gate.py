# -*- coding: utf-8 -*-
"""Gate CI de bugs (M141-Beta, ítem 9/147): falla si hay P0/P1 abiertos.

Regla del proyecto (AGENTS.md §21.6 / DoD): un módulo COMPLETADO no puede dejar
bugs críticos o de funcionalidad core abiertos. Este gate lee
`DOCUMENTACION/11-BUGS.md` y devuelve exit 1 si encuentra entradas con severidad
P0/P1 (🔴 Crítica / 🟠 Alta) cuyo estado sea `[ ]`, `[→]` o `[?]`.

Uso:
    python scripts/verificar_bugs_gate.py            # humano
    python scripts/verificar_bugs_gate.py --quiet    # CI (solo exit code)

Notas de diseño:
- La detección es por FILAS DE TABLA del archivo de registro, no por secciones,
  porque 11-BUGS.md tiene varias tablas (activas, resueltos, delegados).
- Un bug resuelto (`[x]`) nunca bloquea.
- Severidad desconocida se informa como WARNING pero NO bloquea (regla cozy:
  mejor falso negativo visible que gate roto por datos incompletos).
"""

import io
import re
import sys

RUTA_BUGS = "DOCUMENTACION/11-BUGS.md"

# Severidades que bloquean el gate (P0 crítica / P1 alta funcional).
# La tabla de 11-BUGS.md usa emojis + texto.
BLOQUEANTES = ("🔴", "CRÍTICA", "CRITICA", "🟠", "ALTA", "P0", "P1")

# Estados que significan "sigue abierto".
ABIERTOS = ("[ ]", "[→]", "[?]")


def _normalizar(txt):
    return txt.upper().replace("Ó", "O").replace("Í", "I").replace("É", "E").replace("Á", "A").replace("Ú", "U").replace("Ñ", "N")


def _es_bloqueante(severidad):
    s = _normalizar(severidad)
    return any(marca in s for marca in BLOQUEANTES)


def _esta_abierto(estado):
    e = estado.strip()
    return any(e.startswith(marca) for marca in ABIERTOS)


def leer_bugs(ruta=RUTA_BUGS):
    """Devuelve (filas, abiertos_bloqueantes) del registro central.

    filas: lista de dicts con {id, titulo, modulo, severidad, estado}
    abiertos_bloqueantes: subconjunto con P0/P1 abiertos.
    """
    filas = []
    try:
        texto = io.open(ruta, encoding="utf-8").read()
    except IOError:
        print("WARNING: no se pudo leer %s (gate no concluyente)" % ruta)
        return [], []

    for linea in texto.split("\n"):
        if not linea.strip().startswith("|"):
            continue
        celdas = [c.strip() for c in linea.strip().strip("|").split("|")]
        if len(celdas) < 5:
            continue
        id_bug = celdas[0]
        # Cabeceras y separadores no son bugs.
        if id_bug in ("BUG", "Símbolo", "---") or id_bug.startswith("---"):
            continue
        if not re.match(r"^[A-Z]+[-_][0-9]+", id_bug):
            continue
        filas.append({
            "id": id_bug,
            "titulo": celdas[1] if len(celdas) > 1 else "",
            "modulo": celdas[2] if len(celdas) > 2 else "",
            "severidad": celdas[3] if len(celdas) > 3 else "",
            "estado": celdas[4] if len(celdas) > 4 else "",
        })

    abiertos = [f for f in filas if _es_bloqueante(f["severidad"]) and _esta_abierto(f["estado"])]
    return filas, abiertos


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    quiet = "--quiet" in argv or "-q" in argv

    filas, abiertos = leer_bugs()
    total_bloqueantes = [f for f in filas if _es_bloqueante(f["severidad"])]

    if not quiet:
        print("=== GATE CI DE BUGS (M141 ítem 147) ===")
        print("Bugs registrados: %d" % len(filas))
        print("Con severidad P0/P1: %d" % len(total_bloqueantes))
        print("P0/P1 abiertos: %d" % len(abiertos))
        for f in abiertos:
            print("  BLOQUEA %s [%s] %s" % (f["id"], f["severidad"], f["titulo"][:60]))
        if not abiertos:
            print("RESULTADO: PASS (sin P0/P1 abiertos)")
        else:
            print("RESULTADO: FALLO")

    return 1 if abiertos else 0


if __name__ == "__main__":
    sys.exit(main())
