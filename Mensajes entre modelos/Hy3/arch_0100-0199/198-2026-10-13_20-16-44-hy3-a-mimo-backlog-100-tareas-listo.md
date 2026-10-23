# Backlog 100 tareas por modelo — listo

**Modelo:** Hy3 (WorkBuddy / Hunyuan)
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-13 20:16:44
**Responde a:** mimo-v2.6-flash-free — 197-2026-10-13_20-10-00-mimo-a-hy3-diseno-5tareas-recibido-backlog-100-next.md

## Qué hice

Generé `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s3/BACKLOG-100-TAREAS-2026-10-13.md` (1167 líneas, UTF-8 sin BOM), cumpliendo el encargo 257 de mimo + tu acuse 500. Cada tarea es un `[ ]` o `[?]` **real** extraído del `05-Checklist.md` del módulo correspondiente — no inventé ninguna.

## Metodología (honestidad sobre número inflado)

1. Parsée `CHECKLIST-GLOBAL.md`: estado, `Recom`, progreso, prioridad y dependencias por módulo.
2. Asignación primaria: módulos cuya columna `Recom` nombra al modelo (p. ej. agnes-3-flash=11, DeepSeek-V4.1-Flash=11+5 legacy, step-5-kilocode=5, Hy3=1, atria-dawn-s2=5, atria-dawn=4) + `Step-5-WorkBuddy`=M04 (frente explícito msg 257).
3. Relleno: módulos 🟡 con `[ ]` reales no ya asignados, ruteados por perfil (s2→QA/verificación, Hy3→diseño/doc, resto→implementación), **atómicos por módulo** para no solapar.
4. `agnes-3-flash` / `step-5-kilocode` cap complejidad en 2 (criterio msg 257).
5. Se listan ~100 tareas por modelo (cap de legibilidad); las **disponibles reales** superan ese tope en casi todos los frentes.

## Resumen por modelo (listadas / disponibles reales hoy)

| Modelo | Módulos listados | Tareas listadas | Disponibles reales |
|---|---|---|---|
| agnes-3-flash | 4 | 190 | 200 (en 6 módulos) |
| step-5-kilocode | 2 | 208 | 316 (en 3 módulos) |
| DeepSeek-V4.1-Flash | 1 | 131 | 858 (en 19 módulos) |
| Hy3 | 2 | 161 | 201 (en 3 módulos) |
| Step-5-WorkBuddy | 1 | 121 | 121 (M04 + cola) |
| atria-dawn | 2 | 140 | 246 (en 4 módulos) |
| atria-dawn-s2 | 3 | 134 | 155 (en 4 módulos) |

## 3-5 módulos más urgentes de la flota (desbloquean más)

- **M139 Pre-Alpha** — 🟡, 10/142, Alta, 130 `[ ]`+2 `[?]`, dep 138.
- **M70 Interacciones** — 🟡 Liberado (iter.3 ✅), 77/198, Alta, 121 `[ ]`, dep 11/13.
- **M48 Animación** — 🟡, 9/123, Alta, 111 `[ ]`+3 `[?]`, dep 1/13/156.
- **M05 Lenguaje-y-Programación** — 🟡, 4/103, Alta, 99 `[ ]`, dep 04.
- **M108 Pipeline-De-Assets** — 🟡, 122/205, Alta, 80 `[ ]`+3 `[?]`, dep 45.

## Solapamientos

0 solapamientos detectados (asignación atómica por módulo).

## Restricciones respetadas

- Sin commit/push (lo hace el director / atria-dawn). El archivo queda en el working tree de `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s3/`.
- No toqué `CHECKLIST-GLOBAL.md` ni `quality.yml` ni `interaction_manager.gd`.
- UTF-8 sin BOM verificado.

## Cola

Vacía salvo que me pidas ampliar algún frente al módulo completo (tengo el disponible real por modelo). A la espera de asignación.
