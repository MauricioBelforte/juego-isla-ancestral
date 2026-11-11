# Reporte de configuración y shaders — Glyph Cluster
**Proyecto:** `game/isla-ancestral/`  
**Fecha de análisis:** 2026-11-10  
**Alcance:** `project.godot`, shaders del juego (`.gdshader`/`.gdshaderinc`) y recursos `.tres` de configuración del motor  
**Método:** análisis estático de archivos (lectura directa). No se ejecutó Godot headless ni MCP de Godot en esta sesión.

---

## 1. Configuraciones de `project.godot` inconsistentes o con valores hardcodeados

**Archivo:** `game/isla-ancestral/project.godot`

| # | Línea(s) | Hallazgo | Tipo | Detalle / impacto |
|---|---:|---|---|---|
| 1 | 21-136 | Lista masiva de autoloads hardcodeada (116 entradas singleton en `[autoload]`) | Hardcodeado / mantenibilidad | Cada servicio se registra con ruta fija `*res://scripts/...`. No hay parametrización por perfil/feature flags; habilitar/deshabilitar subsistemas (debug, analytics, bots, etc.) exige editar `project.godot`. Aumenta acoplamiento al arranque, tiempo de carga inicial y riesgo de orden de inicialización implícito. |
| 2 | 115 | `BotPaseoM09="*res://scripts/world/bot_paseo_m09.gd"` | Hardcodeado / posible config de debug | Autoload con nombre de módulo/iteración (`M09`) sugiere herramienta de paseo/prueba permanente en runtime. Si es solo apoyo de desarrollo, debería condicionarse por build/configuración, no vivir fijo en producción. |
| 3 | 143-180 | Sección `[gdscript]` con claves `formatter/*` y `linter/*` no estándar para runtime de Godot 4.7 | Inconsistente / configuración dudosa | Godot 4 no consume estas claves como configuración oficial del motor en `project.godot` (formatter/linter suelen ser de addons/herramientas externas). La presencia de decenas de opciones custom puede ser ignorada por el motor pero ensucia configuración y genera falsa expectativa de enforcement. |
| 4 | 171 | `linter/warnings=PackedStringArray(...)` extremadamente largo, con nombres de warning inventados/no reconocibles | Valor hardcodeado inválido o sin efecto | Incluye entradas como `rendering_warning`, `linear_warning` repetido, advertencias matemáticas genéricas (`sin_warning`, `lerp_warning`, etc.) y otras que no corresponden a warnings GDScript estándar. Riesgo: configuración inefectiva, ruido documental y posible confusión al depurar calidad real. |
| 5 | 207-211, 227-231 | Colisión de binding: `interactuar` y `equipamiento` usan la misma tecla física `E` (`physical_keycode` 69) | Inconsistente funcional | Ambas acciones mapean a `Key E` (líneas 209 y 229). Puede provocar activación ambigua, conflictos de input o comportamiento dependiente de orden/prioridad. Deberían separarse o unificarse explícitamente. |
| 6 | 138-142 | `[display]` define solo `stretch/mode` y `stretch/aspect`; faltan `window/size/viewport_*` y modo de ventana explícito | Hardcodeado parcial / valores por defecto implícitos | Resolución base, tamaño inicial y modo ventana quedan a defaults del motor/editor. Para consistencia entre entornos conviene declararlos explícitamente como configuración de proyecto. |
| 7 | 342-345 | `[physics]` fija `3d/physics_engine="Jolt Physics"` sin parámetros de tick/rendimiento asociados | Hardcodeado de motor físico | Elección válida, pero no se acompañan de ajustes explícitos (`physics/common/physics_ticks_per_second`, `max_physics_steps_per_frame`, etc.), dejando comportamiento temporal al default. |
| 8 | 353-355 | `[rendering]` solo define `rendering_device/driver.windows="d3d12"` | Hardcodeado por plataforma | Fuerza backend D3D12 en Windows sin declarar fallback/preferencias para otras plataformas ni opciones de calidad (AA, sombras, escalado). Configuración mínima que delega mucho al default. |
| 9 | 14 | `config/version="0.0.6"` | Hardcodeado | Versión embebida en archivo de proyecto; aceptable, pero requiere actualización manual disciplinada (no derivada de pipeline/variable única). |
| 10 | 15 | `run/main_scene="res://scenes/main_island.tscn"` | Hardcodeado | Escena principal fija; correcto para juego, pero no configurable por perfil (dev/test/demo) sin editar el archivo. |

