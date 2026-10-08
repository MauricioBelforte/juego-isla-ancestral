# -*- coding: utf-8 -*-
import re, io
p = "game/isla-ancestral/scripts/shops/catalogo_tiendas.gd"
c = io.open(p, encoding="utf-8").read()

# Mapeo M39 (nombres es) -> M15 (id validos, por 'nombre' M15)
map = {
    "madera_roble": "wood",
    "piedra_caliza": "stone",
    "baya_roja": "OBJ-ITE-024",
    "mineral_cobre": "copper_ore",
    "fragmento_ancestral": "OBJ-ART-003",
    "pergamino_rec_tela_lino": "OBJ-ART-002",
    "herramienta_basica": "OBJ-HER-001",
    "fibra_algodon": "grass",
}
# Reemplazar los ids COMILLADOS (no tocar otros usos). Antes de reemplazar,
# guardo el texto original de cada uno para no pisar coincidencias parciales.
for old, new in map.items():
    pat = '"' + old + '"'
    n = c.count(pat)
    c = c.replace(pat, '"' + new + '"')
    print("reemplazo %-24s -> %-14s (%d ocurrencias)" % (old, new, n))

# Insertar comentario de trazabilidad tras la linea 10 (antes de 'extends Node')
nota = '''# BUG-106 (agnes-3-flash, 2026-10-08): los item_ids originales de M39 eran NOMBRES
# EN ESPAOL que M15 nunca tuvo (M15 usa 'id' en ingles u 'OBJ-*'). Mapeados a ids
# VALIDOS de M15 (por el campo 'nombre' de M15, data/items/*.tres):
#   madera_roble           -> wood          (M15: Madera)
#   piedra_caliza          -> stone         (M15: Piedra)
#   baya_roja              -> OBJ-ITE-024   (M15: Bayas)
#   mineral_cobre          -> copper_ore    (M15: Cobre)
#   fragmento_ancestral    -> OBJ-ART-003   (M15: Cristel ancestral)
#   pergamino_rec_tela_lino-> OBJ-ART-002   (M15: Pergamino mistico)
#   herramienta_basica     -> OBJ-HER-001   (M15: Hacha de madera)
#   fibra_algodon          -> grass         (M15: no tiene fibra -> SUSTITUTO, flag)
# Ver: test_catalogo_m39_m15.gd (guardian anti-regresion) + Log del BUG-106.

'''
anchor = "extends Node"
assert c.count(anchor) == 1
c = c.replace(anchor, nota + anchor, 1)

io.open(p, "w", encoding="utf-8", newline="").write(c)
# Verificacion: no deben quedar ids antiguos
rest = [k for k in map if ('"%s"' % k) in c]
print("\nIds antiguos que aunan quedan:", rest if rest else "NINGUNO (bien)")
for k in map:
    print("  %s presente: %d" % (map[k], c.count('"%s"' % map[k])))
mojibake = re.search(r"Ã|Â|â€", c)
print("Mojibake:", bool(mojibake))
