#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
#
# SB-03 — space-bunny-alpha — 2026-10-04 — Log 1278
#
# Verifica la CONDICION DEL EJEMPLO 3 de M152 ("Ampliar mapa solo si se agregan
# NPCs, recursos, misiones en nuevas areas") contra los artefactos de datos
# REALES del juego.
#
# El mapa se amplio de radio 256 -> 2560 (mundo 5120^2, centro 2560,2560;
# commit c107419, rework "Isla 10x"). Fuente de verdad de las constantes:
# scripts/world/mundo_raiz.gd  (CENTRO=Vector2(2560,2560), RADIO_ISLA=1800,
# RADIO_ORILLA=1700, SPAWN_JUGADOR=(3860,0,3860)).
#
# METODO: extrae toda declaracion de posicion (x,z / position / Vector3 /
# "x": N, "z": M) de los artefactos de datos, calcula el radio respecto del
# centro, y clasifica cada pieza de contenido en:
#   - AREA VIEJA  : r <= 256   (la isla como era antes del rework)
#   - AREA NUEVA  : r >  256   (la superficie agregada por la ampliacion)
#   - INDETERMINADO: no hay posicion numerica (radio por bioma/anillo, o
#                     posicion calculada en runtime)
#
# SOLO LECTURA. No escribe nada del proyecto.

import io
import json
import math
import os
import re
import sys
from collections import defaultdict

# scripts-prueba -> space-bunny-alpha -> TAREAS-POR-MODELO -> DOCUMENTACION -> raiz
# (4 niveles, no 5: con 5 llegaba una carpeta de más y no encontraba nada —
#  bug propio, detectado porque el resultado fue 0/0 en todas las categorías)
RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                     "..", "..", "..", ".."))
JUEGO = os.path.join(RAIZ, "game", "isla-ancestral")
# Los datos del juego viven bajo game/isla-ancestral/data/ (bug propio: la 1a
# version buscaba game/isla-ancestral/fauna/... y no encontraba NADA).
DATA = os.path.join(JUEGO, "data")
SCRIPTS = os.path.join(JUEGO, "scripts")

CENTRO = (2560.0, 2560.0)
R_VIEJO = 256.0
R_NOMINAL = 1800.0     # mundo_raiz.RADIO_ISLA
R_ORILLA = 1700.0      # mundo_raiz.RADIO_ORILLA

# Categorias del encargo, con los artefactos que las respaldan.
CATEGORIAS = {
    "NPCs": [
        ("fauna/catalog.json", "fauna"),
        ("fauna/catalog.json", "fauna"),
        ("npc_visuals", "npc_visual"),
        ("villagers", "villager"),
        ("dialogues/contextual/registry.json", "dialogo_npc"),
        ("ubicaciones/ubicaciones_loc.json", "ubicacion_npc"),
    ],
    "RECURSOS": [
        ("items", "item_obj"),
        ("mining/ores.json", "mineral"),
        ("vegetacion/vegetacion_config.json", "vegetacion"),
        ("coleccionables/catalog.json", "coleccionable"),
        ("economia/barter", "barter"),
        ("construccion/piezas", "pieza_construccion"),
        ("enchantments", "encantamiento"),
    ],
    "MISIONES_Y_LORE": [
        ("historia/historia_principal.json", "mision_historia"),
        ("historias/secundarias.json", "mision_secundaria"),
        ("historias/cadenas_ejemplo.json", "cadena"),
        ("lore/lore.json", "lore"),
        ("lore/consumidores.json", "consumidor_lore"),
        ("logros/logros.json", "logro"),
        ("postgame/actividades.json", "actividad"),
        ("motivacion/objetivos.json", "objetivo"),
        ("balance/quests.json", "quest_balance"),
        ("templos/templo_blueprint.json", "templo"),
    ],
    "GEOGRAFIA (control)": [
        ("islas/islas.json", "isla"),
        ("islas/definiciones", "definicion_isla"),
        ("locations", "location"),
        ("ubicaciones/ubicaciones.json", "ubicacion"),
        ("mapa/map_config.json", "mapa"),
        ("map/map_data.json", "map_data"),
        ("fasttravel/anclas.json", "ancla_fasttravel"),
        ("transporte/m68_catalogo.json", "ruta_transporte"),
        ("viajes/rutas.json", "ruta"),
        ("terrenos/terrenos.json", "terreno"),
    ],
}

