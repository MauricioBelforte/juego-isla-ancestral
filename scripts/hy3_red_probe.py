# -*- coding: utf-8 -*-
"""HY3 RED-PROBE — sonda de emisiones de señales parametrizada por módulo (gate-2, model-agnostic).

Heredero de scripts/red_probe_event_bus.py (GLM, M14). Generalizado para CUALQUIER
módulo: escanea un directorio de scripts (o el event_bus global) y cuenta emisiones
reales `.<señal>.emit(` en .gd, reportando señales 0-emit (muertas) vs usadas.

El veredicto es máquina-verificable: cualquier agente/humano/cron puede correrlo.
NO es runtime (no bootea Godot): cuenta emisiones estáticas de texto. Para
0-runtime-captura usar game/isla-ancestral/scripts/core/probe_runtime_bus_m14.gd.

Uso:
  python -X utf8 scripts/hy3_red_probe.py --bus
      # escanea event_bus.gd global (equivalente a red_probe_event_bus.py)
  python -X utf8 scripts/hy3_red_probe.py --dir game/isla-ancestral/scripts/inventario
      # señales declaradas localmente en ese dir + emisiones en todo scripts/
  python -X utf8 scripts/hy3_red_probe.py --bus --serial item_removed
      # solo la señal item_removed

Exit code: 0 siempre (es inventario, no test de aprobación).
"""
import os, re, sys, argparse

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SCRIPTS = os.path.join(RAIZ, "game", "isla-ancestral", "scripts")
BUS = os.path.join(SCRIPTS, "core", "event_bus.gd")

def senales_declaradas(ruta):
    out = []
    if not os.path.isfile(ruta):
        return out
    for line in open(ruta, encoding="utf-8", errors="replace"):
        m = re.match(r"\s*signal\s+([A-Za-z_][A-Za-z0-9_]*)", line)
        if m:
            out.append(m.group(1))
    return out

def main():
    ap = argparse.ArgumentParser(description="HY3 red-probe de señales (gate-2)")
    ap.add_argument("--bus", action="store_true", help="usar event_bus.gd global")
    ap.add_argument("--dir", help="directorio de scripts del módulo a escanear")
    ap.add_argument("--serial", help="filtrar una señal objetivo (substring)")
    args = ap.parse_args()

    if args.bus or not args.dir:
        senales = senales_declaradas(BUS)
        base = BUS
        modo = "bus global: %s" % BUS
    else:
        d = args.dir
        if not os.path.isabs(d):
            d = os.path.join(RAIZ, d)
        senales = []
        for root, _d, files in os.walk(d):
            for f in files:
                if f.endswith(".gd"):
                    senales += senales_declaradas(os.path.join(root, f))
        base = d
        modo = "dir: %s" % d

    if args.serial:
        senales = [s for s in senales if args.serial in s]
        modo += " [filtro --serial '%s' -> %d]" % (args.serial, len(senales))

    print("[HY3 RED-PROBE] modo %s" % modo)
    if not senales:
        print("Sin señales para medir.")
        sys.exit(0)

    emisiones = {s: 0 for s in senales}
    rx = {s: re.compile(r"\.%s\.emit\s*\(" % re.escape(s)) for s in senales}
    scan = 0
    for root, _dirs, files in os.walk(SCRIPTS):
        for f in files:
            if not f.endswith(".gd"):
                continue
            p = os.path.join(root, f)
            if os.path.abspath(p) == os.path.abspath(base):
                continue
            scan += 1
            try:
                contenido = open(p, encoding="utf-8", errors="replace").read()
            except OSError:
                continue
            for s in senales:
                if rx[s].search(contenido):
                    emisiones[s] += 1
    muertas = [s for s in senales if emisiones[s] == 0]
    usadas = [s for s in senales if emisiones[s] > 0]
    print("archivos .gd escaneados (excluye base): %d" % scan)
    print("--- SEÑALES 0-EMIT (muertas): %d ---" % len(muertas))
    for s in muertas:
        print("   ", s)
    print("--- SEÑALES CON EMISIONES: %d ---" % len(usadas))
    for s in usadas:
        print("   %-42s %d emisión(es)" % (s, emisiones[s]))
    print()
    print("[HY3 RED-PROBE] oráculo M14 (Hy3 27oct): 54 declaradas / 20 muertas en event_bus.gd.")
    print("Si tu conteo difiere, CITA la diferencia (honestidad de piso).")
    sys.exit(0)

if __name__ == "__main__":
    main()
