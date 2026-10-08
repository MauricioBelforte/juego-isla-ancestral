# L-01 — Auditoría de `.claude/skills/` (§27 AGENTS.md)

**Modelo:** ling-3.1-flash (inclusionAI / Ant Group)
**Plataforma:** Kilo Gateway
**Fecha:** 2026-10-06
**Tarea:** Validación L-01 — auditoría de las 69 skills instaladas en `.claude/skills/` contra el repo real.
**Restricciones cumplidas:** SOLO LECTURA sobre el repo (no se modificó ninguna skill, código, CHECKLIST-GLOBAL.md ni ESTADO-PARALELO.md). Sin commit, sin push. UTF-8 sin BOM (§28).

---

## 1. Metodología

1. **Listado:** 69 carpetas en `.claude/skills/` (verificado: `Get-ChildItem .claude/skills -Directory` = 69).
2. **Verificación de links internos:** script PowerShell que extrajo todos los links `](scripts/...)`, `](references/...)`, `](shaders/...)`, `](resources/...)` de cada `SKILL.md` y verificó `Test-Path` contra disco. **Resultado: 0 links markdown rotos** en las 42 skills de Godot que usan links markdown.
3. **Verificación de refs con backticks:** para las 27 skills que citan `` `scripts/...` `` / `` `references/...` `` con backticks (no links markdown). **Resultado: 0 rotas.**
4. **Verificación de APIs Godot 3 vs 4:** escaneo case-sensitive (PowerShell `-cmatch`) de los **1675 scripts `.gd`** de las skills buscando: `File.new`, `Directory.new`, `Pool*Array`, `.instance()`, `JSON.parse` estático, `VisualServer`, `OS.get_ticks_msec`, `yield()`, `extends Spatial/MeshInstance/Area/RigidBody/KinematicBody/CollisionShape`. **Resultado: 0 APIs Godot 3 reales en código activo.** Conteo positivo: 584 archivos con `@export`, 110 con `@onready`, 0 con `export var`/`onready var` sin `@`.
5. **Verificación de rutas de proyecto:** extracción de rutas `res://...` citadas en SKILL.md y verificación contra `game/isla-ancestral/`. Las inexistentes son ejemplos ilustrativos genéricos (`res://sprite.png`, `res://materials/stone.tres`), no afirmaciones de existencia.
6. **Verificación de references compartidas de Blender:** extracción de refs `../references/...` citadas por skills de Blender y verificación contra `.claude/skills/references/` (no existe) y `<skill>/references/`.
7. **Verificación de mojibake (§28):** escaneo de bytes de todos los `.md`/`.gd`/`.py` de skills buscando secuencias mojibake (`C3 A2 C2`). **Resultado: 0 archivos con mojibake real.** Todos UTF-8 sin BOM.
8. **Verificación de dominio:** búsqueda de menciones Unity/Unreal/React/Next.js para detectar skills de otros dominios.

**Proyecto verificado:** `game/isla-ancestral/project.godot` → `config/features=PackedStringArray("4.7", "Forward Plus")` (L: `config/features`). Binario headless: `C:\Temp\godot\godot472.exe`. `game/isla-ancestral/export_presets.cfg` tiene presets **Web** y **Windows Desktop**.

---

## 2. Tabla de las 69 skills

Leyenda: ✅ VERIFICADA · ⚠️ CON DRIFT · ❌ ROTA/IRRELEVANTE

### Skills de Godot (44)