# Patrones de posicion. (regex, grupos que son (x, z))
PATRONES = [
    (re.compile(r'"x"\s*:\s*(-?\d+(?:\.\d+)?)'), 1, None),
    (re.compile(r'"z"\s*:\s*(-?\d+(?:\.\d+)?)'), None, 1),
    (re.compile(r'position\s*=\s*Vector3\(\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)'),
     1, 3),
    (re.compile(r'posicion\s*=\s*Vector2\(\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)'), 1, 2),
    (re.compile(r'posicion\s*=\s*Vector3\(\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)'),
     1, 3),
    (re.compile(r'\bpos_x\s*=\s*(-?\d+(?:\.\d+)?)'), 1, None),
    (re.compile(r'\bpos_z\s*=\s*(-?\d+(?:\.\d+)?)'), None, 1),
    (re.compile(r'\bposition\s*=\s*\{?\s*"x"\s*:\s*(-?\d+(?:\.\d+)?)'), 1, None),
    (re.compile(r'\bposition\s*=\s*\{?.*?"z"\s*:\s*(-?\d+(?:\.\d+)?)'), None, 1),
]

RE_TXT = [".json", ".tres", ".gd", ".tscn", ".txt"]


def radio(x, z):
    return math.hypot(x - CENTRO[0], z - CENTRO[1])


def clasifica(r):
    if r <= R_VIEJO:
        return "VIEJA"
    return "NUEVA"


def recorrer(raiz_rel, exts=RE_TXT):
    """Devuelve lista de rutas absolutas bajo un dir relativo a DATA o SCRIPTS.

    Acepta rutas relativas a 'data/' por defecto; si empiezan con 'scripts/'
    se resuelven contra SCRIPTS.
    """
    out = []
    if raiz_rel.startswith("scripts/"):
        base = os.path.join(JUEGO, raiz_rel)
    else:
        base = os.path.join(DATA, raiz_rel)
    if os.path.isfile(base):
        return [base]
    if not os.path.isdir(base):
        return []
    for dirp, _dn, fns in os.walk(base):
        for fn in fns:
            if fn.endswith(tuple(exts)):
                out.append(os.path.join(dirp, fn))
    return sorted(out)


def extraer_posiciones(ruta):
    """Devuelve lista de (linea_no, x, z, fragmento)."""
    with io.open(ruta, "r", encoding="utf-8", errors="replace") as f:
        texto = f.read()
    lineas = texto.split("\n")
    res = []
    for i, l in enumerate(lineas, 1):
        # caso JSON: "x": N y "z": M en la MISMA linea
        mx = re.search(r'"x"\s*:\s*(-?\d+(?:\.\d+)?)', l)
        mz = re.search(r'"z"\s*:\s*(-?\d+(?:\.\d+)?)', l)
        if mx and mz:
            res.append((i, float(mx.group(1)), float(mz.group(1)), l.strip()[:90]))
            continue
        for rx, gx, gz in PATRONES:
            if gx is None or gz is None:
                continue
            m = rx.search(l)
            if m:
                try:
                    res.append((i, float(m.group(gx)), float(m.group(gz)), l.strip()[:90]))
                except (IndexError, ValueError):
                    pass
                break
    return res


