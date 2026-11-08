# Reporte de análisis de recursos .tres — game/isla-ancestral

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08 08:30

## Resumen ejecutivo

Se analizaron **479 archivos `.tres`** dentro de `game/isla-ancestral/`. De ellos, 468 (97,7%) referencian al menos un recurso externo (`ext_resource`). El análisis automatizado no encontró rutas rotas a recursos, ni referencias a scripts `.gd` inexistentes, ni referencias a escenas `.tscn`. Se detectó **1 grupo de duplicados exactos** (2 archivos idénticos) y **3 candidatos a recursos huérfanos** fuera de las carpetas de carga dinámica. Los 442 "huérfanos" reportados por la heurística textual son en su mayoría falsos positivos, ya que los recursos en `data/`, `resources/terrain/` y `scripts/eventos/data/` se cargan dinámicamente mediante `DirAccess.open` en el código.

## Metodología

- Recorrido recursivo de `game/isla-ancestral/**/*.tres` (479 archivos).
- Parseo de cada archivo buscando bloques `[ext_resource ...]` y rutas `res://` embebidas.
- Verificación de existencia en disco de cada `path="res://..."` y de cada `uid="uid://..."` (mapeo vía archivos `.uid` y encabezados de `.tres`).
- Detección de duplicados por hash SHA-256 del contenido completo.
- Detección de huérfanos por ausencia de la ruta `res://...tres` en cualquier archivo del proyecto (`.gd`, `.tscn`, `.tres`, `.cfg`, `.json`, `.txt`, `.md`), con revisión manual de los directorios de carga dinámica.
- Exclusión de `Obsoletos/` y `DOCUMENTACION/` del alcance de recursos de runtime.

## (1) Archivos .tres con rutas rotas a recursos

**Resultado: 0 hallazgos.**

Se verificaron 836 referencias externas (536 a scripts `.gd` + 300 a texturas `CompressedTexture2D`) distribuidas en 468 archivos. Todas las rutas `res://` y todos los `uid://` resuelven a archivos existentes en disco.

Ejemplo de verificación (sin roturas):
- `game/isla-ancestral/data/amistad/amistad_config.tres:3` → `res://scripts/friendship/amistad_config.gd` (existe).
- `game/isla-ancestral/data/construccion/piezas/alfombra.tres:3` → `res://scripts/construccion/placement_rule.gd` (existe).

No se detectaron archivos `.tres` que referencien escenas (`.tscn`): 0 referencias a `PackedScene`/`.tscn` entre los `ext_resource`.

## (2) Recursos .tres que referencian scripts .gd inexistentes

**Resultado: 0 hallazgos.**

Los 536 `ext_resource` de tipo `Script` apuntan a archivos `.gd` existentes. Lista representativa de scripts referenciados (todos presentes):
- `res://scripts/islas/island_definition.gd` (referenciado por `data/islas/definiciones/*.tres` y `probe_m27/aurora.tres`).
- `res://scripts/construccion/placement_rule.gd` (referenciado por 50+ piezas de construcción).
- `res://scripts/terrain/terrain_data.gd` (referenciado por `resources/terrain/*.tres`).
- `res://scripts/eventos/...` (referenciado por `scripts/eventos/data/**`).

## (3) Recursos .tres duplicados con el mismo contenido

**Resultado: 1 grupo de duplicados exactos (2 archivos).**

| # | Archivo A | Archivo B | Coincidencia |
|---|-----------|-----------|--------------|
| 1 | `game/isla-ancestral/Godot/app_userdata/isla-ancestral/probe_m27/aurora.tres` | `game/isla-ancestral/data/islas/definiciones/aurora.tres` | Hash SHA-256 idéntico (contenido byte-a-byte, incluido `uid` y `ext_resource`) |

Detalle del duplicado:
- `probe_m27/aurora.tres:1` → `[gd_resource type="Resource" script_class="IslandDefinition" format=3]`
- `probe_m27/aurora.tres:3` → `[ext_resource type="Script" path="res://scripts/islas/island_definition.gd" id="1_76itp"]`
- `probe_m27/aurora.tres:6` → `script = ExtResource("1_76itp")`
- `probe_m27/aurora.tres:7` → `id = &"aurora"`

