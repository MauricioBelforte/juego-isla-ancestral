# -*- coding: utf-8 -*-
"""Saneamiento de GUIA-COMPARATIVA-MODELOS/GUIA-COMPARATIVA-MODELOS-V1.md (confirmado por el fundador 25oct 21:18).

Arma: zona original (1-3013) + fichas N + notas de la copia F (105804, relativas 1-305)
+ nota 08:42 y 15:14 DES-FUSIONADAS (venian pegadas en una sola linea) + LECCION 15:17
(de la copia 64 recortada) + ficha N.6.

Verificacion pesada ANTES del reemplazo (atomico temp+os.replace):
 1. cobertura total de lineas unicas (whitelist documentada para la unica linea
    que no puede existir tal cual: la fusion 'nota 08:42 + header 10 GUIA' pegados);
 2. conteos exactos 1:1 de secciones y notas;
 3. cero lineas nuevas inventadas;
 4. UTF-8 sin BOM.
"""
import os

P = r"DOCUMENTACION\GUIA-COMPARATIVA-MODELOS\GUIA-COMPARATIVA-MODELOS-V1.md"
TMP = P + ".nuevo.tmp"

lines = open(P, encoding="utf-8").read().split("\n")
old_set = set(lines)

# piezas (0-indexed python)
zona = lines[0:3013]               # 1-3013: documento original
fichas = lines[105803:105803+305]  # copia F relativas 1-305: fichas N + notas 08:08/08:19/08:28
assert fichas[0].startswith("## N.1 "), "empalme F roto"
assert any("Regimen produce-first de Beam (fundador 08:28" in l for l in fichas), "F sin nota 08:28"

# des-fusion de la nota 08:42 + Nota disponibilidad 15:14 (venian pegadas: '...y sello.Nota disponibilidad...')
fus = lines[212217]                # 1-indexed 212218, len 597
MARCA = "cruzados y sello."
assert MARCA in fus, "fusion no encontrada"
corte = fus.index(MARCA) + len(MARCA)
nota_42 = fus[:corte]
nota_15 = fus[corte:]
assert nota_42.endswith("y sello."), "corte de nota 08:42 impreciso"
assert nota_15.startswith("Nota disponibilidad (fundador 15:14"), "nota 15:14 imprecisa"

lecc = [lines[212218]]             # 1-indexed 212219: LECCION DE DISPONIBILIDAD EFIMERA
assert "LECCION DE DISPONIBILIDAD" in lecc[0], "LECCION rota"
n6 = lines[212221:212250]          # 212222-212250: ficha N.6 (incluye '' final)
assert n6[0].startswith("## N.6"), "N.6 rota"

nuevo = zona + fichas + [nota_42, nota_15] + lecc + n6

# --- verificacion 1: cobertura de lineas unicas ---
new_set = set(nuevo)
texto_nuevo = "\n".join(nuevo)

# whitelist documentada (total: 2 variantes de la nota 08:42 fusionadas con texto pegado):
# 1) variante CORTA (277): '...y sello.# 10 - GUÍA COMPARATIVA DE MODELOS' — header pegado
#    sin newline; el texto util es prefijo de la variante des-fusionada y el header existe
#    como linea propia (zona original, linea 1).
# 2) variante LARGA (597): '...y sello.Nota disponibilidad (15:14)...' — EXACTAMENTE la
#    concatenacion de nota_42 + nota_15 que el armado separa en dos lineas (check estricta abajo).
WHITELIST = set()
for l in old_set:
    if l.startswith("Cadena definitiva (fundador 08:42)"):
        if l == (nota_42 + nota_15):
            WHITELIST.add(l)   # larga: comprobada identidad con las dos lineas des-fusionadas
        elif l.endswith("GUÍA COMPARATIVA DE MODELOS") and l[:len(nota_42)] == nota_42:
            WHITELIST.add(l)   # corta: prefijo exacto de nota_42 + header ya existente
        else:
            print("ATENCION: variante de nota 08:42 NO reconocida:", repr(l[:150]))

faltan = []
for l in old_set:
    if l in new_set or l in WHITELIST:
        continue
    if not l.strip():
        continue  # lineas en blanco equivalentes
    if l.strip() in texto_nuevo:
        continue  # contenido presente como substring de otra linea
    faltan.append(l)
print("lineas unicas viejo: %d | faltantes reales: %d | whitelist: %d" %
      (len(old_set), len(faltan), len(WHITELIST)))
if faltan:
    print("PERDIDAS (primeras 20):")
    for l in faltan[:20]:
        print("  -", repr(l[:150]))
    raise SystemExit("ABORTADO: habria perdida de contenido")

# --- verificacion 2: conteos exactos 1:1 ---
def count(sub):
    return sum(1 for l in nuevo if sub in l)
checks = {
    "# 10 - GUÍA COMPARATIVA": 1,
    "## N.1 Reflection Beam": 1,
    "## N.2 DATOS EMPIRICOS": 1,
    "## N.2-bis": 1,
    "## N.2-ter": 1,
    "## N.2-quater": 1,
    "## N.3-N.5": 1,
    "Actualizacion N.2-bis (08:08)": 1,
    "Nota horaria (08:19)": 1,
    "Regimen produce-first de Beam (fundador 08:28": 1,
    "Cadena definitiva (fundador 08:42)": 1,
    "Nota disponibilidad (fundador 15:14": 1,
    "LECCION DE DISPONIBILIDAD": 1,
    "## N.6 NVIDIA Nemotron 3.5 Super VL": 1,
}
mal = []
for sub, esperado in checks.items():
    c = count(sub)
    ok = c == esperado
    print("%-47s esperado=%d real=%d %s" % (sub, esperado, c, "OK" if ok else "FALLA"))
    if not ok:
        mal.append((sub, c))
if mal:
    raise SystemExit("ABORTADO: conteos inconsistentes: %s" % mal)

# --- verificacion 3: cero lineas inventadas ---
inventadas = [l for l in set(nuevo) if l not in old_set]
print("lineas nuevas que no existian en el viejo: %d" % len(inventadas))
for l in inventadas[:10]:
    print("  +", repr(l[:150]))

texto = "\n".join(nuevo)
with open(TMP, "w", encoding="utf-8", newline="\n") as f:
    f.write(texto)
bom = open(TMP, "rb").read(3) == b"\xef\xbb\xbf"
print("BOM en tmp:", bom)
if bom:
    raise SystemExit("ABORTADO: BOM inesperado")

os.replace(TMP, P)
print("REEMPLAZO ATOMICO OK — lineas finales: %d (antes: %d)" % (len(nuevo), len(lines)))
