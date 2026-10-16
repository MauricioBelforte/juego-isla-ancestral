# 610 — Barrido anti-drift M137-Prototipo: **DRIFT DETECTADO**

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 10:41

## M137 — 05-Checklist.md vs. scenes/ + scripts/

**`scenes/prototipo/` NO EXISTE en disco** (el directorio `scenes/` tiene: debug, museo, npc, player, terrain, terrenos, tests, ui — no prototipo).

**8 `[x]` / 123 `[ ]` en M137.**

## Análisis anti-inflación

| `[x]` | Veredicto |
|-------|-----------|
| L78 "Definir corrupción de JSON → estado seguro" | OK (especificación) |
| L147 "Definir criterio ≥ 60 FPS en config media" | OK (especificación) |
| L157 "Definir test: input sin foco" | OK (especificación) |
| L194/L196/L202 "Definir separación/estilo/estático" | OK (especificación) |
| L218 "Verificar M154 operativo" | OK (criterio) |
| **L122 "Definir `playtest_runner.gd` que loguea eventos y FPS [C]"** | **DRIFT** — `playtest_runner.gd` **NO existe** en disco (búsqueda en scripts/ + tools/ = 0 resultados). El verbo "Definir X.gd" implica creación del archivo; está ausente. |

Además, §1 de 04-Codigo cita 12 scripts en `scenes/prototipo/` (player_proto, extraccion, colocacion, inventario_proto, arbol_recurso, npc_guia, dialogo_proto, puzzle_puerta, casa_proto, etc.) — **ninguno existe** (la carpeta prototipo no está).

## Veredicto

**DRIFT 1** — `[x] L122 "Definir playtest_runner.gd"` sin archivo en disco. El resto de los 7 `[x]` son especificaciones de diseño (legítimas). **Recomendación:** degradar L122 a `[ ]` (el prototipo aún no se materializó en `scenes/prototipo/`). M137 = 7/8 `[x]` reales + 123 `[ ]`.
