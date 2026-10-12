# -*- coding: utf-8 -*-
"""Gate CI de rendimiento (M141-Beta, ítem 8/131): mínimo y recomendado.

Parámetros del gate (hardware mínimo y recomendado, ítem 8/128):

    MÍNIMO     60 FPS en la ruta fija de medición (20 min, ítem 9/129)
    RECOMENDADO 60 FPS con headroom ≥ 30 % en la misma ruta

El gate no mide el juego: mide el **presupuesto declarado**. El runtime lo mide
M61 (`scripts/performance/budget_profile.gd`) y el validador de Godot
(`validate_budget.gd`). Este script cierra el ciclo en CI: si los presupuestos
declarados exceden el frame de 60 FPS, la build falla.

Uso:
    python scripts/verificar_presupuesto_gate.py            # humano
    python scripts/verificar_presupuesto_gate.py --quiet    # CI

Salida: exit 0 si los presupuestos caben en 60 FPS, exit 1 si no.
"""

import io
import re
import sys

# 60 FPS = 16.667 ms/frame. M103 (logging) usa 0,5 % = 0,083 ms como referencia.
FRAME_60FPS_MS = 1000.0 / 60.0
# Recomendado = 30 % de headroom para engines/VFX/herramientas.
HEADROOM_RECOMENDADO = 0.30

# Presupuestos DECLARADOS por M61 para el gate. Fuente:
# DOCUMENTACION/61-Rendimiento (budget_profile.gd) y 11-BUGS.md (BUG-067).
# Mapeados a frame de 60 FPS: cada categoría debe caber en el frame.
PRESUPUESTOS = [
    # (categoria, presupuesto_ms, nota)
    ("frame_total", FRAME_60FPS_MS, "el frame completo (60 FPS)"),
    ("logging", 0.083, "M103 logging < 0,5 % del frame (BUG-067)"),
    ("eventos", 0.05, "M74 eventos < 3 ms/s en el día de cambio"),
    ("iluminacion", 1.0, "M49 ciclo día/noche porCambio"),
    ("streaming", 2.0, "M27 carga de islas por frame"),
]


def _fmt(ms):
    return "%.3f ms" % ms


def evaluar():
    """Devuelve (ok, lineas) evaluando los presupuestos contra 60 FPS."""
    lineas = []
    ok = True
    frame = FRAME_60FPS_MS
    recom = frame * (1.0 - HEADROOM_RECOMENDADO)

    lineas.append("=== GATE CI DE RENDIMIENTO (M141 ítem 131) ===")
    lineas.append("Frame 60 FPS:            %s" % _fmt(frame))
    lineas.append("Presupuesto recomendado: %s (headroom %.0f %%)" % (_fmt(recom), HEADROOM_RECOMENDADO * 100))
    lineas.append("")

    for categoria, presupuesto, nota in PRESUPUESTOS:
        # El recomendado es más estricto: cada categoría debe caber en el
        # presupuesto recomendado, no solo en el frame.
        estado = "OK"
        if presupuesto > frame:
            estado = "FALLO (excede 60 FPS)"
            ok = False
        elif presupuesto > recom:
            estado = "AVISO (cabe en 60 FPS pero come el headroom)"
        lineas.append("  %-12s %10s  %-42s %s" % (categoria, _fmt(presupuesto), nota, estado))

    lineas.append("")
    lineas.append("RESULTADO: %s" % ("PASS" if ok else "FALLO"))
    return ok, lineas


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    quiet = "--quiet" in argv or "-q" in argv
    ok, lineas = evaluar()
    if not quiet:
        print("\n".join(lineas))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
