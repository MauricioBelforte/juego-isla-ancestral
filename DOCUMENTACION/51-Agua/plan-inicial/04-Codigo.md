**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 51: Agua

> Rutas previstas dentro de `Assets/_Project/` (estructura del proyecto Godot 4.x, ver AGENTS.md §24).
> ⚠️ **Estado: Pendiente de implementación.** Los archivos listados son diseño/documentación; no existe código runtime todavía.

## 1. Archivos Previstos

### 1.1 Config de tipos — `Assets/_Project/Water/types/`

| Archivo | Contenido | Estado |
|---|---|---|
| `agua_oceano.tres` · `agua_rio.tres` · `agua_lago.tres` | Parámetros de shader por tipo (color, opacidad, olas, espuma) | Vacía — pendiente |
| `agua_cascada.tres` · `agua_subterranea.tres` · `agua_hielo.tres` · `agua_termal.tres` | Ídem | Vacía — pendiente |

### 1.2 Render del océano — `Assets/_Project/Water/ocean/`

| Archivo | Propósito | Estado |
|---|---|---|
| `ocean_mesh.gd` | Mesh de agua por chunk con LOD y culling | Pendiente de implementación |
| `olas.gd` | Fase fija + semilla por cuerpo de agua | Pendiente de implementación |

### 1.3 Ríos y corrientes — `Assets/_Project/Water/river/`

| Archivo | Propósito | Estado |
|---|---|---|
| `river_spline.gd` | Spline de río de M10 → geometría y flujo | Pendiente de implementación |
| `current.gd` | Fuerza de corriente sobre M70 (objetos) y M28/M67 (barcos) | Pendiente de implementación |

### 1.4 Estados del agua — `Assets/_Project/Water/state/`

| Archivo | Propósito | Estado |
|---|---|---|
| `water_state.gd` | Nivel por cuerpo: inundación/drenaje (puzzles M24), evaporación | Pendiente de implementación |
| `hielo.gd` | Congelamiento estacional (M29/M32) + límites anti-softlock (M66) | Pendiente de implementación |
| `cascada.gd` | VF de caída + partículas (M52) + sonido (M42) | Pendiente de implementación |

### 1.5 Física — `Assets/_Project/Water/physics/`

| Archivo | Propósito | Estado |
|---|---|---|
| `water_surface.gd` | Plano físico por chunk: flotación de M11 (jugador) y M70 (objetos) | Pendiente de implementación |

### 1.6 Registro y validación — `Assets/_Project/Water/budget/` + `Assets/_Project/Editor/`

| Archivo | Contenido | Estado |
|---|---|---|
| `budget/water_budget.json` | Verts, probes, overdraw por escena | Vacía — pendiente |
| `validate_water.gd` | Validador: nivel de mar, presupuesto, determinismo | Pendiente de implementación |

## 2. Funciones Clave (firmas GDScript previstas)

```gdscript
# ---------- ocean_mesh.gd ----------
class_name OceanMesh
extends MeshInstance3D

const NIVEL_MAR_GLOBAL: float = 4.0  # valor de M09/M10 (semilla)

func construir_chunk(chunk_pos: Vector3i, nivel_mar: float) -> void:
    # 1) nivel_mar = valor global (M09); desvío por POI NO permitido
    #    (salvo excepciones documentadas M09)
    # 2) grid del mesh con segmentos por LOD (lejano: plano simple)
    # 3) shader M47 con olas: fase = hash(cuerpo_id, semilla_chunk)
    # 4) registrar en water_budget.json (verts, overdraw)
    pass

func aplicar_lod(distancia: float) -> void:
    # LOD1: plano sin olas (detalle bajo) > 80 m; LOD0 con olas cerca
    pass
```

```gdscript
# ---------- water_state.gd (nivel por cuerpo) ----------
class_name WaterState
extends Node

func fijar_nivel(cuerpo: StringName, nivel_objetivo: float, duracion: float) -> void:
    # 1) tween del nivel actual → objetivo (easing determinista)
    # 2) actualizar olas/espuma/corrientes según nivel
    # 3) notificar a fauna (M36/M65) y barcos (M28/M67)
    # 4) log WATER-NIVEL
    pass

func inundar(cantidad: float, origen: StringName) -> void:
    # lluvia (M32) o puzzle (M24): sube nivel con tope por cuerpo
    pass

func drenar(cantidad: float, origen: StringName) -> void:
    # puzzle o evaporación (desierto M32): baja nivel, nunca < fondo
    pass
```

