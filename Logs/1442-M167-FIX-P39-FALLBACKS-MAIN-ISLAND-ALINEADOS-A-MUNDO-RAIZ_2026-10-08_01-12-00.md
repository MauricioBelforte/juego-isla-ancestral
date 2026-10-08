# Log 1442: M167 — fix de código P-39 (fallbacks de main_island.gd alineados a MUNDO_RAIZ)

**Fecha:** 2026-10-08
**Hora:** 01:12
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Frente M167 (opción 2 del canal 79, recomendada por el director). El drift P-39 (radio 256 vs 2560) restante
eran los **fallovals** de `main_island.gd` (los caminos primarios ya usaban `MUNDO_RAIZ`). Los alineé a la
fuente única `MUNDO_RAIZ` (constante preloaded, siempre disponible).

## Cambios (`scripts/main_island.gd`, solo 4 líneas, camino de fallback)
- L311: `else 256.0` → `else MUNDO_RAIZ.SPAWN_JUGADOR.x` (3860).
- L312: `else 256.0` → `else MUNDO_RAIZ.SPAWN_JUGADOR.z` (3860).
- L410: `else 320.0` → `else (MUNDO_RAIZ.CENTRO.x - 240.0)` (2320).
- L411: `else 300.0` → `else (MUNDO_RAIZ.CENTRO.y - 260.0)` (2300).

## Por qué es safe (regla §26)
- No toqué las constantes de `mundo_raiz.gd` (la fuente única) ni los caminos primarios.
- El cambio solo afecta el **camino de fallback** (autoload `MundoRaiz` ausente, p. ej. headless `--script`).
  En runtime normal (`mundo != null`) es **no-op** → no mueve la isla.
- Los "(256,…)" restantes son comentarios de historia, no código.

## Verificación
- `godot472.exe --headless --check-only --script res://scripts/main_island.gd` → **EXIT 0** (parse OK).
- Grep: no quedan hardcodes de centro viejo en el código (solo en comentarios).
- No hice visual check de la isla (generator M167 sello 🔒 hy3; run full pesado). Fix fallback-only = riesgo 0
  en runtime normal. Lo dejo para hy3 o un check V4/Playwright si el director lo pide.

## Cambios / entrega
- `scripts/main_island.gd` (4 líneas de fallback).
- Reporte en MI canal: `agnes-3-flash/80-…m167-fix-p39-fallbacks-alineados-a-mundo-raiz.md`.
- Log 1442 (este).

## Reglas
Sin commit/push. M167 no flippeo ni toco su checklist (sello 🔒 hy3 + frente doc = s3 + flips = director).
Solo toqué main_island.gd (libre, BUG-119 cerrado). No toqué mundo_raiz.gd/quality.yml/NO-TOUCH.