| # | Skill | Categoría | Estado | Evidencia (ruta exacta / script verificado) |
|---|-------|-----------|--------|----------------------------------------------|
| 1 | godot-3d-lighting | Godot 3D | ✅ | `.claude/skills/godot-3d-lighting/scripts/` (16 scripts: `day_night_cycle.gd`, `light_lod_optimizer.gd`, `light_probe_manager.gd`, `shadow_cascade_tuner.gd`, `volumetric_fog_zones.gd`); 18 links verificados; usa `@export` |
| 2 | godot-3d-materials | Godot 3D | ✅ | `.claude/skills/godot-3d-materials/scripts/` (14 scripts: `decal_placer_expert.gd`, `pbr_material_builder.gd`, `triplanar_world.gd`); `shaders/triplanar_smooth.gdshader`; 15 links OK |
| 3 | godot-3d-world-building | Godot 3D | ✅ | `.claude/skills/godot-3d-world-building/scripts/` (10 scripts: `csg_bake_tool.gd`, `gridmap_runtime_builder.gd`, `lod_manager.gd`); 10 links OK |
| 4 | godot-ability-system | Godot gameplay | ✅ | `.claude/skills/godot-ability-system/scripts/` (11 scripts: `ability_container.gd`, `ability_manager.gd`, `ability_resource.gd`); 12 links OK |
| 5 | godot-agent-vision | Godot herramienta | ✅ | `.claude/skills/godot-agent-vision/scripts/capture.py`, `webp_encode.py`, `asset_sheet.py`, `ensure_gitignore.py`, `stage_editor_bridge.py`, `editor_bridge/plugin.cfg`+`plugin.gd`+`capture_viewport.gd` (23 links OK). El addon `res://addons/_gdskills_agent_vision/` NO existe en disco **por diseño** (SKILL.md L14: "NEVER ship the editor bridge... leave `addons/_gdskills_agent_vision/` committed — stage, capture, teardown"). Capturas reales en `game/isla-ancestral/.gdskills/vision/*.webp` (6 archivos) confirman uso. |
| 6 | godot-ai-navigation | Godot AI | ✅ | `.claude/skills/godot-ai-navigation/references/` (2 refs); 1 link OK; contenido Godot 4 (NavigationServer) |
| 7 | godot-analyst | Godot herramienta | ✅ | `.claude/skills/godot-analyst/scripts/` (`marking_rubrics_atlas.gd`, `scoring_logic.gd`, `visionary_comparison.gd`); `references/categories/` (76 archivos); 4 links OK |
| 8 | godot-audio-systems | Godot audio | ✅ | `.claude/skills/godot-audio-systems/scripts/` (16 scripts: `audio_bus_manager.gd`, `audio_adaptive_music_player.gd`, `audio_visualizer.gd`); 19 links OK |
| 9 | godot-auditor | Godot herramienta | ✅ | `.claude/skills/godot-auditor/scripts/` (4 scripts); `references/categories/` (93 archivos); 9 links OK |
| 10 | godot-autoload-architecture | Godot arquitectura | ✅ | `.claude/skills/godot-autoload-architecture/scripts/` (18 scripts); 20 links OK |
| 11 | godot-builder | Godot CLI/CI | ✅ | `.claude/skills/godot-builder/scripts/` (29 scripts: `ci_exporter.py`, `launch_editor.py`, `run_project.py`, `get_debug_output.py`, `create_scene.py`, `navmesh_baker.py`); 12 links OK. Target Godot 4.7+ (description). |
| 12 | godot-camera-systems | Godot cámara | ✅ | `.claude/skills/godot-camera-systems/scripts/` (17 scripts); 18 links OK |
| 13 | godot-characterbody-2d | Godot 2D | ⚠️ | Scripts existen (`.claude/skills/godot-characterbody-2d/scripts/`, 15 scripts) y contenido es Godot 4 válido, **pero es 2D** (CharacterBody2D, platformer, coyote time, `move_and_slide` 2D) en un proyecto **3D voxel** (`config/features=PackedStringArray("4.7", "Forward Plus")`). Baja relevancia: el jugador es 3D (CharacterBody3D). No rota — dominio 2D en proyecto 3D. |
| 14 | godot-combat-system | Godot gameplay | ✅ | `.claude/skills/godot-combat-system/scripts/` (11 scripts); 12 links OK |
| 15 | godot-composition | Godot arquitectura | ✅ | `.claude/skills/godot-composition/scripts/` (10 scripts) + `resources/` (2); 11 links OK |
| 16 | godot-debugging-profiling | Godot debug | ✅ | `.claude/skills/godot-debugging-profiling/scripts/` (20 scripts); 21 links OK |
| 17 | godot-dialogue-system | Godot gameplay | ✅ | `.claude/skills/godot-dialogue-system/scripts/` (15 scripts); 16 links OK |
| 18 | godot-export | Blender→Godot | ✅ | `.claude/skills/godot-export/SKILL.md` (domain: blender, GLTF/GLB export a Godot 4.x); 1 ref backtick OK. Relevante: el proyecto importa assets Blender. |
| 19 | godot-export-builds | Godot export | ✅ | `.claude/skills/godot-export-builds/scripts/` (14 scripts: `export_universal_manager.gd` usa `ConfigFile`, `OS.execute`, `push_error` — Godot 4); 15 links OK. Cita `res://export_presets.cfg` → **existe** en `game/isla-ancestral/export_presets.cfg` (presets Web + Windows Desktop). |
| 20 | godot-gdscript-mastery | Godot GDScript | ✅ | `.claude/skills/godot-gdscript-mastery/scripts/` (14 scripts); 15 links OK |
| 21 | godot-input-handling | Godot input | ✅ | `.claude/skills/godot-input-handling/scripts/` (16 scripts: `safe_runtime_rebind.gd` usa `ConfigFile.new()` — Godot 4); 17 links OK |
| 22 | godot-inventory-system | Godot gameplay | ✅ | `.claude/skills/godot-inventory-system/scripts/` (12 scripts) + `references/` (10); 18 links OK |
| 23 | godot-master | Godot hub | ✅ | `.claude/skills/godot-master/scripts/` (1271 scripts espejo) + `references/categories/` (76) + `references/patterns/` (8); 106 links OK. Target Godot 4.7+ (SKILL.md L10). Es mirror consolidado de las otras skills — sus scripts son copias de las skills individuales (mismos contenidos, mismas APIs 4.x). |
| 24 | godot-navigation-pathfinding | Godot AI | ✅ | `.claude/skills/godot-navigation-pathfinding/scripts/` (15 scripts); 17 links OK |
| 25 | godot-particles | Godot VFX | ✅ | `.claude/skills/godot-particles/scripts/` (13 scripts: `smart_oneshot_recycler.gd`, `particle_burst_emitter.gd`, `massive_swarm_multimesh.gd`); `scripts/custom_particle_logic.gdshader`; 14 links OK. Contenido Godot 4 verificado: `GPUParticles3D`, `ParticleProcessMaterial`, `restart()`, `await`. |
| 26 | godot-performance-optimization | Godot perf | ✅ | `.claude/skills/godot-performance-optimization/scripts/` (12 scripts); 13 links OK |
| 27 | godot-physics-3d | Godot física | ✅ | `.claude/skills/godot-physics-3d/scripts/` (14 scripts); 16 links OK |
| 28 | godot-platform-desktop | Godot plataforma | ✅ | `.claude/skills/godot-platform-desktop/scripts/` (12 scripts); 11 links OK. Relevante: proyecto tiene preset Windows Desktop. |
| 29 | godot-platform-web | Godot plataforma | ✅ | `.claude/skills/godot-platform-web/scripts/` (13 scripts); 14 links OK. **Relevante:** `game/isla-ancestral/export_presets.cfg` tiene preset `platform="Web"`. |
| 30 | godot-procedural-generation | Godot procgen | ✅ | `.claude/skills/godot-procedural-generation/scripts/` (15 scripts); 15 links OK. Relevante: proyecto es voxel/terreno procedural. |
| 31 | godot-project-foundations | Godot base | ✅ | `.claude/skills/godot-project-foundations/scripts/` (14 scripts); 14 links OK |
| 32 | godot-quest-system | Godot gameplay | ✅ | `.claude/skills/godot-quest-system/scripts/` (14 scripts); 15 links OK |
| 33 | godot-raycasting-queries | Godot física | ✅ | `.claude/skills/godot-raycasting-queries/scripts/` (10 scripts); 11 links OK |
| 34 | godot-resource-data-patterns | Godot datos | ✅ | `.claude/skills/godot-resource-data-patterns/scripts/` (13 scripts); 14 links OK |
| 35 | godot-save-load-systems | Godot persistencia | ✅ | `.claude/skills/godot-save-load-systems/scripts/` (4 scripts: `save_load_patterns.gd` usa `FileAccess.open`/`FileAccess.WRITE` — Godot 4 correcto; `save_system_encryption.gd` usa `JSON.new()`+`json.parse()` — método de instancia Godot 4 válido); 5 links OK |
| 36 | godot-scene-management | Godot escenas | ✅ | `.claude/skills/godot-scene-management/scripts/` (12 scripts); 13 links OK |
| 37 | godot-shaders-basics | Godot shaders | ✅ | `.claude/skills/godot-shaders-basics/scripts/` (13 scripts) + `references/` (5); 17 links OK |
| 38 | godot-signal-architecture | Godot señales | ✅ | `.claude/skills/godot-signal-architecture/scripts/` (13 scripts); 14 links OK |
| 39 | godot-state-machine-advanced | Godot FSM | ✅ | `.claude/skills/godot-state-machine-advanced/scripts/` (12 scripts); 12 links OK |
| 40 | godot-testing-patterns | Godot testing | ✅ | `.claude/skills/godot-testing-patterns/scripts/` (14 scripts) + `references/` (3); 16 links OK |
| 41 | godot-tweening | Godot animación | ✅ | `.claude/skills/godot-tweening/scripts/` (12 scripts); 13 links OK |
| 42 | godot-ui-containers | Godot UI | ✅ | `.claude/skills/godot-ui-containers/scripts/` (13 scripts); 14 links OK |
| 43 | godot-ui-theming | Godot UI | ✅ | `.claude/skills/godot-ui-theming/scripts/` (13 scripts); 14 links OK |
| 44 | godot-version-migration | Godot migración | ✅ | `.claude/skills/godot-version-migration/references/` (96 archivos: `era-index.md`, `hop-index.md`, `legacy/`, `bridges/`); 5 links OK. **Legítimo:** su propósito es documentar migración 3→4 y hops 4.x; target 4.7+ coincide con el proyecto (4.7). Citar Godot 3 aquí es correcto, no drift. |