**Resumen (1):** hay inconsistencias reales de configuración (conflicto de input E, sección `[gdscript]` con claves/valores no confiables, ausencia de layout de buses/audio y de ajustes de rendering/física explícitos) y múltiples valores hardcodeados que serían mejores como variables/configuración externa, feature flags o perfiles.

---

## 2. Archivos `.gdshader` / `.gdshaderinc` — sintaxis y variables

### 2.1 Alcance encontrado en el juego
- **Shaders del juego (`game/isla-ancestral/shaders/`):**
  - `game/isla-ancestral/shaders/agua_olas.gdshader` (97 líneas)
  - `game/isla-ancestral/shaders/agua_olas.gdshader.uid` (metadato)
  - `game/isla-ancestral/shaders/caustics.gdshader` (39 líneas)
  - `game/isla-ancestral/shaders/caustics.gdshader.uid` (metadato)
  - `game/isla-ancestral/shaders/oceano.gdshader` (34 líneas)
  - `game/isla-ancestral/shaders/oceano.gdshader.uid` (metadato)
  - `game/isla-ancestral/shaders/wind_vegetacion.gdshader` (24 líneas)
  - `game/isla-ancestral/shaders/wind_vegetacion.gdshader.uid` (metadato)
- **`.gdshaderinc`:** no se encontraron archivos `.gdshaderinc` dentro de `game/isla-ancestral/`.
- **Nota:** existen muchos `.gdshader` adicionales en `.claude/skills/` y `.kilo/worktrees/.../.claude/skills/` (biblioteca de skills/copias), fuera del juego ejecutable principal; no se reportan como shaders del proyecto `game/isla-ancestral`.

### 2.2 Revisión por archivo

| Archivo | Líneas relevantes | Estado | Observaciones |
|---|---:|---|---|
| `game/isla-ancestral/shaders/agua_olas.gdshader` | 1-97 | Sin errores de sintaxis evidentes (análisis estático) | Declara `shader_type spatial`, uniforms, varyings y usa built-ins válidos en Godot 4 (`TIME`, `MODEL_MATRIX`, `VERTEX`, `NORMAL`, `VIEW`, `SCREEN_UV`, `INV_PROJECTION_MATRIX`, `ALBEDO`, `ALPHA`, `SPECULAR`, `ROUGHNESS`, `EMISSION`). `depth_texture` con `hint_depth_texture` es correcto para muestreo de profundidad. Comentarios presentan mojibake en texto (encoding de comentarios), pero no afecta tokens del shader. |
| `game/isla-ancestral/shaders/caustics.gdshader` | 1-39 (uso en 35) | **Posible variable/builtin no declarada: `ALBEDO_UV`** | Línea 35: `vec2 uv = ALBEDO_UV;` En shaders `spatial` de Godot 4 el builtin estándar para coordenadas es `UV` (y `UV2`); `ALBEDO_UV` no es un varying/builtin de lectura estándar en `fragment()`. **Riesgo alto de error de compilación del shader** o comportamiento no definido según versión. Corrección probable: `vec2 uv = UV;` |
| `game/isla-ancestral/shaders/oceano.gdshader` | 1-34 | Sin errores de sintaxis evidentes (análisis estático) | Shader simple: modifica `VERTEX.y` en `vertex()` y `ALBEDO/SPECULAR/ROUGHNESS/METALLIC` en `fragment()`. No usa variables no declaradas; lógica y uniforms coherentes. |
| `game/isla-ancestral/shaders/wind_vegetacion.gdshader` | 1-24 (uso en 20-22) | Sin error de sintaxis claro; advertencia menor de uso de hints | `uniform vec3 direccion_viento : source_color = vec3(...)` (línea 15): `source_color` es hint típico para `vec3/vec4` color; usarlo en vector de dirección es inusual pero no necesariamente inválido. Usa `UV`, `TIME`, `POSITION`, `VERTEX` correctamente. `m = clamp(UV.y, 0.0, 1.0)` asume convención de UV (base/copa) que debe coincidir con mallas. |

