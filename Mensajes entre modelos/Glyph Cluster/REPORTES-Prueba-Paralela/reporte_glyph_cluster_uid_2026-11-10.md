# Reporte de verificación de UID en `.tscn` / `.tres`

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (Glyph Cluster / stealth)  
**Fecha:** 2026-11-10 21:10  
**Alcance:** `game/isla-ancestral/` (recursivo), excluyendo copias/worktrees/backups fuera de esa ruta (`.kilo/worktrees`, `Obsoletos`, etc.) para evitar duplicar hallazgos de artefactos no activos.

## Resumen ejecutivo

| Métrica | Valor |
|---|---:|
| Archivos `.tscn`/`.tres` escaneados | 548 |
| Archivos con UID propio declarado en cabecera (`uid="uid://..."`) | 21 |
| UIDs propios declarados (cabecera) | 21 |
| UID duplicados entre escenas/recursos (misma cabecera UID en >1 archivo) | **0** |
| Referencias `uid="uid://..."` a UID no declarados en cabeceras de `.tscn/.tres` escaneados | **303 UID** (303 ocurrencias `ext_resource`) |
| Referencias/cabeceras UID con formato mal formado | **0** |
| Ocurrencias del patrón literal `[uid=` | **0** |
| Ocurrencias de `unique_id=` | **160** (13 archivos) |
| Valores `unique_id` con formato numérico inválido | **0** |
| Archivos sin `uid` en cabecera | 527 |

**Conclusión general:** no se detectaron **UID de recurso/escena duplicados** ni **UID mal formados** en cabeceras/referencias dentro de `game/isla-ancestral/`. El hallazgo principal es un volumen alto de **referencias `uid://` a assets externos** (texturas/iconos) cuyo UID no aparece como cabecera en ningún `.tscn/.tres` escaneado; esto es consistente con dependencias a recursos importados (`.png`, etc.) que en Godot pueden tener su UID en metadatos de importación/`.uid`, pero requiere verificación de integridad de assets. También hay uso extendido de `unique_id=` en nodos de escena (atributo de instancia de nodo en Godot 4), sin valores mal formados detectados.

## 1) ¿Hay UID duplicados entre escenas?

**Resultado: No.**

- Se detectaron 21 UIDs propios declarados en cabecera (`[gd_scene ... uid=...]` / `[gd_resource ... uid=...]`), cada uno en un único archivo.
- No hay ningún caso donde el mismo `uid://...` aparezca como UID propio de cabecera en dos o más archivos.

### UIDs declarados en cabecera (21)

| UID | Archivo | Línea |
|---|---|---:|
| `uid://c1234568aa0` | `game/isla-ancestral/scenes/main.tscn` | 1 |
| `uid://caso_reloj_001` | `game/isla-ancestral/scenes/caso_reloj.tscn` | 1 |
| `uid://cm27t001` | `game/isla-ancestral/scenes/tests/test_m108.tscn` | 1 |
| `uid://com4osvg1vnk8` | `game/isla-ancestral/scenes/test_anillo_arena.tscn` | 1 |
| `uid://dm0w488a2kgyd` | `game/isla-ancestral/scenes/main.tscn` | 1 |
| `uid://gadunitinspector` | `game/isla-ancestral/addons/gdUnit4/src/ui/GdUnitInspector.tscn` | 1 |
| `uid://gadunitstatusbar` | `game/isla-ancestral/addons/gdUnit4/src/ui/parts/GdUnitInspectorStatusBar.tscn` | 1 |
| `uid://gadunittoolbar` | `game/isla-ancestral/addons/gdUnit4/src/ui/parts/GdUnitInspectorToolBar.tscn` | 1 |
| `uid://gadunittree` | `game/isla-ancestral/addons/gdUnit4/src/ui/parts/GdUnitInspectorTreeMainPanel.tscn` | 1 |
| `uid://gareportpanel` | `game/isla-ancestral/addons/gdUnit4/src/ui/parts/GdUnitReportPanel.tscn` | 1 |
| `uid://gasettingshooks` | `game/isla-ancestral/addons/gdUnit4/src/ui/settings/GdUnitSettingsTabHooks.tscn` | 1 |
| `uid://hus0v3sy6ned` | `game/isla-ancestral/scenes/CameraRig.tscn` | 1 |
| `uid://main_island_debug001` | `game/isla-ancestral/scenes/main_island.tscn` | 1 |
| `uid://particles_preview` | `game/isla-ancestral/scenes/preview_particles.tscn` | 1 |
| `uid://ppisos4qhbmkb` | `game/isla-ancestral/addons/gdUnit4/src/ui/menu/GdUnitContextMenu.tscn` | 1 |
| `uid://pvkrbo2gu4n1v` | `game/isla-ancestral/addons/gdUnit4/src/ui/menu/EditorFileSystemContextMenuHandler.tscn` | 1 |
| `uid://pvksq6s8jkugj` | `game/isla-ancestral/addons/gdUnit4/src/ui/menu/ScriptEditorContextMenuHandler.tscn` | 1 |
| `uid://simplewalk001` | `game/isla-ancestral/scenes/simple_walk.tscn` | 1 |
| `uid://test_arch_001` | `game/isla-ancestral/scenes/test_arquitectura.tscn` | 1 |
| `uid://test_m155_3d` | `game/isla-ancestral/scenes/test_m155_3d.tscn` | 1 |
| `uid://test_m155_ui` | `game/isla-ancestral/scenes/test_m155_ui.tscn` | 1 |

