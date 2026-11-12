# Reporte de análisis UID / referencias — `game/isla-ancestral`

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (sesión paralela)  
**Fecha:** 2026-11-12  
**Alcance analizado:** `game/isla-ancestral/` (raíz del proyecto Godot, donde reside `project.godot`)  
**Método:** escaneo estático de archivos `.tscn`, `.gd` y `.uid` mediante expresiones regulares sobre `ext_resource`, cabeceras `gd_scene`/`gd_resource`, `uid=`, `res://`, `preload()`/`load()` y resolución de rutas `res://` al sistema de archivos.

## Resumen cuantitativo

| Métrica | Valor |
|---|---:|
| Archivos `.tscn` | 69 (53 del proyecto, 16 del addon `gdUnit4`) |
| Archivos `.gd` | 1590 |
| Archivos `.uid` (sidecar) | 1621 |
| Referencias rotas en `.tscn` (`ext_resource` / `path=res://`) | **0** |
| Referencias `res://` rotas detectadas en `.gd` | **173** (ver clasificación) |
| UIDs de escena únicos detectados | 21 |
| UIDs de escena duplicados entre archivos de escena distintos | **0** |
| Aristas de dependencia PackedScene (`.tscn` → `.tscn`) | 17 |
| Dependencias circulares entre escenas | **0** |
| Referencias `unique_id` en `.gd` | **0** |

---

## 1) Archivos `.tscn` con referencias a recursos que no existen

**Resultado:** No se detectaron referencias a recursos inexistentes dentro de archivos `.tscn` del alcance.

- `ext_resource` con `path="res://..."` sin archivo destino: **0**.
- Rutas inline `path="res://..."` en nodos/propiedades sin archivo destino: **0**.
- Errores de lectura de `.tscn`: **0**.

**Evidencia de cobertura (escenas del proyecto, muestra con conteo de recursos):**

| Escena | `ext_resource` | refs `res://` | UID cabecera |
|---|---:|---:|---|
| `scenes/main.tscn` | 4 | 4 | `uid://c1234568aa0` |
| `scenes/main_island.tscn` | 19 | 19 | (sin uid) |
| `scenes/main_simple.tscn` | 3 | 3 | (sin uid) |
| `scenes/main_test.tscn` | 3 | 3 | (sin uid) |
| `scenes/main_test2.tscn` | 3 | 3 | (sin uid) |
| `scenes/player/Player.tscn` | 8 | 8 | (sin uid) |
| `scenes/CameraRig.tscn` | 2 | 2 | `uid://y7owcvev8t76` |
| `scenes/ui/hud.tscn` | 10 | 10 | `uid://hud_m53_screen` |
| `scenes/tests/test_m108.tscn` | 1 | 1 | `uid://bqv5xj7k2m3r` |
| `scenes/preview_particles.tscn` | 1 | 1 | `uid://c4ewhaonnk2g8` |
| `scenes/test_anillo_arena.tscn` | 1 | 1 | `uid://test_anillo_arena_m09` |

**Observación:** Muchas escenas del proyecto no declaran `uid="..."` en la cabecera `[gd_scene ...]` (p. ej. `scenes/player/Player.tscn:1`, `scenes/main_island.tscn:1`, `scenes/main_simple.tscn:1`, la mayoría de previews/terrenos/tests/fixtures). No es una ruta rota, pero implica dependencia de resolución por `res://` o de UIDs gestionados externamente; conviene validar con el editor de Godot si el flujo del proyecto lo requiere.

---

## 2) UIDs duplicados entre escenas

**Resultado:** No se encontraron UIDs duplicados entre archivos `.tscn` distintos.

- UIDs de escena detectados en cabeceras `[gd_scene ... uid="..."]`: 21.
- Casos donde el mismo UID aparece en más de un archivo de escena: **0**.

**Listado de UIDs de escena y archivo asociado (evidencia):**

