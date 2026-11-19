# -*- coding: utf-8 -*-
import io, os, datetime, glob as globmod, subprocess
base = os.getcwd()
cut = datetime.datetime(2026, 11, 18, 15, 5, 0)  # 18:05Z = 15:05 local (-0300)
def nuevos(directorio, label):
    if not os.path.isdir(directorio):
        print(label, ": NO EXISTE"); return
    out = []
    for root, dirs, files in os.walk(directorio):
        for fn in files:
            p = os.path.join(root, fn)
            try:
                mt = datetime.datetime.fromtimestamp(os.path.getmtime(p))
            except OSError:
                continue
            if mt > cut and not fn.endswith(".md.bak"):
                out.append((mt, os.path.relpath(p, base)))
    print(label, ":", len(out), "nuevos desde 15:05 local")
    for mt, p in sorted(out)[-8:]:
        print("   ", mt.strftime("%H:%M"), os.path.basename(p)[:90])
nuevos(os.path.join(base, "Mensajes entre modelos", "Reflection-Beam-1.0"), "BEAM")
nuevos(os.path.join(base, "Mensajes entre modelos", "Glyph Cluster"), "GLYPH")
nuevos(os.path.join(base, "Mensajes entre modelos"), "RAIZ-MENSAJES")
est = os.path.join(base, "Logs", "estado_director.json")
print("ESTADO mtime:", datetime.datetime.fromtimestamp(os.path.getmtime(est)).isoformat())
canal = os.path.join(base, "Mensajes entre modelos", "Ling-3.1-Flash")
msgs = sorted(globmod.glob(os.path.join(canal, "*.md")))
print("CANAL LING ultimos 3:")
for m in msgs[-3:]:
    print("   ", os.path.basename(m)[:100], os.path.getsize(m), "B")
ev = os.path.join(base, "Mensajes entre modelos", "Glyph Cluster", "evaluacion_informes_2026-11-18_1800.md")
for cand in globmod.glob(os.path.join(base, "**", "evaluacion_informes_2026-11-18_1800.md"), recursive=True):
    print("EVAL NEMOTRON ENCONTRADO:", cand, os.path.getsize(cand), "B")
g = subprocess.run(["git", "log", "-3", "--format=%h %ad %s", "--date=iso"], capture_output=True, text=True, cwd=base)
print("GIT LOG:\n" + g.stdout.strip())
