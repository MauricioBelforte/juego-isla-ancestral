#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""M52 (Particulas y VFX) — generador validante del catalogo de VFX.

Iter. 6 (Log 1002, DeepSeek-V4.1-Flash). Reemplaza el catalogo de 8 entradas de
la iter. 5 por el catalogo COMPLETO derivado del plan maestro.

Uso:
    python tools/vfx/gen_vfx_catalog.py            # regenera el catalogo
    python tools/vfx/gen_vfx_catalog.py --check     # exit 1 si el disco difiere

El catalogo es un DATASET: su fuente de verdad es la tabla E de este archivo.
Regenerarlo es determinista (mismo E -> mismos bytes), y `--check` lo verifica
en CI, asi que editar el JSON a mano se detecta.

Reglas que se validan ANTES de escribir (no despues):
  - ids unicos y con naming M108 (`vfx_<snake_case>`).
  - `tipo` y `categoria` de conjuntos CERRADOS y ortogonales (categoria != tipo:
    eran dos ejes mezclados, y `atmosferico` aparecia como los dos).
  - cantidad 5-300, emision 0.1-3, presupuesto >= cantidad.
  - RF7: `luz_por_particula` SIEMPRE false (la luz es de M49).
  - RF11: `parpadeo_hz` <= 10 (sin estroboscopios).
  - RF14: un loop SIEMPRE tiene `radio` de culling; un no-loop nunca.
  - RF6: sin `bus` -> hace falta `dueno_evento` (nadie dispara el efecto).
  - Cobertura: los 24 nombres del plan maestro estan todos representados.

