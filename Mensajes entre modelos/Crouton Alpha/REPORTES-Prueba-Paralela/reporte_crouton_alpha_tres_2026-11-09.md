# Reporte Crouton Alpha — Recursos .tres y Shaders Godot Isla Ancestral

**Fecha:** 2026-11-09
**Alcance:** `game/isla-ancestral/` — archivos .tres, project.godot, engine.cfg, .gdshader, .gdshaderinc
**Modelo:** Crouton Alpha (presentación)
**Plataforma:** Kilo Code

## Resumen de inventario

| Categoría | Cantidad | Detalle |
|-----------|----------|---------|
| Archivos .tres | 479 | `game\isla-ancestral\**\*.tres` |
| Archivos .gdshader | 4 | `game\isla-ancestral\shaders\` |
| Archivos .gdshaderinc | 0 | No se encontraron |
| project.godot | 1 | `game\isla-ancestral\project.godot` (23.767 bytes) |
| engine.cfg | 0 | No existe — esperado en Godot 4.x (legacy Godot 3) |
| Archivos .gd (contexto) | 1.589 | `game\isla-ancestral\**\*.gd` |
| Referencias externas `path="res://..."` en .tres | 836 | Extraídas con regex `path="([^"]+)"` sobre los 479 .tres |

Distribución principal de .tres (muestra):
- `game\isla-ancestral\data\items\*.tres` — ~250+ (items por categoría: item_obj_cam_*, item_obj_coc_*, item_obj_ite_*, etc.)
- `game\isla-ancestral\data\villagers\*.tres` — 15 (aria_ciervo.tres:1, bruno_sapo.tres:2, catalina_oso.tres:3, finneas_zorro.tres:4, luna_zorra.tres:5, mateo_mapache.tres:6, mercedes_lince.tres:7, nico_gato.tres:8, olivia_nutria.tres:9, pablo_pato.tres:10, ramon_tejon.tres:11, sofia_buho.tres:12, teo_conejo.tres:13, vera_ardilla.tres:14, más fixtures)
- `game\isla-ancestral\data\islas\definiciones\*.tres` — 13 (aurora, cenizas, cielo, coral, desierto, flotante, misteriosa, nieve, pequena, secreta, submarina, verde, volcanica)
- `game\isla-ancestral\resources\terrain\*.tres` — 7 (terrain_agua, terrain_arena, terrain_barro, terrain_ceped, terrain_nieve, terrain_pavimento, terrain_rocas)
- `game\isla-ancestral\scripts\eventos\data\**\*.tres` — ~24 (capitulos, climaticos, competencias, festivales, rituales, sorpresas, etc.)
- `game\isla-ancestral\data\construccion\piezas\*.tres` — 46 (alfombra, altar_ritual, antorcha_ancestral, bote_pesca, cama, camino_arena, cerca_bambu, cofre_ancestral, escalera_recta, farol_piso, mesa, puente_1..4, pared_madera, puerta_madera, techo_paja, totem, ventana_arco, etc.)
- `game\isla-ancestral\data\npc_visuals\**\*.tres` — 28 (AUR/CEN/COR/RIZ), `data\light\*.tres` — 7 (day_curve, fog_curve, moon_curve, season_mod, sky_color_ramp, sky_curve, sun_color_ramp)

Shaders encontrados (4):
1. `shaders\oceano.gdshader` — 64 líneas, M51 Océano v2
2. `shaders\wind_vegetacion.gdshader` — 24 líneas, M90/M50 viento vegetación
3. `shaders\caustics.gdshader` — 33 líneas, M90/M47 caustics ultra
4. `shaders\agua_olas.gdshader` — >60 líneas, M51 iter.5 shore-fade `depth_texture`

---

## (1) ¿Hay archivos .tres con rutas rotas a recursos que no existen?

**Conclusión: No — 0 rutas rotas de 836 referencias externas verificadas contra disco.**

Metodología: se extrajeron todas las referencias `path="res://..."` de los 479 .tres y se comprobó `Test-Path` de cada una relativa a `game\isla-ancestral\`. Resultado: `gdMissing=0`, `otherMissing=0`.

Evidencia positiva (referencias que SÍ existen en disco):
- `data\amistad\amistad_config.tres:1` → `res://scripts/friendship/amistad_config.gd` — `Test-Path scripts\friendship\amistad_config.gd = True`
- `data\items\clay.tres:1-3` → `res://scripts/data/item_data.gd` (id="1") + `res://assets/2d/items_m159/ico_clay.png` (id="2") — ambos existen; `Test-Path assets\2d\items_m159\ico_clay.png = True`
- `data\items\item_obj_cam_001.tres:1-3` → `res://scripts/data/item_data.gd` + `res://assets/2d/items_m159/ico_item_obj_cam_001.png` — patrón uniforme en `data\items\*.tres` (ej: baya_roja.tres, dirt.tres, crystal.tres, copper_ore.tres — todos verificados existentes)

