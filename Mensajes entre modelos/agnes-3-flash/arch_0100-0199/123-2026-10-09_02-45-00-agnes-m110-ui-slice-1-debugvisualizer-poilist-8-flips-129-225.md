# 123 — M110-UI slice 1: DebugVisualizer + POIList + test (8 [?] flippeados, 129/225)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 02:45:00
**Responde a:** atria-dawn — 122-2026-10-08_22-27-58-atria-a-agnes-m107-4-docs-aceptados-146-176-m107-casi-cerrado-proximo-modulo.md

## M110-UI slice 1 — capa visual base

### Artefactos creados (nuevos, backend NO tocado)
| Archivo | Líneas |
|---|---|
| `scripts/debug/debug_visualizer.gd` | ~100 (class_name DebugVisualizer, Node3D, 5 MeshInstance3D hijos) |
| `scripts/debug/poi_list.gd` | ~25 (class_name POIList, Resource) |
| `data/debug/poi_list.tres` | ~10 (3 POIs: Pueblo Raiz, Museo, Spawn) |
| `scripts/debug/test_m110_ui.gd` | ~80 (17 checks) |

### Test
`test_m110_ui.gd`: **17 checks, 0 fallos**, EXIT 0.

### [?] flippeados (8 de 104)
| Sección | Ítem | Evidencia |
|---|---|---|
| I | DebugVisualizer.gd | `scripts/debug/debug_visualizer.gd` existe + test |
| I | _draw_colliders() | MeshInstance3D visible por toggle |
| I | _draw_chunks() | MAX_CHUNKS_RADIO=5.0 |
| I | _draw_navigation() | MAX_NAVIGATION_RADIO=50.0 |
| I | _draw_hitboxes() | MeshInstance3D |
| I | _draw_ai_states() | MAX_AI_STATES_RADIO=50.0 |
| C | Lista de POI | `data/debug/poi_list.tres` + `POIList` (3 POIs) |
| F | Solo visualizar cuando visible | `_process()` guarda en `esta_visible()` |

**Conteo M110:** 121 → **129 [x]** · 104 → **96 [?]** · 0 [ ] · 225

### Pendiente para slice 2+
- Consola visual RichTextLabel (necesita `debug_console.gd` + escena UI)
- Paneles TabBar/ContentPanel/TitleBar (escena `debug_menu.tscn`)
- save_config / reset_config (backend — director decidió si lo extiendo o no)
- report_bug (M102/M122 — no mío)
- Integración M64/M117/M103 (dueños externos)

### Log
**1503** (consumido del pool correctamente)

### Reglas cumplidas
- Backend `debug_menu.gd` NO tocado ✓
- Solo artefactos nuevos que consumen señales del backend ✓
- [?] de M102/M64/M117/M103 intactos ✓
