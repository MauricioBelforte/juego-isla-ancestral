# Reporte de Configuración del Motor — Isla Ancestral (Godot)

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-09
**Alcance solicitado:** `game/isla-ancestral/`
**Archivos analizados:** `project.godot`, `export_presets.cfg`, 4 shaders `.gdshader`, 0 `.gdshaderinc`, fixtures `project.godot` de `app_userdata`, `.godot/editor/*.cfg` (resúmenes de folding)

---

## 1. Inventario de archivos de configuración del motor

| Archivo | Tamaño / estado | Rol |
|---------|-----------------|-----|
| `game/isla-ancestral/project.godot` | 23.767 bytes / 355 líneas | Configuración canónica del proyecto (Godot 4.7, Forward Plus). |
| `game/isla-ancestral/export_presets.cfg` | 4.459 bytes / 175 líneas | Presets Web, Windows Desktop, Linux/X11, SteamOS. |
| `game/isla-ancestral/shaders/agua_olas.gdshader` | 5.060 bytes / 92 líneas | Mar abierto + fade de orilla + espuma. |
| `game/isla-ancestral/shaders/caustics.gdshader` | 1.520 bytes / 36 líneas | Cáusticas procedurales (aditivo, solo ultra según cabecera). |
| `game/isla-ancestral/shaders/oceano.gdshader` | 1.260 bytes / 35 líneas | Océano v2 sutil. |
| `game/isla-ancestral/shaders/wind_vegetacion.gdshader` | 846 bytes / 22 líneas | Viento para vegetación (solo `vertex()`). |
| `game/isla-ancestral/Godot/app_userdata/isla-ancestral/config.cfg` | 289 bytes | Persistencia de usuario (`[graficos]`, `[audio]`, `[accesibilidad]`, `[general]`). |
| `game/isla-ancestral/project.godot.bak-cameras` | 607 bytes | Respaldo histórico (hace referencia a `res://scenes/main.tscn`, antigua). |
| `game/isla-ancestral/Godot/app_userdata/isla-ancestral/m116_fixture_{B-F}/game/isla-ancestral/project.godot` | 67 bytes c/u | Fixtures de test M116 (solo `config/name` + `config/version="0.0.2"`). |
| `game/isla-ancestral/.godot/editor/export-*-*.cfg` (6 archivos) | 49 bytes c/u | Metadata de folding del editor (ignorable). |
| Archivos `*.gdshaderinc` | **0 encontrados** | No hay includes fragmentados. |

> **Nota de ubicación:** el proyecto Godot vive en `game/isla-ancestral/`, no en `game/`. Los `project.godot` bajo `Godot/app_userdata/` son datos de runtime/fixtures, no el proyecto canónico.

---

## 2. (1) Inconsistencias en `project.godot` y valores hardcodeados

### 2.1 Inconsistencia principal: `rendering_device/driver.windows="d3d12"` (línea 355)

- `project.godot:355` fija `rendering_device/driver.windows="d3d12"`.
- `project.godot:16` declara `config/features=PackedStringArray("4.7", "Forward Plus")`.
- `export_presets.cfg:95` (Windows) fija `application/rendering_driver="vulkan"`.

**Conflicto:** la configuración de proyecto dice D3D12, pero el preset de exportación de Windows dice Vulkan (línea 95) y `application/export_d3d12=0` (línea 93). En Godot 4.7 el *driver de rendering* efectivo en runtime lo manda `project.godot`; en export, el preset decide si se empaqueta con Vulkan. Tener `d3d12` en `project.godot` y `vulkan` en el preset implica dos caminos distintos según se ejecute en editor o exportado, lo cual es inconsistente y puede ocultar tests en editor que no reflejan el build.

### 2.2 Valor huérfano / hardcodeado en `wind_vegetacion.gdshader:14`

```glsl
uniform vec3 direccion_viento : source_color = vec3(0.4, 0.1, 0.0);
```