> Nota: varios UIDs usan identificadores legibles/personalizados (`uid://caso_reloj_001`, `uid://main_island_debug001`, etc.). Son sintácticamente válidos para el patrón `uid://<id>` pero difieren del formato hash típico generado por Godot; no se clasifican como mal formados por regex ni como duplicados.

## 2) ¿Hay referencias a UID que no existen?

**Resultado: Sí (según definición estricta contra cabeceras de `.tscn/.tres` escaneados).**

- **303 UIDs referenciados** no tienen una declaración de cabecera correspondiente en ningún `.tscn/.tres` dentro de `game/isla-ancestral/`.
- **303 ocurrencias** encontradas (todas en `ext_resource` con `uid=... path=...`).
- Patrón observado: referencias a texturas/iconos de items bajo `res://assets/2d/items_m159/...` desde recursos `.tres` de datos.

### Ejemplos representativos (archivo, línea, UID referenciado, recurso)

| Archivo | Línea | UID referenciado | Path referenciado |
|---|---:|---|---|
| `game/isla-ancestral/data/items/stone.tres` | 4 | `uid://04obc05kum5s` | `res://assets/2d/items_m159/ico_stone.png` |
| `game/isla-ancestral/data/items/ancient_crystal.tres` | 4 | `uid://r3oie0pv35qn` | `res://assets/2d/items_m159/ico_ancient_crystal.png` |
| `game/isla-ancestral/data/items/baya_roja.tres` | 4 | `uid://cvyxq1riytmlw` | `res://assets/2d/items_m159/ico_baya_roja.png` |
| `game/isla-ancestral/data/items/clay.tres` | 4 | `uid://b75l6je0kr8ip` | `res://assets/2d/items_m159/ico_clay.png` |
| `game/isla-ancestral/data/items/item_obj_nat_004.tres` | 4 | `uid://0d0aaw7ecsre` | (ver archivo) |
| `game/isla-ancestral/data/items/item_obj_her_006.tres` | 4 | `uid://0obnpcal1arv` | (ver archivo) |

### Contexto observado (muestra)

`game/isla-ancestral/data/items/stone.tres:4`
```text
[ext_resource type="CompressedTexture2D" uid="uid://04obc05kum5s" path="res://assets/2d/items_m159/ico_stone.png" id="2"]
```

### Interpretación técnica

- Estos `uid://` **no existen como UID propios en cabeceras de `.tscn/.tres`**, pero sí pueden pertenecer a assets importados por Godot (imágenes, etc.).
- Verificación puntual: `game/isla-ancestral/assets/2d/items_m159/ico_stone.png` y `ico_stone.png.import` existen; **no se encontró `ico_stone.png.uid`** en esa carpeta durante el muestreo.
- Por lo tanto, no se puede afirmar automáticamente que sean referencias rotas en runtime/editor sin contrastar el estado de importación de Godot (`.godot/`, `.import`, `.uid` asociados) y la resolución real en el editor. Sí se reporta como **desalineación entre referencias UID y UIDs declarados en `.tscn/.tres`**.

## 3) ¿Hay escenas con `unique_id` mal formado?

**Resultado: No se detectaron valores mal formados; sí hay uso de `unique_id`.**

- Patrón literal `[uid=`: **0** ocurrencias.
- Atributo `unique_id=`: **160** ocurrencias en **13** archivos `.tscn`.
- Todos los valores observados son enteros (positivos/negativos permitidos por regex de validación numérica; en la práctica positivos en este muestreo). **0 valores con formato inválido**.

### Archivos con `unique_id=` (conteo por archivo)

