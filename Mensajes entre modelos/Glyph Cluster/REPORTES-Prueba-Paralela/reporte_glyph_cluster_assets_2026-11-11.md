# Reporte de assets, UIDs y dependencias — Glyph Cluster

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (CLI)  
**Fecha:** 2026-11-11  
**Alcance:** game/isla-ancestral/ (análisis estático de .tscn, .gd y .uid; se excluyó .godot/ por ser caché generada)

## 1. Metodología y cobertura

- Inventario analizado (excluyendo .godot/): **69** archivos .tscn, **1590** archivos .gd, **1621** archivos .uid, **7815** archivos totales conocidos en el árbol del proyecto.
- .tscn: se parsearon cabeceras uid="..." y bloques [ext_resource ...] (atributos path, uid, 	ype) para detectar rutas 
es:// inexistentes, formato de UID y dependencias de instanciado entre escenas (path terminado en .tscn).
- .gd: se buscaron literales 
es://... y uid://... para detectar rutas ausentes y UIDs mal formados (análisis textual; no resuelve rutas construidas en runtime).
- UIDs: se recolectaron declaraciones en cabeceras .tscn, sidecars .uid y literales en código; se compararon por recurso base para detectar duplicados.
- Dependencias circulares: grafo dirigido de escenas (.tscn → .tscn instanciadas por ext_resource) con búsqueda de ciclos por DFS.

## 2. Hallazgos

### 2.1 Archivos .tscn con referencias a recursos que no existen

**Resultado:** **0** referencias ext_resource con path="res://..." inexistente en los **69** archivos .tscn analizados.

No se detectaron recursos externos faltantes declarados en escenas del proyecto (fuera de .godot/).

### 2.2 UIDs duplicados o mal formados

**UIDs duplicados (mismo UID asignado a distintos recursos base):** **0**.

**UIDs mal formados detectados:** **1** coincidencia textual, clasificada como **falso positivo de recurso**:

