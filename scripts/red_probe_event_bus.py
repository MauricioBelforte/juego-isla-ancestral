# -*- coding: utf-8 -*-
"""RED-PROBE M14 — sondas de runtime automatizadas del gate-2 (model-agnostic).

Procedimiento de Hy3 (1) automatizado:
  1)extrae las señales declaradas en game/isla-ancestral/scripts/core/event_bus.gd
  2)cuenta emisiones reales `.<señal>.emit(` en todos los .gd de game/isla-ancestral/scripts
     (excluyendo la declaración del propio event_bus)
  3)reporta señales 0-emit (muertas) vs usadas.
Oráculo de referencia (Hy3 27oct): 54 declaradas / 20 con 0 emisiones. Si tu conteo
difiere del oráculo, CITÁ la diferencia — el oráculo es válido a la fecha de su medición,
los 05/03 y el código cambian.

Uso: python -X utf8 scripts/red_probe_event_bus.py
Exit code: 0 siempre (es un sondeo de inventario, no un test de aprobación).
Cualquier agente o humano puede correrlo: el veredicto es máquina-verificable.
"""
import os, re, sys

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SCRIPTS = os.path.join(RAIZ, "game", "isla-ancestral", "scripts")
BUS = os.path.join(SCRIPTS, "core", "event_bus.gd")

def señales_declaradas(ruta_bus):
    out = []
    for line in open(ruta_bus, encoding="utf-8"):
        m = re.match(r"\s*signal\s+([A-Za-z_][A-Za-z0-9_]*)", line)
        if m:
            out.append(m.group(1))
    return out

def main():
    if not os.path.isfile(BUS):
        print("FALTA event_bus.gd en", BUS)
        sys.exit(2)
    señales = señales_declaradas(BUS)
    print("señales declaradas en event_bus.gd: %d" % len(señales))
    emisiones = {s: 0 for s in señales}
    rx = {s: re.compile(r"\.%s\.emit\s*\(" % re.escape(s)) for s in señales}
    scan = 0
    for root, _dirs, files in os.walk(SCRIPTS):
        for f in files:
            if not f.endswith(".gd"):
                continue
            p = os.path.join(root, f)
            if os.path.abspath(p) == os.path.abspath(BUS):
                continue  # la declaración no cuenta como emisión
            scan += 1
            try:
                contenido = open(p, encoding="utf-8", errors="replace").read()
            except OSError:
                continue
            for s in señales:
                if rx[s].search(contenido):
                    emisiones[s] += 1
    muertas = [s for s in señales if emisiones[s] == 0]
    usadas = [s for s in señales if emisiones[s] > 0]
    print("archivos .gd escaneados (excluye event_bus.gd): %d" % scan)
    print("--- SEÑALES 0-EMIT (muertas): %d ---" % len(muertas))
    for s in muertas:
        print("   ", s)
    print("--- SEÑALES CON EMISIONES: %d ---" % len(usadas))
    for s in usadas:
        print("   %-42s %d emisión(es)" % (s, emisiones[s]))
    print()
    print("[GATE-2 SONDA RED-PROBE M14] oráculo Hy3 27oct: 54 declaradas / 20 muertas.")
    print("Compara tu salida con el oráculo y CITA la diferencia si existe (honestidad de piso).")
    sys.exit(0)

if __name__ == "__main__":
    main()