### Skills de Blender core (2)

| # | Skill | Categoría | Estado | Evidencia |
|---|-------|-----------|--------|-----------|
| 45 | blender-director | Blender orquestador | ⚠️ | `.claude/skills/blender-director/SKILL.md` (358 líneas, orquestador de pipeline AAA) + `references/skill-routing.md` (existe). **DRIFT:** cita **9 references compartidas `../references/` que NO existen** en disco: `asset-pipeline.md`, `mcp-integration.md`, `mcp-tools.md`, `naming-conventions.md`, `polycount-budgets.md`, `reference-analysis-template.md`, `reference-image-match.md`, `validation-checklist.md`, `visual-match-checklist.md`. Verificado: `.claude/skills/references/` **no existe** (`Test-Path` = False) y `blender-director/references/` solo contiene `skill-routing.md`. SKILL.md L34: "Every asset follows the universal pipeline in `../references/asset-pipeline.md`" — archivo ausente. |
| 46 | blender-modeler | Blender modelado | ⚠️ | `.claude/skills/blender-modeler/SKILL.md` (166 líneas) + `references/modifier-stack.md` + `references/scene-organization.md` (existen). **DRIFT:** cita **3 references compartidas `../references/` inexistentes**: `asset-pipeline.md` (L156), `mcp-integration.md` (L132), `naming-conventions.md` (L51). Mismo origen: la carpeta compartida `references/` del repo upstream (arjun988/blender-skills) no se instaló. |

