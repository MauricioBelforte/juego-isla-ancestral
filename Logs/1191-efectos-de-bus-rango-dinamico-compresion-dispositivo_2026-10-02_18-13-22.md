# Log 1191: Efectos de bus M91 — rango dinámico, compresión y dispositivo de salida (lote 1 de 5)

**Fecha:** 2026-10-02
**Hora:** 18:13
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Se implementó el **lote 1 de 5** del backlog del módulo `91-Configuracion-De-Audio`
(lock 🔵 a este agente, otorgado por atria-dawn en commit `24ddc7e`): tres subsistemas
de efectos de bus hasta ahora inexistentes, stateless, sin nodos ni coste por frame.
Ambas suites quedaron en verde y el checklist del módulo pasó de 92 a 118 `[x]`.

Se descubrieron y documentaron **dos trampas nuevas** de Godot 4.7.2 (**T-107** y
**T-108**) en `DOCUMENTACION/GUIA-GODOT/06-registro-errores.md`.

## Cambios Realizados

### Código nuevo (4 archivos, todos en `game/isla-ancestral/scripts/audio/`)

| Archivo | `class_name` | Contenido |
|---|---|---|
| `dynamic_range_manager.gd` | `DynamicRangeManager` | perfiles `quiet`/`medio`/`dinámico` + knobs manuales (threshold, ratio, attack, release); derivado de `AudioServer`, stateless |
| `compression_manager.gd` | `CompressionManager` | limiter con `THRESHOLD_DB_DEFECTO=-3`, `CEILING_DB_DEFECTO=0`, `SOFT_CLIP_DB_DEFECTO=-6`, `SOFT_CLIP_RATIO_DEFECTO=2`; `activar/desactivar/activa/configurar/parametros` |
| `output_device_manager.gd` | `OutputDeviceManager` | `dispositivos()/actual()/seleccionar()` + `CATEGORIAS_LISTA` (5 etiquetas de UI); **renombrado** desde `output_device_service.gd` para coincidir con el `04-Codigo.md` |
| `test_audio_effects_m91.gd` | — | suite nueva, `CHECKS_MINIMOS := 82` **medido en verde** (patrón M105, no estimado) |

### Verificación

- Suite nueva: `TEST M91 EFECTOS: 82 checks, 0 fallo(s)` — EXIT 0
- Suite base (`test_audio_config.gd`): `TEST M91 AUDIO: 0 fallo(s)` — EXIT 0 (regresión nula)
- `python tools/ci/run_tests.py --module m91 --godot "C:/Temp/godot/godot472.exe" --timeout 180` → **1 OK, 0 FAIL** (auto-descubre el test)
- `--check-only` sobre los 3 scripts: EXIT 0, sin parse errors

### Checklist

`91-Configuracion-De-Audio/plan-actual/05-Checklist.md`: **92 → 118 `[x]`** (26 ítems),
`147 → 121 [ ]`, total **239 intacto**, 0 `[?]`. Cada ítem marcado lleva evidencia con
firma. Se recalculó la línea `**Totales:**`.

### Documentación

- `04-Codigo.md`: filas de §15 actualizadas (`dynamic_range`, `compression`,
  `output_device` → HECHO) + sección **"Notas del Agente — Iteración 2"** con la API
  real, la tabla de redundancias y lo no hecho.
- `GUIA-GODOT/06-registro-errores.md`: **T-107** y **T-108** insertadas
  (782 → 894 líneas, CRLF/UTF-8 verificados), header actualizado a "T-105, T-106,
  T-107 y T-108".

### Trampas descubiertas (nuevas en la guía)

- **T-107 — Adivinar la API nativa.** El `04-Codigo.md` §9/§10/§11 de M91 cita
  `AudioServer.get_device_list()/set_device()/get_device()`,
  `compressor.release_us`, `compressor.output_gain`, `limiter.ceil_db`,
  `limiter.soft_clip` — **ninguno existe en Godot 4.7.2**. La API real es
  `get_output_device_list()/get_output_device()/set_output_device()`,
  `release_ms`, `gain`, `ceiling_db`, `soft_clip_db` + `soft_clip_ratio`.
  Se sondeó por reflexión (`get_method_list()` / `get_property_list()` /
  `ClassDB.class_exists`) antes de codificar. Refinamiento de T-105:
  `--check-only` **sí** detecta llamadas estáticas inexistentes de clases
  nativas y funciones locales, pero **NO** propiedades inexistentes en
  instancias (esas revientan solo en runtime).
- **T-108 — `class_name` invisible en headless.** Un `class_name` recién creado
  no se registra si `.godot/global_script_class_cache.cfg` quedó parcial: la
  caché solo procesa scripts "modificados" y un editor matado a mitad del
  escaneo los deja marcados como vistos. Solución: **borrar** la caché +
  `--headless --editor --quit`. Costó 4 corridas.

### Decisiones de diseño

- **NO se crearon los 12 archivos** que pide el esqueleto §2/§15: cuatro son
  redundantes con `AudioConfigService` (Iteración 1) — `audio_bus_setup.gd`
  (ya crea los 7 buses), `audio_settings.gd` (ya guarda volúmenes/mutes),
  `audio_settings_loader.gd` y `audio_settings_saver.gd` (persistencia M60
  automática en cada `set_volumen`). Crearlos duplicaría estado.
- Las **rutas del §2 son incorrectas** (`res://audio/`, `res://ui/`,
  `res://settings/`): la convención real es `game/isla-ancestral/scripts/audio/`.

### Errores propios corregidos en el camino

1. Llamada a `_remover()` inexistente (debería ser `remover()`) — atrapado por
   `--check-only`, que **sí** valida funciones locales.
2. Olvidé los tres `class_name` → añadidos; caché de clases reconstruida
   (521 → 524 clases).
3. Renombre `OutputDeviceService` → `OutputDeviceManager` con verificación de
   0 referencias residuales en fuente, test y checklist.

## Archivos Modificados/Creados

**Creados (4):**
- `game/isla-ancestral/scripts/audio/dynamic_range_manager.gd`
- `game/isla-ancestral/scripts/audio/compression_manager.gd`
- `game/isla-ancestral/scripts/audio/output_device_manager.gd`
- `game/isla-ancestral/scripts/audio/test_audio_effects_m91.gd`

**Modificados (3):**
- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/05-Checklist.md` (92 → 118 `[x]`)
- `DOCUMENTACION/91-Configuracion-De-Audio/plan-actual/04-Codigo.md` (§15 + Notas Iteración 2)
- `DOCUMENTACION/GUIA-GODOT/06-registro-errores.md` (T-107, T-108)

**Sin tocar (decisión):**
- `scripts/audio/audio_config_service.gd` — lote 1 es puramente aditivo.
- `CHECKLIST-GLOBAL.md` — se edita recién al terminar/liberar (§21.4.5).

## Pendiente (backlog de M91)

- **Lote 2:** API de porcentaje 0-100% (`set_volumen_porcentaje` /
  `get_volumen_porcentaje`) → glues de sliders del backlog tarea #1.
- Lotes 3-5: subtítulos, `ui_sound_manager`, `audio_3d_setup`,
  `audio_test_manager`, integración M58/M87/M61.
- `06-Plan-Testings.md` del `plan-actual/` (aún no existe).

---
**Nota:** este lote **no está commiteado aún** (pendiente de petición explícita).
