**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 50: Vegetación

> Rutas previstas dentro de `Assets/_Project/` (estructura del proyecto Godot 4.x, ver AGENTS.md §24).
> ⚠️ **Estado: Pendiente de implementación.** Los archivos listados son diseño/documentación; no existe código runtime todavía.

## 1. Archivos Previstos

### 1.1 Catálogo y datos — `Assets/_Project/Vegetation/catalog/`

| Archivo | Contenido | Estado |
|---|---|---|
| `especies.tres` | 26+ especies: malla (M45), slots (M47), biomas, params de densidad | Vacía — pendiente |
| `densidades_bioma.tres` | Tabla bioma → especie → densidad/altura/pendiente | Vacía — pendiente |

### 1.2 Generación y runtime — `Assets/_Project/Vegetation/`

| Archivo | Propósito | Estado |
|---|---|---|
| `generation/vegetation_placer.gd` | Placement determinista por chunk (PRNG M10) | Pendiente de implementación |
| `runtime/vegetation_manager.gd` | Manager global: MultiMesh por especie × chunk, culling, LOD | Pendiente de implementación |
| `runtime/viento_shader.gdshader` | Vertex shader de viento GPU (fase por instancia) | Pendiente de implementación |
| `runtime/vegetation_lod.gd` | LOD 2 niveles + culling por distancia | Pendiente de implementación |

### 1.3 Interacción y estaciones — `Assets/_Project/Vegetation/`

| Archivo | Propósito | Estado |
|---|---|---|
| `interaction/tala_falling.gd` | Caída de follaje tras tala (M08), tween 1-2 s | Pendiente de implementación |
| `interaction/hierba_pisada.gd` | Hierba flectada transitoria (M11) | Pendiente de implementación |
| `interaction/recoleccion_flores.gd` | Flores cosechables (M33) | Pendiente de implementación |
| `interaction/regeneracion.gd` | Deltas + regeneración por eventos de juego | Pendiente de implementación |
| `seasons/season_vegetation.gd` | Tint por estación con fade (M29) | Pendiente de implementación |

### 1.4 Registro y validación — `Assets/_Project/Vegetation/budget/` + `Assets/_Project/Editor/`

| Archivo | Contenido | Estado |
|---|---|---|
| `budget/vegetation_budget.json` | Instancias, draw calls, VRAM por chunk/escena | Vacía — pendiente |
| `validate_vegetation.gd` | Validador: densidad real vs tabla, LOD, presupuesto, arte sucio | Pendiente de implementación |

## 2. Funciones Clave (firmas GDScript previstas)

```gdscript
# ---------- vegetation_placer.gd ----------
class_name VegetationPlacer
extends RefCounted

func generar_chunk(chunk_pos: Vector3i, bioma: StringName, semilla_chunk: int) -> void:
    # 1) especies = densidades_bioma.tres[bioma] (M09)
    # 2) para cada especie:
    #    n = _cuenta_instancias(especie, area_chunk)  # PRNG(chunk, especie)
    #    para i en n: pos = _posicionar(prng_ctx, especie)  # filtros:
    #       pendiente <= max, altura en rango, fuera de agua (M51),
    #       fuera de cueva (M10), dentro del chunk (border)
    # 3) y = heightmap + delta_especie (suelo)
    # 4) vegetacion_manager.agregar_especie_chunk(chunk_pos, especie, transforms)
    pass
```

```gdscript
# ---------- vegetation_manager.gd (manager global) ----------
class_name VegetationManager
extends Node

func agregar_especie_chunk(chunk_pos: Vector3i, especie: StringName,
        transforms: PackedVector3Array) -> void:
    # 1) crear MultiMeshInstance3D por (especie, chunk) si no existe
    # 2) asignar instancia transforms (transform + tint de estación)
    # 3) aplicar shader viento (fase = hash(instancia, semilla_chunk))
    # 4) registrar en vegetation_budget.json
    pass

func aplicar_lod() -> void:
    # culling por distancia: LOD1 (malla baja) a 24 m, cull a 40 m
    pass

func limpiar_chunk(chunk_pos: Vector3i) -> void:
    # liberar MultiMesh y memoria (M62) cuando el chunk descarga
    pass
```

