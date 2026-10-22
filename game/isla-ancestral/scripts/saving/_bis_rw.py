# -*- coding: utf-8 -*-
# PASO 2-BIS rewrite (regla operativa del fundador 03:29) + Totales nota
import io

P = r"DOCUMENTACION\TAREAS-POR-MODELO\G-5.3-Flash-Agente\CRONOMETRO-ACTIVO.md"
s = io.open(P, encoding="utf-8").read()

start = s.find("=== PASO 2-BIS — COLA AGOTADA O BLOQUEADA → PEDIR TAREAS AL DIRECTOR ===")
end = s.find("=== PASO 3 — REPORTE")
assert start > 0 and end > start, (start, end)

nuevo = """=== PASO 2-BIS — TU COLA REAL SON LOS 05 DE MÓDULOS NO-BLOQUEADOS (regla operativa del fundador 03:29 del 21-10; SIEMPRE vigente) ===
1. **JAMÁS esperar al director para producir.** En el disco SIEMPRE hay +100 [ ] libres en módulos
   no-bloqueados (verificado con escaneo 2-BIS.2: 28 módulos, ~1350 [ ] accionables). En cada
   vuelta: re-escaneá (uno o dos con el patrón `\s*- [ ]` por módulo), elegí [ ] concretos del
   módulo que te toque y EJECUTÁ la tanda SIN pedir permiso.
2. **El director NO asigna: solo INFORMA.** Le escribís el REPORT de lo hecho (mín 1 línea por
   vuelta) — no una consulta de "qué hago". Solo si LITERALAMENTE no existiera nada (imposible
   con el escaneo), recién ahí le pedís tareas.
3. Guardia por ciclo mientras corre la tanda: sonda ligera de suites + filas 4/4 — sin inventar
   tanda falsa ni tocar módulos con dueño/GO.
"""

s = s[:start] + nuevo + "\n" + s[end:]

# Historial
h_add = "| 2026-10-22 03:30 | **PASO 2-BIS REESCRITO como regla operativa**: ejecutar [ ] del escaneo de los 05 NO-BLOQUEADOS como cola permanente SIN esperar al director (el director solo recibe el reporte; pedir tareas SOLO si literalmente no hay nada — imposible con el escaneo) | orden del fundador 03:29 |"
h_old = "| 2026-10-22 03:28 | **PISO de reporte SIN EXCEPCIONES**: m\u00edn 1 l\u00ednea por vuelta aunque no haya novedad (lecci\u00f3n: 4 vueltas sin ping que el fundador detect\u00f3; \"solo novedad material\" NO anula el piso) | orden del fundador |"
if h_old in s and h_add not in s:
    s = s.replace(h_old, h_old + "\n" + h_add)

io.open(P, "w", encoding="utf-8", newline="\n").write(s)
print("2-BIS reescrito ok")
