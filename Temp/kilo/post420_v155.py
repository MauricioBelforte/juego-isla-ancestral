# -*- coding: utf-8 -*-
import os, glob, hashlib, subprocess, datetime
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

# 1. Verificar 420 en disco
cands = glob.glob(os.path.join(root, r"Mensajes entre modelos\Ling-3.1-Flash\420-*.md"))
print("420 files:", cands)
if cands:
    b = open(cands[0], "rb").read()
    t = b.decode("utf-8")
    print("420 bytes:", len(b), "| BOM:", b[:3] == b"\xef\xbb\xbf", "| CR:", b"\r" in b,
          "| FFFD:", "\ufffd" in t, "| firma:", "Ling-3.1-Flash" in t, "| LT4KiB:", len(b) < 4096)

# 2. estado_director.json: mtime + total claves + campos clave
ej = os.path.join(root, r"Logs\estado_director.json")
st = os.stat(ej)
print("estado_director mtime:", datetime.datetime.fromtimestamp(st.st_mtime).isoformat())
try:
    import json
    d = json.load(open(ej, encoding="utf-8"))
    print("estado_director claves:", len(d))
    for k in ["ling", "pt", "go", "bug152", "gemelos", "nemotron", "hy3"]:
        if k in d:
            v = str(d[k])[:120]
            print("  campo", k, "=", v)
except Exception as e:
    print("estado_director parse error:", e)

# 3. Ultimos 3 mensajes del canal Ling por mtime
canal = os.path.join(root, r"Mensajes entre modelos\Ling-3.1-Flash")
files = [f for f in glob.glob(os.path.join(canal, "*.md"))]
files.sort(key=lambda p: os.path.getmtime(p), reverse=True)
print("ULTIMOS 3 canal Ling:")
for f in files[:3]:
    mt = datetime.datetime.fromtimestamp(os.path.getmtime(f)).isoformat()
    print("  ", mt, os.path.basename(f))

# 4. Helper estado pool
r = subprocess.run(["python", "-X", "utf8", "scripts/proximo_numero.py", "Ling-3.1-Flash"],
                   cwd=root, capture_output=True, text=True)
print(r.stdout.strip())

# 5. Riel pt
pt = open(os.path.join(root, r"game\isla-ancestral\locales\pt.po"), "rb").read()
print("pt sha256:", hashlib.sha256(pt).hexdigest().upper()[:16], "| size:", len(pt))