El archivo en `probe_m27/` es una copia generada durante una prueba de integración (M27) y no debería versionarse en runtime; debería eliminarse o excluirse del repositorio (está bajo `Godot/app_userdata/`, que típicamente es ignorado por `.gitignore`).

## (4) Recursos .tres huérfanos sin uso

**Resultado: 3 candidatos reales (fuera de carpetas de carga dinámica) + 442 falsos positivos por carga dinámica.**

La heurística textual reportó 442 `.tres` sin referencia directa en el código. Sin embargo, la revisión cruzada con `DirAccess.open` en el código GDScript confirma que los recursos en estas carpetas se cargan por directorio y **no** son huérfanos:
- `data/**` (items, villagers, construccion, enchantments, economia, locations, npc_visuals, islas, light, time, ui, tutorial, transporte, licencias, legal, interacciones, analytics, amistad, clima, ia, logging, equipment) → cargados por `DirAccess.open("res://data/...")`.
- `resources/terrain/*.tres` → `scripts/terrain/terrain_data_provider.gd:11-20` (`DirAccess.open("res://resources/terrain/")`).
- `scripts/eventos/data/**` → `scripts/eventos/...` (`DirAccess.open("res://scripts/eventos/data")`).

Los **3 candidatos reales** a huérfanos (no aparecen referenciados ni se cargan por directorio del proyecto) son:

| # | Archivo | Líneas representativas | Motivo |
|---|---------|------------------------|--------|
| 1 | `game/isla-ancestral/Godot/app_userdata/isla-ancestral/probe_m27/aurora.tres` | `1: [gd_resource type="Resource" script_class="IslandDefinition" format=3]` · `3: [ext_resource type="Script" path="res://scripts/islas/island_definition.gd" id="1_76itp"]` | Copia de prueba (duplicado exacto de `data/islas/definiciones/aurora.tres`). |
| 2 | `game/isla-ancestral/Godot/app_userdata/isla-ancestral/version.tres` | `1: [updates]` · `3: version_juego="1.0.0"` | Archivo de configuración de actualizaciones (no es recurso Godot estándar; extensión `.tres` incorrecta). |
| 3 | `game/isla-ancestral/Godot/editor_settings-4.7.tres` | `1: [gd_resource type="EditorSettings" format=3]` | Configuración del editor Godot (generada localmente, no debe versionarse). |

Los tres residen bajo `Godot/` (configuración/runtime del editor) y deberían estar excluidos del control de versiones.

## (5) Sugerencias de verificación (2 acciones)

1. **Validación automática de referencias `res://` en el CI/headless:** crear un test GDScript (o extender `scripts/validadores/`) que recorra todos los `.tscn`/`.tres` del proyecto, parsee `ext_resource` y `sub_resource`, y falle si alguna ruta `res://` no existe en disco o si algún `uid://` no resuelve. Ejecutarlo en `run_tests.gd` antes de cada build para detectar regresiones de rutas rotas.

2. **Auditoría de huérfanos y duplicados en `data/`:** implementar un script (Python o GDScript) que compare los archivos `.tres` de cada carpeta de datos contra el conjunto de archivos realmente cargados por los `DirAccess.open` correspondientes; reportar (a) archivos no cargados por ningún loader, (b) duplicados por hash, y (c) archivos bajo `Godot/app_userdata/` o `Godot/*.tres` que se hayan colado al repositorio. Agregar la carpeta `Godot/` al `.gitignore` si aún no lo está.

## Conclusión final

Los 479 recursos `.tres` del proyecto `game/isla-ancestral/` están **íntegros en cuanto a referencias**: no hay rutas rotas ni scripts inexistentes. El único problema real de higiene es la presencia de 3 archivos generados por el editor/runtime bajo `Godot/` (uno de ellos un duplicado exacto de `data/islas/definiciones/aurora.tres`). Se recomienda excluir `Godot/` del repositorio y automatizar la validación de referencias en el pipeline de tests para evitar regresiones futuras. No se requiere acción correctiva sobre los recursos de datos del juego.
PYEOF