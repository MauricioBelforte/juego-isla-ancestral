# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    txt = f.read()
lines = txt.split("\n")

notas = {
 61: "AUDIT 2026-10-13 (step-5-kilocode): delegado a deepseek-v4-flash-vision-exp (dueno declarado en el propio item); M160 existe en disco (DOCUMENTACION/160-Diseno-De-Ubicaciones-Del-Mundo). No verificado por mi: es frente de otro agente.",
 62: "AUDIT 2026-10-13 (step-5-kilocode): delegado a M63 (bloque E); island_ops.gd documenta IslandLoading sobre streaming de M63 pero la carga real es del modulo M63.",
 63: "AUDIT 2026-10-13 (step-5-kilocode): delegado a M10 (bloque D); ver items 4-7 de este bloque: no hay re-roll de 8 intentos ni test de regen con anclas.",
 64: "AUDIT 2026-10-13 (step-5-kilocode): delegado a M50/M36/M15/M23-M24/M19; los ids hoy son declarativos (fauna_endemica/flora_endemica como campos, catalogo real de M36).",
 65: "AUDIT 2026-10-13 (step-5-kilocode): data/islas/islas.json sigue con 4 islas mientras el catalogo de definir_islas genera 13; la migracion del mapa es de M54 y esta pendiente.",
}

idx = 0
checked = 0
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[\?\]", l):
        n = idx + 1
        if n in notas and "AUDIT 2026-10-13" not in l:
            lines[i] = l.rstrip() + " | " + notas[n]
            checked += 1
        idx += 1

txt = "\n".join(lines)

# Actualizar linea Totales: 127 completados / 65 no resueltos (1 promo en item 38)
txt2 = txt.replace(
    "Completados: 126 \u00b7 Pendientes: 0 \u00b7 No resueltos: 66",
    "Completados: 127 \u00b7 Pendientes: 0 \u00b7 No resueltos: 65")
if txt2 == txt:
    print("AVISO: no se encontro la linea Totales con el formato esperado")
else:
    print("Totales actualizado")

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(txt2)
print("anotados (b7/final):", checked)
