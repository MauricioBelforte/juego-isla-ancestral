# -*- coding: utf-8 -*-
"""SB-03 — tabla de evidencia final: radios exactos del contenido placement.

Fuente de verdad de las constantes: game/isla-ancestral/scripts/world/mundo_raiz.gd
  CENTRO          = Vector2(2560, 2560)
  RADIO_ISLA      = 1800.0   (anillos de bioma)
  RADIO_ORILLA    = 1700.0   (el agua voxel termina ~r 1700)
  SPAWN_JUGADOR   = Vector3(3860, 0, 3860)
  SPAWN_CONTENIDO = Vector3(3860, 0, 3860)

Umbral AREA VIEJA = radio <= 256 (la isla antes del rework "Isla 10x", commit c107419).
"""
import math

CENTRO = (2560.0, 2560.0)
R_VIEJO = 256.0
R_ORILLA = 1700.0
R_NOMINAL = 1800.0


def r(x, z):
    return math.hypot(x - CENTRO[0], z - CENTRO[1])


def zona(nombre, fuente, cxy, radio, tipo):
    rc = r(*cxy)
    lo = rc - radio
    hi = rc + radio
    lado = "NUEVA" if lo > R_VIEJO else ("VIEJA" if hi <= R_VIEJO else "MIXTA")
    print("  %-26s %s" % (nombre.strip(), fuente))
    print("  %-26s centro=(%.0f,%.0f) r=%.0f  radio=%-5.0f -> r ∈ [%.0f .. %.0f]  => %s"
          % ("", cxy[0], cxy[1], rc, radio, max(0.0, lo), hi, lado))


print("=" * 104)
print("SB-03 — EVIDENCIA DE PLACEMENT (radios exactos, centro 2560,2560)")
print("=" * 104)
print("Umbral area VIEJA r<=%.0f · orilla r=%.0f · radio nominal r=%.0f"
      % (R_VIEJO, R_ORILLA, R_NOMINAL))
print()

SP = (3860.0, 3860.0)
DIR = (0.70710678, 0.70710678)  # normalizada de objetivo - centro

print("[ NPCs / FAUNA ]  fauna_spawner.gd L54-68 — 3 zonas nominales derivadas de MundoRaiz")
zona("  pradera", "fauna_spawner.gd:66 (objetivo=SPAWN_CONTENIDO)", SP, 250.0, "fauna")
zona("  playa", "fauna_spawner.gd:67 (costa=centro+dir*1666)", (CENTRO[0] + DIR[0] * 1666, CENTRO[1] + DIR[1] * 1666), 120.0, "fauna")
zona("  humedal", "fauna_spawner.gd:68 (centro+dir*1780)", (CENTRO[0] + DIR[0] * 1780, CENTRO[1] + DIR[1] * 1780), 100.0, "fauna")
print()

print("[ RECURSOS ]  main_island.gd L71 -> resource_manager.poblar_isla -> resource_spawner.planificar_region")
print("  centro = mundo.SPAWN_CONTENIDO = (3860, 0, 3860) -> r = %.0f" % r(*SP))
print("  offsets candidatos por definicion (resource_spawner.gd:56 _offsets_candidatos), max 12 por region")
print()

print("[ VEGETACION ]  vegetation_spawner.gd L36-37")
zona("  isla", "vegetation_spawner.gd:36-38 (centro=SPAWN_CONTENIDO, radio=1200)", SP, 1200.0, "vegetacion")
print()

print("[ CRAFTING ]  main_island.gd L55-56")
cs = (SP[0] + 6.0, SP[1] + 2.0)
zona("  estacion inicial", "main_island.gd:55-56 (SPAWN_CONTENIDO + (6,2))", cs, 0.0, "crafting")
print()

print("[ SPAWN JUGADOR ]  mundo_raiz.gd L26")
print("  (3860, 0, 3860) -> r = %.0f  => AREA NUEVA" % r(*SP))
print()

print("[ MISIONES ]  historia_principal.json (M22) — grafo narrativo SIN posiciones")
print("  8 capitulos · 7 sellos · 4 finales · 0 coordenadas")
print("  campos por nodo: id, capitulo, titulo, tipo, resumen, requisitos, siguiente")
print("  VEREDICTO: NO ANCLADO ESPACIALMENTE (no se puede cumplir 'misiones en areas nuevas')")
print()

print("[ UBICACIONES (M160) ]")
print("  data/ubicaciones/ubicaciones_loc.json (39) + data/locations/*.tres (9): SIN posicion")
print("  campos: location_id, nombre, descripcion, requisitos, npcs, conexiones, tags, objetos")
print("  data/ubicaciones/ubicaciones.json (10 entradas): TIENE posicion, pero del SISTEMA VIEJO")
print("    %-30s %-16s %-22s %s" % ("id", "x,z declarados", "r con centro NUEVO", "donde cae"))
for i, (n, x, z) in enumerate([
    ("ubic_spawn_riz", 256, 256), ("ubic_templo_raiz", 200, 200),
    ("ubic_biblioteca_choza", 320, 320), ("ubic_faro", 350, 350),
    ("ubic_laguna_coral", 1024, 256), ("ubic_templo_coral", 1200, 256),
    ("ubic_volcan", 256, 1024), ("ubic_templo_ceniza", 400, 1024),
    ("ubic_aurora_cielo", 1024, 1024), ("ubic_templo_aurora", 1150, 1024),
]):
    rr = r(x, z)
    donde = "AGUA (fuera de orilla %.0f)" % R_ORILLA if rr > R_ORILLA else "isla"
    print("    %-30s %-16s %-22.0f %s" % (n, "%d,%d" % (x, z), rr, donde))
print()
print("  NOTA: data/ubicaciones/ubicaciones.json NO tiene consumidor en ningun .gd ni .tscn")
print("        -> es dato muerto. Verificado con grep de 'ubicaciones.json' en el proyecto.")
print()

print("=" * 104)
print("VEREDICTO POR CATEGORIA")
print("=" * 104)
cats = [
    ("NPCs (fauna, 7 especies / 3 zonas)", "CUMPLIDA", "100 % de las zonas a r >= 1546"),
    ("Recursos (M15, 6+ definiciones)", "CUMPLIDA", "centrados en r = 1838"),
    ("Vegetacion (M50)", "CUMPLIDA", "r ∈ [638 .. 3038]"),
    ("Estacion de crafting (M16)", "CUMPLIDA", "r = 1845"),
    ("Misiones (M22)", "NO CUMPLIDA", "grafo narrativo sin anclaje espacial"),
    ("Ubicaciones (M160)", "NO VERIFICABLE", "sin posicion; 1 archivo con coords del sistema viejo"),
]
for c, v, e in cats:
    print("  %-36s %-16s %s" % (c, v, e))
print()
print("  GLOBAL: PARCIAL (3 de 3 tipos del encargo quedan: NPCs OK, recursos OK, misiones NO)")