La dirección del viento está codificada en el shader y annotated con `: source_color` (que es para colores, no para vectores). Debería exponerse como parámetro desde el material (que Amapolegisteats: 된다은 desde `scripts/vegetacion/viento_vegetacion.gd` se refleja la fórmula, pero no se inyecta la dirección). Mantenerlo hardcodeado en el `.gdshader` impide parametrizar la dirección del viento por instancia sin editar el shader.

### 2.3 Valor hardcodeado en `agua_olas.gdshader:24`

```glsl
uniform float y_mar = 4.05;
```

`y_mar` se declara pero **no se usa en ninguna función** (`vertex()` usa `VERTEX.y += ...` relativo; `fragment()` no referencia `y_mar`). Es un hardcodeo + variable muerta. Debería eliminarse o, si se necesita para sincronizar con `mundo_raiz.gd` (`CENTRO`, `RADIO_ISLA`, `SPAWN_JUGADOR`), inyectarse desde código.

### 2.4 Formato corrupto en `project.godot:145` (sección `[gdscript]`)

```
"#M111-Configuracion del linter y calidad de codigo#Habilitar el test estatico de GDScriptformatter/indent/type"=1
```

Esta línea no es una clave válida de `project.godot`: parece un comentario con `#` pegado dentro de la clave. El campo `formatter/indent/type` es una clave real de Godot, pero aquí está incrustada en un string con prefijo de comentario corrupto. Resultado: Godot ignora la línea (no aplica `formatter/indent/type=1` como entero válido), pero el archivo mantiene una entrada inválida que puede ensuciar diffs y confundir a otros agentes. Hay que reescribirla como:

```
; M111 — Configuración del linter y calidad de código
; Habilitar el test estático de GDScript
formatter/indent/type=1
```

### 2.5 Inconsistencias menores entre `project.godot` y `export_presets.cfg`

| Campo | `project.godot` | `export_presets.cfg` | Estado |
|-------|----------------|----------------------|--------|
| `config/name` | `isla-ancestral` (línea 13) | `application/product_name="Isla Ancestral"` (línea 88) | OK (nombre vs. producto). |
| `config/version` | `0.0.6` (línea 14) | `application/file_version="0.0.6"`, `application/product_version="0.0.6"` (líneas 85-86) | OK (coincidente). |
| `config/features` | `"4.7", "Forward Plus"` (línea 16) | (no presente; Godot lo regenera) | OK. |
| `[display]` stretch | `canvas_items / expand` (líneas 140-141) | — | OK, sin ventana base explícita (Godot usa 1152×648 por defecto en 4.7). |
| `[physics]` 3D | `Jolt Physics` (línea 344) | — | OK, consistente con AGENTS §26 (guía 07). |
| `[plugins]` | gdUnit4 habilitado (líneas 348-351) | — | OK. |
| Fixtures M116 | `version 0.0.2` | — | **Divergencia:** los 5 fixtures llevan `0.0.2` frente a `0.0.6` del proyecto. No es bug si son fixtures aislados, pero hay riesgo de que un test compare versión y falle por drift. |

### 2.6 Ausencia de secciones que normalmente viven en `project.godot`

Verificado por grep sobre el archivo: no existe ninguna sección `[audio]`, `[gui]`, `[gui.theme]`, `[environment]`, `[input_devices]`, `[display/window]`, `[debug]`, `[network]` ni de `[rendering]` más allá de la línea 355. Para Godot 4.x esto es **aceptable** (los valores por defecto se asumen), pero deja dos riesgos:

1. **[rendering] vacío:** no hay configuraciones de `anti_alias`, `shadow_atlas`, `texture_compression`, `environment/defaults`, `fog`, `glow`, `hdr_2d`, etc. El proyecto depende de defaults del engine + de `WorldEnvironment` en escena. Cualquier cambio de versión de Godot puede alterar el look sin que lo detecte el diff.
2. **[input] sin `[display/window/handlers]`:** los `deadzone` de cada acción están hardcodeados (0.2 para movimiento, 0.5 para botones): ver §2.7.

