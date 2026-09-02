# Log 385: M155 Vestimenta — Iteración 2: fix crítico de catálogo duplicado + boot desbloqueado + suite completa OK

**Fecha:** 2026-09-01
**Hora:** 18:55
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Iteración 2 del módulo M155 (Vestimenta y Accesorios): se corrigió el bloqueo crítico que impedía arrancar el proyecto (catálogo con claves duplicadas + indentación mixta en equipment_manager.gd), se amplió la suite de tests a 17 casos y se verificó el sistema completo en runtime (boot OK, FPS 60, HUD intacto) con evidencia visual.

## Cambios Realizados

### Fix crítico de catálogo (M155)
- `scripts/player/equipment_manager.gd` — el diccionario de prendas contenía `body_vest_explorer` y `acc_backpack` DOS veces (una versión antigua sin `unlock` y una versión nueva con `unlock` → `Parser Error: Key was already used in this dictionary`, que frenaba el boot). Eliminadas las entradas antiguas sin unlock (conservando las versiones con desbloqueo progresivo). Verificado: `[EquipmentManager] Catálogo cargado: 16 prendas` (parse OK).
- `scripts/player/equipment_manager.gd` — 35 líneas con indentación de espacios convertidas a tabs (`Parser Error: Used space character...`) — mismo bloqueo reportado en la iter 2 de M61 (guía 07 §9.60).

### Tests (suite ampliada a 17)
- `tests/unit/player/test_equipment_manager.gd` — 3 tests nuevos: `test_flag_unlock_vest_explorer` (unlock por flag `mochila_mejorada`), `test_catalog_no_duplicates` (16 prendas únicas — regresión del fix), `test_equip_replaces_same_slot` (reemplazo en el mismo slot).
- **Suite completa del proyecto** vía `res://tests/run_tests.gd` → **ÉXITO, 0 fallos, exit 0**.

### Verificación visual (V4 godot-mcp + captura)
- Juego ejecutado: boot completo sin debugger breaks, FPS 60, jugador en la ladera, HUD + hotbar + calendario intactos. Captura: `tools/mcp/godot-mcp/capturas/155-Vestimenta-Y-Accesorios/cap_155_2026-09-01_18-50-00_jugador.png`.

### Coordinación / nota transversal
- El AVISO GLOBAL del árbol dev (que dejé en el Log 384) se actualizó a **🟢 RESUELTO**: el fix de `fauna_manager.gd` (_get_registry) lo aplicó su dueño y el de equipment_manager el mío. Suite completa en verde lo confirma.

## Archivos Modificados/Creados

- Modificados: `game/isla-ancestral/scripts/player/equipment_manager.gd` (catálogo 16 únicas + indent), `game/isla-ancestral/tests/unit/player/test_equipment_manager.gd` (+3 tests), `DOCUMENTACION/155-Vestimenta-Y-Accesorios/plan-actual/05-Checklist.md` (bloque iter 2, 55/123), `CHECKLIST-GLOBAL.md` (fila 155), `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M155), `Mensajes entre modelos/ESTADO-PARALELO.md` (fila M155 + aviso global resuelto), `Logs/ULTIMO_NUMERO.txt` (→385)
- Creados: captura PNG (no versionada)

## Verificación

- Suite completa: ÉXITO (0 fallos, exit 0) · Catálogo: 16 prendas únicas · Boot: OK (FPS 60 con M155 activo) · 3 [?] honestos: UI de equipamiento (iter 3, M53/M57), modelo visual al equipar (M156), integración inventario→equipar (M14).
