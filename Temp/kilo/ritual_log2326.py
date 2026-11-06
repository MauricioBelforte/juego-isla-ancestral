# -*- coding: utf-8 -*-
"""Ritual §6.1.a: consumir Log 2326 del pool Logs/NUMEROS_DISPONIBLES.txt (borrar línea, verificar cabeza)."""
import io

POOL = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Logs\NUMEROS_DISPONIBLES.txt"

with io.open(POOL, "r", encoding="utf-8", newline="") as f:
    raw = f.read()

lines = raw.split("\n")
# tolerancia: quitar BOM si existiera y líneas vacías iniciales
if lines and lines[0].startswith(u"﻿"):
    lines[0] = lines[0][1:]
while lines and lines[0].strip() == u"":
    lines.pop(0)

cabeza = lines[0].strip()
print("Cabeza actual del pool Logs:", cabeza)
assert cabeza == u"2326", u"ERROR: cabeza esperada 2326, encontrada " + cabeza

# Consumir: borrar la línea 2326 (primera ocurrencia exacta)
idx = None
for i, ln in enumerate(lines):
    if ln.strip() == u"2326":
        idx = i
        break
assert idx is not None, u"ERROR: 2326 no encontrado como línea"
del lines[idx]

# Reconstruir preservando estructura (sin línea final vacía duplicada)
out = u"\n".join(lines)
if not out.endswith(u"\n"):
    out += u"\n"

with io.open(POOL, "w", encoding="utf-8", newline="\n") as f:
    f.write(out)

with io.open(POOL, "r", encoding="utf-8", newline="") as f:
    nueva = f.read()
nn = [l for l in nueva.split("\n") if l.strip()]
print("2326 borrado OK. Nueva cabeza:", nn[0], "| líneas:", len(nn))
assert nn[0].strip() == u"2327", u"ERROR: nueva cabeza esperada 2327, encontrada " + nn[0]
assert u"2326" not in [l.strip() for l in nn], "ERROR: 2326 sigue presente"
print("RITUAL §6.1.a COMPLETO: Log 2326 consumido (pool Logs 2326 -> 2327)")
