# Reporte: Verificación de assets, .import y .tscn rotos

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Proyecto:** game/isla-ancestral (Godot 4.x)
**Alcance:** archivos `.import`, escenas `.tscn`, recursos `.tres` y scripts `.gd` que referencian assets (texturas, modelos, audio).

---

## 1. Resumen ejecutivo

- Total de archivos `.import` analizados: **833**.
- Total de escenas `.tscn` analizadas: **69**.
- Total de recursos `.tres` analizados: **479**.
- Total de scripts `.gd` analizados: **1586**.
- **No se encontraron referencias rotas a assets reales del juego** en `.import`, `.tscn` ni `.tres`.
- Se detectaron **8 referencias a `.glb` inexistentes**, todas en scripts de **test** (`test_construccion_iter3.gd`, `asset_profile.gd`, `test_asset_profile_m166.gd`) que las usan intencionalmente para probar manejo de errores de carga.
- Se detectaron **7 assets sin `.import`**, todos irrelevantes para el juego (6 capturas `.webp` de `.gdskills/vision` y 1 `logo.png` del addon `gdUnit4`).
- Verificación de casing (case-sensitive): **0 issues**.

---

## 2. Análisis (1) — Archivos `.import` que apuntan a archivos inexistentes

### 2.1 source_file

Se extrajo el campo `source_file="res://..."` de cada `.import` y se verificó su existencia en disco.

- Archivos `.import` analizados: 833.
- Con `source_file` faltante: **0**.
- Con `source_file` presente pero archivo inexistente: **0**.

### 2.2 dest_files (archivo importado en `.godot/imported/`)

- Archivos `.import` con `dest_files` parseado: 833.
- `dest_files` faltantes: **0**.

### 2.3 Nombre desincronizado (`.import` vs source)

- `.import` cuyo nombre no coincide con `source_file + ".import"`: **0**.

### 2.4 Assets sin `.import`

Se buscó assets (`.png/.jpg/.jpeg/.glb/.gltf/.ogg/.wav/.mp3/.webp`) sin su correspondiente `.import`:

- Assets totales (excluyendo `.godot/`): 810.
- Sin `.import`: **7**.
  - `\.gdskills\vision\*.webp` (6 archivos) — capturas de debug del agente, no assets del juego.
  - `\addons\gdUnit4\src\reporters\html\template\css\logo.png` (1) — addon de terceros.

**Conclusión (1):** No hay `.import` rotos ni huérfanos que afecten assets del juego.

---

## 3. Análisis (2) — Escenas `.tscn` con rutas de textura/modelo rotas

Se extrajeron todas las rutas `res://...` de los 69 `.tscn` (953 `ext_resource` con `path=`) y se verificó existencia (incluyendo casing exacto).

- Referencias directas a assets en `.tscn`: **2**.
  - `addons/gdUnit4/src/ui/settings/GdUnitSettingsDialog.tscn` L4 → `res://addons/gdUnit4/src/ui/settings/logo.png` (existe).
  - `scenes/player/Player.tscn` L4 → `res://assets/3d/media/45-Arte3D_jugador_voxel.glb` (existe).
- Rutas rotas en `.tscn`: **0**.

**Conclusión (2):** Ninguna escena `.tscn` referencia un asset inexistente.

---

## 4. Análisis (3) — Assets `.png/.jpg/.glb/.ogg` faltantes referenciados

Se analizaron `.tscn`, `.tres` y `.gd` buscando referencias literales a assets con extensión `.png/.jpg/.jpeg/.glb/.gltf/.ogg/.wav/.mp3/.webp` (excluyendo placeholders `%s`, `{...}`, `<...>`, globs `*`, y rutas de addons/tests).

### 4.1 En `.tres`

- Archivos `.tres`: 479.
- Referencias literales a assets: 340.
- Faltantes: **0**.

### 4.2 En `.gd`

- Archivos `.gd`: 1586.
- Referencias literales a assets (excl. addons/tests): filtradas.
- Faltantes detectados: **8**, todos `.glb`, todos en scripts de test:

| Archivo | Línea aprox. (ref) | Ruta referenciada |
|---|---|---|
| `scripts/construccion/test_construccion_iter3.gd` | — | `res://no/existe_zzz.glb` |
| `scripts/construccion/test_construccion_iter3.gd` | — | `res://assets/3d/...glb` |
| `scripts/construccion/test_construccion_iter3.gd` | — | `res://test/malla.glb` |
| `scripts/construccion/test_construccion_iter3.gd` | — | `res://a/b.glb` |
| `scripts/rendimiento/asset_profile.gd` | — | `res://assets/3d/alta/foo.glb` |
| `tests/test_asset_profile_m166.gd` | — | `res://assets/3d/alta/x.glb` |
| `tests/test_asset_profile_m166.gd` | — | `res://assets/3d/alta/foo_bar.glb` |
| `tests/test_asset_profile_m166.gd` | — | `res://assets/3d/media/y.glb` |

Estas rutas son **intencionales** (fixtures de prueba para validar manejo de errores de carga/ausencia). No son assets del juego faltantes.

### 4.3 Casing (case-sensitive)

- Referencias analizadas en `.tscn` + `.tres`: 341.
- Issues de casing: **0**.

**Conclusión (3):** No hay assets `.png/.jpg/.glb/.ogg` del juego faltantes. Las únicas referencias faltantes son fixtures de test intencionales.

---

## 5. Sugerencias de verificación (2 acciones)

1. **Ejecutar el proyecto en Godot y revisar la consola de debug** (`godot_run_project` + `godot_get_debug_output`): Godot reporta en runtime errores como `Failed to load resource` o `Resource file not found` aunque el archivo exista en disco, especialmente por imports desactualizados o UIDs rotos. Validar que no aparezcan errores al cargar escenas principales (Player, islas, UI).
2. **Regenerar/validar UIDs e imports** (`godot_update_project_uids` sobre `game/isla-ancestral`) y re-ejecutar `godot_get_project_info` para confirmar que todos los recursos se resuelven; luego abrir una escena clave (ej. `scenes/player/Player.tscn`) en el editor y verificar que no haya iconos de "missing resource" en el inspector.

---

## 6. Conclusión final

El proyecto `game/isla-ancestral` está **limpio respecto a referencias rotas de assets**: los 833 `.import` apuntan a archivos existentes (source y dest), las 69 `.tscn` no tienen rutas rotas, los 479 `.tres` resuelven sus 340 referencias a assets, y no hay problemas de casing. Las 8 referencias faltantes a `.glb` son fixtures intencionales de scripts de test. Los 7 assets sin `.import` son capturas de debug y un asset de addon de terceros, sin impacto en el juego. Se recomienda validar en runtime con el MCP de Godot para descartar errores de carga no detectables por análisis estático.
