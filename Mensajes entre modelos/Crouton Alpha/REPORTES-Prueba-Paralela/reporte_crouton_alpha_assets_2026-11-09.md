# Reporte de auditoría de assets — Crouton Alpha

**Modelo:** Crouton Alpha
**Plataforma:** Kilo / OpenCode API
**Fecha:** 2026-11-09
**Alcance:** `game/isla-ancestral/` — archivos `.import` y `.gd` que referencien assets de audio (`.ogg`/`.wav`/`.mp3`) y texturas (`.png`/`.jpg`/`.webp`/`.svg`), más escenas `.tscn`.

## Resumen ejecutivo

Se auditaron **848 archivos `.import`**, **1590 archivos `.gd`** y **69 archivos `.tscn`** dentro de `game/isla-ancestral/`. Resultado: **0 audios en disco** (0 `.ogg`/`.wav`/`.mp3`), **0 `.import` de audio**, **0 referencias de audio en escenas**, **0 referencias de audio funcionales en código** (las 17 menciones son comentarios, fixtures de tests y un catálogo de extensiones); **1 sola textura referenciada desde escenas** (`logo.png` de `gdUnit4`, addon de terceros, válida); **0 `.import` huérfanos** (848/848 con fuente existente); **0 `.jpg`/`.jpeg` en disco**; las 300 texturas del juego (`assets/2d/items_m159/`) son PNG de **48×48** con `.import` sin límites ni compresión configurada. **No hay rutas rotas**: hay ausencia de contenido de audio y de fotografía, no referencias rotas.

## Metodología

- Raíz auditada: `game/isla-ancestral/` (mapeo `res://` → `game/isla-ancestral/`).
- `.import`: para cada `X.import` se verificó la existencia del fuente `X` junto al `.import`, y se leyeron `size_limit`, `compress/mode`, `mipmaps/generate` y `uid` en los 362 imports de imagen (`.png`/`.svg`).
- `.tscn`: extracción de `res://...` con regex de extensiones `.png|.jpg|.jpeg|.webp|.svg|.ogg|.wav|.mp3` y verificación de existencia en disco. Búsqueda adicional de **todas** las `res://` para contexto.
- `.gd`: búsqueda de `load(`/`preload(` con ruta literal de asset, y de menciones sueltas `.(ogg|wav|mp3)` en código.
- Dimensiones reales: cabecera IHDR de los 347 PNG en disco (347/347 legibles) y cabeceras VP8/VP8L/VP8X de los 6 WEBP.

## (1) ¿Hay assets de audio o texturas referenciados en escenas `.tscn` que no existen en disco?

**No.** De 69 `.tscn`, **1 solo** referencia textura/audio:

- `game/isla-ancestral/addons/gdUnit4/src/ui/settings/GdUnitSettingsDialog.tscn:4` —
  `[ext_resource type="Texture2D" path="res://addons/gdUnit4/src/ui/settings/logo.png" id="3_isfyl"]` → existe `game/isla-ancestral/addons/gdUnit4/src/ui/settings/logo.png` (49 775 bytes). Es de `gdUnit4`, no del juego.

**60 escenas del juego** (ej. `scenes/main_island.tscn`, `scenes/player/Player.tscn`) referencian **0 texturas y 0 audios**; sus referencias `res://` son scripts `.gd`, escenas `.tscn` y 1 `.glb`. El resto de las 102 `res://` únicas de todo el corpus son `.gd` (85), `.tscn` (13), `.tres` (2), 1 `.png` (el de arriba) y 1 `.glb` — todas existentes.

**Audio en escenas: 0 referencias.** Coherente con el disco: hay **0 archivos `.ogg`/`.wav`/`.mp3` en todo el árbol** (búsqueda recursiva completa, 0 resultados) y **0 `.import` de audio** (distribución: `.glb` 472, `.png` 346, `.svg` 16, `.blend` 10, `.ttf` 4).

## (2) ¿Hay archivos `.import` con rutas rotas o incompletas?

