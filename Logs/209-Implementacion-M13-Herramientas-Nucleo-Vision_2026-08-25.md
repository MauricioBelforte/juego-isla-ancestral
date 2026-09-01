# Log 209: Implementación núcleo+visión M13 — Herramientas

**Fecha:** 2026-08-25
**Hora:** 21:25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen

Implementado el **núcleo del M13 (Herramientas)**: catálogo de 9 herramientas × 4 niveles (36 combos) con las tablas de stats del diseño, contrato `try_extract`/`try_place` (M08/M17), y la **parte de visión verificada con captura real**: highlight emissive "late" del recurso apuntado cuando la herramienta equipada aplica.

## Archivos creados (`game/isla-ancestral/`)

| Archivo | Contenido |
|---|---|
| `scripts/tools/tool_data.gd` | Resource ToolData: enums Tipo (9) / Nivel (4) / Accion (7); tablas STATS por tipo×nivel (durabilidad, velocidad, área 1x1/3x3 desde T3); durabilidad cozy (nunca se rompe, aviso <20%), mejoras M158 (afilada/templada/potenciada), serialización GameState.M13 |
| `scripts/tools/tool_controller.gd` | Controller: raycast 4 m (RF7), highlight emissive al 60% si la herramienta aplica al target (vía `get_acciones_validas()` duck-typed), contratos `try_extract()` / `try_place(block_id, meta)` con consumo de durabilidad |
| `scripts/tools/recurso_mock.gd` | Recurso de prueba que expone el contrato mínimo (`get_acciones_validas`/`try_extract`/`try_place`) |
| `scripts/tools/preview_herramientas.gd` | Escena de preview generada por código: luz, suelo, 3 recursos (piedra=EXTRACT, árbol=EXTRACT/SHEAR, parcela=TILL/WATER como control negativo), cámara y controller equipado con Pico T1 |
| `scenes/preview_herramientas.tscn` | Escena mínima con el script raíz |

Modificados: `data/items/item_obj_pla_001.tres` (**fix bug propio del placeholder M159**: faltaba cabecera `[gd_resource type="Resource" script_class="ItemData"]` + ext_resource del script → error "Unrecognized file type 'resource'").

## Validación

1. `--check-only`: **0 errores** en scripts tools/; sin regresiones M59/M159/M66.
2. **Visión (V2)**: escena lanzada → consola `[M13] Equipada: Pico de Cobre (dur 150/150)`. Captura de pantalla verificada: **la piedra brilla (highlight correcto), árbol y parcela NO brillan (control negativo OK)**.
3. Re-lanzada tras fix del .tres: carga limpia, sin errores.
   Captura: `tools/mcp/herramientas-mcp/capturas/13-Herramientas/cap_13_2026-08-25_preview_pico_highlight.png`

## Pendientes honestos ([?])

- Integración voxel real: los contratos hoy van contra mocks; conectar a VoxelTerrain (M08) cuando su módulo esté operativo.
- HUD de durabilidad + icono reparación (M57), sonidos por material (M41), partículas (M52).
- Mini-juego de pesca de la caña (M35), mesa de trabajo reparaciones (M16/M17).