### Otras skills (23) — 21 Blender disciplinares + find-skills + (godot-export ya listado arriba)

| # | Skill | Categoría | Estado | Evidencia |
|---|-------|-----------|--------|-----------|
| 47 | asset-optimization | Blender optimización | ⚠️ | `SKILL.md` + `references/` (1 archivo). **DRIFT:** cita 2 refs compartidas inexistentes: `polycount-budgets.md`, `validation-checklist.md`. |
| 48 | camera-cinematography | Blender cámara | ✅ | `SKILL.md` + `references/` (3 archivos). 0 refs compartidas faltantes. Contenido bpy vigente. |
| 49 | character-artist | Blender personaje | ⚠️ | `SKILL.md` + `references/` (2 archivos). **DRIFT:** cita `asset-pipeline.md` (compartida, inexistente). |
| 50 | collision-proxy | Blender colisiones | ✅ | `SKILL.md` + `references/` (2 archivos). 0 refs compartidas faltantes. |
| 51 | creature-artist | Blender criaturas | ⚠️ | `SKILL.md` + `references/` (2 archivos). **DRIFT:** cita `asset-pipeline.md` (inexistente). |
| 52 | environment-artist | Blender entorno | ⚠️ | `SKILL.md` + `references/` (2 archivos). **DRIFT:** cita `asset-pipeline.md` (inexistente). |
| 53 | export-pipeline | Blender export | ⚠️ | `SKILL.md` + `references/` (1 archivo). **DRIFT:** cita `validation-checklist.md` (inexistente). |
| 54 | find-skills | Utilidad ecosistema | ✅ | `SKILL.md` (141 líneas). Utilidad genérica del ecosistema de skills (`npx skills find/add`, skills.sh) — **no es Godot ni Blender**, pero es relevante para §27 (descubrimiento de skills). Sin scripts ni rutas de proyecto que verificar. Contenido correcto para su propósito. |
| 55 | hard-surface | Blender HS | ⚠️ | `SKILL.md` + `references/` (2 archivos). **DRIFT:** cita `asset-pipeline.md` (inexistente). |
| 56 | lighting | Blender iluminación | ✅ | `SKILL.md` + `references/` (2 archivos). 0 refs compartidas faltantes. |
| 57 | lod-pipeline | Blender LOD | ✅ | `SKILL.md` + `references/` (2 archivos). 0 refs compartidas faltantes. |
| 58 | materials | Blender materiales | ✅ | `SKILL.md` + `references/procedural-patterns.md` + `references/surface-recipes.md` (existen). Contenido bpy vigente: Principled BSDF, PBR, prefijo `MAT_`. 0 refs compartidas faltantes. |
| 59 | procedural-modeling | Blender procgen | ✅ | `SKILL.md` (sin refs con backticks ni links — contenido autocontenido). 0 refs faltantes. |
| 60 | prop-artist | Blender props | ✅ | `SKILL.md` + `references/` (3 archivos). 0 refs compartidas faltantes. |
| 61 | qa-review | Blender QA | ⚠️ | `SKILL.md` + `references/` (2 archivos). **DRIFT:** cita 4 refs compartidas inexistentes: `naming-conventions.md`, `polycount-budgets.md`, `validation-checklist.md`, `visual-match-checklist.md`. |
| 62 | rendering | Blender render | ⚠️ | `SKILL.md` + `references/` (2 archivos). **DRIFT:** cita 2 refs compartidas inexistentes: `reference-image-match.md`, `visual-match-checklist.md`. |
| 63 | retopology | Blender topología | ⚠️ | `SKILL.md` + `references/` (2 archivos). **DRIFT:** cita `polycount-budgets.md` (inexistente). |
| 64 | scene-assembly | Blender escenas | ✅ | `SKILL.md` + `references/` (2 archivos). 0 refs compartidas faltantes. |
| 65 | sculpting | Blender escultura | ✅ | `SKILL.md` + `references/` (1 archivo). 0 refs compartidas faltantes. |
| 66 | set-dressing | Blender dressing | ✅ | `SKILL.md` + `references/` (2 archivos). 0 refs compartidas faltantes. |
| 67 | texture-workflow | Blender texturas | ⚠️ | `SKILL.md` + `references/` (2 archivos). **DRIFT:** cita 2 refs compartidas inexistentes: `naming-conventions.md`, `polycount-budgets.md`. |
| 68 | uv-workflow | Blender UVs | ✅ | `SKILL.md` + `references/` (2 archivos). 0 refs compartidas faltantes. |
| 69 | vegetation-artist | Blender vegetación | ✅ | `SKILL.md` + `references/` (3 archivos). 0 refs compartidas faltantes. |