**No.** 848 `.import`, **0 huérfanos**: cada `X.import` tiene su fuente `X` junto a él (848/848). Los 362 imports de imagen (346 `.png` + 16 `.svg`) tienen `uid="uid://..."` válido (362/362) y su `source_file="res://..."` apunta a un `res://` existente.

Ejemplo sano — `game/isla-ancestral/icon.svg.import:1-11`:

```
[remap]
importer="texture"
type="CompressedTexture2D"
uid="uid://cuxfbc6lyj442"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
...
[deps]
source_file="res://icon.svg"
dest_files=["res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"]
```

**Incompletos (sin configuración):** los 362 imports de imagen comparten la misma configuración por defecto de Godot, sin adaptar:

| Parámetro | Valor en los 362 imports | Evaluación |
|---|---|---|
| `process/size_limit` | `0` (sin límite) | Sin compresión por tamaño; correcto para íconos 48×48, pero es "sin configurar", no "configurado" |
| `compress/mode` | `0` (lossless) en 362/362 | Correcto para íconos planos; se deja así a propósito |
| `mipmaps/generate` | `false` en 362/362 | Correcto para UI 2D; incorrecto si alguna textura fuese para 3D |

Ningún `.import` apunta a un archivo ausente; el único "incompleto" es la ausencia de ajustes por tipo de uso (todo por defecto).

## (3) ¿Hay texturas con resolución inconsistente?

**Sí, dos grupos a vigilar (nada de 4096×4096 para íconos):**

**a) Íconos del juego — consistentes.** Los 300 PNG de `game/isla-ancestral/assets/2d/items_m159/` son **48×48** (verificado por IHDR: distribución de ancho `48: 300`), pesos 456–490 bytes. Cohesivos, sin sobre-resolución. No hay caso "4096×4096 para un ícono de 32×32".

**b) Entorno del proyecto — heterogéneo (archivos que no son assets del juego):**

| Tamaño real | Cantidad | Ruta |
|---|---|---|
| 1920×1080 (1 349 905 bytes) | 1 | `game/isla-ancestral/tools/mcp/godot-mcp/capturas/31-Ciclo-Dia-Noche/cap_31_2026-09-19_06-26-00_profunda_0300.png` — captura de pantalla, no asset |
| 1200×? / 720×144 / 656×144–208 | 19 | `game/isla-ancestral/tools/mcp/godot-mcp/capturas/159-Catalogo-De-Objetos/cap_159_tanda*_contact_sheet.png` — contact sheets |
| 256×256 (49 775 bytes c/u) | 22 | `game/isla-ancestral/reports/report_51…70/css/logo.png` + 2 en `addons/gdUnit4/...` — logo de reportes, duplicado 20 veces |
| 862–910×512 | 6 | `game/isla-ancestral/.gdskills/vision/*.webp` — capturas de debug |
| 16×16, 40×16, 80×?, 200×? | 4 | Íconos de `addons/gdUnit4/src/update/assets/` (`border_*.png`, `dot*.png`, `embedded.png`, `horizontal-line2.png`) |
| 16 SVG con `svg/scale=1.0` | 16 | `icon.svg` (995 bytes) + 15 en `addons/zylann.voxel/editor/icons/` (351–4 088 bytes) |

Si se excluyen `tools/.../capturas/`, `reports/` y `.gdskills/` (no son assets del juego), la distribución real de texturas del juego es **monótona: 48×48 (300 íconos) + 256×256 (2 logos de gdUnit4)**. Sin inconsistencia interna. Las únicas anomalías son duplicación (20 logos idénticos en `reports/`) y el PNG de 1,35 MB de captura, que no conviene dejar en el árbol versionado.

**Nota:** 0 `.jpg`/`.jpeg` en disco. Las 6 `.webp` son capturas de `.gdskills/vision/`, ninguna es textura del juego.

## (4) Referencias de audio/textura en código `.gd`

