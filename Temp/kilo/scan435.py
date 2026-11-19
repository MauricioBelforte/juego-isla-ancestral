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
est = os.path.join(base, "Logs", "estado_director.json")
print("ESTADO mtime:", datetime.datetime.fromtimestamp(os.path.getmtime(est)).isoformat())
ne = os.path.join(MB, "Nemotron-3.5-Super-VL", "EVALUACIONES")
if os.path.isdir(ne):
    print("NEMO EVALUACIONES:")
    for p in sorted(globmod.glob(os.path.join(ne, "*.md"))):
        print("   ", datetime.datetime.fromtimestamp(os.path.getmtime(p)).strftime("%m-%d %H:%M"), os.path.basename(p)[:80], os.path.getsize(p), "B")
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
ultimos(os.path.join(MB, "agnes-3-flash"), "AGNES", 3)
ultimos(os.path.join(MB, "HY4 Flash"), "HY4", 3)
ultimos(os.path.join(MB, "ERNIE-5.5-Flash-Preview"), "ERNIE", 2)
cut = datetime.datetime(2026, 11, 18, 20, 20, 0)
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
        print(label, "nuevos >20:20 local:", len(out))
        for mt, p in sorted(out)[-5:]:
            print("   ", mt.strftime("%H:%M"), os.path.relpath(p, base)[:110])
for d, l in [("Reflection-Beam-1.0", "BEAM"), ("Glyph Cluster", "GLYPH"), ("Nemotron-3.5-Super-VL", "NEMO"), ("Step-5-WorkBuddy", "STEP5"), ("GLM-5.3-Flash", "GLM")]:
    nuevos(os.path.join(MB, d), l)
r = subprocess.run(["python", "-X", "utf8", os.path.join("scripts", "validar_i18n_integridad.py")], capture_output=True, text=True, cwd=base, encoding="utf-8", errors="replace")
print("WATCHDOG directo rc:", r.returncode)
lineas = [l for l in r.stdout.splitlines() if "VEREDICTO" in l or "LIMPIO" in l or "fallos" in l.lower()]
for l in lineas[:3]:
    print("   WD:", l.strip()[:100])
