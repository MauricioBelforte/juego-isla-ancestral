# Log 1285: Se corrigió la violación A2 SubtitleManager->DataStore (CI M62 rojo)

**Fecha:** 2026-10-04
**Hora:** 19:51
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Atención del encargo **T-M0** (canal `13-2026-10-04_20-50-00-a2-m62-ci-rojo-m91.md` del director atria-dawn): el job de CI **Architecture Guard (M62)** estaba rojo con el hallazgo nuevo `A2|SubtitleManager->DataStore`, introducido por mi propio commit `80819e1` (2026-10-02, M91 lote 3 de subtítulos, Log 198). Fix aplicado con la opción preferida por el director: **mover la declaración de `DataStore` antes que `SubtitleManager` en la sección `[autoload]` de `project.godot`** (movimiento de 1 línea, sin altas ni bajas). T-M0 cerrado en la misma sesión; T-M1 (M55-Diario) queda listo para retomar.

## Cambios Realizados

1. **Sonda en ROJO (antes del fix):** `python scripts/auditar_arquitectura_m62.py` → `exit=1`, `Hallazgos NUEVOS: 1` → `A2|SubtitleManager->DataStore` (orden: SubtitleManager #65 → DataStore #72, delta=+7). Reproduce exactamente el hallazgo del director.
2. **Fix:** en `game/isla-ancestral/project.godot`, sección `[autoload]`, la línea
   `DataStore="*res://scripts/datos/data_store.gd"` se movió desde la posición 74 a la **67 (justo antes de `SubtitleManager`)**. Verificado antes de mover que `data_store.gd` no referencia a ninguno de los 6 autoloads que quedan después de su nueva posición (StreamManager, PantallaCarga, MonetizacionManager, TerrainProvider, GameFlowManager, SceneManager) y que sus dependencias (`SaveManager`, `ServiceRegistry`, `GameLogger`) siguen antes — el movimiento es seguro en runtime.
3. **Sonda en VERDE (después del fix):** `python scripts/auditar_arquitectura_m62.py` → `exit=0`, `Hallazgos NUEVOS: 0`.
4. **Selftest del auditor (igual que en CI):** `python scripts/auditar_arquitectura_m62.py --selftest` → `exit=0`, `=== Selftest: 0 fallos ===` (incluye las pruebas de ceguera 1-5).
5. **Diff mínimo:** `git diff --stat` sobre `project.godot` = `1 insertion(+), 1 deletion(-)` — la línea movida, nada más. FFFD=0, misma cantidad de líneas antes/después (movimiento puro).
6. **Backlog:** T-M0 marcado `[x]` con este log; T-M1 (M55) pasa de `[→]` a `[ ]` pendiente de retomar.

**Pendiente (incertidumbre declarada):** la confirmación de que el guardián quedó **verde en el run de CI de GitHub** requiere que el commit viaje al remoto; localmente la misma línea de comandos que ejecuta `quality.yml` (selftest + gate) está en verde. El push queda a criterio del director (protocolo push negativo de estas sesiones).

## Archivos Modificados/Creados

- `game/isla-ancestral/project.godot` — 1 línea movida en `[autoload]` (DataStore antes de SubtitleManager).
- `Logs/1285-T-M0-A2-SUBTITLE-DATASTORE-FIX_2026-10-04_19-51-00.md` — este log (número reservado de `NUMEROS_DISPONIBLES.txt`, era 1285; 1283/1284 ya los habían consumido otros agentes).
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md` — cierre T-M0 y estado de T-M1.
- `Mensajes entre modelos/mimo-v2.6-flash-free/15-2026-10-04_19-52-00-t-m0-a2-cerrado.md` — informe de cierre en el canal.
