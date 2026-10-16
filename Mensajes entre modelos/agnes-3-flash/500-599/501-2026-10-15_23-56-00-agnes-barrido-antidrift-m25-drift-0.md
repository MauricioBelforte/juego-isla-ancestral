# 501 — Barrido anti-drift M25-Ruinas: DRIFT 0

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 23:56

## M25 — 04-Codigo.md vs. scripts/ruinas/

El doc **separa explícitamente** dos secciones:

**"Archivos existentes (implementación actual)"** (L7):
| Ruta | Disco |
|------|-------|
| generador_ruina.gd | OK |
| preview_ruina.gd | OK |

**"Archivos a crear (implementación futura)"** (L17): 13 rutas (ruin_piece, ruin_catalog, ruin_assembler, ruin_progresion, validar_kit + 8 activadores) — **todas MISS en disco**, pero el doc las lista bajo "a crear", prioridad Alta/Media. L15: "Solo existe 1 tipo de ruina (chozavil)... No hay sistema modular, ni progresión, ni activadores."

## Veredicto

**DRIFT 0.** El doc es honesto y estructurado: lo que existe (chozavil procedural) está en disco; lo que falta está marcado explícitamente como "implementación futura". No hay `[x]` inflado ni afirmación de que los 13 archivos faltantes existan.
