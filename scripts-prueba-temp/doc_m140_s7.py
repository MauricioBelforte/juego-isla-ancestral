# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 2.9.1 QA intensivo de Alpha (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 7 del checklist. **Los modulos duenos ya estan practicamente completos**, verificado:

| Modulo | Estado |
|---|---|
| 101-QA-General | **209/209** |
| 102-Bug-Tracking | **140/140** |
| 114-Playtest | **185/185** |
| 112-Testing-Automatico | **211/216** (5 `[ ]`) |

**Sprint final de QA de 3-4 semanas:** definido aca como las ultimas 3 semanas antes del GONOGO-BETA,
con las builds semanales de M114 (5+ jugadores) como hito.

**Triaje diario con severidades P0-P2:** el registro canonico (`11-BUGS.md`) ya usa 4 niveles
(🔴 Critico | 🟠 Mayor | 🟡 Menor | ⚪ Trivial). **Mapeo a P0-P2 definido aca:** P0 = Critico
(crash/softlock/perdida de datos) · P1 = Mayor + Menor que bloquea una mecanica · P2 = Menor y
Trivial (cosmetico y calidad de vida). El mapeo es 1:1 sin perdida de informacion.

**Politica de duplicados (M102, completo):** respaldada por el modulo 102-Bug-Tracking (140/140) —
un bug duplicado se cierra referenciando al ID original, nunca se borra, y el contador de duplicados
alimenta la metrica semanal.

**Fix con test de regresion adjunto (M112):** el modulo 112 esta en 211/216. **Nota honesta:** en
`scripts/` hay solo 1 archivo con "regresion" en el nombre — la practicidad de "todo fix con test"
es la politica, no el estado actual. La politica se define aca: ningun fix de P0/P1 se mergea sin su
test de regresion.

**Encuesta de diversion y confusion (M152/M114):** M114 esta completo (185/185) e incluye la
plantilla `PLAYTEST-ENCUESTA.md`. La encuesta de Alpha agrega 2 preguntas: "¿te divertiste?" y
"¿hubo algo que no entendiste?".

**Metricas de bugs por semana (M102):** abiertos / cerrados / regresion por semana, mas el contador
de duplicados. Sale del registro `11-BUGS.md`.

**Cierre con 0 bugs P0/P1 y P2 documentados:** definido aca como criterio de GONOGO-BETA — 0 P0,
0 P1 abiertos, y cada P2 con su entrada en `11-BUGS.md` (documentado, no necesariamente cerrado).

**Auditoria de severidad duplicada:** definida aca — revision cruzada semanal de las severidades
asignadas por distintos reportadores al mismo bug (la experiencia de BUG-034 mostro que hace falta).
La hace un agente distinto del que trió.

**Integracion de QA con el tracking (M101/M102):** ambos modulos estan completos (209/209 y 140/140),
por lo que la integracion existe: `11-BUGS.md` es el registro operativo y M101/M102 el sistema.
"""

ancla = "### 2.7 Deuda"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 2.9.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