def main():
    print("=" * 100)
    print("SB-03 — Condicion del Ejemplo 3 de M152: hay contenido en el AREA NUEVA?")
    print("Log 1278 · space-bunny-alpha · 2026-10-04")
    print("=" * 100)
    print("Centro (fuente: mundo_raiz.gd)  : (%.0f, %.0f)" % CENTRO)
    print("Radio isla nominal RADIO_ISLA   : %.0f" % R_NOMINAL)
    print("Orilla (agua) RADIO_ORILLA      : %.0f" % R_ORILLA)
    print("Umbral AREA VIEJA (pre-rework)  : r <= %.0f" % R_VIEJO)
    print("Spawn jugador                   : (3860, 3860) -> r = %.0f  => AREA NUEVA"
          % radio(3860.0, 3860.0))
    print()

    gran_total = {"VIEJA": 0, "NUEVA": 0}
    filas = []
    for cat, arts in CATEGORIAS.items():
        c = {"VIEJA": 0, "NUEVA": 0, "SIN_POS": 0}
        detalle = []
        for rel, etiqueta in arts:
            for ruta in recorrer(rel):
                n_arch = len(detalle)
                pos = extraer_posiciones(ruta)
                if pos:
                    for ln, x, z, frag in pos:
                        r = radio(x, z)
                        k = clasifica(r)
                        c[k] += 1
                        detalle.append((k, r, etiqueta, ruta, ln, frag))
                else:
                    c["SIN_POS"] += 1
                    detalle.append(("SIN_POS", None, etiqueta, ruta, None, ""))
        gran_total["VIEJA"] += c["VIEJA"]
        gran_total["NUEVA"] += c["NUEVA"]
        filas.append((cat, c, detalle))
        total = c["VIEJA"] + c["NUEVA"]
        pct = (100.0 * c["NUEVA"] / total) if total else 0.0
        print("-" * 100)
        print("%s" % cat)
        print("  piezas con posicion: %d   NUEVA: %d (%.1f%%)   VIEJA: %d   sin posicion: %d"
              % (total, c["NUEVA"], pct, c["VIEJA"], c["SIN_POS"]))
        # radios
        rs = sorted(d[1] for d in detalle if d[0] in ("NUEVA", "VIEJA"))
        if rs:
            print("  radio min=%.0f  max=%.0f  mediana=%.0f" % (rs[0], rs[-1], rs[len(rs) // 2]))
        # muestras de cada lado
        for lado in ("VIEJA", "NUEVA"):
            ej = [d for d in detalle if d[0] == lado][:3]
            for k, r, et, ruta, ln, frag in ej:
                print("    %-5s r=%-7.0f %-22s %s:%s" % (
                    lado, r, et,
                    os.path.relpath(ruta, JUEGO).replace("\\", "/"), ln))
        print()

    print("=" * 100)
    print("RESULTADO GLOBAL")
    print("=" * 100)
    print("  piezas de contenido con posicion: NUEVA=%d  VIEJA=%d"
          % (gran_total["NUEVA"], gran_total["VIEJA"]))
    tot = gran_total["NUEVA"] + gran_total["VIEJA"]
    if tot:
        print("  %% en AREA NUEVA: %.1f%%" % (100.0 * gran_total["NUEVA"] / tot))
    print()
    print("  VEREDICTO POR CATEGORIA (lo que el fundador quiere saber):")
    for cat, c, _d in filas:
        t = c["VIEJA"] + c["NUEVA"]
        if t == 0:
            v = "SIN POSICIONES DECLARADAS (no verificable con datos)"
        elif c["NUEVA"] > 0 and c["VIEJA"] == 0:
            v = "CUMPLIDA (100%% en area nueva)"
        elif c["NUEVA"] > 0:
            v = "PARCIAL (%.0f%% en area nueva)" % (100.0 * c["NUEJA"] / t)
        else:
            v = "NO CUMPLIDA (0%% en area nueva)"
        print("    %-22s %s" % (cat, v))
    return 0


if __name__ == "__main__":
    sys.exit(main())