| UID | Archivo(s) |
|---|---|
| `uid://0xyeci1tqebj` | `addons/gdUnit4/src/update/GdUnitUpdateNotify.tscn` |
| `uid://2eahgaw88y6q` | `addons/gdUnit4/src/update/GdUnitUpdate.tscn` |
| `uid://41l7a46fol5m` | `addons/gdUnit4/src/ui/settings/GdUnitSettingsTabHooks.tscn` |
| `uid://belidlfknh74r` | `addons/gdUnit4/src/core/runners/GdUnitTestRunner.tscn` |
| `uid://bjcc71p2h1trr` | `addons/gdUnit4/src/ui/menu/GdUnitInspectorContextMenu.tscn` |
| `uid://bqfpidewtpeg0` | `addons/gdUnit4/src/ui/parts/GdUnitInspectorTreeMainPanel.tscn` |
| `uid://bqv5xj7k2m3r` | `scenes/tests/test_m108.tscn` |
| `uid://c1234568aa0` | `scenes/main.tscn` |
| `uid://c22l4odk7qesc` | `addons/gdUnit4/src/ui/parts/GdUnitInspectorStatusBar.tscn` |
| `uid://c4ewhaonnk2g8` | `scenes/preview_particles.tscn` |
| `uid://cn5mp3tmi2gb1` | `addons/gdUnit4/src/network/GdUnitServer.tscn` |
| `uid://dga8nhaxnyr53` | `addons/gdUnit4/src/ui/parts/GdUnitReportPanel.tscn` |
| `uid://dm0wvfyeew7vd` | `addons/gdUnit4/src/ui/GdUnitConsole.tscn` |
| `uid://dte0m2endcgtu` | `addons/gdUnit4/src/ui/templates/GdUnitTestSuiteTemplatePanel.tscn` |
| `uid://dva3tonxsxrlk` | `addons/gdUnit4/src/ui/parts/GdUnitInspectorProgressBar.tscn` |
| `uid://dx7xy4dgi3wwb` | `addons/gdUnit4/src/ui/parts/GdUnitInspectorToolBar.tscn` |
| `uid://hud_m53_screen` | `scenes/ui/hud.tscn:1` |
| `uid://mpo5o6d4uybu` | `addons/gdUnit4/src/ui/GdUnitInspector.tscn` |
| `uid://pmnkxrhglak5` | `addons/gdUnit4/src/ui/settings/GdUnitInputCapture.tscn` |
| `uid://test_anillo_arena_m09` | `scenes/test_anillo_arena.tscn:1` |
| `uid://y7owcvev8t76` | `scenes/CameraRig.tscn:1` |

**Nota:** `uid://hud_m53_screen` y `uid://test_anillo_arena_m09` no siguen el formato alfanumérico típico generado por Godot, pero son únicos dentro del proyecto analizado. Requieren confirmación de validez/estabilidad en el editor.

---

## 3) Dependencias circulares entre escenas

**Resultado:** No se detectaron ciclos de dependencia entre escenas `.tscn`.

- Grafo analizado: instancias de `PackedScene` declaradas como `ext_resource type="PackedScene"` en `.tscn` y resueltas a archivos `.tscn` existentes.
- Aristas: **17**.
- Ciclos encontrados (DFS con normalización): **0**.

**Grafo de dependencias detectado (archivo:línea implícita en `ext_resource` de cada origen):**