**Conteo final:** 56 ✅ VERIFICADAS · 13 ⚠️ CON DRIFT · 0 ❌ ROTA/IRRELEVANTE · **69/69 auditadas.**

---

## 3. Hallazgos detallados

### H-1 (severo) — 12 skills de Blender citan references compartidas `../references/` que no existen

**Qué referenceda:** 12 skills de Blender citan, en sus `SKILL.md`, archivos en `../references/` (carpeta compartida del repo upstream `arjun988/blender-skills`).

**Qué hay en disco:** `.claude/skills/references/` **no existe** (`Test-Path` = False). Las references compartidas ausentes son 9 archivos únicos:

| Referencia compartida | Skills que la citan |
|---|---|
| `asset-pipeline.md` | blender-director, blender-modeler, character-artist, creature-artist, environment-artist, hard-surface (6 skills) |
| `mcp-integration.md` | blender-director, blender-modeler |
| `naming-conventions.md` | blender-director, blender-modeler, qa-review, texture-workflow |
| `polycount-budgets.md` | blender-director, asset-optimization, qa-review, retopology, texture-workflow |
| `validation-checklist.md` | blender-director, asset-optimization, export-pipeline, qa-review |
| `visual-match-checklist.md` | blender-director, qa-review, rendering |
| `reference-image-match.md` | blender-director, rendering |
| `reference-analysis-template.md` | blender-director |
| `mcp-tools.md` | blender-director |