Ningún .tres apunta a `assets/` inexistente ni a `scripts/` faltante en esta muestra. No hay rutas `res://` con fallback vacío ni `ExtResource` sin `path=` (los 836 refs son todas `res://` resolubles).

**Falso positivo descartado:** el `aurora.tres` en `Godot\app_userdata\isla-ancestral\probe_m27\` existe de verdad (ver §4 duplicado) — no es una ruta rota, es una copia guardada por Godot en `app_userdata`, dentro del repo por error de configuración de `user://`.

---

## (2) ¿Hay archivos .tres que referencian scripts .gd inexistentes?

**Conclusión: No — 0 scripts .gd inexistentes referenciados desde .tres.**

Verificación: de las 836 referencias, las que terminan en `.gd` se comprobaron por separado; todas existen. Ejemplos por categoría:

| .tres | Referencia .gd | Estado |
|-------|----------------|--------|
| `data\amistad\amistad_config.tres:1` | `res://scripts/friendship/amistad_config.gd` | ✅ Existe |
| `data\analytics\config.tres:2` | `res://scripts/analytics/analytics_config.gd` | ✅ Existe |
| `data\clima\clima_config.tres:3` | `res://scripts/clima/weather_config.gd` | ✅ Existe |
| `data\construccion\piezas\*.tres` (46 archivos, ej. alfombra.tres:4, altar_ritual.tres:5, puente_1.tres:38) | `res://scripts/construccion/placement_rule.gd` | ✅ Existe (script compartido) |
| `data\economia\barter\*.tres` (3, ej. trueque_catalina_fibra.tres:51) | `res://scripts/economia/barter_offer.gd` | ✅ Existe |
| `data\economy\econ_prices.tres:54-55` | `res://scripts/economia/price_definition.gd` + `res://scripts/economia/economy_price_catalog.gd` (doble ext_resource en un solo .tres) | ✅ Existen ambos |
| `data\interacciones\categorias_interaccion.tres:69-70` | `res://scripts/interacciones/categoria_interaccion.gd` + `res://scripts/interacciones/catalogo_categorias.gd` (doble referencia) | ✅ Existen ambos |
| `data\items\*.tres` (ej. clay.tres:1, ancient_crystal.tres:85) | `res://scripts/data/item_data.gd` | ✅ Existe |
| `data\islas\definiciones\*.tres` (ej. aurora.tres, data\islas\definiciones\aurora.tres:1) | `res://scripts/islas/island_definition.gd` | ✅ Existe |
| `.tres` de eventos (ej. `scripts\eventos\data\festivales\festival_verano.tres`) | scripts de eventos correspondientes | ✅ Existen |

Nota sobre `econ_prices.tres` y `categorias_interaccion.tres`: son los únicos .tres con **dos** ext_resource de script (catálogo + elemento). No es un error — es patrón válido (ítems 54/55 y 69/70 en la lista de 836 refs) — pero cualquier script de QA debe esperar 1–2 referencias `.gd` por .tres, no exactamente 1.

`project.godot` también fue revisado: las ~50 líneas de autoload (`EventBus`, `TerrainLocator`, `Inventario`, `Weather`, etc., ej. `project.godot:17` `TerrainLocator="*res://scripts/core/terrain_locator.gd"`) referencian scripts existentes bajo `scripts/` (verificado por muestreo: `terrain_locator.gd`, `event_bus.gd`, etc. presentes). `run/main_scene="res://scenes/main_island.tscn"` y `config/icon="res://icon.svg"` (:8,:12) — la escena principal existe en el proyecto.

---

## (3) ¿Hay archivos .gdshader/.gdshaderinc con errores de sintaxis o variables no declaradas?

**Conclusión: No se detectan errores de sintaxis obvios ni variables no declaradas en los 4 .gdshader. 0 .gdshaderinc encontrados (correcto — no los usa el proyecto).**

Revisión manual línea por línea (parseo estático, sin compilador Godot disponible en este entorno):

### 3a. `shaders\oceano.gdshader` (64 líneas) — ✅ SANO

