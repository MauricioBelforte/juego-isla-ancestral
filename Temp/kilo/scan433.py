# -*- coding: utf-8 -*-
import io, os, datetime, glob as globmod, subprocess, hashlib
base = os.getcwd()
canal = os.path.join(base, "Mensajes entre modelos", "Ling-3.1-Flash")
msgs = sorted(globmod.glob(os.path.join(canal, "*.md")))
print("CANAL LING ultimos 4:")
for m in msgs[-4:]:
    print("   ", os.path.basename(m)[:95], os.path.getsize(m), "B")
pt = os.path.join(base, "game", "isla-ancestral", "locales", "pt.po")
print("PT sha256:", hashlib.sha256(open(pt, "rb").read()).hexdigest()[:16])
g = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True, cwd=base)
print("HEAD:", g.stdout.strip())
gl = subprocess.run(["git", "log", "-1", "--format=%h %ad %s", "--date=iso"], capture_output=True, text=True, cwd=base)
print("GL:", gl.stdout.strip()[:120])
cut = datetime.datetime(2026, 11, 18, 19, 30, 0)
def nuevos(directorio, label):
    if not os.path.isdir(directorio):
        return
    out = []
    for root, dirs, files in os.walk(directorio):
        for fn in files:
            p = os.path.join(root, fn)
            try:
                mt = datetime.datetime.fromtimestamp(os.path.getmtime(p))
            except OSError:
                continue
            if mt > cut:
                out.append((mt, p))
    if out:
        print(label, ":", len(out), "nuevos desde 19:30 local")
        for mt, p in sorted(out)[-6:]:
            print("   ", mt.strftime("%H:%M"), os.path.relpath(p, base)[:110])
for d, l in [("Reflection-Beam-1.0", "BEAM"), ("Glyph Cluster", "GLYPH"), ("Nemotron-3.5-Super-VL", "NEMO"), ("HY4 Flash", "HY4"), ("agnes-3-flash", "AGNES"), ("DeepSeek-V4.1-Flash", "DS"), ("Hy3", "HY3"), ("kimi-k3", "KIMI"), ("Step-5-WorkBuddy", "STEP5")]:
    nuevos(os.path.join(base, "Mensajes entre modelos", d), l)
nuevos(os.path.join(base, "Mensajes entre modelos"), "RAIZ(top-level only files)")
for pat in ["*b29*", "*B29*", "*acuse-b27*", "*cierre-i18n*"]:
    hits = globmod.glob(os.path.join(base, "Mensajes entre modelos", "**", pat), recursive=True)
    for h in hits[:6]:
        print("HIT", pat, "->", os.path.relpath(h, base)[:120])
est = os.path.join(base, "Logs", "estado_director.json")
print("ESTADO mtime:", datetime.datetime.fromtimestamp(os.path.getmtime(est)).isoformat())