```gdscript
# ---------- hielo.gd (congelamiento estacional) ----------
class_name Hielo
extends Node

func _on_estacion_cambiada(estacion: StringName) -> void:
    # 1) invierno: congelar cuerpos congelables (fade 10 s)
    # 2) collider sólido + sonido crujido (M42)
    # 3) verificar salidas: nunca cubrir zonas de progresión (M66)
    pass

func derretir_con_fuego(pos: Vector3) -> void:
    # antorcha (M13) derrite celda puntual (determinista)
    pass
```

```gdscript
# ---------- validate_water.gd (EditorTool) ----------
class_name WaterValidator
extends RefCounted

func validar_chunk(chunk_pos: Vector3i) -> Array[String]:
    var errores: Array[String] = []
    # 1) nivel de mar == global (tolerancia ± 0.01 m)
    # 2) verts <= 2.000; probes <= 2; overdraw <= 1.5x (M61)
    # 3) determinismo: fase reproducible con misma semilla
    # 4) hielo: sin cobertura de zonas de progresión (M66)
    return errores
```

## 3. Señales y Eventos

| Evento | Emisor | Consumidor |
|---|---|---|
| `NIVEL_AGUA(cuerpo, nivel)` | WaterState | OceanMesh, cascadas, M70, M28/M67 |
| `CHAPOTEO(actor, intensidad)` | WaterSurface | Sonido M42, partículas M52 |
| `CONGELADO(cuerpo, estado)` | Hielo | M11 (física), M42, M66 |
| `ESTACION_CAMBIADA` / `CLIMA_CAMBIADO` | M29/M32 | Hielo, evaporación, cascada |

## 4. Logs Relacionados

| Log | Contexto | Nivel |
|---|---|---|
| `WATER-CHUNK` | mesh de chunk construido (verts, LOD) | INFO |
| `WATER-NIVEL` | nivel de cuerpo cambiado (origen, duración) | INFO |
| `WATER-HIELO` | congelamiento/derretimiento (cuerpo, motivo) | INFO |
| `WATER-PUZZLE` | compuerta accionada (cuerpo, nivel final) | INFO |
| `WATER-REJECT` | chunk rechazado por validador | WARN |

## 5. Dependencias de Implementación

| Necesita | Módulo | Uso |
|---|---|---|
| Godot 4.x (>= 4.4.1) | M04 | MeshInstance3D, shaders, physics |
| Nivel de mar y splines | M09/M10 | Altura global, geometría de ríos |
| Shader de agua | M47 | agua.gdshader por tipo |
| Natación | M11 | Flotación y sprint |
| Ítems de agua | M13/M14/M15/M33 | Balde, botella, riego |
| Puzzles | M24 | Compuertas, canales, pools |
| Barcos | M28/M67 | Flotabilidad y deriva |
| Fauna | M36/M65 | Natación de peces |
| Clima/estaciones | M29/M31/M32 | Hielo, inundación, evaporación |
| Sonido/partículas | M42/M52 | Chapoteo, rocío, cascadas |
| Presupuestos | M61/M62 | Verts, overdraw, memoria |
| Anti-softlock | M66 | Límites del hielo |
| Objetos sueltos | M70 | Flotación y corrientes |
| Import/CI | M108/M118 | Validación |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentado (diseño completo, checklist completo en 05-Checklist.md)

### Lo que hice
- Documentación completa del módulo 51-Agua (5 archivos en plan-inicial y plan-actual).
- Catálogo de los 7 tipos de agua del plan maestro (sección 50: océano, río, lago, cascada, subterránea, congelada, especial/termal), nivel de mar global consistente (M09/M10), mesh por chunk con olas GPU y espuma costera, reflejos ≤2 probes y refracción solo en puzzles (M24), corrientes por spline que mueven objetos (M70) y barcos (M28/M67), estados estacionales/climáticos (hielo con anti-softlock M66, inundación, evaporación), física de flotación (M11), sonidos (M42) y partículas (M52).
- Integrado con M08/M09/M10/M11/M24/M28/M29/M31/M32/M36/M42/M47/M52/M61/M62/M66/M70.

### Lo que NO pude hacer
- No implementé `ocean_mesh.gd`, `water_state.gd`, `hielo.gd` ni el validador (se implementan en el hito M1).
- No definí el valor exacto del nivel de mar (depende de la calibración de M09/M10 en M1).

### Recomendaciones para el próximo agente
- Implementar primero el océano (nivel global + mesh por chunk + shader M47) y verificar consistencia entre chunks.
- Coordinar con M24 los puzzles de agua antes de implementar compuertas.
- Probar el hielo estacional temprano para validar anti-softlock (M66).
- Considerar QA cruzado (sección 21.8) por otro modelo.