| Origen | Destino |
|---|---|
| `addons/gdUnit4/src/ui/GdUnitInspector.tscn` | `addons/gdUnit4/src/network/GdUnitServer.tscn` |
| `addons/gdUnit4/src/ui/GdUnitInspector.tscn` | `addons/gdUnit4/src/ui/parts/GdUnitInspectorProgressBar.tscn` |
| `addons/gdUnit4/src/ui/GdUnitInspector.tscn` | `addons/gdUnit4/src/ui/parts/GdUnitInspectorStatusBar.tscn` |
| `addons/gdUnit4/src/ui/GdUnitInspector.tscn` | `addons/gdUnit4/src/ui/parts/GdUnitInspectorToolBar.tscn` |
| `addons/gdUnit4/src/ui/GdUnitInspector.tscn` | `addons/gdUnit4/src/ui/parts/GdUnitInspectorTreeMainPanel.tscn` |
| `addons/gdUnit4/src/ui/parts/GdUnitInspectorTreeMainPanel.tscn` | `addons/gdUnit4/src/ui/menu/GdUnitInspectorContextMenu.tscn` |
| `addons/gdUnit4/src/ui/parts/GdUnitInspectorTreeMainPanel.tscn` | `addons/gdUnit4/src/ui/parts/GdUnitReportPanel.tscn` |
| `addons/gdUnit4/src/ui/settings/GdUnitSettingsDialog.tscn` | `addons/gdUnit4/src/ui/settings/GdUnitInputCapture.tscn` |
| `addons/gdUnit4/src/ui/settings/GdUnitSettingsDialog.tscn` | `addons/gdUnit4/src/ui/settings/GdUnitSettingsTabHooks.tscn` |
| `addons/gdUnit4/src/ui/settings/GdUnitSettingsDialog.tscn` | `addons/gdUnit4/src/ui/templates/GdUnitTestSuiteTemplatePanel.tscn` |
| `addons/gdUnit4/src/ui/settings/GdUnitSettingsDialog.tscn` | `addons/gdUnit4/src/update/GdUnitUpdateNotify.tscn` |
| `addons/gdUnit4/src/update/GdUnitUpdateNotify.tscn` | `addons/gdUnit4/src/update/GdUnitUpdate.tscn` |
| `scenes/main.tscn` | `scenes/player/Player.tscn` |
| `scenes/main_island.tscn` | `scenes/player/Player.tscn` |
| `scenes/main_simple.tscn` | `scenes/player/Player.tscn` |
| `scenes/main_test.tscn` | `scenes/player/Player.tscn` |
| `scenes/main_test2.tscn` | `scenes/player/Player.tscn` |

**Interpretación:** El grafo del addon es un DAG de UI/update; las escenas principales comparten `Player.tscn` como hoja de composición sin referencias inversas.

---

## 4) Archivos `.tscn` con rutas rotas

**Resultado para `.tscn`:** No se encontraron archivos `.tscn` con rutas rotas (`res://` inexistentes) en recursos externos o propiedades `path=`.

**Hallazgos relacionados en `.gd` (contexto solicitado: referencias en `.tscn` y `.gd`):** se detectaron **173** ocurrencias de rutas `res://` que no resuelven a un archivo/carpeta existente en el proyecto (tras deduplicación por archivo/línea/ruta/tipo). Se clasifican así:

| Categoría | Cant. aprox. | Ejemplos (archivo:línea → ruta) | Riesgo |
|---|---:|---|---|
| Addon `gdUnit4` — documentación/ejemplos/snippets embebidos en comentarios o strings de API | ~41 | `addons/gdUnit4/src/GdUnitSceneRunner.gd:31` → `res://scenes/simple_scene.tscn`; `addons/gdUnit4/src/GdUnitTestSuite.gd:239` → `res://TestScene.tscn`; `.../GdUnitTestSuite.gd:263` → `res://foo/my_scne.tscn`; `addons/gdUnit4/src/core/templates/test_suite/GdUnitTestSuiteTemplate.gd:36` → `res://folder/my_class.gd` | Bajo (ejemplos); pueden generar ruido en validadores automáticos. |
| Addon `gdUnit4` — rutas dinámicas/placeholders o tokens mal parseados (backticks, BBCode, `%s`, `...`) | varios | `addons/gdUnit4/src/dotnet/GdUnit4CSharpApiLoader.gd:66` → `res://%s.csproj`; `addons/gdUnit4/src/ui/parts/GdUnitInspectorTreeMainPanel.gd:1115` → `res://%s.json`; `addons/gdUnit4/src/update/GdMarkDownReader.gd:13` → `res://addons/gdUnit4/src/update/assets/horizontal-line2.png[/img` | Bajo/medio (falsos positivos de parseo o recursos opcionales). |
| Addon `gdUnit4` — rutas de runtime/update opcional ausentes | varios | `addons/gdUnit4/src/update/GdUnitUpdate.gd:266` → `res://update.zip`; `addons/gdUnit4/src/update/GdUnitUpdateNotify.gd:166` → `res://addons/.gdunit_update/GdUnitUpdate.tscn`; `addons/gdUnit4/src/core/GdUnitRunnerConfig.gd:12` → `res://addons/gdUnit4/GdUnitRunner.cfg` | Medio según uso del updater/config. |
| Scripts/tests del proyecto — rutas intencionalmente inexistentes para pruebas negativas/fallback | ~50+ | `scripts/ci/test_gates_m118.gd:88` → `res://no/existe.json`; `scripts/core/test_infraestructura.gd:91` → `res://no_existe.tscn`; `scripts/crash/test_crash_m122_offline.gd:106` → `res://escena.tscn`; `scripts/localization/test_validador_po_m87.gd:176` → `res://locales/NO_EXISTE.po` | Bajo (intencional) si los tests esperan fallo controlado. |
| Scripts del proyecto — plantillas/placeholders en documentación o formato dinámico | varios | `scripts/data/item_database.gd:8` → `res://data/items/\``; `scripts/debug/debug_menu.gd:16` → ``res://` ``; `scripts/rendimiento/asset_profile.gd:124` → `res://assets/3d/%s/%s.glb`; `scripts/vegetacion/vegetation_spawner.gd:70` → `res://assets/3d/media/%s.glb` | Medio: validar que el formateo runtime siempre produzca rutas válidas. |
| Scripts del proyecto — referencias a assets/datos potencialmente pendientes o externos | varios | `scripts/ci/cicd_manager.gd:8` → `res://scripts/ci/escanear_assets.py`; `scripts/data/world_locations.gd:148` → `res://data/locations/RIZ/%s.tres`; `scripts/dialogos/test_validacion_grafo_m21.gd:77` → `res://data/dialogues/%s.json`; `scripts/arte2d/pack_atlas.gd:47` → `res://assets/2d/<atlas>.png\`` | A revisar por módulo (puede ser deuda de contenido/datos). |
| Tools del proyecto | varios | `tools/asset_pipeline/asset_memory_reporter_logic.gd:104` → `res://assets/final/_memory_report.md`; `tools/asset_pipeline/promote_asset_logic.gd:51` → `res://assets/final/_APROBADAS.md`; `tools/asset_pipeline/retire_asset_logic.gd:51` → `res://assets/archive/_RETIRADOS.md`; `tools/validate_dialogues.gd:6` → `res://tools/validation_result.txt` | Esperable si son salidas generadas; confirmar rutas de escritura. |

