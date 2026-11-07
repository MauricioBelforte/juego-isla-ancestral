# -*- coding: utf-8 -*-
# Centinela v42 corregido: detector real, riel canónico locales/, localization_manager, historial ling_i18n, project.godot.
import io, os, subprocess, re, glob, hashlib, json

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
GAME = os.path.join(RAIZ, u"game", u"isla-ancestral")

def rd(p):
    try:
        return io.open(p, encoding=u"utf-8", errors=u"replace").read()
    except Exception as e:
        return u"ERR:" + str(e)

def git(*args, cwd=RAIZ):
    r = subprocess.run([u"git"] + list(args), cwd=cwd, capture_output=True)
    return r.stdout.decode(u"utf-8", u"replace"), r.stderr.decode(u"utf-8", u"replace")

print(u"=== 1. DETECTOR REAL (scripts/detectar_autocontradiccion.py, cwd=RAIZ) ===")
r = subprocess.run([u"python", u"-X", u"utf8", u"scripts/detectar_autocontradiccion.py"], cwd=RAIZ, capture_output=True)
dt = r.stdout.decode(u"utf-8", u"replace")
print(u"rc:", r.returncode, u"| chars:", len(dt))
with io.open(RAIZ + u"\\Temp\\kilo\\v42_detector_delta.txt", u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(dt)
for k in [u"A1=", u"R4=", u"A2=", u"A3=", u"C2=", u"SOS=", u"FP=", u"F=", u"GRIS=", u"[x]=", u"checklists", u"promovidos"]:
    m = re.search(re.escape(k) + u"\s*[:=]?\s*([0-9]+)", dt)
    if m:
        print(u"   ", k, m.group(1))
print(u"   stderr:", r.stderr.decode(u"utf-8", u"replace")[:300])

print(u"\n=== 2. CENTINELA RIEL CANONICO locales/ + JSON ===")
for loc in [u"es", u"en", u"pt"]:
    p = os.path.join(GAME, u"locales", loc + u".po")
    b = rd(p).encode(u"utf-8")
    h = hashlib.sha1(b"blob " + str(len(b)).encode() + b"\0" + b).hexdigest()
    out, _ = git(u"rev-parse", u"HEAD:game/isla-ancestral/locales/%s.po" % loc, cwd=GAME)
    msgids = len(re.findall(r'^msgid\s+"(?!")', rd(p), re.M))
    print(u"  locales/%s.po: msgids=%d sha=%s HEAD=%s WT==HEAD=%s" % (loc, msgids, h[:12], out.strip()[:12], h == out.strip()))
jsondir = os.path.join(GAME, u"data", u"localizacion")
for jf in sorted(glob.glob(jsondir + u"\\strings_*.json")):
    print(u"  JSON %s: %dB" % (os.path.basename(jf), os.path.getsize(jf)))

print(u"\n=== 3. localization_manager.gd canónico (scripts/localization/ y localizacion/) ===")
for rel in [u"scripts/localization/localization_manager.gd", u"scripts/localizacion/localization_manager.gd"]:
    p = os.path.join(GAME, rel)
    if os.path.exists(p):
        b = rd(p).encode(u"utf-8")
        h = hashlib.sha1(b"blob " + str(len(b)).encode() + b"\0" + b).hexdigest()
        out, _ = git(u"rev-parse", u"HEAD:game/isla-ancestral/" + rel.replace(u"\\", u"/"), cwd=GAME)
        print(u"  %s: %dB sha=%s HEAD=%s WT==HEAD=%s" % (rel, len(b), h[:12], out.strip()[:12], h == out.strip()))
    else:
        print(u"  %s: NO EXISTE" % rel)

print(u"\n=== 4. project.godot: config localization ===")
pg = rd(os.path.join(GAME, u"project.godot"))
for l in pg.split(u"\n"):
    if u"locale" in l.lower() or u"translat" in l.lower():
        print(u"  ", l.strip()[:150])

print(u"\n=== 5. historial git de ling_i18n_manager.gd (alguna vez trackeado?) ===")
out, err = git(u"log", u"--all", u"--oneline", u"--", u"*ling_i18n*")
print(u"git log --all *ling_i18n*:", out.strip()[:300] or u"(vacio)")
out, err = git(u"log", u"--all", u"--oneline", u"--diff-filter=D", u"--", u"*ling_i18n*")
print(u"deletes:", out.strip()[:200] or u"(vacio)")
out, err = git(u"log", u"--all", u"--oneline", u"--", u"game/isla-ancestral/translation/")
print(u"hist translation/:", out.strip()[:200] or u"(vacio — nunca trackeado)")

print(u"\n=== 6. watchdog completo a archivo evidencia ===")
r2 = subprocess.run([u"python", u"-X", u"utf8", u"scripts/validar_i18n_integridad.py"], cwd=RAIZ, capture_output=True)
w = u"=== WATCHDOG i18n oficial v42 (scripts/validar_i18n_integridad.py, cwd=RAIZ) ===\nrc=%d\n--- stdout ---\n%s--- stderr ---\n%s" % (
    r2.returncode, r2.stdout.decode(u"utf-8", u"replace"), r2.stderr.decode(u"utf-8", u"replace"))
with io.open(RAIZ + u"\\Temp\\kilo\\v42_validador_i18n.txt", u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(w)
print(w[-900:])

print(u"\n=== 7. translation/ y scripts/ling_i18n_manager.gd: confirmacion eliminacion ===")
print(u"  translation/ existe:", os.path.isdir(os.path.join(GAME, u"translation")))
print(u"  scripts/ling_i18n_manager.gd existe:", os.path.exists(os.path.join(GAME, u"scripts", u"ling_i18n_manager.gd")))
print(u"  .gitignore tiene 'translation'?", u"translation" in rd(os.path.join(RAIZ, u".gitignore")))