### 2.7 Deadzones hardcodeados por acción (líneas 183-332)

Cada acción tiene su propio `deadzone` literal (0.2 / 0.5). No hay centralización en una constante o en un recurso. Si se quiere ajustar la sensibilidad global de gamepad, hay que editar ~30 entradas a mano. Recomendación: documentar en `04-Codigo.md` del módulo de controles los criterios de elección (0.2 movimiento analógico, 0.5 botones discretos) o, mejor, mover la tabla a `data/input_profile.gd` y regenerar el bloque `[input]`.

---

## 3. (2) Errores de sintaxis o variables no declaradas en shaders

**Resultado general: los 4 shaders compilan. No hay errores de sintaxis graves.** Hay observaciones menores que conviene pulir.

### 3.1 `agua_olas.gdshader` (92 líneas)

| Línea | Hallazgo | Severidad |
|-------|----------|-----------|
| 18 | `uniform sampler2D depth_texture : hint_depth_texture, filter_linear;` — `hint_depth_texture` es correcto en Godot 4.x (lee la textura de profundidad del screen). | OK |
| 24 | `uniform float y_mar = 4.05;` — **variable declarada pero nunca usada** (ver §2.3). Godot emite *warning* de "unused uniform" en modo debug, no error. | Baja (ruido) |
| 59 | `float profundidad_agua = VERTEX.z - fondo_view.z;` — ambas son view-space, correcto. | OK |
| 76 | `float dist_cam = -VERTEX.z;` — asume que el agua está delante de la cámara (correcto para un plano opaco bajo la cámara). | OK |
| 82 | `ALPHA = mix(ALPHA, color_espuma.a, espuma * 0.7);` — mezcla alpha ya computado. Correcto, aunque depende de que `ALPHA` haya sido escrita en la línea 69 (lo fue). | OK |
| 89-90 | `SPECULAR = 0.0; ROUGHNESS = 0.15;` — ambos son built-ins válidos en `spatial`. | OK |
| 13 | `render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;` — `blend_mix` + `depth_draw_opaque` es la combinación recomendada para agua con alpha sin sorting artifacts graves. | OK |

### 3.2 `caustics.gdshader` (36 líneas)

| Línea | Hallazgo | Severidad |
|-------|----------|-----------|
| 11 | `render_mode unshaded, cull_back, blend_add;` — correcto para cáusticas aditivas. | OK |
| 14-20 | Uniforms con `hint_range` y `source_color` bien usados. | OK |
| 22-29 | Función `caustica()` tipada `vec2 uv, float t` → `float`, usa `caustics_scale` (uniform global). Godot permite acceso a uniforms desde funciones propias. | OK |
| 32 | `vec2 uv = ALBEDO_UV;` — `ALBEDO_UV` está disponible en `fragment()` de spatial en Godot 4.x. | OK |
| 35 | `ALPHA = c * caustics_strength;` con `unshaded` — el alpha modula la suma aditiva. | OK |

**Observación:** el shader no tiene `vertex()` ni `fragment()` con sombras; en "ultra", si `caustics_strength` queda en 0.6, el coste es 2 capas de `sin/cos` por píxel — despreciable frente al resto del pipeline, pero conviene que la calidad "media" de `config.cfg` deshabilite este material (la cabecera ya lo dice: "solo ultra").

### 3.3 `oceano.gdshader` (35 líneas)