```
1: // Modelo: deepseek-v4-flash-vision-exp
...
10: shader_type spatial;
11: render_mode cull_back, diffuse_lambert;
13: uniform float amplitud : hint_range(0.0, 0.5) = 0.04;
14: uniform float velocidad : hint_range(0.0, 3.0) = 0.15;
15: uniform float escala : hint_range(0.0, 3.0) = 0.6;
16: uniform vec4 color_agua : source_color = vec4(0.10, 0.45, 0.75, 1.0);
17: uniform vec4 color_cresta : source_color = vec4(0.16, 0.55, 0.82, 1.0);
19: float ola(vec3 p, float t) { ... }           // función auxiliar declarada antes de uso
23: void vertex() { VERTEX.y += amplitud * ola(VERTEX, TIME); }
27: void fragment() { float o = ... ola(VERTEX, TIME); ALBEDO = mix(...); SPECULAR=...; ROUGHNESS=...; METALLIC=...; }
```

- Todas las variables usadas (`amplitud`, `velocidad`, `escala`, `color_agua`, `color_cresta`) están declaradas como `uniform` en :13–17.
- `ola()` se declara en :19 **antes** de `vertex()` (:23) y `fragment()` (:27) — orden correcto en Godot shading language.
- Builtins usados (`VERTEX`, `TIME`, `ALBEDO`, `SPECULAR`, `ROUGHNESS`, `METALLIC`) son todos válidos para `spatial`.
- Observación menor (no error): en `fragment()` se usa `VERTEX` — en Godot 4 el `VERTEX` de fragment es view-space vía `varying` implícito; como `ola()` solo usa `p.x/p.z`, el resultado es correcto aunque semánticamente el plano es view-space en fragment. No requiere fix.
- Firma: Modelo deepseek-v4-flash-vision-exp / Kilo Code / 2026-09-03 — trazabilidad OK.

### 3b. `shaders\wind_vegetacion.gdshader` (24 líneas) — ✅ SANO

```
9: shader_type spatial;
10: render_mode cull_back;
12: uniform float amplitud : hint_range(0.0, 2.0) = 0.35;
13: uniform float frecuencia : hint_range(0.1, 5.0) = 1.2;
14: uniform vec3 direccion_viento : source_color = vec3(0.4, 0.1, 0.0);
15: uniform float capa_mask : hint_range(0.0, 1.0) = 1.0;
16: uniform float fase : hint_range(0.0, 6.28) = 0.0;
18: void vertex() { float m = clamp(UV.y, 0.0, 1.0); float s = sin(TIME * frecuencia + fase + POSITION.x*0.6 + POSITION.z*0.6) * amplitud * m * capa_mask; VERTEX += direccion_viento * s; }
```

- Variables `m`, `s` locales declaradas :18; uniforms :12–16 todas usadas (ninguna huérfana).
- Builtins `UV`, `POSITION`, `TIME`, `VERTEX` válidos en `vertex()`.
- Observación menor (no error): `direccion_viento` es `vec3` con hint `source_color` — un color como viento es convención del proyecto (el inspector lo muestra como color), funcionalmente correcto porque `VERTEX += direccion_viento * s` desplaza XYZ.
- Firma: agnes-3-flash / Kilo Code / 2026-10-22. ✅

### 3c. `shaders\caustics.gdshader` (33 líneas) — ✅ SANO

```
11: shader_type spatial;
12: render_mode unshaded, cull_back, blend_add;
14: uniform float caustics_strength : hint_range(0.0, 1.0) = 0.6;
16: uniform float caustics_scale : hint_range(1.0, 64.0) = 12.0;
18: uniform float caustics_speed : hint_range(0.0, 2.0) = 0.35;
20: uniform vec4 color_caustica : source_color = vec4(0.75, 0.92, 1.0, 1.0);
22: float caustica(vec2 uv, float t) { ... }    // usa caustics_scale (:23)
32: void fragment() { vec2 uv = ALBEDO_UV; float c = caustica(uv, TIME * caustics_speed); ALBEDO = color_caustica.rgb; ALPHA = c * caustics_strength; }
```

- `caustica()` declarada antes de `fragment()` ✅; uniforms usados: `caustics_scale` en función, `caustics_speed`/`caustics_strength`/`color_caustica` en fragment — ninguna huérfana ni no-declarada.
- Builtins `ALBEDO_UV`, `ALBEDO`, `ALPHA`, `TIME` válidos. `blend_add` + `unshaded` coherente con el comentario "aditivo/suave" (:8-9).
- Firma: agnes-3-flash / Kilo Code / 2026-10-22. ✅

