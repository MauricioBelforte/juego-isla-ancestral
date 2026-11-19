# -*- coding: utf-8 -*-
import io, os, datetime, glob as globmod, subprocess, hashlib
base = os.getcwd()
MB = os.path.join(base, "Mensajes entre modelos")
canal = os.path.join(MB, "Ling-3.1-Flash")
msgs = sorted(globmod.glob(os.path.join(canal, "*.md")))
print("CANAL LING ultimos 3:")
for m in msgs[-3:]:
    print("   ", os.path.basename(m)[:95], os.path.getsize(m), "B")
pool = os.path.join(canal, "NUMEROS_DISPONIBLES.txt")
print("POOL LING bytes:", os.path.getsize(pool) if os.path.exists(pool) else "NO EXISTE")
pt = os.path.join(base, "game", "isla-ancestral", "locales", "pt.po")
print("PT sha:", hashlib.sha256(open(pt, "rb").read()).hexdigest()[:16])
g = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True, cwd=base)
print("HEAD:", g.stdout.strip())
gl = subprocess.run(["git", "log", "-1", "--format=%h %ad %s", "--date=iso"], capture_output=True, text=True, cwd=base)
print("GL:", gl.stdout.strip()[:130])
est = os.path.join(base, "Logs", "estado_director.json")
print("ESTADO mtime:", datetime.datetime.fromtimestamp(os.path.getmtime(est)).isoformat())
def ultimos(directorio, label, n=3):
    if not os.path.isdir(directorio):
        print(label, ": sin canal"); return
    out = []
    for root, dirs, files in os.walk(directorio):
        for fn in files:
            if fn.endswith(".md"):
                p = os.path.join(root, fn)
                try:
                    out.append((os.path.getmtime(p), p))
                except OSError:
                    pass
    out.sort()
    print(label, "ultimos", n, ":")
    for mt, p in out[-n:]:
        print("   ", datetime.datetime.fromtimestamp(mt).strftime("%H:%M"), os.path.relpath(p, base)[:100])
ultimos(os.path.join(MB, "HY4 Flash"), "HY4", 3)
ultimos(os.path.join(MB, "agnes-3-flash"), "AGNES", 2)
ultimos(os.path.join(MB, "Nemotron-3.5-Super-VL"), "NEMO", 2)
cut = datetime.datetime(2026, 11, 19, 0, 0, 0)
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
        print(label, "nuevos >00:00Z:", len(out))
        for mt, p in sorted(out)[-5:]:
            print("   ", mt.strftime("%H:%M"), os.path.relpath(p, base)[:110])
for d, l in [("Reflection-Beam-1.0", "BEAM"), ("Glyph Cluster", "GLYPH"), ("Nemotron-3.5-Super-VL", "NEMO-N"), ("HY4 Flash", "HY4-N"), ("agnes-3-flash", "AGNES-N"), ("ERNIE-5.5-Flash-Preview", "ERNIE-N"), ("Step-5-WorkBuddy", "STEP5"), ("GLM-5.3-Flash", "GLM")]:
    nuevos(os.path.join(MB, d), l)
