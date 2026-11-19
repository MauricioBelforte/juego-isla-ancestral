# -*- coding: utf-8 -*-
import io, os, subprocess, hashlib, glob as globmod
base = os.getcwd()
canal = os.path.join(base, "Mensajes entre modelos", "Ling-3.1-Flash")
msgs = sorted(globmod.glob(os.path.join(canal, "*.md")))
print("CANAL total msgs:", len(msgs))
for m in msgs[-3:]:
    print("  ", os.path.basename(m), os.path.getsize(m), "B")
est = os.path.join(base, "Logs", "estado_director.json")
st = os.stat(est)
import datetime
print("ESTADO mtime:", datetime.datetime.fromtimestamp(st.st_mtime).isoformat(), "size:", st.st_size)
r = subprocess.run(["python", "-X", "utf8", "scripts", "validar_i18n_integridad.py"], capture_output=True, text=True, cwd=base, encoding="utf-8", errors="replace")
print("WATCHDOG rc:", r.returncode)
tail = r.stdout.strip().splitlines()[-3:] if r.stdout.strip() else []
for t in tail:
    print("  WD:", t)
pt = os.path.join(base, "game", "isla-ancestral", "locales", "pt.po")
b = open(pt, "rb").read()
print("PT bytes:", len(b), "sha256:", hashlib.sha256(b).hexdigest()[:16])
g = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True, cwd=base)
print("HEAD:", g.stdout.strip())
h = subprocess.run(["python", "-X", "utf8", "scripts", "proximo_numero.py", "Ling-3.1-Flash"], capture_output=True, text=True, cwd=base, encoding="utf-8", errors="replace")
for line in h.stdout.splitlines():
    if "XIMO" in line.upper() or "pool" in line.lower():
        print("HELPER:", line.strip())
