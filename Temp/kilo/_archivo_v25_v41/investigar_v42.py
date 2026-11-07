# -*- coding: utf-8 -*-
# Investigacion v42: riel i18n movido/corrupto? Que paso con pt.po (0 msgids), manager, watchdog rc=2, detector rc=2.
import io, os, json, glob, subprocess, re

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

print(u"=== 1. UBICACION ACTUAL DE ARCHIVOS RIEL ===")
for pat in [u"**/ling_i18n_manager.gd", u"**/pt.po", u"**/*.mo", u"**/es.po", u"**/en.po"]:
    hits = glob.glob(GAME + u"\\" + pat, recursive=True)
    print(u"  %s:" % pat)
    for h in hits[:10]:
        print(u"    %s | %dB" % (h.replace(GAME + u"\\", u""), os.path.getsize(h)))

print(u"\n=== 2. pt.po en translation/ (primeras 15 lineas) ===")
ptp = os.path.join(GAME, u"translation", u"pt.po")
if os.path.exists(ptp):
    print(u"  tamaño:", os.path.getsize(ptp))
    head = rd(ptp).split(u"\n")[:15]
    for l in head:
        print(u"  |", l[:120])
else:
    print(u"  NO EXISTE translation/pt.po")

print(u"\n=== 3. git status (33 WT) ===")
out, _ = git(u"status", u"--porcelain")
for l in out.strip().split(u"\n")[:40]:
    print(u"  ", l[:130])

print(u"\n=== 4. paths i18n en HEAD ===")
out, _ = git(u"ls-tree", u"-r", u"--name-only", u"HEAD")
for l in out.split(u"\n"):
    ll = l.lower()
    if (u"ling_i18n" in ll or u"pt.po" in ll or u"translation" in ll or u"localization" in ll) and u".meta" not in ll:
        print(u"  ", l)

print(u"\n=== 5. git log reciente (ultimos 6) ===")
out, _ = git(u"log", u"--oneline", u"-6")
print(out)

print(u"\n=== 6. WATCHDOG stderr ===")
r = subprocess.run([u"python", u"-X", u"utf8", u"scripts/validar_i18n_integridad.py"], cwd=GAME, capture_output=True)
print(u"rc:", r.returncode)
print(u"stdout:", r.stdout.decode(u"utf-8", u"replace")[:800])
print(u"stderr:", r.stderr.decode(u"utf-8", u"replace")[:1500])

print(u"\n=== 7. DETECTOR stderr ===")
r2 = subprocess.run([u"python", u"-X", u"utf8", u"scripts/verificar_claims_md_detector.py"], cwd=RAIZ, capture_output=True)
print(u"rc:", r2.returncode)
print(u"stdout:", r2.stdout.decode(u"utf-8", u"replace")[:400])
print(u"stderr:", r2.stderr.decode(u"utf-8", u"replace")[:1500])

print(u"\n=== 8. Log 2350 (cierre tanda 482 Hy3) ===")
f2350 = glob.glob(RAIZ + u"\\Logs\\2350-*.md")
if f2350:
    print(rd(f2350[0])[:2500])

print(u"\n=== 9. estado_director: crons nuevas ===")
ed = json.loads(rd(RAIZ + u"\\Logs\\estado_director.json"))
for k in [u"crons_v3_reactivados_7nov", u"crons_apagados"]:
    if k in ed:
        print(u"--", k, u"--")
        print(json.dumps(ed[k], ensure_ascii=False, indent=1)[:1200])

print(u"\n=== 10. claims/Claims.md existe? detector paths ===")
for p in [u"DOCUMENTACION/Claims.md", u"Claims.md", u"DOCUMENTACION/CLAIMS.md"]:
    print(u"  ", p, os.path.exists(os.path.join(RAIZ, p)))
cl = glob.glob(RAIZ + u"\\**\\laims*.md", recursive=True)
print(u"  glob claims:", [c.replace(RAIZ + u"\\", u"") for c in cl[:5]])