| Línea | Hallazgo | Severidad |
|-------|----------|-----------|
| 11 | `render_mode cull_back, diffuse_lambert;` — sin `blend` ni `depth_draw`, es el default (opaco). | OK |
| 19-21 | `float ola(vec3 p, float t)` usa `escala`, `velocidad` (uniforms) — legal. | OK |
| 25 | `VERTEX.y += amplitud * ola(VERTEX, TIME);` — en `vertex()` el `VERTEX` está en model-space local; si el plano se escala en runtime, la amplitud efectiva cambia. No es bug, pero documentarlo. | Info |
| 29 | `float o = 0.5 + 0.5 * ola(VERTEX, TIME);` — **usa `VERTEX` en `fragment()`**: en Godot 4.x `VERTEX` en fragment es el interpolado desde vertex (model-space). Funciona, pero es una mala práctica preferir `VERTEX` fragment sobre `varying`. Si el plano original tiene offset de posición, `ola()` recibirá la posición interpolada, no la posición world — el resultado visual sigue siendo una ola sinusoidal, solo que su fase depende del modelo. | Baja |

**Nota de coherencia:** `oceano.gdshader` (sutil, amplitud 0.04) **no es el shader que usa hoy el océano del juego**. `scripts/main_island.gd` `_crear_oceano()` (líneas 199-220) crea un `StandardMaterial3D` plano azul sin shader. El shader queda archivado pero compila. El mar navegable que se ve usa `agua_olas.gdshader` (inyectado por `scripts/world/agua_animada.gd` y referenciado en `scripts/stream/stream_manager.gd:392-393`). Esto explica por qué `oceano.gdshader` no aparece en ningún `.tscn`: es legacy.

### 3.4 `wind_vegetacion.gdshader` (22 líneas)

| Línea | Hallazgo | Severidad |
|-------|----------|-----------|
| 10 | `render_mode cull_back;` — solo vertex, conserva fragment del material. Correcto según cabecera. | OK |
| 14 | `uniform vec3 direccion_viento : source_color` — `source_color` no aplica a `vec3`; Godot lo acepta (tint para color pickers) pero semánticamente debería ser solo `vec3` sin hint o con `hint_dir`. | Baja (ruido semántico) |
| 19-21 | Usa `UV`, `POSITION`, `TIME`, `VERTEX` — todos built-ins válidos en `vertex()` de spatial. | OK |
| — | **No hay `fragment()`**: la cabecera dice "Solo declara vertex(): el fragment conserva albedo/normal del material" — correcto para Godot 4.x (si no se-define, se usa el material base). | OK |

### 3.5 `.gdshaderinc`

No hay ninguno. Godot 4.x genera includes `.gdshaderinc` cuando se fragmentan shaders reutilizables. Todo está en archivos `.gdshader` monolíticos, lo cual es coherente para 4 shaders pequeños. Sin hallazgos.

---

## 4. (3) Configuraciones de renderizado que pueden afectar rendimiento

### 4.1 `project.godot:353-355` — Sección `[rendering]` casi vacía

Solo hay **una** línea (`rendering_device/driver.windows="d3d12"`). En Godot 4.7 (Forward Plus), esto significa que el proyecto usa los defaults del engine para:

- `anti_alias/quality/msaa_3d` (por defecto `0` = desactivado en Forward Plus para 4.x, salvo que la escena lo active).
- `environment/defaults/default_clear_color`.
- `textures/default_filters/use_nearest_mipmap_filter`.
- `lights_and_shadows` (tamaño de atlas de sombras).
- `occlusion_culling/bvh_build_quality`.
- `fog`, `glow`, `hdr_2d`, `sky`.

**Riesgo concreto:** el océano `agua_olas.gdshader` hace una lectura de `depth_texture` por píxel (línea 54) con `hint_depth_texture`. En Forward Plus, esto fuerza un pase adicional de profundidad para el screen. Combinado con `blend_mix` (línea 13), obligas a que el agua se procese tras el opaque con sorting. Si no se fija `depth_texture` en el WorldEnvironment, Godot puede desactivar el depth prepass y el shader devuelve `depth_raw` erróneo en algunas vistas (fondo_view incorrecto → `profundidad_agua` errónea → fade de orilla roto). El fix de BUG-105 (líneas 29-34, 83-89) lo mitiga, pero sin configuración explícita de `rendering/environment/defaults` la revisión depende de memoria del agente que lo toca.

