#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Aplica los 30 (a) de la clasificacion de stales al GLOBAL (solo Ultima actividad)."""
import io, os, re, glob

_d = os.path.abspath(__file__)
for _ in range(5):
    _d = os.path.dirname(_d)
ROOT = _d
GLOBAL = os.path.join(ROOT, "CHECKLIST-GLOBAL.md")

# (a) MID -> numero de log citado por s3 (la fecha se saca del nombre del archivo del log)
A = {
    4: 1403, 8: 1263, 12: 1079, 41: 1375, 45: 1356, 57: 958, 59: 1397, 62: 1391,
    64: 1330, 74: 777, 75: 682, 76: 1387, 77: 1356, 80: 425, 85: 1424, 97: 420,
    98: 421, 99: 422, 103: 1323, 112: 1453, 114: 481, 115: 1078, 118: 1125,
    119: 1157, 128: 1067, 154: 302, 156: 1388, 159: 477, 160: 1137, 161: 396,
}

def fecha_de_log(num):
    for p in glob.glob(os.path.join(ROOT, "Logs", "%d-*" % num)):
        b = os.path.basename(p)
        m = re.search(r"_(\d{4}-\d{2}-\d{2})_", b)
        if m:
            return m.group(1)
    return None

nuevas = {}
for mid, lognum in A.items():
    f = fecha_de_log(lognum)
    if f is None:
        print("WARN: no se encontro fecha para log %d (M%d)" % (lognum, mid))
    else:
        nuevas[mid] = f
print("fechas resueltas: %d/30" % len(nuevas))

with io.open(GLOBAL, encoding="utf-8", newline="") as f:
    lineas = f.readlines()

PAT_FILA = re.compile(r"^\|\s*(\d+)\s*\|")
actualizados, saltados_menor, saltados_bloqueo, sin_match = [], [], [], []

for i, linea in enumerate(lineas):
    m = PAT_FILA.match(linea)
    if not m:
        continue
    mid = int(m.group(1))
    if mid not in nuevas:
        continue
    partes = linea.split("|")
    if len(partes) < 11:
        sin_match.append(mid)
        continue
    celda = partes[10].strip()
    estado = partes[3].strip()
    if estado.startswith("🔵") or estado.startswith("🔴"):
        saltados_bloqueo.append(mid)
        continue
    mfecha = re.match(r"(\d{4}-\d{2}-\d{2})", celda)
    if not mfecha:
        print("WARN: M%d formato de fecha no reconocido: %r" % (mid, celda))
        sin_match.append(mid)
        continue
    actual = mfecha.group(1)
    if nuevas[mid] <= actual:
        saltados_menor.append((mid, actual, nuevas[mid]))
        continue
    partes[10] = " " + nuevas[mid] + " "
    lineas[i] = "|".join(partes)
    actualizados.append((mid, actual, nuevas[mid]))

with io.open(GLOBAL, "w", encoding="utf-8", newline="") as f:
    f.writelines(lineas)

print("\n=== RESULTADO ===")
print("actualizados (%d):" % len(actualizados))
for mid, a, n in sorted(actualizados):
    print("  M%d: %s -> %s" % (mid, a, n))
print("saltados por fecha no mayor (%d):" % len(saltados_menor))
for mid, a, n in sorted(saltados_menor):
    print("  M%d: actual=%s nueva=%s" % (mid, a, n))
print("saltados por bloqueo azul/rojo (%d): %s" % (len(saltados_bloqueo), sorted(saltados_bloqueo)))
print("sin match (%d): %s" % (len(sin_match), sorted(sin_match)))