**Conclusión (2):** el hallazgo técnico más relevante es `ALBEDO_UV` en `caustics.gdshader:35` (probable referencia inválida/no declarada en Godot 4 spatial). El resto no muestra errores de sintaxis obvios en inspección estática, aunque se recomienda compilar/validar en editor/Godot headless.

---

## 3. Configuraciones de renderizado que pueden afectar rendimiento

**Archivo:** `game/isla-ancestral/project.godot`

| Línea(s) | Configuración | Observación de rendimiento |
|---:|---|---|
| 16 | `config/features=PackedStringArray("4.7", "Forward Plus")` | Forward+ habilita iluminación y efectos avanzados; mayor costo GPU/CPU que Mobile/Compatibility. Adecuado para calidad, pero sensible en hardware modesto si no se ajusta calidad. |
| 353-355 | `[rendering]` → `rendering_device/driver.windows="d3d12"` | Fuerza D3D12 en Windows. Puede ser beneficioso en GPUs modernas, pero elimina selección automática/fallback por driver; en equipos problemáticos puede impactar estabilidad o rendimiento. No hay configuración equivalente explícita para otras plataformas. |
| (ausente) | Sin claves explícitas de AA (`rendering/anti_aliasing/*`, MSAA/TAA/FXAA) | Se usan defaults del motor/renderer. Sin control explícito del costo de antialiasing (importante en Forward+). |
| (ausente) | Sin claves explícitas de sombras (`rendering/lights_and_shadows/*`, resolución, filtros) | Calidad/costo de sombras queda al default; puede ser alto o inconsistente según escena. |
| (ausente) | Sin `application/run/max_fps` ni VSync explícito (`display/window/vsync/*`) | Sin tope de FPS ni política de sincronía declarada: posible consumo innecesario de GPU, calor y variabilidad de frame pacing. |
| (ausente) | Sin ajustes de escalado de render (`viewport` scaling, FSR/upscaling, `rendering/scaling_3d/*`) | En escenas 3D exigentes, la falta de escalado dinámico/fijo configurable reduce margen de optimización. |
| (ausente) | Sin `physics/common/physics_ticks_per_second` / `max_physics_steps_per_frame` en `[physics]` o `[application]` | Tasa física por defecto puede ser más costosa o menos estable de lo necesario; impacta CPU y consistencia en cargas altas. |
| 342-345 | `3d/physics_engine="Jolt Physics"` | Motor moderno y generalmente eficiente, pero su perfil real depende de escena/colisiones; sin parámetros de tuning declarados es difícil garantizar presupuesto de rendimiento. |
| 138-141 | `window/stretch/mode="canvas_items"`, `aspect="expand"` | Decisión de escalado UI/viewport correcta para adaptabilidad, pero combinada con defaults de render puede escalar costo de fillrate según resolución de ventana. |

**Resumen (3):** la configuración de renderizado es mínima y delega en defaults: Forward+ + D3D12 forzado + ausencia de límites/ajustes explícitos (FPS/VSync, AA, sombras, escalado 3D, ticks físicos) son los puntos con mayor potencial impacto en rendimiento y predictibilidad.

---

## 4. Configuraciones de audio en `project.godot` que no se usan

**Archivo:** `game/isla-ancestral/project.godot`

