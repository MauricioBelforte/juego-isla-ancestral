# -*- coding: utf-8 -*-
# Investigacion v42 parte 2: PT canonico intacto? donde fueron mis scripts? quien movio?
import io, os, json, glob, subprocess, re, hashlib

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

def sha_blob(path):
    b = rd(path).encode(u"utf-8") if os.path.exists(path) else b""
    if not os.path.exists(path):
        return u"(no existe)"
    return hashlib.sha1(b"blob " + str(len(b)).encode() + b"\0" + b).hexdigest()

print(u"=== 1. PT CANONICO locales/ ===")
for loc in [u"es", u"en", u"pt"]:
    p = os.path.join(GAME, u"locales", loc + u".po")
    if os.path.exists(p):
        t = rd(p)
        msgids = len(re.findall(r'^msgid\s+"(?!")', t, re.M))
        print(u"  locales/%s.po: %dB msgids=%d sha=%s" % (loc, os.path.getsize(p), msgids, sha_blob(p)[:12]))
        out, _ = git(u"rev-parse", u"HEAD:game/isla-ancestral/locales/%s.po" % loc, cwd=GAME)
        hhead = out.strip()
        print(u"    HEAD sha=%s | WT==HEAD=%s" % (hhead[:12], sha_blob(p) == hhead))
    else:
        print(u"  locales/%s.po: NO EXISTE" % loc)

print(u"\n=== 2. estructura game/isla-ancestral ===")
for sub in [u"scripts", u"locales", u"translation", u"data/localization"]:
    d = os.path.join(GAME, sub)
    print(u"  %s: existe=%s" % (sub, os.path.isdir(d)))
    if os.path.isdir(d) and sub.startswith(u"scripts"):
        pass
n_gd = len(glob.glob(GAME + u"\\**\\*.gd", recursive=True))
print(u"  total .gd en game:", n_gd)

print(u"\n=== 3. buscar MIS SCRIPTS en TODO el repo ===")
for pat in [u"**/ling_i18n_manager.gd", u"**/validar_i18n_integridad.py", u"**/verificar_claims_md_detector.py", u"**/*i18n*", u"**/*detector*"]:
    hits = [h for h in glob.glob(RAIZ + u"\\" + pat, recursive=True) if u".git" not in h]
    print(u"  %s -> %d hits" % (pat, len(hits)))
    for h in hits[:8]:
        print(u"     ", h.replace(RAIZ + u"\\", u""), os.path.getsize(h) if os.path.isfile(h) else u"(dir)")

print(u"\n=== 4. Obsoletos/ con mtime reciente (hoy) ===")
ob = os.path.join(RAIZ, u"Obsoletos")
if os.path.isdir(ob):
    recientes = []
    for root, dirs, files in os.walk(ob):
        for f in files:
            fp = os.path.join(root, f)
            mt = os.path.getmtime(fp)
            if mt > 1762400000:  # ~2026-11-06
                recientes.append((mt, fp))
    for mt, fp in sorted(recientes)[-15:]:
        print(u"  ", __import__("datetime").datetime.fromtimestamp(mt).strftime(u"%m-%d %H:%M"), fp.replace(RAIZ + u"\\", u""))
else:
    print(u"  Obsoletos/ no existe")

print(u"\n=== 5. .gitignore ===")
print(rd(os.path.join(RAIZ, u".gitignore"))[:1500])

print(u"\n=== 6. mensajes CANALES con mtime > 21:00 local (eventos recientes flota) ===")
import datetime
todos = glob.glob(os.path.join(RAIZ, u"Mensajes entre modelos", u"*", u"*.md"))
rec = [(os.path.getmtime(f), f) for f in todos if os.path.getmtime(f) > datetime.datetime(2026, 11, 6, 20, 30).timestamp()]
for mt, f in sorted(rec)[-20:]:
    ts = datetime.datetime.fromtimestamp(mt).strftime(u"%H:%M")
    print(u"  %s %s" % (ts, f.replace(RAIZ + u"\\Mensajes entre modelos\\", u"")))

print(u"\n=== 7. Log 2350 parte 2 (M87 de Hy3) ===")
f2350 = glob.glob(RAIZ + u"\\Logs\\2350-*.md")[0]
t = rd(f2350)
i = t.find(u"M87")
print(t[i:i+1800] if i >= 0 else u"(sin M87)")

print(u"\n=== 8. msg Hy3/498 cuerpo ===")
f498 = glob.glob(os.path.join(RAIZ, u"Mensajes entre modelos", u"Hy3", u"498-*.md"))
if f498:
    print(rd(f498[0])[:2000])

print(u"\n=== 9. git stash / reflog (alguien hizo algo?) ===")
out, _ = git(u"stash", u"list")
print(u"stash:", out.strip()[:200] or u"(vacio)")
out, _ = git(u"reflog", u"-8")
print(u"reflog:\n", out[:800])