NOTA de discrepancia (reportada, no resuelta aca): el checklist RF1 pide
"listar los 25 efectos del plan maestro", pero `plan-inicial/04-Codigo.md:149`
enumera **24** nombres. La tabla PLAN cubre esos 24. El "25" no tiene respaldo
en el plan -> lo decide el dueno del checklist.
"""
import argparse
import json
import pathlib
import re
import sys

RAIZ = pathlib.Path(__file__).resolve().parents[2]
DESTINO = RAIZ / "game" / "isla-ancestral" / "data" / "vfx" / "vfx_catalog.json"

# (id, nombre, plan, tipo, categoria, evento, bus, dueno_evento, condicion,
#  cantidad, color, emision, material, emisor, presupuesto, loop, fase, radio,
#  parpadeo_hz, luz_por_particula)
E = [
    # --- B. RF1 catalogo: humo/polvo ---
    ("vfx_humo", "Humo", "humo", "humo", "ambiental", "fuego_encendido", "", "M49", "", 40, "#9AA0A6", 1.5, "unshaded_alpha", "global", 80, True, 0.00, 40.0, 0.0, False),
    ("vfx_polvo", "Polvo del desierto", "polvo", "polvo", "ambiental", "polvo_desierto", "", "M32", "clima:despejado", 60, "#C8B08A", 1.5, "unshaded_alpha", "global", 120, True, 0.13, 90.0, 0.0, False),
    ("vfx_bloque_roto", "Bloque roto", "polvo", "polvo", "impacto", "bloque_roto", "world.block_removed", "", "", 24, "#C8B08A", 0.35, "unshaded_alpha", "punto", 60, False, 0.0, 0.0, 0.0, False),
    # --- hojas / petalos ---
    ("vfx_hojas", "Hojas al viento", "hojas", "hojas", "ambiental", "viento_hojas", "calendar.season_changed", "", "estacion:otono", 40, "#58A55D", 1.2, "unshaded_alpha", "global", 100, True, 0.27, 70.0, 0.0, False),
    ("vfx_polen", "Polen", "petalos", "flotante", "ambiental", "primavera_inicio", "calendar.season_changed", "", "estacion:primavera", 150, "#F4E04D", 1.2, "unshaded_alpha", "global", 220, True, 0.41, 80.0, 0.0, False),
    ("vfx_petalos", "Petalos primaverales", "petalos", "flotante", "ambiental", "petalos_primavera", "calendar.season_changed", "", "estacion:primavera", 60, "#F2B8CE", 1.2, "unshaded_alpha", "global", 120, True, 0.58, 70.0, 0.0, False),
    # --- chispas ---
    ("vfx_chispas", "Chispas de herramienta", "chispas", "chispas", "impacto", "herramienta_golpe", "", "M13", "", 18, "#FFD700", 0.30, "unshaded_add", "punto", 40, False, 0.0, 0.0, 0.0, False),
    ("vfx_crafteo", "Crafteo completado", "chispas", "chispas", "impacto", "crafting_completado", "", "M16", "", 20, "#FFD700", 0.40, "unshaded_add", "esfera", 50, False, 0.0, 0.0, 0.0, False),
    # --- agua ---
    ("vfx_salpicadura", "Salpicadura al nadar", "agua", "splash", "impacto", "agua_salpicadura", "", "M51", "", 36, "#6FB7DE", 0.50, "unshaded_alpha", "punto", 70, False, 0.0, 0.0, 0.0, False),
    ("vfx_gotas_cascada", "Gotas de cascada", "agua", "gotas", "ambiental", "cascada_cerca", "", "M51", "", 50, "#8FBFE0", 1.0, "unshaded_alpha", "caja", 90, True, 0.19, 50.0, 0.0, False),
    ("vfx_pesca_exito", "Pesca exitosa", "pesca", "splash", "impacto", "pesca_exito", "", "M13", "", 40, "#6FB7DE", 0.60, "unshaded_alpha", "punto", 80, False, 0.0, 0.0, 0.0, False),
    # --- lluvia / nieve (categoria `clima`: antes decia `atmosferico`, que es un TIPO) ---
    ("vfx_lluvia", "Lluvia", "lluvia", "gotas", "clima", "clima_lluvia", "weather.clima_cambio", "", "clima:lluvia", 120, "#8FBFE0", 1.0, "unshaded_alpha", "global", 200, True, 0.07, 120.0, 0.0, False),
    ("vfx_lluvia_salpicadura", "Salpicadura de lluvia", "lluvia", "gotas", "clima", "lluvia_salpicadura", "weather.clima_cambio", "", "clima:lluvia", 60, "#8FBFE0", 0.80, "unshaded_alpha", "caja", 110, True, 0.33, 60.0, 0.0, False),
    ("vfx_nieve", "Nieve", "nieve", "nieve", "clima", "clima_nieve", "weather.clima_cambio", "", "clima:nieve", 100, "#EAF2F8", 1.4, "unshaded_alpha", "global", 180, True, 0.51, 120.0, 0.0, False),
    # --- fuego / lava (RF7: sin luz por particula) ---
    ("vfx_fuego", "Fuego", "fuego", "fuego", "ambiental", "fuego_encendido", "", "M49", "", 45, "#FF9A3C", 0.80, "unshaded_add", "caja", 90, True, 0.23, 35.0, 0.0, False),
    ("vfx_lava", "Lava", "lava", "lava", "ambiental", "lava_cerca", "", "M49", "", 30, "#FF5A1F", 1.0, "unshaded_add", "caja", 70, True, 0.61, 35.0, 0.0, False),
    # --- luz / magia / ancestral ---
    ("vfx_luz", "Luz de herramienta", "luz", "luz", "impacto", "herramienta_nivel", "progresion.nivel_herramienta_cambio", "", "", 24, "#FFE9A8", 0.60, "unshaded_add", "esfera", 50, False, 0.0, 0.0, 0.0, False),
    ("vfx_magia", "Magia tecnologica", "magia", "magia", "magia", "magia_tecnologica", "", "M86", "", 50, "#7FE0D4", 0.90, "unshaded_add", "esfera", 100, False, 0.0, 0.0, 0.0, False),
    ("vfx_resonancia", "Resonancia ancestral", "resonancia", "resonancia", "magia", "runa_resonancia", "quest.prereq_met", "", "", 40, "#A98BFF", 0.70, "unshaded_add", "esfera", 80, False, 0.0, 0.0, 0.0, False),
    ("vfx_runas", "Activacion de runas", "runas", "runas", "magia", "runa_activada", "quest.prereq_met", "", "", 36, "#A98BFF", 0.80, "unshaded_add", "esfera", 70, False, 0.0, 0.0, 0.0, False),
    ("vfx_teletransporte", "Teletransporte", "teletransporte", "teletransporte", "magia", "viaje_iniciado", "travel.travel_started", "", "", 70, "#8FD3FF", 0.60, "unshaded_add", "esfera", 120, False, 0.0, 0.0, 0.0, False),
    ("vfx_sello", "Obtencion de Sello", "sello", "sello", "magia", "sello_obtenido", "quest.prereq_met", "", "", 80, "#FFD86B", 1.0, "unshaded_add", "esfera", 140, False, 0.0, 0.0, 0.0, False),
    ("vfx_puzzle", "Resolucion de puzzle", "puzzle", "puzzle", "magia", "puzzle_resuelto", "quest.quest_completed", "", "", 60, "#9BE8B0", 0.90, "unshaded_add", "esfera", 110, False, 0.0, 0.0, 0.0, False),
    # --- construccion / cosecha ---
    ("vfx_construccion", "Construccion", "construccion", "construccion", "impacto", "bloque_colocado", "world.block_placed", "", "", 28, "#C8B08A", 0.40, "unshaded_alpha", "punto", 60, False, 0.0, 0.0, 0.0, False),
    ("vfx_cosecha", "Cosecha", "cosecha", "hojas", "impacto", "cosecha_realizada", "inventory.item_added", "", "", 30, "#58A55D", 0.50, "unshaded_alpha", "esfera", 70, False, 0.0, 0.0, 0.0, False),
    # --- descubrimiento / estaciones / interfaz / atmosfericos ---
    ("vfx_descubrimiento", "Descubrimiento", "descubrimiento", "descubrimiento", "magia", "entrada_diario", "diary.entrada_nueva", "", "", 45, "#FFE9A8", 0.90, "unshaded_add", "esfera", 90, False, 0.0, 0.0, 0.0, False),
    ("vfx_estacional", "Cambio estacional", "estaciones", "estacional", "estacional", "estacion_cambio", "calendar.season_changed", "", "", 90, "#C77FDB", 1.4, "unshaded_alpha", "global", 160, False, 0.0, 0.0, 0.0, False),
    ("vfx_ui", "Efectos de interfaz", "interfaz", "ui", "ui", "notificacion", "ui.notify", "", "", 30, "#FFFFFF", 0.50, "unshaded_alpha", "punto", 50, False, 0.0, 0.0, 0.0, False),
    ("vfx_atmosferico", "Atmosferico por zona", "atmosfericos", "atmosferico", "ambiental", "clima_cambio", "weather.clima_cambio", "", "", 80, "#B8C6D1", 1.5, "unshaded_alpha", "global", 150, True, 0.37, 150.0, 0.0, False),
    # --- extras preexistentes (no estan en la lista canonica; no se borran) ---
    ("vfx_regalo_amistad", "Regalo de amistad", "", "corazones", "impacto", "amistad_subio", "npc.friendship_level_up", "", "", 12, "#E08FB0", 0.50, "unshaded_alpha", "punto", 30, False, 0.0, 0.0, 0.0, False),
    ("vfx_evento_festival", "Festival", "", "confeti", "impacto", "evento_iniciado", "calendar.day_started", "", "", 120, "#C77FDB", 0.90, "unshaded_alpha", "global", 200, False, 0.0, 0.0, 0.0, False),
]

CAMPOS = ("id", "nombre", "plan", "tipo", "categoria", "evento", "bus",
          "dueno_evento", "condicion", "cantidad", "color", "emision",
          "material", "emisor", "presupuesto", "loop", "fase", "radio",
          "parpadeo_hz", "luz_por_particula")

# Los 24 nombres del plan maestro (plan-inicial/04-Codigo.md:149). El checklist
# dice 25: discrepancia reportada, no inventada.
PLAN = ["humo", "polvo", "hojas", "petalos", "chispas", "agua", "pesca",
        "lluvia", "nieve", "fuego", "lava", "luz", "magia", "resonancia",
        "runas", "teletransporte", "sello", "puzzle", "construccion",
        "cosecha", "descubrimiento", "estaciones", "interfaz", "atmosfericos"]

# Conjuntos CERRADOS (la schema GDScript valida contra estos mismos valores).
CATEGORIAS = ["ambiental", "clima", "estacional", "impacto", "magia", "ui"]
EMISORES = ["punto", "esfera", "caja", "global"]
MATERIALES = ["unshaded_alpha", "unshaded_add"]
TIPOS = ["atmosferico", "chispas", "confeti", "construccion", "corazones",
         "descubrimiento", "estacional", "flotante", "fuego", "gotas", "hojas",
         "humo", "lava", "luz", "magia", "nieve", "polvo", "puzzle",
         "resonancia", "runas", "sello", "splash", "teletransporte", "ui"]
RE_ID = re.compile(r"^vfx_[a-z0-9_]+$")
RE_HEX = re.compile(r"^#[0-9A-Fa-f]{6}$")


def construir():
    """Devuelve (doc, entradas) tras validar la tabla E. Lanza AssertionError."""
    entradas = []
    for fila in E:
        assert len(fila) == len(CAMPOS), \
            "fila con %d campos (esperado %d): %s" % (len(fila), len(CAMPOS), fila[0])
        entradas.append(dict(zip(CAMPOS, fila)))

    ids = [e["id"] for e in entradas]
    assert len(ids) == len(set(ids)), \
        "ids duplicados: %s" % sorted({i for i in ids if ids.count(i) > 1})

    tipos = sorted({e["tipo"] for e in entradas})
    for e in entradas:
        v = e["id"]
        assert RE_ID.match(v), "%s: naming M108 invalido" % v
        assert e["nombre"], "%s: sin nombre" % v
        assert e["tipo"] in TIPOS, \
            "%s: tipo '%s' fuera del conjunto cerrado" % (v, e["tipo"])
        assert e["categoria"] in CATEGORIAS, \
            "%s: categoria '%s' fuera del conjunto cerrado %s" % (v, e["categoria"], CATEGORIAS)
        assert e["emisor"] in EMISORES, "%s: emisor '%s' invalido" % (v, e["emisor"])
        assert e["material"] in MATERIALES, "%s: material '%s' invalido" % (v, e["material"])
        assert RE_HEX.match(e["color"]), "%s: color '%s' invalido" % (v, e["color"])
        assert 5 <= e["cantidad"] <= 300, "%s: cantidad %d" % (v, e["cantidad"])
        assert 0.1 <= e["emision"] <= 3.0, "%s: emision %s" % (v, e["emision"])
        assert e["presupuesto"] >= e["cantidad"], "%s: presupuesto < cantidad" % v
        assert 0.0 <= e["fase"] < 1.0, "%s: fase %s" % (v, e["fase"])
        assert e["luz_por_particula"] is False, "%s: RF7 violado (luz por particula)" % v
        assert e["parpadeo_hz"] <= 10.0, "%s: RF11 violado (estroboscopio)" % v
        if e["loop"]:
            assert e["radio"] > 0.0, "%s: loop sin radio de culling (RF14)" % v
        else:
            assert e["radio"] == 0.0, "%s: no-loop con radio" % v
        if not e["bus"]:
            assert e["dueno_evento"], "%s: sin bus y sin dueno_evento (RF6)" % v
        else:
            assert "." in e["bus"], "%s: bus mal formado (%s)" % (v, e["bus"])

    cubiertos = {e["plan"] for e in entradas if e["plan"]}
    faltan = [p for p in PLAN if p not in cubiertos]
    assert not faltan, "nombres canonicos sin cubrir: %s" % faltan

    # La proteccion real de la taxonomia es que CATEGORIAS sea un conjunto CERRADO
    # y HONESTO: si declaras una categoria y no la usas, el constante miente y el
    # siguiente que agregue una entrada la inventara. (Nota: `categoria == tipo`
    # NO es un error — `magia` y `ui` son legitimamente los dos. El defecto real
    # de la iter. 5 era que `atmosferico` estaba en la lista de categorias como
    # duplicado de un tipo, agrupando otra cosa.)
    usadas = {e["categoria"] for e in entradas}
    assert usadas == set(CATEGORIAS), \
        "CATEGORIAS declara %s pero se usan %s" % (sorted(CATEGORIAS), sorted(usadas))
    assert tipos == sorted(TIPOS), \
        "TIPOS declara %s pero se usan %s" % (sorted(TIPOS), tipos)

    return {"version": 2, "vfx": entradas}, entradas


def serializar(doc, crlf):
    texto = json.dumps(doc, ensure_ascii=False, indent=2)
    if crlf:
        texto = texto.replace("\n", "\r\n")
    return texto.encode("utf-8")


def eol_actual():
    """EOL del archivo en disco (no imponer uno nuevo: trampa 69)."""
    if DESTINO.exists():
        b = DESTINO.read_bytes()
        return b.count(b"\r\n") > (b.count(b"\n") - b.count(b"\r\n"))
    return False


def main():
    ap = argparse.ArgumentParser(description="Generador validante del catalogo de VFX (M52)")
    ap.add_argument("--check", action="store_true",
                    help="no escribe: exit 1 si el disco difiere del generador")
    a = ap.parse_args()

    doc, entradas = construir()
    datos = serializar(doc, eol_actual())

    print("catalogo M52: %d entradas, %d loops, %d con bus, %d con dueno_evento"
          % (len(entradas), sum(1 for e in entradas if e["loop"]),
             sum(1 for e in entradas if e["bus"]),
             sum(1 for e in entradas if e["dueno_evento"])))
    print("  plan cubierto : %d/%d nombres canonicos"
          % (len({e["plan"] for e in entradas if e["plan"]}), len(PLAN)))
    print("  categorias    : %s" % sorted({e["categoria"] for e in entradas}))

    if a.check:
        if not DESTINO.exists():
            print("DRIFT: %s no existe" % DESTINO)
            return 1
        actual = DESTINO.read_bytes()
        if actual == datos:
            print("OK: %s coincide con el generador" % DESTINO.name)
            return 0
        print("DRIFT: %s (%d bytes) != generador (%d bytes)"
              % (DESTINO.name, len(actual), len(datos)))
        return 1

    DESTINO.write_bytes(datos)
    b = DESTINO.read_bytes()
    print("escrito: %s" % DESTINO.name)
    print("  bytes=%d CRLF=%d LF_solos=%d dobleCR=%d BOM=%s" % (
        len(b), b.count(b"\r\n"), b.count(b"\n") - b.count(b"\r\n"),
        b.count(b"\r\r\n"), b[:3] == b"\xef\xbb\xbf"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