**Muestra representativa de hallazgos en `.gd` (archivo:línea, tipo, ruta):**
- `addons/gdUnit4/src/GdUnitSceneRunner.gd:31` — `res_path` — `res://scenes/simple_scene.tscn`
- `addons/gdUnit4/src/GdUnitTestSuite.gd:239` — `preload/load` — `res://TestScene.tscn`
- `addons/gdUnit4/src/core/GdUnitRunnerConfig.gd:12` — `res_path` — `res://addons/gdUnit4/GdUnitRunner.cfg`
- `addons/gdUnit4/src/update/GdUnitUpdate.gd:266` — `res_path` — `res://update.zip`
- `scripts/ci/cicd_manager.gd:8` — `res_path` — `res://scripts/ci/escanear_assets.py`
- `scripts/ci/test_gates_m118.gd:88` — `res_path` — `res://no/existe.json`
- `scripts/core/test_infraestructura.gd:91` — `res_path` — `res://no_existe.tscn`
- `scripts/crash/test_crash_m122_offline.gd:106` — `res_path` — `res://escena.tscn`
- `scripts/data/item_database.gd:8` — `res_path` — ``res://data/items/` ``
- `scripts/data/world_locations.gd:148` — `res_path` — `res://data/locations/RIZ/%s.tres`
- `scripts/dialogos/test_validacion_grafo_m21.gd:77` — `res_path` — `res://data/dialogues/%s.json`
- `scripts/rendimiento/memoria/sesion_m62_baselines.gd:58` — `res_path` — `res://scenes/main_menu.tscn`
- `scripts/vegetacion/vegetation_spawner.gd:70` — `res_path` — `res://assets/3d/media/%s.glb`
- `tests/run_tests.gd:55` — `res_path` — `res://tests/test_debug_menu.gd,` (posible token con coma capturado por regex)
- `tools/validate_dialogues.gd:6` — `res_path` — `res://tools/validation_result.txt`

> **Nota metodológica:** el detector en `.gd` captura literales `res://...` y argumentos de `preload/load`; puede incluir placeholders (`%s`, `<atlas>`, `**`), rutas de salida esperadas o fragmentos con caracteres de formato/BBCode. Cada hallazgo debe triagarse antes de considerarlo bug.

---

## 5) Dos acciones de verificación sugeridas

1. **Validación dentro del editor Godot (canónica) con informe de dependencias y UIDs:** abrir `game/isla-ancestral/project.godot` en Godot 4.x, ejecutar "Reimportar" / "Scan" del filesystem y revisar el panel *Debugger → Errors* y *Output* al cargar escenas clave (`scenes/main.tscn`, `scenes/main_island.tscn`, `scenes/player/Player.tscn`, `scenes/ui/hud.tscn`). Complementar con una búsqueda en editor de referencias rotas y verificar que UIDs no estándar (`uid://hud_m53_screen`, `uid://test_anillo_arena_m09`) y escenas sin `uid` en cabecera no generen advertencias en el flujo del proyecto.
2. **Triaging automatizado de referencias `res://` en `.gd` con filtro por contexto:** ejecutar un script/CI que clasifique cada coincidencia en *real rota*, *placeholder dinámico*, *ruta de salida*, *test negativo* o *ejemplo de addon* (p. ej. excluir `addons/gdUnit4/**` de severidad alta, ignorar patrones `%s`/`<...>`/`**`, y validar en runtime las plantillas usadas por `data/items`, `data/dialogues`, `assets/3d/media/%s.glb`, etc.). Para los casos de proyecto marcados como deuda de contenido (`scripts/ci/cicd_manager.gd:8`, `scripts/data/world_locations.gd:148`, `scripts/rendimiento/memoria/sesion_m62_baselines.gd:58`, `tests/run_tests.gd:55`), confirmar existencia o corregir/eliminar la referencia.

---

## Conclusión final

En el análisis estático del proyecto Godot `game/isla-ancestral/` (69 `.tscn`, 1590 `.gd`) **no se detectaron problemas estructurales críticos en escenas**: no hay referencias rotas en `.tscn`, no hay UIDs de escena duplicados entre archivos distintos y no hay dependencias circulares entre escenas (17 aristas, DAG coherente con `Player.tscn` como dependencia compartida).

Los hallazgos relevantes se concentran en **173 referencias `res://` no resolubles en scripts `.gd`**, en su mayoría atribuibles a ejemplos/documentación del addon `gdUnit4`, pruebas negativas intencionales y plantillas/rutas dinámicas; aun así, existe un subconjunto de referencias de proyecto y tools que amerita triage manual/CI para descartar deuda real de assets, datos o rutas de salida. Como mejora de higiene, se recomienda normalizar/confirmar los UIDs no estándar y la ausencia de UID en cabeceras de muchas escenas mediante verificación en el editor.