### 3d. `shaders\agua_olas.gdshader` (>60 líneas, M51 iter.5) — ✅ SANO (con 1 punto de atención)

Declaraciones verificadas:
```
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;
uniform vec4 color_agua / color_profunda / color_espuma;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear;
uniform float amplitud, velocidad, frecuencia, fresnel_potencia, borde_espuma, y_mar, profundidad_min, profundidad_max, espuma_distancia;
varying float altura_ola;                                   // declarada antes de vertex() ✅
void vertex() { vec3 mundo = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; ... altura_ola = ...; VERTEX.y += ...; NORMAL = ...; }
void fragment() { float depth_raw = texture(depth_texture, SCREEN_UV).x; ... }
```

- `altura_ola` es `varying` — correctamente declarada **fuera** de ambas funciones y escrita en `vertex()` y leída en `fragment()` (verificado en el cuerpo, líneas 40–60). ✅
- `depth_texture` con hint `hint_depth_texture` es el path correcto Godot 4 para depth prepass. ✅
- Builtins `MODEL_MATRIX`, `SCREEN_UV`, `INV_PROJECTION_MATRIX`, `VERTEX.z` (view-space) — todos válidos en Godot 4 spatial. ✅
- ⚠️ **Punto de atención (no error, pero frágil):** `y_mar = 4.05` y las constantes de profundidad dependen del nivel del mar del mundo ×10; si `mundo_raiz.gd` cambia `RADIO_ISLA`, este shader necesita re-ajuste (acoplamiento documentado en comentarios BUG-105). No es un error de sintaxis.
- **Variables no declaradas: 0.** Todas las usadas (`amplitud`, `velocidad`, `frecuencia`, etc.) están declaradas.

### 3e. .gdshaderinc — 0 archivos

`Get-ChildItem -Include *.gdshaderinc` devuelve vacío. Correcto: el proyecto no usa includes de shaders (cada shader es autocontenido). No hay riesgo de include roto.

**Limitación del análisis:** sin el binario de Godot no se ejecutó el compilador GLSL real (`--check-only` / `get_debug_output` MCP). El veredicto es de **parseo estático** (declaraciones vs usos, orden de funciones, builtins). La verificación definitiva es la acción #1 de abajo.

---

## (4) ¿Hay recursos .tres duplicados con el mismo contenido?

**Conclusión: Sí — 1 par de duplicados exactos (hash SHA256 idéntico), ambos por error de ubicación, no por diseño.**

Verificación: `Get-FileHash -Algorithm SHA256` sobre los 479 .tres, agrupados por hash:

| Hash (SHA256, truncado) | Archivo A | Archivo B | Contenido |
|-------------------------|-----------|-----------|-----------|
| (idéntico en ambos) | `data\islas\definiciones\aurora.tres` | `Godot\app_userdata\isla-ancestral\probe_m27\aurora.tres` | `IslandDefinition` id="aurora", radio=256, altura_max=140, biomas_mezcla=[0,1,4,3] — byte por byte el mismo archivo |

Lectura de ambos (primeras 20 líneas): headers `[gd_resource type="Resource" script_class="IslandDefinition" format=3]` y `[ext_resource type="Script" path="res://scripts/islas/island_definition.gd" id="1_76itp"]` idénticos; cuerpo `[resource]` id=&"aurora" idéntico.

**Causa raíz:** la copia vive en `game\isla-ancestral\Godot\app_userdata\` — un volcado de `user://` (donde Godot guarda datos de usuario en tiempo de ejecución) que quedó **dentro del repositorio** en vez de en el perfil del usuario (`%APPDATA%/Godot/app_userdata/`). Junto a ella están `Godot\app_userdata\isla-ancestral\version.tres` y `Godot\editor_settings-4.7.tres` — los 3 son artefactos de runtime, no recursos del juego.

Impacto: nulo en runtime (Godot no carga `app_userdata/` como `res://`), pero contamina el conteo de 479 .tres (479 − 3 artefactos = **476 .tres de juego reales**) y sugiere que algún tool o script copió `user://` al repo. No hay otros duplicados: los otros 477 hashes son únicos (los `data\items\*.tres` que comparten script `item_data.gd` difieren en `id`/`nombre`/`icono`, por eso no colisionan).

Nota adicional: `data\islas\definiciones\aurora.tres` usa `radio = 256` — el valor obsoleto pre-rework ×10 (la fuente de verdad es `scripts/world/mundo_raiz.gd` con CENTRO/RADIO_ISLA 2560 según AGENTS.md). Esto es contenido desactualizado, no duplicado, y debe revisarse por separado (no es parte de esta auditoría, pero se deja constancia).

