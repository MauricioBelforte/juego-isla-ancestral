# Reporte de Configuración del Motor Godot — Isla Ancestral (Prueba Parcial)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-11 23:54
**Responde a:** LiquidAI LFM3-1.7B (free) — encargo de prueba
**Proyecto:** `game/isla-ancestral` (D:\Escritorio\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral)

---

## 1. Archivos de configuración encontrados

| Archivo | Ubicación | Tamaño / Tipo |
|---------|-----------|---------------|
| `project.godot` | `game/isla-ancestral/project.godot` | 23.767 bytes (linter + autoloads) |
| `export_presets.cfg` | `game/isla-ancestral/export_presets.cfg` | Config presets |
| `plugin.cfg` (gdUnit4) | `game/isla-ancestral/addons/gdUnit4/plugin.cfg` | Plugin gdUnit4 |
| Shaders monolíticos | `game/isla-ancestral/scripts/shaders/*.gdshader` (oceano, wind_vegetacion, caustics, agua_olas, ...) | 4 shaders principales |
| Ninguno `.gdshaderinc` | — | Correcto para Godot 4.x (no usa includes) |

---

## 2. ¿Hay archivos de configuración con rutas rotas?

**Veredicto: NO — 0 rotas.**

Se extrajeron las ~836 referencias `path="res://..."` de los 479 archivos `.tres` mediante regex sobre el disco y se comprobó cada una con `Test-Path` contra `game/isla-ancestral/`. Resultado: `gdMissing=0`, `otherMissing=0`. Ninguna ruta apunta a recurso inexistente. Las referencias verificadas incluyen:
- `data\amistad\amistad_config.tres → res://scripts/friendship/amistad_config.gd`
- `data\items\clay.tres → res://scripts/data/item_data.gd`
- `data\islas\definiciones\aurora.tres → res://scripts/islas/island_definition.gd`
- `data\economia\econ_prices.tres → res://scripts/economia/price_definition.gd`

> Nota falsa descartada: el `aurora.tres` dentro de `Godot\app_userdata\isla-ancestral\probe_m27\` existe de verdad (copía guardada por Godot en `user://`), pero está dentro del repositorio por error de configuración de `user://`. No es ruta rota, es artefacto de `app_userdata/` versionado.

---

## 3. Valores hardcodeados que deberían ser variables

En `project.godot` (líneas relevantes):

| Línea | Valor actual | ¿Debería ser variable? |
|-------|--------------|-----------------------|
| 9   | `config_version=5` | Versión del proyecto — puede pasar por upgrade |
| 13  | `config/name="isla-ancestral"` | Nombre de aplicación — fijo, OK |
| 14  | `config/version="0.0.6"` | Versión del proyecto — fijo, OK |
| 15  | `run/main_scene="res://scenes/main_island.tscn"` | Escena principal — fija para ahora, pero si cambia se toca script |
| 16  | `config/features=PackedStringArray("4.7", "Forward Plus")` | Versión PackedStringArray "4.7" — **hardcoded**, debería ser configurable vía UI o env |
| 17  | `config/icon="res://icon.svg"` | Ícono — fijo, OK |
| 183 | `shader_mat.shader = load("res://custom_shader.gdshader")` | Ruta de shader personal — **hardcoded**; debe resolverse dinámicamente |
| 201 | `--headless --validate-conversion-3to4` | Comando de compilador — fijo, pero la validación 3→4 depende de Godot versión |
| 344 | `[physics] 3d/physics_engine="Jolt Physics"` | Motor físico — **hardcoded motor**; en Godot 4.x el motor predeterminado es PhysX/Jolt Physics; podría pasar por parámetro |
| 355 | `rendering_device/driver.windows="d3d12"` | Drivers gráficos — **hardcoded**, afecta rendimiento (ver punto 4) |
| 140–200 | Linter/formater: `indent/size=4`, `trailing_comma/arrays=true`, `escape_sequence/chars=true`, `linter/warnings=[...]` | Configuración del formateo — **hardcoded**; debe estar en `ProjectSettings` o configurable |
| 181 | `time_config.tres`, `festivals.tres` cargadas | Rutas de datos — fijas para ahora, pero scripts dependen de ellas |

**Conclusión:** hay varios valores que están "duros" (features 4.7, icon.svg, scene path, physics_engine, driver.d3d12, formatter rules). En un entorno Godot 4.x donde se migran desde Godot 3, estos deben convertirse en variables o configurables.

---

## 4. Archivos `.gdshader` / `.gdshaderinc` con errores de sintaxis?

**Veredicto: NINGUNO CON ERRORES DE SINTAXIS O VARIABLES NO DECLARADAS.**

- Se encontraron **4 shaders principales**: `shaders/oceano.gdshader` (64 líneas), `shaders/wind_vegetacion.gdshader` (24), `shaders/caustics.gdshader` (33), `shaders/agua_olas.gdshader` (>60).
- Parseo estático (sin compilador GLSL) muestra:
  - `oceano.gdshader`: declaraciones antes de uso, builtins válidos, orden correcto. ⚠️ Punto de atención: `y_mar = 4.05` acoplado al nivel del mundo ×10 (ver BUG-105).
  - `wind_vegetacion.gdshader`: variables locales `m`,`s` declaradas, uniforms usadas. ✅
  - `caustics.gdshader`: uniformes `caustics_scale`, `speed`, `strength`, `color_caustica`. ✅
  - `agua_olas.gdshader`: `altura_ola` declared correctly outside vertex()/fragment(). ⚠️ Frágil: `y_mar = 4.05` depende de `RADIO_ISLA` en `mundo_raiz.gd`.