| Archivo | Línea | UID detectado | Contexto | Clasificación |
|---|---:|---|---|---|
| ddons/gdUnit4/src/update/GdUnitUpdate.gd | 143 | uid://[^\ (fragmento) | 
egex.compile("(\\[ext_resource[^\\]]*?)\\s+uid=\\"uid://[^\\"]*\\"") | Patrón RegEx dentro de un literal de cadena usado para limpiar UIDs en archivos; **no** es una referencia UID de recurso ni un UID declarado. |

**Conclusión parcial:** no se hallaron UIDs de recurso mal formados ni duplicados en el contenido del juego analizado. El único caso proviene de tooling de terceros (gdUnit4) y corresponde a una expresión regular.

### 2.3 Dependencias circulares entre escenas

**Resultado:** **0** ciclos detectados.

- Grafo evaluado: instancias de escenas declaradas como ext_resource .tscn dentro de archivos .tscn.
- No se encontraron rutas de dependencia circular en ese grafo.
- **Nota de alcance:** no se modelaron como aristas de escena los load()/preload() de .tscn realizados desde .gd en runtime; si existieran ciclos mediados por scripts, requerirían un análisis adicional de flujo/carga dinámica.

### 2.4 Referencias 
es:// en .gd a rutas no resueltas (rutas rotas potenciales)

Se detectaron **322** literales 
es:// en .gd cuya ruta no existe como archivo/directorio conocido en el árbol (excl. .godot/): **283** en código/herramientas del proyecto y **39** en ddons/gdUnit4 (terceros; incluyen ejemplos de documentación, rutas de configuración/actualización y fixtures del addon).

#### 2.4.1 Proyecto — clasificación (283)

| Categoría | Cantidad | Criterio / observación |
|---|---:|---|
| Directorio o ruta sin extensión | 206 | Usos tipo DirAccess.open(...), escaneo de carpetas o constantes de directorio; requieren verificación de existencia del directorio en runtime/repositorio según caso. |
| Test / intencional probable | 36 | Archivos o literales con indicadores de prueba/negativo (	est, 
o_existe, inexistente, zzz, corrupto, rutas deliberadamente inválidas). |
| Dinámico / plantilla | 28 | Rutas con placeholders (%s, %d, etc.) no resolubles estáticamente. |
| Revisar manualmente | 13 | Rutas concretas ausentes que pueden ser salidas esperadas, configuración faltante o referencias obsoletas. |

#### 2.4.2 Proyecto — referencias concretas a revisar (13)

| Archivo | Línea | Ruta 
es:// | Observación |
|---|---:|---|---|
| scripts/combat/combat_island_system.gd | 48 | 
es://data/combat/zone_catalog.tres | Recurso de catálogo de zonas no encontrado; posible dependencia de datos faltante o ruta desactualizada. |
| scripts/legal/audio_legal_manager.gd | 200 | 
es://build/AUDIO_CREDITS.txt | Ruta bajo uild/ ausente en repo; probablemente artefacto de salida generado en build. |
| scripts/legal/audio_legal_manager.gd | 202 | 
es://build/AUDIO_LICENSE_REPORT.txt | Igual que anterior (salida de reporte). |
| scripts/rendimiento/asset_profile.gd | 113 | 
es://assets/3d/alta/foo.glb | Aparece en comentario de ejemplo (##), no en carga real. |
| scripts/rendimiento/memoria/sesion_m62_baselines.gd | 58 | 
es://scenes/main_menu.tscn | Candidato de escena de menú no presente en scenes/. |
| scripts/rendimiento/memoria/sesion_m62_baselines.gd | 59 | 
es://scenes/ui/main_menu.tscn | Candidato de escena de menú no presente. |
| scripts/rendimiento/memoria/sesion_m62_baselines.gd | 60 | 
es://scenes/ui/menu.tscn | Candidato de escena de menú no presente. |
| scripts/rendimiento/memoria/sesion_m62_baselines.gd | 61 | 
es://scenes/menu.tscn | Candidato de escena de menú no presente. |
| scripts/stress/stress_comparator.gd | 17 | 
es://scripts/stress/perf_base.json | Baseline de rendimiento no encontrado; puede requerir generación inicial o ruta configurable. |
| 	ools/validate_dialogues.gd | 6 | 
es://tools/validation_result.txt | Ruta de salida de validación (archivo generado). |
| 	ools/asset_pipeline/asset_memory_reporter_logic.gd | 104 | 
es://assets/final/_memory_report.md | Ruta de reporte generado por pipeline. |
| 	ools/asset_pipeline/promote_asset_logic.gd | 51 | 
es://assets/final/_APROBADAS.md | Índice/registro generado por pipeline. |
| 	ools/asset_pipeline/retire_asset_logic.gd | 51 | 
es://assets/archive/_RETIRADOS.md | Registro generado por pipeline. |

#### 2.4.3 Proyecto — ejemplos representativos por categoría

**Dinámico/plantilla (28, muestra):**
- scripts/backup/backup_manager.gd:105 — 
es://%s
- scripts/construccion/test_construccion_iter2.gd:156 — 
es://data/items/%s.tres
- scripts/data/world_locations.gd:148 — 
es://data/locations/RIZ/%s.tres
- scripts/dialogos/test_validacion_grafo_m21.gd:77 — 
es://data/dialogues/%s.json
- scripts/fauna/cangrejo_npc.gd:62, gaviota_npc.gd:117, jabali_npc.gd:86, 	ortuga_npc.gd:83 — 
es://assets/3d/%s/...glb
- scripts/rendimiento/asset_profile.gd:124 — 
es://assets/3d/%s/%s.glb
- scripts/terrenos/terrain_footprints.gd:32, 	errain_particles.gd:33 — 
es://scenes/terrenos/...%s.tscn

**Test/intencional probable (36, incluye rutas deliberadamente inválidas):** concentrado en scripts de prueba/validación y casos negativos, p. ej. scripts/ci/test_gates_m118.gd:88 (
es://no/existe.json), scripts/clock/caso_reloj_tests.gd:218 (
es://data/ui/inexistente_f107.tres), scripts/construccion/test_construccion_iter2.gd:205 (
es://ruta/que/no/existe), scripts/crash/test_crash_m122_offline.gd (escenas ficticias 
es://a.tscn, 
es://b.tscn, etc.), scripts/validadores/test_validador_autoloads.gd:149 (
es://no_existe_project.godot), entre otros.

**Directorios/sin extensión (206):** p. ej. scripts/animacion/validacion/validate_animation_cli.gd:22 (
es://scripts/animacion/libraries), scripts/balance/balance_service.gd:14 (
es://data/balance/), scripts/construccion/build_manager.gd:37 (
es://data/construccion/piezas), scripts/data/item_database.gd:11,44,45 (
es://data/items/, 
es://data, 
es://data/items), scripts/dialogos/dialogue_manager.gd:22 (
es://data/dialogues/), scripts/fonts/test_fuentes_optimizadas_m88.gd:26,27 (
es://assets/fonts, 
es://locales), y múltiples rutas de módulos/sistemas bajo 
es://scripts/... usadas como base de escaneo.

#### 2.4.4 ddons/gdUnit4 (terceros, 39)

Referencias no resueltas principalmente en documentación de API, configuración por defecto, updater y herramientas de reporte del addon (p. ej. 
es://scenes/simple_scene.tscn, 
es://addons/gdUnit4/GdUnitRunner.cfg, 
es://gdUnit4-examples/, 
es://reports, rutas temporales de update). No se consideran defectos del juego, pero conviene excluir ddons/ de validadores propios para reducir ruido.

## 3. Mejoras sugeridas

1. **Validador automático de integridad de recursos (CI/pre-commit y modo tool):** incorporar un script (GDScript @tool o Python) en scripts/validadores/ o en el pipeline existente que verifique en cada cambio: (a) existencia de ext_resource.path en .tscn, (b) unicidad y formato uid://... de UIDs declarados/usados, (c) literales 
es:// en .gd resolubles con **lista blanca** para patrones dinámicos (%s), rutas de pruebas negativas, directorios intencionales y archivos de salida (uild/, reportes), y (d) ausencia de ciclos .tscn → .tscn. Ejecutarlo en CI y como chequeo local antes de integrar; excluir ddons/ de terceros o validarlos por separado.

2. **Centralizar y tipificar rutas críticas + separar salidas de fuentes:** reducir drift y falsos rotos definiendo un registro único (autoload/constantes o Resource de configuración) para escenas de menú/baselines y catálogos de datos (ej. revisar scripts/combat/combat_island_system.gd:48 → zone_catalog.tres, y los candidatos de menú en scripts/rendimiento/memoria/sesion_m62_baselines.gd:58-61 / scripts/stress/stress_comparator.gd:17). Para artefactos generados (uild/, _APROBADAS.md, _RETIRADOS.md, _memory_report.md, alidation_result.txt), usar rutas de salida explícitas (p. ej. user://, carpeta configurable o creación previa con DirAccess.make_dir_recursive_absolute) y documentarlas como "outputs" para que el validador no las marque como recursos fuente faltantes.

## 4. Conclusión final

- **.tscn y recursos externos:** no se detectaron referencias ext_resource rotas en las 69 escenas analizadas.
- **UIDs:** sin duplicados entre recursos distintos y sin UIDs de recurso mal formados en el proyecto; 1 detección textual en gdUnit4 corresponde a una regex, no a un UID real.
- **Ciclos de escenas:** no se observaron dependencias circulares por instanciado .tscn.
- **Rutas 
es:// en .gd:** existen 283 referencias no resueltas en el proyecto, mayoritariamente explicables (directorios, tests intencionales, plantillas dinámicas y salidas generadas), pero hay **casos concretos que merecen revisión**: 
es://data/combat/zone_catalog.tres ausente, baseline 
es://scripts/stress/perf_base.json ausente y candidatos de escenas de menú inexistentes en sesion_m62_baselines.gd; el resto de los 13 "manuales" son sobre todo rutas de salida/comentarios.
- **Estado general:** la integridad estructural de escenas y UIDs es buena según el análisis estático; el principal riesgo operativo está en literales de ruta en scripts (datos/escenas esperadas y convenciones de artefactos) que se beneficiarían de validación automatizada y centralización.