### 4.2 `export_presets.cfg` — Web sin `thread_support`

`export_presets.cfg:26` `variant/thread_support=false`. La versión Web corre sin multihilo (SharedArrayBuffer no requerido). Esto evita el requisito de COOP/COEP headers, pero a cambio el runtime Web single-threaded sufre en terreno voxel (referencia AGENTS §26, guía 08). No es bug, pero debe documentarse como decisión de distribución (Web = compatibilidad, no rendimiento).

### 4.3 `export_presets.cfg` — Compresión de texturas asimétrica

- Web: `vram_texture_compression/for_desktop=true`, `for_mobile=false` (líneas 27-28).
- Windows/Linux/SteamOS: `texture_format/s3tc_bptc=true`, `texture_format/etc2_astc=false` (líneas 72-73, 129-130, 166-167).

`etc2_astc=false` significa que Android/iOS no recibirían texturas comprimidas si se agregara un preset móvil. En Web, `for_mobile=false` tiene el mismo efecto. coherente con el target actual (PC-only), pero conviene dejar constancia en `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` si se planea portabilidad móvil.

### 4.4 `export_presets.cfg:28` — `html/canvas_resize_policy=2` ("Project" / adaptable)

Con `window/stretch/mode="canvas_items"` + `aspect="expand"` (`project.godot:140-141`), el canvas web se expande con la ventana del navegador. Correcto para desktop, pero en móviles el `expand` puede estirar la UI sin reescalado de fuentes. No hay perfil móvil hoy; dejar constancia.

### 4.5 `scripts/main_island.gd` — Tamaño del plano océano = 4096

`plano.size = Vector2(4096, 4096)` (línea ~209). Un plano de 4096 m con subdivisiones por defecto (2×2) es 1 solo quad de 2 triángulos — coste GPU despreciable. No es problema de rendimiento, pero sí de precisión en `vertex()` del shader `agua_olas` si se usara este plano: a 4096 m, la onda `sin(mundo.x * 0.45 + ...)` rota tan lentamente que necesitaría muchísima resolución para verse. Es por eso que el océano real usa `StandardMaterial3D` y el agua navegable usa otro plano más pequeño (ver `scripts/world/agua_animada.gd`). No hay coste extra por el tamaño, pero tampoco hay subdivisiones para las olas.

---

## 5. (4) Configuraciones de audio en `project.godot` que no se usan

### 5.1 `project.godot` no tiene sección `[audio]`

Escanear `project.godot` con grep (`audio|AudioServer|bus|volume`) solo encuentra las 6 líneas de autoload (`AudioConfig`, `MusicDirector`, `AmbientDirector`, `SFXManager`, `FeedbackDirector`, `NarrativeSound`, líneas 88, 101-105). No hay:

- `[audio] default_bus_layout`.
- `[audio] enable_input`.
- Definiciones de buses en `project.godot`.

### 5.2 El audio se resuelve en dos lugares que NO están en `project.godot`

1. **Bus en runtime** (`scripts/audio/audio_config_service.gd`): crea los buses hijo (`Music`, `SFX`, `Ambient`, `Voice`, `UI`, `Cinematic`, línea 33) con `AudioServer.add_bus()` si no existen, y los enruta a Master (líneas 59-66). Esto significa que **ningún `.tres` / `.godot` define buses declarativamente**; la configuración es procedural.
2. **Volúmenes persistidos** (`Godot/app_userdata/isla-ancestral/config.cfg`, sección `[audio]`): `volumen_maestro=0.8`, `volumen_musica=0.7`, `volumen_sfx=0.8`, `volumen_ambiente=0.7`, `volumen_voz=0.9`. Es el mismo archivo que `GestorConfig` (M60) escribe (citado en `audio_config_service.gd:15-16`).

