#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Extrae metadata de los logs citados por L-06 (timestamps stale) para clasificar a/b/c."""
import io, os, re, json, glob

_d = os.path.abspath(__file__)
for _ in range(5):
    _d = os.path.dirname(_d)
ROOT = _d
L06 = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s3", "L-06-timestamps-stale.md")
LOGS = os.path.join(ROOT, "Logs")

PAT = re.compile(r"^\s*(\d+)\s+(\S+)\s+GLOBAL=(\S+)\s+Log(\d+)\s+(\S+)\s+\(\+(\d+)d\)", re.M)

with io.open(L06, encoding="utf-8") as f:
    txt = f.read()

entradas = []
for m in PAT.finditer(txt):
    entradas.append({
        "mid": int(m.group(1)),
        "nombre": m.group(2),
        "fecha_global": m.group(3),
        "log": int(m.group(4)),
        "fecha_log": m.group(5),
        "delta_dias": int(m.group(6)),
    })

print("entradas parseadas:", len(entradas))

# indexar logs por numero
logs_idx = {}
for p in glob.glob(os.path.join(LOGS, "*.md")):
    b = os.path.basename(p)
    mm = re.match(r"^(\d+)-", b)
    if mm:
        logs_idx.setdefault(int(mm.group(1)), []).append(b)

def leer_log(num):
    if num not in logs_idx or not logs_idx[num]:
        return None, None
    b = logs_idx[num][0]
    p = os.path.join(LOGS, b)
    with io.open(p, encoding="utf-8", errors="replace") as f:
        contenido = f.read()
    titulo = None
    resumen = []
    in_resumen = False
    for linea in contenido.splitlines():
        if linea.startswith("# Log ") and titulo is None:
            titulo = linea[2:].strip()
        if linea.strip() == "## Resumen":
            in_resumen = True
            continue
        if in_resumen:
            if linea.startswith("## ") or (linea.strip() and not linea.strip().startswith(("-", "*")) and len(resumen) >= 3):
                break
            if linea.strip():
                resumen.append(linea.strip())
    if titulo is None:
        titulo = b
    return titulo, " | ".join(resumen[:4])

out = []
missing = []
for e in entradas:
    titulo, resumen = leer_log(e["log"])
    if titulo is None:
        missing.append(e)
        continue
    # el modulo aparece en el cuerpo del log?
    b = logs_idx[e["log"]][0]
    p = os.path.join(LOGS, b)
    with io.open(p, encoding="utf-8", errors="replace") as f:
        cuerpo = f.read()
    mid_tok = "M%d" % e["mid"]
    mid_tok_pad = "M%02d" % e["mid"]
    en_cuerpo = (mid_tok in cuerpo) or (mid_tok_pad in cuerpo)
    e.update({"titulo": titulo, "resumen": resumen, "archivo_log": b, "mid_en_cuerpo": en_cuerpo})
    out.append(e)

print("logs encontrados:", len(out), "| faltantes:", len(missing))
for m in missing:
    print("  MISSING log:", m["log"], m["nombre"])

with io.open(os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2", "stales_intermedio.json"), "w", encoding="utf-8") as f:
    json.dump(out, f, ensure_ascii=False, indent=1)
print("escrito: stales_intermedio.json")
