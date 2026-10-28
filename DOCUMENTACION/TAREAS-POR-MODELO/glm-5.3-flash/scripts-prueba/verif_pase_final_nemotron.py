# -*- coding: utf-8 -*-
"""Verificación masiva del pase final de Nemotron (28oct)."""
import os, re

T = r"DOCUMENTACION\TAREAS-POR-MODELO\Reflection-Beam-1.0\tareas"
DOC = "DOCUMENTACION"

print("=== 1) COLA: mojibake + estados ===")
p = os.path.join(T, "COLA-FALTANTE-A-26oct.md")
raw = open(p, "rb").read()
bom = raw[:3] == b"\xef\xbb\xbf"
bad = len(re.findall(rb"\xc3\x83|\xc3\xa9\xc2", raw))
print("BOM:", bom, "| secuencias doble-encode:", bad)
txt = raw.decode("utf-8", errors="replace")
lines = txt.split("\n")
xs = sum(1 for l in lines if "| [x] |" in l)
opens = [l for l in lines if re.search(r"\|\s*\[\s\]\s*\|", l)]
qs = [l for l in lines if re.search(r"\|\s*\[\?\]\s*\|", l)]
print("items: [x]=%d, [ ]=%d, [?]=%d" % (xs, len(opens), len(qs)))
for l in opens[:8]:
    print("   open:", re.sub(r"\s+", " ", l)[:110])

print()
print("=== 2) ARCHIVOS EVIDENCIA D1/I1 ===")
for f in ["D1-012_resultado.txt", "D1-013_resultado.txt", "D1-014_resultado.txt",
          "D1-015_resultado.txt", "I1-001_resultado.txt", "I1-002_resultado.txt"]:
    fp = os.path.join(T, f)
    st = str(os.path.getsize(fp)) + " bytes" if os.path.isfile(fp) else "FALTA"
    print("  %-26s %s" % (f, st))

print()
print("=== 3) FLIPS 28oct de Nemotron en 05s ===")
total = 0
mods = {}
for d in os.listdir(DOC):
    p5 = os.path.join(DOC, d, "plan-actual", "05-Checklist.md")
    if os.path.isfile(p5):
        n = sum(1 for line in open(p5, encoding="utf-8") if "FLIP 2026-10-28 (Nemotron" in line)
        if n:
            total += n
            mods[d] = n
print("flips COLA-A 28oct:", total, "| módulos:", sorted(mods.items(), key=lambda kv: -kv[1])[:10])