```gdscript
# ---------- viento_shader.gdshader (vertex) ----------
shader_type spatial;
// amplitud/frecuencia/fase uniformes por instancia:
// INSTANCE_CUSTOM (x = fase, y = amplitud local, z = frecuencia)
// hola = sin(TIME * freq + fase) * amp * suavizado_por_altura_hoja
// bloqueo en nieve/sin viento: amp = 0.2 (M32/M29)
```

```gdscript
# ---------- validate_vegetation.gd (EditorTool) ----------
class_name VegetationValidator
extends RefCounted

func validar_chunk(chunk_pos: Vector3i) -> Array[String]:
    var errores: Array[String] = []
    # 1) densidad real (MultiMesh.instance_count) vs tabla (M09/M50)
    # 2) instancias dentro de agua/cueva (arte sucio) → error
    # 3) LOD presente (2 niveles por especie)
    # 4) presupuesto: instancias visibles, draw calls, VRAM (M61/M62)
    # 5) naming veg_/tree_/foliage_ (M108)
    return errores
```

## 3. Señales y Eventos

| Evento | Emisor | Consumidor |
|---|---|---|
| `CHUNK_VEG_GENERADO(chunk_pos, especie, instancias)` | VegetationPlacer | VegetationManager, logging M103 |
| `TALA_BLOQUE(pos, tipo)` | Jugador (M13/M08) | tala_falling.gd (caída de follaje) |
| `PLANTA_RECOLECTADA(pos, especie)` | Jugador (M33) | recoleccion_flores.gd, inventario M14 |
| `ESTACION_CAMBIADA(estacion)` | Calendario (M29) | season_vegetation.gd (fade) |
| `CLIMA_CAMBIADO(clima)` | ClimaService (M32) | viento (amplitud) + nieve |

## 4. Logs Relacionados

| Log | Contexto | Nivel |
|---|---|---|
| `VEG-GEN` | chunk generado (especie, instancias) | INFO |
| `VEG-LOD` | LOD aplicado (distancia) | DEGUB |
| `VEG-SEASON` | estación aplicada con fade | INFO |
| `VEG-REJECT` | chunk rechazado por validador (dividido en WARN/ERROR) | WARN |
| `VEG-BUDGET` | presupuesto de instancias actualizado | INFO |

## 5. Dependencias de Implementación

| Necesita | Módulo | Uso |
|---|---|---|
| Godot 4.x (>= 4.4.1) | M04 | MultiMesh/MultiMeshInstance3D, shaders |
| Mundo voxel | M08 | Tala y bloques de madera/hojas |
| PRNG por chunk | M10 | Determinismo de placement |
| Biomas | M09 | Tabla de especies por bioma + clamps |
| Mallas/materiales | M45/M47 | Especies y texturas |
| Presupuestos | M61/M62 | Instancias/draw calls/VRAM |
| Viento | M48 | Vertex shader contratado por M48 |
| Estaciones | M29 | Fades de estación |
| Agricultura | M33 | Recolección de flores y cultivos |
| Clima | M32 | Amplitud de viento y nieve |
| Agua | M51 | Plantas acuáticas/submarinas |
| Import/CI | M108/M118 | Validación |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentado (diseño completo, checklist completo en 05-Checklist.md)

### Lo que hice
- Documentación completa del módulo 50-Vegetación (5 archivos en plan-inicial y plan-actual).
- Catálogo de las 26+ especies del plan maestro (sección 49), tablas de densidad por bioma (M09), placement determinista por chunk (PRNG M10), MultiMesh por especie × chunk con LOD y culling, viento GPU con fase por instancia, interacción (tala M08, pisado, recolección M33), estaciones con fade (M29) y regeneración por eventos de juego con deltas.
- Integrado con M08/M09/M10/M33/M29/M32/M51 y presupuestos M61/M62.

### Lo que NO pude hacer
- No implementé `vegetation_manager.gd`, `vegetation_placer.gd` ni el shader de viento (se implementan en el hito M1).
- No definí las densidades numéricas finales por bioma (requieren balance visual posterior).

### Recomendaciones para el próximo agente
- Implementar primero el placer con 3 especies (hierba, flores, árboles) en un chunk y validar draw calls.
- Coordinar con M10 el timing de generación de vegetación (post terreno) y con M08 la tala.
- Validar el shader de viento en la malla alta antes de escalar.
- Considerar QA cruzado (sección 21.8) por otro modelo.