**Por qué no coincide:** la curatoría del 2026-08-25 (§27) instaló las carpetas por skill pero **no la carpeta `references/` compartida** del repo upstream. Las skills individuales sí traen sus propias `references/` locales (esas sí existen), pero las referencias cruzadas a la carpeta compartida quedan rotas. **Impacto:** blender-director (el orquestador principal, SKILL.md L34: "Every asset follows the universal pipeline in `../references/asset-pipeline.md`") pierde su pipeline universal, su guía de integración MCP, sus convenciones de nomenclatura y sus checklists de validación. Un agente que siga el flujo "MANDATORY" de blender-director llegará a un dead link.

**Clasificación:** ⚠️ CON DRIFT (no ❌ porque el contenido principal de cada skill —su `SKILL.md` y sus references locales— sí existe y es válido; el drift es en las referencias cruzadas compartidas).

### H-2 (leve) — godot-characterbody-2d es 2D en un proyecto 3D

**Evidencia:** `.claude/skills/godot-characterbody-2d/SKILL.md` description: "Expert patterns for **CharacterBody2D** including platformer movement (coyote time, jump buffering...), top-down movement (8-way, tank controls)...". El proyecto es 3D: `game/isla-ancestral/project.godot` → `config/features=PackedStringArray("4.7", "Forward Plus")`, y la documentación del proyecto (§2b, GUIA-GODOT/08-terreno-voxel.md) describe terreno voxel 3D con jugador CharacterBody3D.

**Por qué no coincide:** el dominio de la skill (movimiento 2D platformer/top-down) no aplica al jugador 3D del proyecto. No es error de API (el contenido es Godot 4 válido), es desalineación de dominio. Podría servir para UI 2D o minimapas, pero su contenido principal (movimiento, colisiones 2D) no aplica.

### H-3 (informativo) — godot-master es un mirror de 1271 scripts

**Evidencia:** `.claude/skills/godot-master/scripts/` = 1271 archivos `.gd`, `references/categories/` = 76 archivos. Su SKILL.md (L10): "All Domain Skill mirrors target Godot 4.7+". Los scripts son copias espejo de las skills individuales (ej: `godot-master/scripts/save_load_systems_save_load_patterns.gd` ≈ `godot-save-load-systems/scripts/save_load_patterns.gd`). Verificación case-sensitive: 0 APIs Godot 3 reales en los 1675 scripts `.gd` totales (incluidos los espejos). Esto explica por qué el conteo de scripts es tan alto y confirma que no hay drift de API oculto en los espejos.

### H-4 (informativo) — Las rutas `res://` inexistentes son ejemplos ilustrativos

