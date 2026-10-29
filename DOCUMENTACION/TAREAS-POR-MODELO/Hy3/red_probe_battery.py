# -*- coding: utf-8 -*-
"""Batería red-probe por módulo core: ¿qué señales del event_bus global EMITE cada módulo?

Complementa scripts/hy3_red_probe.py (que mide emisiones globales). Aquí acotamos
el escaneo al directorio de cada módulo para ver su huella de señales del bus.
Salida: por módulo, total de emisiones y señales-distintas emitidas.
"""
import os, re

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SCRIPTS = os.path.join(RAIZ, "game", "isla-ancestral", "scripts")
BUS = os.path.join(SCRIPTS, "core", "event_bus.gd")

MODULOS = {
    "M13-herramientas": "herramientas158",
    "M16-inventario": "inventario",
    "M19-npc": "npc",
    "M19b-ia_npc": "ia_npc",
    "M20-amistad": "community",
    "M54-mapa": "mapa",
    "M70-islas": "islas",
    "M74-eventos": "eventos",
    "M11-personaje": "construccion",
}

def senales_bus():
    out = []
    for line in open(BUS, encoding="utf-8", errors="replace"):
        m = re.match(r"\s*signal\s+([A-Za-z_][A-Za-z0-9_]*)", line)
        if m:
            out.append(m.group(1))
    return out

def main():
    senales = senales_bus()
    rx = {s: re.compile(r"\.%s\.emit\s*\(" % re.escape(s)) for s in senales}
    print("[BATERIA] señales de event_bus.gd: %d" % len(senales))
    for mod, rel in MODULOS.items():
        d = os.path.join(SCRIPTS, rel)
        if not os.path.isdir(d):
            print("%-18s DIR NO EXISTE: %s" % (mod, rel))
            continue
        total = 0
        distintas = set()
        for root, _dirs, files in os.walk(d):
            for f in files:
                if not f.endswith(".gd"):
                    continue
                try:
                    c = open(os.path.join(root, f), encoding="utf-8", errors="replace").read()
                except OSError:
                    continue
                for s in senales:
                    n = len(rx[s].findall(c))
                    if n:
                        total += n
                        distintas.add(s)
        print("%-18s emisiones_bus=%d  señales_distintas=%d" % (mod, total, len(distintas)))

if __name__ == "__main__":
    main()
