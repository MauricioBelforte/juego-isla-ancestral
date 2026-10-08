# -*- coding: utf-8 -*-
import re, glob, os
print("=== M15: archivos item ===")
for p in sorted(set(glob.glob("game/isla-ancestral/scripts/items/*.gd", recursive=True)
                    + glob.glob("game/isla-ancestral/scripts/items/**/*.gd", recursive=True)
                    + glob.glob("game/isla-ancestral/scripts/*item*.gd", recursive=True)
                    + glob.glob("game/isla-ancestral/data/items/**", recursive=True)
                    + glob.glob("game/isla-ancestral/data/items*", recursive=True))):
    print("  ", p.split("isla-ancestral/")[-1])

# los 8 ids del bug
ids8 = ["baya_roja", "fibra_algodon", "madera_roble", "mineral_cuche", "pergamino_rec_tela_lino",
        "herramienta_basica", "mineral_cobre", "fragmento_ancestral"]
ids8 = ["baya_roja", "fibra_algodon", "madera_roble", "mineral_cobre", "pergamino_rec_tela_lino",
        "herramienta_basica", "fragmento_ancestral"]
# recolectar todos los ids que existen en el repo (data/items + scripts)
allids = set()
for f in glob.glob("game/isla-ancestral/**/*item*", recursive=True):
    try:
        c = open(f, "rb").read().decode("utf-8", "ignore")
        allids.update(re.findall(r'"([a-z][a-z0-9_]{3,40})"\s*:', c))
        allids.update(re.findall(r'[a-z_][a-z0-9_]{4,40}', " ".join(re.findall(r'\b(a|e|i|o|u)_[a-z_]{3,30}', c))))
    except Exception:
        pass
# mejor: buscar item ids en data/items
data_items = glob.glob("game/isla-ancestral/data/items/**", recursive=True) + glob.glob("game/isla-ancestral/data/items/*", recursive=True)
print("\n=== data/items files ===", [os.path.basename(x) for x in data_items])

# ver catalogo_tiendas.gd
c = open("game/isla-ancestral/scripts/shops/catalogo_tiendas.gd", encoding="utf-8").read()
print("\ncatalogo_tiendas.gd: %d líneas" % len(c.splitlines()))
print("--- referencias a item (contexto) ---")
for L in c.splitlines():
    if re.search(r'baya_roja|fibra_algodon|madera_roble|mineral_cobre|pergamino|herramienta_basica|fragmento_ancestral|_validar_tienda|item_id', L):
        print("   ", L.strip()[:95])
