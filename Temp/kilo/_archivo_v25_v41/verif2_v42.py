# -*- coding: utf-8 -*-
# Verificacion urgente v42: D en game/ y scripts/ (codigo en peligro?), D/M en canal Ling (mis mensajes?), composicion D por canal.
import io, os, subprocess

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def git(*args, cwd=RAIZ):
    r = subprocess.run([u"git"] + list(args), cwd=cwd, capture_output=True)
    return r.stdout.decode(u"utf-8", u"replace")

st = [l for l in git(u"status", u"--porcelain").split(u"\n") if l.strip()]
print(u"Total WT:", len(st))

print(u"\n=== 1. D (deletions) en game/ y scripts/ — CODIGO EN PELIGRO? ===")
d_game = [l for l in st if l[:2].strip() == u"D" and (l[3:].startswith(u"game/") or l[3:].startswith(u"scripts/"))]
print(u"count:", len(d_game))
for l in d_game[:25]:
    print(u"  ", l[:140])

print(u"\n=== 2. Cambios en canal Ling (151) — desglose status ===")
ling = [l for l in st if l[3:].startswith(u"Mensajes entre modelos/Ling-3.1-Flash")]
from collections import Counter
c = Counter(l[:2].strip() for l in ling)
print(u"status counts:", dict(c))
d_ling = [l for l in ling if l[:2].strip() == u"D"]
print(u"D en canal Ling:", len(d_ling))
for l in d_ling[:10]:
    print(u"  DEL:", l[3:][:120])
m_ling = [l for l in ling if l[:2].strip() == u"M"]
print(u"M en canal Ling:", len(m_ling))
for l in m_ling[:10]:
    print(u"  MOD:", l[3:][:120])

print(u"\n=== 3. D global: top carpetas de las 931 deletions ===")
dd = [l[3:].strip().strip(u"\"") for l in st if l[:2].strip() == u"D"]
top = {}
for p in dd:
    parts = p.split(u"/")
    key = u"/".join(parts[:3]) if len(parts) > 2 else p
    top[key] = top.get(key, 0) + 1
for k, v in sorted(top.items(), key=lambda t: -t[1])[:12]:
    print(u"  %4d  %s" % (v, k))

print(u"\n=== 4. game/ y scripts/ todos los cambios (M/D/??) ===")
gs = [l for l in st if l[3:].startswith(u"game/") or l[3:].startswith(u"scripts/")]
print(u"count:", len(gs))
for l in gs[:20]:
    print(u"  ", l[:140])

print(u"\n=== 5. DOCUMENTACION/ cambios (5) ===")
doc = [l for l in st if l[3:].startswith(u"DOCUMENTACION/")]
for l in doc:
    print(u"  ", l[:140])

print(u"\n=== 6. ls-tree HEAD: mis 347-354 con substring (corrige startswith) ===")
tree = git(u"ls-tree", u"-r", u"--name-only", u"HEAD", u"--", u"Mensajes entre modelos/Ling-3.1-Flash/")
for n in range(347, 355):
    hit = [l for l in tree.split(u"\n") if ("/%d-" % n) in l or l.startswith(u"%d-" % n)]
    print(u"  %d en HEAD: %s" % (n, bool(hit)))