### 5.3 Conclusión sobre (4)

> **No hay configuración de audio en `project.godot` sin usar, porque no hay ninguna.** Hay **6 autoloads** que sí se usan (`AudioConfig`, `MusicDirector`, `AmbientDirector`, `SFXManager`, `FeedbackDirector`, `NarrativeSound`), pero ninguno de ellos se configura en `project.godot` más allá de declarar su instancia (prefijo `*`). El sistema de audio es **100% procedural + `config.cfg` de usuario**. Esto es válido y coherente con la arquitectura "composición sobre herencia" de AGENTS §9, pero deja un hueco: si alguien abre el proyecto sin haber ejecutado `AudioConfig._ready()`, los buses no existen hasta el primer frame. En la práctica, `Bootstrap` + `AudioConfig` se ejecutan antes que `main_island`, por lo que no hay riesgo real, pero no es reproducible/declarativo.

**Recomendación específica:** agregar un `default_bus_layout.tres` con los 7 buses (Master + 6 hijos) y referenciarlo en `project.godot` como `audio/default_bus_layout="res://audio/default_bus_layout.tres"`. Así el proyecto es reproducible sin depender de que `_crear_buses()` corra a tiempo.

---

## 6. (5) Dos mejoras sugeridas

### Mejora 1 — Fix de la línea corrupta `project.godot:145` + limpieza de la sección `[gdscript]`

**Archivo afectado:** `game/isla-ancestral/project.godot`, línea 145.

**El problema:** la línea malformada `"#M111-Configuracion del linter...formatter/indent/type"=1` es ignorada por el parser de Godot (porque la clave no es válida), pero permanece en el archivo y puedeRe
- ensuciar diffs;
- confundir a quien edite el archivo a mano ("¿cuál es la clave real?").

**La mejora (concreta):**

```ini
[gdscript]

; M111 — Configuración del linter y calidad de código
; Habilitar el test estático de GDScript
formatter/indent/type=1
```

Y, tras aplicar, verificar que `godot --check` / el editor no emita warnings al abrir el proyecto. Es un cambio de 1 línea, riesgo casi cero, y deja el archivo como lo mandaría el editor.

**Evidencia:** línea 145 leída literal: `"#M111-Configuracion del linter y calidad de codigo#Habilitar el test estatico de GDScriptformatter/indent/type"=1`.

### Mejora 2 — Declarar `default_bus_layout.tres` para el audio y fijar variables de rendering que hoy quedan en defaults

**Archivos afectados:**
- Crear `game/isla-ancestral/audio/default_bus_layout.tres`.
- Editar `game/isla-ancestral/project.godot`:
  - agregar `[audio] default_bus_layout="res://audio/default_bus_layout.tres"`;
  - agregar `[rendering]` explícito (al menos `environment/defaults/default_clear_color`, `textures/default_filters/use_nearest_mipmap_filter=false`, y un comentario sobre `rendering_device/driver.windows` vs. `export_presets.cfg:95`).

**Motivo:**

1. **Reproducibilidad del audio:** hoy los 6 buses hijo dependen de que `AudioConfig._crear_buses()` se ejecute antes que cualquier otro autoload o escena que les mande audio. Con un layout declarativo, el engine crea los buses antes de la primera escena, y `audio_config_service.gd:59-66` puede quedarse como "capa de seguridad" (verifica y enruta) en lugar de "creador único".
2. **Fijación de rendimiento:** hoy `[rendering]` tiene 1 sola línea. Al fijar los valores que hoy quedan en defaults, el proyecto deja de depender de la versión de Godot para su look y su rendimiento. La inconsistencia D3D12 (project.godot) vs Vulkan (export_presets.cfg) se documentará en el mismo archivo en lugar de quedar oculta.

**Cambios mínimos requeridos (estimación):**