**Evidencia:** 15 rutas `res://...` citadas en SKILL.md no existen en `game/isla-ancestral/` (ej: `res://sprite.png`, `res://materials/stone.tres`, `res://normal.png`, `res://UI/Button.tscn`, `res://large_scene.tscn`). Todas son **placeholders de documentación** en ejemplos de código, no afirmaciones de que existan en este repo. La única excepción verificada: `godot-export-builds` cita `res://export_presets.cfg` → **sí existe** en `game/isla-ancestral/export_presets.cfg`. Y `godot-agent-vision` cita `res://addons/_gdskills_agent_vision/plugin.cfg` → no existe **por diseño** (addon temporal, ver tabla #5).

### H-5 (informativo) — Falsos positivos descartados (honestidad metodológica)

Durante la auditoría, mis primeros escaneos (regex case-insensitive) marcaron como "Godot 3" hallazgos que resultaron ser **falsos positivos**. Los documento para transparencia:

- `export var` / `onready var` sin `@`: el conteo inicial marcó 2 archivos, pero la inspección manual de `godot-export-builds/scripts/export_universal_manager.gd` mostró que el patrón coincidía con `export_all`, `export_presets.cfg`, `--export-release` (substrings de "export"), no con `export var` real. **0 archivos con `export var` Godot 3 reales.**
- `yield()`: marcó `godot-master/scripts/game_loop_harvest_harvest_loop_patterns.gd`, pero es `_compute_yield` (nombre de función) + `WorkerThreadPool.add_group_task` (API Godot 4). **0 `yield()` reales.**
- `File` / `JSON.parse`: marcó 12 archivos, pero era `FileAccess.open` (Godot 4), `ConfigFile` (Godot 4), y `json.parse()` minúscula (método de instancia de `JSON.new()`, válido en Godot 4). La re-verificación **case-sensitive** (`-cmatch`) dio **0 APIs Godot 3 reales**.
- "mojibake" en `godot-master/SKILL.md`: el tool de lectura mostraba `â€”`/`ðŸ§`, pero el escaneo de bytes dio **0 secuencias mojibake** (`C3 A2 C2`) en todos los archivos de skills. Era un artefacto de visualización del tool, no corrupción real. Todos los archivos son UTF-8 sin BOM (§28 cumple).

### H-6 (informativo) — Menciones Unity/Unreal/React son routing legítimo

**Evidencia:** `blender-director`, `collision-proxy`, `export-pipeline`, `lod-pipeline`, `texture-workflow` mencionan Unity/Unreal como **destinos de exportación** (routing a skills `unity-export`/`unreal-export` del ecosistema, no instaladas — esperable, son links a GitHub, no afirmaciones de existencia local). `godot-master` menciona Unity en una sección "Quick Start — Unity (C#) to Godot (GDScript)" (guía de transición legítima). `godot-save-load-systems` menciona "React" pero es el verbo "systems **react** without hard-wiring" (falso positivo). `find-skills` menciona React/Next.js porque es una utilidad genérica del ecosistema (ver #54). **Ninguna skill es de Unity/Unreal/web como dominio propio.**

---

## 4. Autoevaluación honesta

### ¿Pudiste hacer la tarea completa?

**Sí — 69/69 skills auditadas.** No quedó ninguna sin auditar. Cada skill tiene fila en la tabla §2 con evidencia de ruta exacta o nombre de script verificado en disco. La verificación fue mayormente automatizada (scripts PowerShell de extracción de links + escaneo de APIs case-sensitive + escaneo de bytes para mojibake), con inspección manual de los casos límite (godot-agent-vision, blender-director, export_universal_manager.gd, save_load_patterns.gd) para descartar falsos positivos.

### ¿Qué me costó?

1. **Falsos positivos de regex case-insensitive.** PowerShell hace matching case-insensitive por defecto, lo que hizo que `JSON.parse` coincidiera con `json.parse` (válido Godot 4) y `export` coincidiera con `export_all`/`export_presets.cfg`. Tuve que re-verificar todo con `-cmatch` (case-sensitive) y filtrado de comentarios. Costó varias iteraciones, pero el resultado final es limpio: 0 APIs Godot 3 reales.
2. **Distingurir "ejemplo ilustrativo" de "afirmación de existencia"** en rutas `res://`. Decidí que `res://sprite.png` en un ejemplo de código no es drift (es placeholder), pero `res://addons/_gdskills_agent_vision/plugin.cfg` sí merecía verificación (y resultó ser temporal por diseño, no drift).
3. **El volumen de godot-master** (1271 scripts + 372 references). No leí cada script; confié en el escaneo automatizado de APIs + el hecho de que es mirror de skills individuales ya verificadas. Esto es una limitación honesta: no verifiqué línea por línea los 1271 espejos, sino por muestreo de APIs.

### ¿Te sentiste cómodo en complejidad 1-2 documental? ¿Te animarías a complejidad 2 con código GDScript o 3?

**Complejidad 1-2 documental: sí, cómodo.** La auditoría fue 100% lectura + verificación en disco + clasificación — exactamente el tipo de tarea atómica y autosuficiente que mi backlog recomienda. El método (automatizar la extracción, verificar con Test-Path, escanear APIs) escaló bien a 69 skills sin saturar el contexto.

**Complejidad 2 con código GDScript: sí, con método.** Pude verificar la corrección de APIs Godot 4 vs 3 en 1675 scripts (case-sensitive, con descarte de falsos positivos), lo que requiere conocer las diferencias 3→4 (`FileAccess` vs `File`, `JSON.new()` vs `JSON.parse` estático, `@export` vs `export var`, `instantiate()` vs `instance()`). Me animaría a tareas de complejidad 2 que sean **verificación/revisión de código GDScript existente** (auditoría, coherencia checklist-vs-disco, análisis de logs).

**Complejidad 3: no todavía.** Mi backlog (sección "Lo que NO debés hacer") y la hands-on independiente (pipeline Blender→Godot que se rompió) indican que no debo tomar implementación GDScript compleja ni pipelines multi-herramienta 3D. DeepSWE 1.1 no está publicado para mí. La auditoría L-01 no cambia eso: verificar código existente ≠ escribir código nuevo complejo.

### ¿Cuál skill te parece la más útil para el proyecto y por qué?

**godot-builder** (`.claude/skills/godot-builder/`). Razones:
1. **Alineación directa con el flujo del proyecto:** el proyecto usa Godot 4.7.2 headless (`C:\Temp\godot\godot472.exe`) y el protocolo §12.1 exige auto-corrección con MCP (get_debug_output, run_project). godot-builder trae 29 scripts exactamente para eso: `get_debug_output.py`, `run_project.py`, `launch_editor.py`, `ci_exporter.py`, `navmesh_baker.py`, `collision_generator.py`, `gltf_processor.py`.
2. **Cobertura del pipeline real:** el proyecto importa assets Blender (GLTF) y tiene terreno voxel — los scripts `gltf_processor.py`, `collision_generator.py`, `csg_optimizer.py`, `tilemap_generator.py` mapean a flujos reales del repo.
3. **Verificada sin drift:** 12 links OK, target Godot 4.7+ declarado, APIs Godot 4 en sus scripts.

Mención honorífica: **godot-agent-vision** — es la única skill que cierra el hueco de mi limitación (no veo imágenes); sus scripts `capture.py`/`webp_encode.py` permiten a un agente texto-puro obtener WebP presupetados del editor. Y **godot-version-migration** por ser el hub correcto para un proyecto en 4.7 que documenta todo el camino de migración.

---

## 5. Cierre

- **Tarea L-01:** completada — 69/69 skills auditadas con evidencia en disco.
- **Backlog:** marcado `[x]` en `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md` (sección L-01).
- **Log:** **no se creó** entrada en `Logs/` ni se tomó número de `Logs/NUMEROS_DISPONIBLES.txt` — la restricción explícita de la tarea ("Solo creás tu reporte y editás tu propio backlog. No toques NINGÚN otro archivo del repo") prevalece sobre el protocolo §6 de logs. Declarado aquí por honestidad (§21.4.3): el log está pendiente por restricción de solo-lectura, no por omisión.
- **Archivos creados/modificados:** `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/L-01-auditoria-skills.md` (creado) y `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md` (editado, solo la sección L-01).
- **Recomendación para el coordinador:** las 12 skills de Blender con drift (H-1) necesitan que alguien con acceso de escritura instale la carpeta `references/` compartida del repo upstream `arjun988/blender-skills` en `.claude/skills/references/` (9 archivos: asset-pipeline.md, mcp-integration.md, mcp-tools.md, naming-conventions.md, polycount-budgets.md, reference-analysis-template.md, reference-image-match.md, validation-checklist.md, visual-match-checklist.md). No lo hice yo por la restricción de solo-lectura.

**Modelo:** ling-3.1-flash (inclusionAI / Ant Group)
**Plataforma:** Kilo Gateway
**Fecha:** 2026-10-06
