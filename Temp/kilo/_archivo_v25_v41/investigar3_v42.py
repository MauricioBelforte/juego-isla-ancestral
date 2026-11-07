# -*- coding: utf-8 -*-
# Investigacion v42 parte 3 (corregida): watchdog desde RAIZ, detector path v41, mensajes recientes, Log 2350, 498, reflog, Obsoletos con try/except.
import io, os, json, glob, subprocess, re, datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def rd(p):
    try:
        return io.open(p, encoding=u"utf-8", errors=u"replace").read()
    except Exception as e:
        return u"ERR:" + str(e)

def git(*args, cwd=RAIZ):
    r = subprocess.run([u"git"] + list(args), cwd=cwd, capture_output=True)
    return r.stdout.decode(u"utf-8", u"replace"), r.stderr.decode(u"utf-8", u"replace")

print(u"=== 1. WATCHDOG desde RAIZ (cwd correcto) ===")
r = subprocess.run([u"python", u"-X", u"utf8", u"scripts/validar_i18n_integridad.py"], cwd=RAIZ, capture_output=True)
print(u"rc:", r.returncode)
print(u"stdout:", r.stdout.decode(u"utf-8", u"replace")[:600])
print(u"stderr:", r.stderr.decode(u"utf-8", u"replace")[:400])

print(u"\n=== 2. correr_detector_v41.py: que path invocaba ===")
t = rd(RAIZ + u"\\Temp\\kilo\\correr_detector_v41.py")
for l in t.split(u"\n"):
    if u"subprocess" in l or u"claims" in l.lower() or u"detector" in l.lower() or u"python" in l.lower():
        print(u"  ", l.strip()[:160])

print(u"\n=== 3. mensajes recientes TODOS los canales (mtime > 20:45 local) ===")
corte = datetime.datetime(2026, 11, 6, 20, 45).timestamp()
todos = []
for root, dirs, files in os.walk(os.path.join(RAIZ, u"Mensajes entre modelos")):
    for f in files:
        if f.endswith(u".md"):
            fp = os.path.join(root, f)
            try:
                mt = os.path.getmtime(fp)
                if mt > corte:
                    todos.append((mt, fp))
            except Exception:
                pass
for mt, f in sorted(todos)[-25:]:
    print(u"  %s %s" % (datetime.datetime.fromtimestamp(mt).strftime(u"%H:%M:%S"), f.replace(RAIZ + u"\\Mensajes entre modelos\\", u"")))

print(u"\n=== 4. Log 2350 seccion M87 completa ===")
f2350 = glob.glob(RAIZ + u"\\Logs\\2350-*.md")
if f2350:
    t2350 = rd(f2350[0])
    for kw in [u"M87", u"locales", u"translation", u"ling_i18n", u"pt.po"]:
        for m in re.finditer(kw, t2350):
            s = max(0, m.start() - 200)
            print(u"  [%s] ...%s..." % (kw, t2350[s:m.start()+250].replace(u"\n", u" | ")))
            break

print(u"\n=== 5. msg Hy3/498 cuerpo ===")
for f in glob.glob(os.path.join(RAIZ, u"Mensajes entre modelos", u"Hy3", u"498-*.md")):
    print(rd(f)[:1800])

print(u"\n=== 6. reflog + stash ===")
out, _ = git(u"reflog", u"-6")
print(out[:600])
out, _ = git(u"stash", u"list")
print(u"stash:", out.strip()[:200] or u"(vacio)")

print(u"\n=== 7. Obsoletos/ mtime hoy (try/except fantasmas) ===")
ob = os.path.join(RAIZ, u"Obsoletos")
rec = []
if os.path.isdir(ob):
    for root, dirs, files in os.walk(ob):
        for f in files:
            fp = os.path.join(root, f)
            try:
                mt = os.path.getmtime(fp)
                if mt > datetime.datetime(2026, 11, 6, 18, 0).timestamp():
                    rec.append((mt, fp))
            except Exception:
                pass
for mt, fp in sorted(rec)[-12:]:
    print(u"  ", datetime.datetime.fromtimestamp(mt).strftime(u"%H:%M"), fp.replace(RAIZ + u"\\", u""))
if not rec:
    print(u"  (sin archivos recientes en Obsoletos/)")

print(u"\n=== 8. .gitignore ===")
print(rd(os.path.join(RAIZ, u".gitignore"))[:1200])

print(u"\n=== 9. Temp/kilo correr_validador_i18n_v41.py (path watchdog v41) ===")
t = rd(RAIZ + u"\\Temp\\kilo\\correr_validador_i18n_v41.py")
for l in t.split(u"\n")[:25]:
    print(u"  ", l[:150])