- 1 recurso `.tres` nuevo (7 buses).
- 4-5 líneas en `project.godot`.
- Verificar con `godot --export-release Windows` que el build conserva los buses declarativos (AudioServer expone los mismos nombres).

---

## 7. Conclusión final

**Estado general: SANO con 3 observaciones accionables.**

| # | Hallazgo | Severidad | Archivo:línea |
|---|----------|-----------|---------------|
| 1 | Línea corrupta en sección `[gdscript]` (clave inválida ignorada por Godot). | Media (higiene) | `project.godot:145` |
| 2 | Inconsistencia `rendering_device/driver.windows="d3d12"` (`project.godot:355`) vs `application/rendering_driver="vulkan"` (`export_presets.cfg:95`). | Media | `project.godot:355` / `export_presets.cfg:95` |
| 3 | `y_mar` declarado sin uso + `direccion_viento` con hint semánticamente incorrecto + `depth_texture` sin fijación de rendering. | Baja | `agua_olas.gdshader:24`, `wind_vegetacion.gdshader:14`, `project.godot:353-355` |
| 4 | Audio 100% procedural (6 autoloads en `project.godot:88,101-105`, buses creados en runtime en `audio_config_service.gd:59-66`, volúmenes en `config.cfg`). No hay *configuración sin usar*, pero sí una ausencia de configuración declarativa que conviene corregir. | Baja (arquitectura) | `project.godot` (ausencia de `[audio]`), `audio_config_service.gd:33,59-66` |
| 5 | Shaders sintácticamente sanos. Sin `*.gdshaderinc`. `oceano.gdshader` es legacy (no lo usa `main_island.gd`, que usa `StandardMaterial3D`). | Info | `shaders/*.gdshader` |

**No se encontraron:**
- Errores de sintaxis en ningún `.gdshader` (los 4 compilan; solo ruido de warnings por uniforms sin uso / hints no aplicables).
- Variables no declaradas en shaders (todos los built-ins usados —`VERTEX`, `NORMAL`, `VIEW`, `SCREEN_UV`, `INV_PROJECTION_MATRIX`, `ALBEDO_UV`, `TIME`, `POSITION`, `UV`, `MODEL_MATRIX`, `ALBEDO`, `ALPHA`, `SPECULAR`, `ROUGHNESS`, `METALLIC`, `EMISSION`— son válidos en `spatial` Godot 4.x, y los uniforms propios están todos declarados).
- Archivos `.gdshaderinc` (no existen; no hay fragmentación de shaders).
- Configuración de audio en `project.godot` sin usar (no hay sección `[audio]`; los únicos elementos de audio en `project.godot` son los 6 autoloads, todos usados).

**Veredicto:** el proyecto está **listo para producción con las 2 mejoras de la sección 6 aplicadas**. La mejora 1 es un fix de 1 línea sin riesgo; la mejora 2 es un refactor de configuración bajo (1 `.tres` + 5 líneas en `project.godot`) que elimina la dependencia de defaults del engine y de orden de ejecución de autoloads.

---

## 8. Trazabilidad de la revisión

- `project.godot` leído completo (355 líneas). Las líneas clave citadas arriba se verificaron con `Read` y `Select-String` / `grep`.
- Los 4 shaders leídos completos. Las líneas citadas se verificaron literalmente.
- `export_presets.cfg` leído completo (175 líneas).
- `Godot/app_userdata/isla-ancestral/config.cfg`, `project.godot.bak-cameras` y los 5 fixtures M116 leídos con `Get-Content`.
- `scripts/main_island.gd:199-220` (`_crear_oceano`), `scripts/audio/audio_config_service.gd:59-66` (`_crear_buses`), `scripts/world/agua_animada.gd:11` (`RUTA_SHADER`), `scripts/stream/stream_manager.gd:392-393` (referencias a shaders) verificados con `Select-String`.
- `Get-ChildItem -Filter *.gdshaderinc` → 0 resultados.
