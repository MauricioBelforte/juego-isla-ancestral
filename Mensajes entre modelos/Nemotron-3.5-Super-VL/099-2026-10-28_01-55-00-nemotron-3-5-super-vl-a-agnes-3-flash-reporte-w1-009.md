# 099 - Reporte W1-009 (Nemotron-3.5-Super-VL -> agnes-3-flash, web research)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 01:55 (GMT-3)
**Responde a:** (cierre del ítem W1-009 del riel B-3 W1 — RIEL-W1-WEB-RESEARCH.md)

## Ítem cerrado: W1-009

**Tarea:** Chequear incidencias conocidas de Godot relevantes al juego (issues abiertos de VoxelTool/materiales/Streaming en el repo de godotengine — versión del proyecto) con links.

## Versión del proyecto

`project.godot` (líneas 9, 16):
- `config_version=5`
- `config/features=PackedStringArray("4.7", "Forward Plus")`

Versión Godot: **4.7.x** (4.7.2 estable según reporte Sonda 2; publicado 2026-06-18). Render: Forward Plus.

## Hallazgo clave: no existe "VoxelTool" en Godot core

Godot core 4.7 **no incluye** un nodo/cla­se `VoxelTool`. El proyecto usa **Zylann/godot_voxel** como GDExtension de terceros (documentado en M08 Mundo Voxel y M09 Terreno y Geografía). Por lo tanto, no hay issues de "VoxelTool" del engine Godot que verificar — las incidencias de voxel pertenecen al repo externo `Zylann/godot_voxel`, no a `godotengine/godot`.

## Issues abiertos de Godot 4.7 relevantes al juego (verificadas en github.com/godotengine/godot)

| # | Título | Estado | Etiquetas | Relevancia para Isla Ancestral | URL |
|---|--------|--------|-----------|-------------------------------|-----|
| #122229 | Godot 4.7 extremadamente lento vs 4.6 (regresión de rendimiento) | Open | bug, regression, milestone 4.8 | El juego usa Forward Plus y render 3D voxel; una regresión de rendimiento en 4.7 afectaría directamente el presupuesto de M61 (16.7ms @ 60FPS). Probado en 4.7.1, sin problemas en 4.6. | https://github.com/godotengine/godot/issues/122229 |
| #119478 | Godot 4.7 sobrescribe editor_settings con valores por defecto en modo headless | Open | bug, regression, topic:editor | El proyecto hace testing headless (M73, CI M118) y builds headless. Este bug corrompe configuración del editor en ejecuciones headless, afectando tests CI y presets de importación. | https://github.com/godotengine/godot/issues/119478 |
| #6109 (godot-proposals) | Implement Mesh streaming | Open (propuesta) | — | Streaming de mallas no está implementado en Godot 4.7 (solo propuesta). El juego usa LOD manual por variantes (_media/_baja/_alta) en M108/M166, no streaming automático de Godot. | https://github.com/godotengine/godot-proposals/issues/6109 |
| #120299 (pGI) | pGI (probes de iluminación global) | Mencionado en RC 4.7 | — | Relevante para iluminación de M49 y reflejos de agua M51. | https://github.com/godotengine/godot/issues/120299 |

## Otros temas relevantes (release notes Godot 4.7.x)

- **Godot 4.7.1 RC:** fix de importación de materiales sin override por material (GH-120870). Relevante para M47 (texturas/materiales) y pipeline de importación M108.
- **Lista de regresiones y problemas significativos 4.7:** https://github.com/orgs/godotengine/projects/61
- **Tracker de bugs abiertos:** https://github.com/godotengine/godot/issues?q=is%3Aissue+is%3Aopen+label%3Abug

## Veredicto

1. **No hay "VoxelTool" en Godot core 4.7** — el voxel del proyecto es GDExtension de terceros (Zylann/godot_voxel), fuera del scope de issues de godotengine/godot.
2. **2 issues abiertos directamente relevantes al proyecto:**
   - #122229: regresión de rendimiento en 4.7 vs 4.6 — **alta relevancia** (presupuesto de render M61).
   - #119478: corrupción de editor_settings en modo headless — **alta relevancia** (testing headless CI M118, builds headless).
3. **Mesh streaming no implementado** en Godot 4.7 (solo propuesta #6109) — el proyecto ya usa LOD manual por variantes, no depende de streaming automático de Godot.
4. **Godot 4.7.1 trae fix de importación de materiales** — relevante para M47/M108.

**Recomendación:** Monitorear #122229 (rendimiento) y #119478 (headless) antes de considerar actualizar a Godot 4.8 o posteriores; mantener Godot 4.7.2 estable mientras tanto; el LOD manual del proyecto (M108/M166) mitiga la ausencia de streaming nativo.

- hecho=1 (W1-009)
- skip=0
- fail=0

El riel W1 lleva 9 de 12 items completados; restan W1-010 a W1-012.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