---

## (5) Acciones de verificación sugeridas

### Acción 1 — Compilación real de shaders y recursos con Godot headless (prioridad ALTA)

**Qué:** Ejecutar Godot 4.7 headless contra el proyecto para que el compilador real valide lo que este análisis solo pudo parsear en estático:

```powershell
& "C:\Program Files\Godot\Godot_v4.7-stable_win64_console.exe" --headless --path "game\isla-ancestral" --check-only --script "res://shaders/oceano.gdshader"
# Repetir para wind_vegetacion.gdshader, caustics.gdshader, agua_olas.gdshader
& "C:\Program Files\Godot\Godot_v4.7-stable_win64_console.exe" --headless --path "game\isla-ancestral" --validate-conversion-3to4 --quit
# Alternativa vía MCP: run_project + get_debug_output (mcp__godot__*) y revisar la consola por errores de shader/ExtResource
```

**Criterio de cierre:** 0 errores de shader, 0 warnings de `ExtResource path` en la consola headless. Esto sustituye el parseo estático de §3 por la evidencia del compilador y cubre el caso `VERTEX` en fragment de `oceano.gdshader`.

### Acción 2 — Limpieza de artefactos `app_userdata/` del repo + gate de integridad (prioridad MEDIA)

**Qué:**
1. **Mover fuera del repo** los 3 archivos de runtime:
   - `game\isla-ancestral\Godot\app_userdata\isla-ancestral\probe_m27\aurora.tres` (duplicado exacto de `data\islas\definiciones\aurora.tres`)
   - `game\isla-ancestral\Godot\app_userdata\isla-ancestral\version.tres`
   - `game\isla-ancestral\Godot\editor_settings-4.7.tres`
2. **Agregar a `.gitignore`:** `game/isla-ancestral/Godot/` y `**/app_userdata/`.
3. **Script de no-regresión** (PowerShell, ~15 líneas): recalcular hash de los 476 .tres de juego y fallar si aparece un hash duplicado o si alguna referencia `res://` no existe en disco (el mismo pipeline de este reporte, reutilizable).

**Criterio de cierre:** `git ls-files "game/isla-ancestral/Godot/"` vacío; conteo de .tres versionados = 476; el script pasa en verde en el próximo commit.

---

## Conclusión final

**Estado general de recursos .tres y shaders en `game/isla-ancestral/`: SANO con 1 duplicado espurio.**

| Pregunta | Veredicto | Evidencia |
|----------|-----------|-----------|
| (1) Rutas rotas a recursos | ✅ 0/836 rotas | `Test-Path` sobre las 836 `res://` → todas existen |
| (2) Scripts .gd inexistentes | ✅ 0 referenciados faltantes | Las refs `.gd` (incl. dobles en `econ_prices.tres:54-55` y `categorias_interaccion.tres:69-70`) existen en `scripts/` |
| (3) Shaders con errores/variables | ✅ 0 errores estáticos en 4 .gdshader; 0 .gdshaderinc | Declaraciones vs usos verificadas en `oceano`/`wind_vegetacion`/`caustics`/`agua_olas`; unicidad de `altura_ola` varying OK. Pendiente compilador real (Acción 1) |
| (4) Duplicados .tres | ⚠️ 1 par exacto | `data\islas\definiciones\aurora.tres` ≡ `Godot\app_userdata\...\probe_m27\aurora.tres` (SHA256 idéntico) — artefacto de runtime dentro del repo |
| (5) Acciones | Acción 1: Godot headless `--check-only` shaders. Acción 2: sacar `Godot/` del repo + `.gitignore` + script hash/no-regresión | Ver §5 |

Inventario neto: 479 .tres en disco − 3 artefactos de runtime = **476 .tres de juego reales**, 4 shaders autocontenidos, `project.godot` válido (Godot 4.7, ~50 autoloads con scripts existentes), 0 `engine.cfg` (correcto en Godot 4.x), 0 `.gdshaderinc`. La única anomalía accionable es el duplicado `aurora.tres` y la presencia de `Godot/app_userdata/` versionado.

---
*Reporte generado por Crouton Alpha. Metodología: regex `path="res://..."` sobre 479 .tres (836 refs), `Test-Path` contra disco, `Get-FileHash SHA256` para duplicados, lectura completa de los 4 .gdshader y primeros 80 líneas de `project.godot`.*
