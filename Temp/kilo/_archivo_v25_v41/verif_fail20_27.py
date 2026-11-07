# -*- coding: utf-8 -*-
# Investigacion FAIL 20 (ls-tree 347-351), FAIL 27 (WT=1265 composicion), y MATERIAL: M87 flip 140/140 (quien, cuando, sustento).
import io, os, subprocess, glob, re, datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def git(*args, cwd=RAIZ):
    r = subprocess.run([u"git"] + list(args), cwd=cwd, capture_output=True)
    return r.stdout.decode(u"utf-8", u"replace"), r.stderr.decode(u"utf-8", u"replace")

print(u"=== c) ls-tree HEAD canal Ling: 347-351 ===")
out, err = git(u"ls-tree", u"-r", u"--name-only", u"HEAD", u"--", u"Mensajes entre modelos/Ling-3.1-Flash/")
lines = [l for l in out.split(u"\n") if l.strip()]
print(u"entries:", len(lines), u"| stderr:", err.strip()[:120])
for n in [347, 348, 349, 350, 351, 352, 353, 354]:
    hits = [l for l in lines if l.startswith(u"%d-" % n)]
    print(u"  %d en HEAD: %s %s" % (n, bool(hits), hits[0][:70] if hits else u""))

print(u"\n=== d) composicion WT ===")
out, _ = git(u"status", u"--porcelain")
st = [l for l in out.split(u"\n") if l.strip()]
from collections import Counter
top = Counter(); status = Counter()
for l in st:
    status[l[:2].strip()] += 1
    path = l[3:].strip().strip(u"\"")
    parts = path.split(u"/")
    key = parts[0] + (u"/" + parts[1] if len(parts) > 1 and parts[0] == u"Mensajes entre modelos" else u"")
    top[key] += 1
print(u"WT total:", len(st), u"| status:", dict(status))
for k, v in top.most_common(15):
    print(u"   %4d  %s" % (v, k))

print(u"\n=== e) M87 flip: mtime + quien + contexto ===")
m87 = RAIZ + u"\\DOCUMENTACION\\87-Localizacion\\plan-actual\\05-Checklist.md"
mt = datetime.datetime.fromtimestamp(os.path.getmtime(m87))
print(u"mtime 05-Checklist M87:", mt.strftime(u"%Y-%m-%d %H:%M:%S"))
t = io.open(m87, encoding=u"utf-8", errors=u"replace").read()
lines = t.split(u"\n")
for i in range(335, min(396, len(lines))):
    print(u"  L%d: %s" % (i + 1, lines[i][:150]))

print(u"\n=== f) M87 Notas del Agente (final archivo) ===")
print(u"\n".join(lines[-40:])[:2600])

print(u"\n=== g) mtime M157 checklist (formato Totales) ===")
m157 = RAIZ + u"\\DOCUMENTACION\\157-Medios-De-Transporte\\plan-actual\\05-Checklist.md"
print(u"mtime:", datetime.datetime.fromtimestamp(os.path.getmtime(m157)).strftime(u"%Y-%m-%d %H:%M:%S"))

print(u"\n=== h) git log --since 2026-11-06 20:00 -- DOCUMENTACION/87-Localizacion ===")
out, _ = git(u"log", u"--oneline", u"--since", u"2026-11-06 20:00", u"--", u"DOCUMENTACION/87-Localizacion")
print(out.strip()[:400] or u"(sin commits)")

print(u"\n=== i) canales con mensajes nuevos > 22:00 (quien escribio M87?) ===")
import datetime as dt
corte = dt.datetime(2026, 11, 6, 21, 30).timestamp()
todos = []
for root, dirs, files in os.walk(os.path.join(RAIZ, u"Mensajes entre modelos")):
    for f in files:
        if f.endswith(u".md"):
            fp = os.path.join(root, f)
            try:
                if os.path.getmtime(fp) > corte:
                    todos.append((os.path.getmtime(fp), fp))
            except Exception:
                pass
for mt, f in sorted(todos)[-18:]:
    print(u"  %s %s" % (datetime.datetime.fromtimestamp(mt).strftime(u"%H:%M"), f.replace(RAIZ + u"\\Mensajes entre modelos\\", u"")[:100]))
