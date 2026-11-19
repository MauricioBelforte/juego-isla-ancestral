# -*- coding: utf-8 -*-
import io, os, re, collections
REPO = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
GAME = os.path.join(REPO, "game", "isla-ancestral")

# 1) msgids de es.po (claves)
po = os.path.join(GAME, "locales", "es.po")
txt = io.open(po, encoding="utf-8").read()
msgids = re.findall(r'^msgid "([^"]+)"', txt, re.M)
msgids = [m for m in msgids if m]
print("ES.PO msgids=%d" % len(msgids))

# 2) corpus de consumo: .gd/.tscn/.tres/.json fuera de locales/ y data/localizacion/
corpus = []
for root, dirs, files in os.walk(GAME):
    rel = os.path.relpath(root, GAME)
    if rel.startswith("locales") or rel.startswith("data" + os.sep + "localizacion"):
        continue
    for fn in files:
        if fn.endswith((".gd", ".tscn", ".tres", ".json")):
            try:
                corpus.append(io.open(os.path.join(root, fn), encoding="utf-8", errors="ignore").read())
            except Exception:
                pass
blob = "\n".join(corpus)
print("corpus archivos=%d bytes=%d" % (len(corpus), len(blob)))

# 3) cruce
orphan, usado = [], []
for m in msgids:
    (usado if m in blob else orphan).append(m)
print("USADOS=%d ORPHAN=%d" % (len(usado), len(orphan)))

# 4) desglose por prefijo
pref = collections.Counter()
for m in orphan:
    pref[m.split(".")[0] if "." in m else "(sin-prefijo)"] += 1
print("ORPHAN-por-prefijo:", dict(pref.most_common()))

print("ORPHAN-lista(%d):" % len(orphan))
for m in orphan[:70]:
    print("  " + m)
