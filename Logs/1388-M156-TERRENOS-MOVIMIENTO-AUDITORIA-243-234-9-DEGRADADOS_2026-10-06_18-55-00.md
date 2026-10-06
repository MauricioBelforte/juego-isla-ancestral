# Log 1388: M156-Terrenos-Y-Movimiento auditado (autorizado por Atria, canal/52) — 243→234 [x], 9 degradados (stale .gd)

**Fecha:** 2026-10-06
**Hora:** 18:55
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen

M156 (243 `[x]`, el más grande de la tanda) **AUTORIZADO por Atria** (glm-5.3 inactivo, §21.4: asignación nominal muerta). Auditado método A. **9 `[x]` degradados a `[?]`** (243 → 234). Core sano: `test_terrenos.gd` 0/0 + "7 terrenos cargados".

## El hallazgo (9 degradados)
Los 9 `[x]` citaban `.gd` **ausentes en disco** que fueron **suplantedos por el enfoque data-driven**:
- `particulas_agua/arena/barro/nieve/rocas.gd` (5) → la funcionalidad está en `data/terrenos/terrenos.json` (7 tipos, testeado), NO en .gd individuales.
- `player_movement.gd`, `terrain_footstep_audio.gd` → archivos no existen.
- `test_terrain_provider.gd`, `test_terrain_detector.gd` → cubiertos por `test_terrenos.gd` (el archivo nombrado no existe).

Mismo patrón que el audit-A original de M156 (3 terrain_block degradados): **el .gd se nombró pero nunca se creó; el feature es data-driven.** Degradé con nota de evidencia.

## Cambios
- `DOCUMENTACION/156-Terrenos-Y-Movimiento/plan-actual/05-Checklist.md`: 9 `[x]`→`[?]` (punto-a-punto) + Totales (Completados 234 / No resueltos 14) + nota "Auditoría T (bloque M156)".
- `CHECKLIST-GLOBAL.md` fila 156: `243/307 → 234/307` (byte-level).
- No toqué el sistema de terreno (core OK). **Sello 🔒 M167 (hy3) respetado** (no apliqué el generador).

## Archivos
- M156 05-Checklist + CHECKLIST-GLOBAL (fila 156) + informe s2/77.

## Siguiente
T-D7 (34/34) + M156 cerrados. Queda a criterio del director: la **lista de QA §21.8 pendientes** (M153/M150 sellados por Hy3, más candidatos a ✅) u otros frentes (M44/M121/M97 dueños descatalogados).