| Línea(s) | Elemento | Análisis |
|---:|---|---|
| 88, 101-105 | Autoloads de audio: `AudioConfig`, `MusicDirector`, `AmbientDirector`, `SFXManager`, `FeedbackDirector`, `NarrativeSound` | El proyecto declara un subsistema de audio amplio (6 singletons), pero **no hay sección `[audio]`** en `project.godot` ni referencia a layout de buses. |
| (ausente) | `audio/buses/default_bus_layout` | No se encontró configuración de bus layout en `project.godot`. |
| (filesystem) | `default_bus_layout.tres` / `*.bus_layout.tres` en `game/isla-ancestral/` | **No existe** `default_bus_layout.tres` en la raíz del proyecto de juego (búsqueda sin resultados). Esto sugiere que la infraestructura de buses personalizada no está configurada a nivel de proyecto, aunque existan autoloads de audio. |
| 171 | Warnings con términos `audio_warning`, `video_warning`, etc. dentro de `linter/warnings` | No son configuraciones de audio del motor; forman parte de una lista de linter no estándar (ver punto 1.4) y **no configuran ni activan audio**. |

**Conclusión (4):** en `project.godot` no hay configuraciones de audio del motor efectivas (sin `[audio]`, sin `default_bus_layout` declarado ni archivo de layout en el proyecto). Los autoloads de audio sí están registrados, pero la capa de configuración de buses/mezcla a nivel proyecto parece ausente o no enlazada, lo que puede implicar dependencia de buses por defecto o configuración solo en runtime/scripts.

---

## 5. Sugerencias de mejora (2)

1. **Corregir input conflictivo y sanear configuración inválida en `project.godot`**  
   - **Archivos/líneas:** `game/isla-ancestral/project.godot:207-211,227-231` (remapear `equipamiento` o `interactuar` para no compartir `E`), `game/isla-ancestral/project.godot:143-180` y especialmente `171` (eliminar o reemplazar `linter/warnings` por un conjunto válido/gestionado por la herramienta real; retirar claves `formatter/*`/`linter/*` no soportadas si no las consume ningún addon activo).  
   - **Beneficio:** evita ambigüedad de controles, reduce configuración muerta/engañosa y mejora mantenibilidad.

2. **Declarar perfil de render/audio explícito y corregir el shader de caustics**  
   - **Archivos/líneas:** `game/isla-ancestral/project.godot:353-355` y secciones nuevas sugeridas (`[audio]`, ajustes de `display/window/vsync`, límites FPS, opciones de AA/sombras/escalado según objetivo), crear/vincular `default_bus_layout.tres` si se usarán buses; `game/isla-ancestral/shaders/caustics.gdshader:35` cambiar `ALBEDO_UV` → `UV`.  
   - **Beneficio:** comportamiento más predecible y optimizable entre máquinas, base correcta para mezcla de audio por buses, y eliminación de un posible fallo de compilación del shader de caustics.

---

## Conclusión final

El análisis estático de `game/isla-ancestral/project.godot` y los shaders del juego muestra una base funcional pero con **deuda de configuración**: (1) colisión de input (`E` compartida en líneas 207-211 y 227-231), (2) bloque `[gdscript]` con lista de linter inflada/no estándar (línea 171) y claves probablemente no efectivas para Godot 4.7, (3) configuración de render/audio mínima (solo driver D3D12 en línea 355, sin layout de buses ni ajustes de rendimiento explícitos) y (4) un problema puntual en shaders: `caustics.gdshader` usa `ALBEDO_UV` (línea 35), builtin probablemente no válido en Godot 4 spatial, con riesgo de compilación. Se recomienda priorizar la corrección del conflicto de input, la limpieza de `project.godot`, la formalización de un perfil de render/audio y la validación en editor/Godot de los 4 shaders (`agua_olas.gdshader`, `caustics.gdshader`, `oceano.gdshader`, `wind_vegetacion.gdshader`).
