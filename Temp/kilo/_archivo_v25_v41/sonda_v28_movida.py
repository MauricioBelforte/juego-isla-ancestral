# -*- coding: utf-8 -*-
"""Sonda i18n v28: movida masiva post-v27 (110 archivos WT) — solo game/ y scripts/.
Clasifica acentos dev-side vs jugador; gaps de claves _t() nuevas vs es.po/pt.po; riel PT."""
import hashlib
import io
import re
import subprocess


def sh(c):
    return subprocess.run(c, shell=True, capture_output=True, text=True,
                          encoding="utf-8", errors="replace").stdout


out = sh('git diff HEAD --name-only -- game scripts')
archivos = [l for l in out.splitlines() if l.strip()]
print("archivos game/+scripts/ modificados vs HEAD:", len(archivos))
plus_total = 0
acentos = []
claves_t = set()
for a in archivos:
    d = sh('git diff HEAD -- "' + a + '"')
    for linea in d.splitlines():
        if linea.startswith("+") and not linea.startswith("+++"):
            plus_total += 1
            if re.search(r"[áéíóúñÁÉÍÓÚÑ¿¡]", linea):
                acentos.append((a, linea.strip()[:160]))
            for m in re.finditer(r'_t\(\s*["\']([A-Z0-9_.]+)["\']', linea):
                claves_t.add(m.group(1))
print("+lines game/+scripts/:", plus_total)
print("lineas con acento:", len(acentos))
for a, l in acentos[:60]:
    print("  [%s] %s" % (a.split("/")[-1], l))


def msgids(po):
    try:
        txt = io.open(po, encoding="utf-8").read()
        return set(re.findall(r'msgid "([^"]+)"', txt))
    except Exception:
        return set()


es = msgids("game/isla-ancestral/locales/es.po")
pt = msgids("game/isla-ancestral/locales/pt.po")
print("claves _t() en +lines:", sorted(claves_t))
gaps_es = [k for k in sorted(claves_t) if k not in es]
gaps_pt = [k for k in sorted(claves_t) if k not in pt]
print("gaps es.po:", gaps_es)
print("gaps pt.po:", gaps_pt)
ptb = io.open("game/isla-ancestral/locales/pt.po", "rb").read()
print("sha1 pt.po:", hashlib.sha1(ptb).hexdigest()[:10], "(canonico 95ee2ce0d1)")