| Archivo | Ocurrencias | Rango de líneas (aprox.) |
|---|---:|---|
| `game/isla-ancestral/addons/gdUnit4/src/ui/GdUnitInspector.tscn` | 3 | 20, 29, 50 |
| `game/isla-ancestral/addons/gdUnit4/src/ui/menu/GdUnitContextMenu.tscn` | 1 | 9 |
| `game/isla-ancestral/addons/gdUnit4/src/ui/parts/GdUnitInspectorProgressBar.tscn` | 2 | 16, 27 |
| `game/isla-ancestral/addons/gdUnit4/src/ui/parts/GdUnitInspectorStatusBar.tscn` | 34 | 20–356 |
| `game/isla-ancestral/addons/gdUnit4/src/ui/parts/GdUnitInspectorToolBar.tscn` | 13 | 53–134 |
| `game/isla-ancestral/addons/gdUnit4/src/ui/parts/GdUnitInspectorTreeMainPanel.tscn` | 8 | 47–126 |
| `game/isla-ancestral/addons/gdUnit4/src/ui/parts/GdUnitReportPanel.tscn` | 4 | 5–40 |
| `game/isla-ancestral/addons/gdUnit4/src/ui/settings/GdUnitSettingsTabHooks.tscn` | 22 | 69–216 |
| `game/isla-ancestral/addons/gdUnit4/src/ui/settings/GdUnitSettingsTabShortcuts.tscn` | 21 | 58–185 |
| `game/isla-ancestral/scenes/CameraRig.tscn` | 4 | 6–15 |
| `game/isla-ancestral/scenes/main_island.tscn` | 23 | 57–192 |
| `game/isla-ancestral/scenes/preview_particles.tscn` | 8 | 22–49 |
| `game/isla-ancestral/scenes/simple_walk.tscn` | 15 | 57–112 |

### Ejemplos

- `game/isla-ancestral/scenes/main_island.tscn:57` — `[node name="Main" type="Node3D" unique_id=1675065870]`
- `game/isla-ancestral/scenes/CameraRig.tscn:6` — `[node name="CameraRig" type="Node3D" unique_id=1636214823]`
- `game/isla-ancestral/scenes/simple_walk.tscn:57` — `[node name="Game" type="CharacterBody3D" unique_id=1217130252]`
- `game/isla-ancestral/addons/gdUnit4/src/ui/parts/GdUnitInspectorStatusBar.tscn:20` — `[node name="StatusBar" type="Control" unique_id=443133780]`

> Aclaración: `unique_id` en nodos de escena (Godot 4) no es lo mismo que el `uid="uid://..."` de recurso/escena en cabecera; su presencia no implica error por sí misma.

## 4) Hallazgos adicionales relevantes

- **Archivos sin UID de cabecera:** 527 de 548 (predominan `.tres` de datos/configuración y varias escenas). No es necesariamente un error, pero reduce trazabilidad por UID.
- **UIDs de cabecera con formato no hash:** presentes (p.ej. `uid://main_island_debug001`, `uid://simplewalk001`) — válidos como identificadores pero poco habituales; conviene normalizarlos si se busca consistencia.
- **`.uid` sidecar:** se encontraron archivos `.gd.uid` en el proyecto (herramientas/scripts), pero en el muestreo de assets referenciados (`assets/2d/items_m159/*.png`) no había `.uid` junto al `.png` (sí `.import`), lo que puede explicar parte de las 303 referencias no resueltas contra cabeceras `.tscn/.tres`.

## 5) Sugerencias de verificación (2 acciones)

1. **Validación en el editor Godot (fuente de verdad de importación):** abrir `game/isla-ancestral/project.godot` con Godot 4.x, forzar reimportación si es necesario y revisar el panel de errores/Output al cargar escenas clave (`scenes/main.tscn`, `scenes/main_island.tscn`, escenas con `unique_id`) y recursos de datos (`data/items/*.tres`). Confirmar si las 303 referencias `uid://...` a assets (p.ej. `res://assets/2d/items_m159/ico_stone.png`) se resuelven correctamente o si el editor solicita regenerar/actualizar UIDs.
2. **Auditoría de consistencia UID↔asset en disco:** ejecutar una comprobación automatizada que cruce cada `ext_resource` con `uid` y `path` contra (a) existencia del `path` en `res://`/filesystem, (b) presencia de `.uid`/`.import` correspondiente y (c) UID esperado en metadatos de importación (`.godot/imported/*` si existe). Priorizar el lote `data/items/*.tres` y, si se detectan inconsistencias reales, regenerar UIDs/recursos desde el editor (o con herramientas oficiales) y volver a escanear para confirmar que las referencias pendientes bajan a 0.

## Conclusión final

- **UID duplicados entre escenas/recursos:** no detectados.
- **UID mal formados en cabeceras/referencias:** no detectados.
- **`unique_id` mal formado en escenas:** no detectado (160 usos, todos numéricos válidos, concentrados en addons gdUnit4 y 4 escenas del juego).
- **Riesgo/hallazgo a revisar:** 303 referencias `uid://` no resueltas contra UIDs de cabecera en `.tscn/.tres` (principalmente texturas de items), que requieren verificación en Godot para distinguir "UID externo/importado válido" de "referencia rota" tras cambios de assets/importación.

**Estado del análisis:** completado sobre el alcance indicado, con evidencia de archivos y líneas incluidas en este reporte.