- `load(`/`preload(` con ruta literal `.png|.jpg|.webp|.svg|.ogg|.wav|.mp3`: **0 hits** en 1590 `.gd`. Ningún script carga assets por ruta literal; la resolución es por catálogo/spawner o recursos `.tres`.
- Menciones sueltas `.ogg|.wav|.mp3`: **17**, ninguna funcional:
  - `game/isla-ancestral/scripts/legal/audio_license_report_tool.gd:25` — `const EXTENSIONES_AUDIO := [".ogg", ".wav", ".mp3", ...]` (catálogo de extensiones, correcto).
  - `game/isla-ancestral/scripts/legal/test_audio_license_report_m84.gd:47` — `for nombre in ["aurora_main.ogg", "ost_piano_01.ogg", "sfx_ambiente_01.wav"]` (fixtures en `user://`, no en el repo).
  - `game/isla-ancestral/scripts/rendimiento/memoria/test_m62_ogg_cache.gd:27` — comentario: *"0 .ogg/.wav/.mp3 en game/isla-ancestral"* (declaración honesta del stand-in).
  - `game/isla-ancestral/tools/asset_pipeline/run_m108_memory_test.gd:27` — dato de test `{ "archivo": "m108_test_c.ogg", ... }`.

## 2 mejoras sugeridas

1. **Buscrear pipeline mínimo de audio (contenido, no rutas).** El proyecto no tiene ni un `.ogg`: confirmar si el audio se carga por otra vía (streaming externo, `res://audio/` fuera de este árbol) o si está pendiente; si está pendiente, registrar 3–5 SFX/ambient de prueba en `assets/audio/`, con sus `.import` generados, y extender `audio_license_report_tool.gd:25` para cubrir `user://` y cargues dinámicos. Impacto: cierra el hueco mayor del inventario (0 audios) y valida el test M84/M62 contra datos reales en vez de fixtures.
2. **Purgar y normalizar el entorno de captura.** Eliminar `reports/report_*/css/logo.png` duplicados (20 copias idénticas de 49 775 bytes → 1 compartido) y sacar del versionado `tools/mcp/godot-mcp/capturas/` y `.gdskills/vision/` (PNG de 1,35 MB y WEBP de debug). Impacto: reduce ruido del árbol, evita que futuras auditorías cuenten capturas como "texturas inconsistentes" y baja el peso del repo.

## Conclusión final

El árbol `game/isla-ancestral/` está **sano en integridad referencial**: 848/848 `.import` con fuente, 1/1 textura referenciada desde `.tscn` existente, 0 referencias de audio porque **no existe ningún archivo de audio** (0 `.ogg`/`.wav`/`.mp3`, 0 `.import` de audio, 0 `load(`/`preload(` funcionales). Las texturas del juego son uniformes (**48×48, 300 íconos**); la heterogeneidad de resoluciones viene de capturas y reportes, no de assets. Sin hallazgos bloqueantes; los pendientes reales son de **contenido** (audio inexistente) y de **higiene** (duplicados y capturas en el árbol).

---

Archivos incluidos en la auditoría (con línea cuando aplica): `icon.svg.import`; `assets/2d/items_m159/*.png.import` (346); `addons/gdUnit4/src/ui/settings/GdUnitSettingsDialog.tscn:4`; `scripts/legal/audio_license_report_tool.gd:25`; `scripts/legal/test_audio_license_report_m84.gd:47`; `scripts/rendimiento/memoria/test_m62_ogg_cache.gd:27`; `tools/asset_pipeline/run_m108_memory_test.gd:27`; `tools/mcp/godot-mcp/capturas/31-Ciclo-Dia-Noche/cap_31_2026-09-19_06-26-00_profunda_0300.png`; `reports/report_51…70/css/logo.png`. Raíz auditada: `game/isla-ancestral/`. Método: `rglob('*.import')` (848), `rglob('*.gd')` (1590), `rglob('*.tscn')` (69), IHDR/VP8/VP8L/VP8X en bytes, verificación de existencia en disco.