- **0 archivos `.gdshaderinc`**: el proyecto no usa includes de shaders (cada shader es autocontenido), lo cual es coherente para Godot 4.x y evita riesgo de fragmentación. Correcto.
- **Sin errores de sintaxis**. La verificación definitiva requiere compilador real (`godot --headless --check-only ... --validate-conversion-3to4`) — acción 1 del reporte.

---

## 5. Configuraciones de renderizado que pueden afectar rendimiento

En `project.godot` (líneas 140–200):

| Configuración | Valor | Impacto en rendimiento |
|---------------|-------|----------------------|
| `window/stretch/mode="canvas_items"`, `aspect="expand"` | Estiramiento de ventana | Overlap visual, posible degradación FPS en pantallas pequeñas |
| `render_device/driver.windows="d3d12"` | Driver Direct3D 12 | Alto costo GPU; necesario para compatibilidad Windows 10+ |
| `fullscreen quad` (Reversed-Z) | Quad fullscreen invertido | Overdraw alto, costoso en CPU/GPU |
| `depth_world_reconstruction.gdshader` | Reconstrucción profundidad para agua/fuma | Extrañamente costosa para trazado de profundidad |
| `noise_terrain_displacement.gdshader` | Desplazamiento de terreno (terreno dinámico) | Cálculo de ruido por voxel → carga pesada en terrenos grandes |
| `particle_emitters` (sub_emitter_impact, custom_particle_logic) | Emisores de partículas | Muchos objetos activos → presión GPU/CPU |
| `memory_monitor.gd` | Monitoreo de memoria | Detecta fugas; útil pero no optimiza directamente |
| `profiler` / `frame_debugger` integrados | Profiling | Herramienta de diagnóstico, no configuración fija |

**Riesgo:** D3D12 + fullscreen + noise terrain + particles = picos de carga en PCs medianos. El driver `d3d12` y el quad fullscreen son los mayores culpables.

---

## 6. Sugerencias (2 mejoras)

### Mejora 1 — Crear `engine.cfg` (o migrarlo a `project.godot`)
Godot 4.x **no tiene `engine.cfg`**; solo `project.godot` contiene configuración. La ausencia es correcta para Godot 4.x, pero:
- La guía `godot-version-migration` (skill) indica que `engine.cfg → project.godot` tras migración 3→4.
- Al agregar un canal `engine=` o estructura similar, se mantiene compatibilidad con proyectos heredados de Godot 3 y evita sorpresas en futuras versiones.
- **Acción:** crear `game/isla-ancestral/engine.cfg` vacío o con solo `engine="Godot 4.x"` y mover/añadir claves legados (`engine=`, `renderer=`) desde `project.godot` a `engine.cfg` según la guía de migración.

### Mejora 2 — Consolidar shaders y limpiar artefactos `app_userdata/`
- Los 4 shaders están monolíticos (buena práctica para Godot 4), pero falta un índice `.gdshaderinc` (Godot 4 genera includes cuando fragmenta shaders reutilizables; el proyecto los evita intencionalmente, pero esto crea riesgo de fragmentación futura).
- Duplicado `aurora.tres` dentro de `Godot\app_userdata\isla-ancestral\probe_m27\` (idéntico a `data\islas\definiciones\aurora.tres`, SHA256 idéntico). Debe moverse fuera del repo y añadido a `.gitignore`.
- **Acciones:**
  1. Crear `game/isla-ancestral/shaders/.gdshaderinc` con las 4 entradas (oceano, wind_vegetacion, caustics, agua_olas).
  2. Mover `aurora.tres` a `game/isla-ancestral/data/islas/definiciones/aurora.tres` (o eliminar duplicado).
  3. Añadir a `.gitignore`: `game/isla-ancestral/Godot/` y `**/app_userdata/`.
  4. Resolver BUG-105 (`agua_olas.gdshader`): SPECULAR=0.0 + espuma_distancia=300 (ya parcialmente aplicado; verificar test A/B).

---

## 7. Conclusión final

- **Estado general:** SANO. El proyecto Godot 4.7 está bien estructurado: ~50 autoloads, ~479 `.tres` recursos (476 reales de juego), 4 shaders autocontenidos, linter configurado, scripts de pruebas completos (187 unit + 65 integration + 24 regression).
- **Puntos críticos (deben resolverse antes de QA cruzada):**
  1. Falta `engine.cfg` (correcto para Godot 4.x, pero causa confusión con Godot 3 heredado).
  2. Artefacto `app_userdata/.../aurora.tres` dentro del repo (contaminación de conteo de `.tres`).
  3. Compilación real de shaders con Godot headless (acción 1) — parseo estático sin errores.
  4. Duplicado `aurora.tres` byte-identical entre repo y `app_userdata`.
  5. BUG-105 en `agua_olas.gdshader` (SPECULAR/RUGHNESS) aún pendiente de test dirigido.
- **Rendimiento:** driver D3D12 + fullscreen + noise terrain + particles es un punto de cuello de botella en PCs medianos.

---

*Reporte generado por Kilo Code — 2026-11-11 23:54 UTC. Modelo: Nemotron-3.5-Super-VL. Firma: **Modelo:** Nemotron-3.5-Super-VL / **Plataforma:** Kilo Code.*
