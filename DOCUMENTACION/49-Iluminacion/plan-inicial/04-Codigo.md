**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 49: Iluminación

> Rutas previstas dentro de `Assets/_Project/` (estructura del proyecto Godot 4.x, ver AGENTS.md §24).
> ⚠️ **Estado: Pendiente de implementación.** Los archivos listados son diseño/documentación; no existe código runtime todavía.

## 1. Archivos Previstos

### 1.1 Servicios (autoload) — `Assets/_Project/Services/`

| Archivo | Propósito | Estado |
|---|---|---|
| `lighting_service.gd` | Aplica presets de franja/clima/bioma a luces globales con easing; único dueño de direccionales y ambiente | Pendiente de implementación |

### 1.2 Presets y perfiles — `Assets/_Project/Lighting/`

| Archivo | Contenido | Estado |
|---|---|---|
| `presets/franjas_alba.tres` (+ dia, atardecer, noche, profunda) | Config de direccional, ambiente, niebla por franja | Vacía — pendiente |
| `presets/niebla_por_bioma.tres` | Densidad y color de niebla por los 13 biomas | Vacía — pendiente |
| `profiles/interior_casa.gd` | Luz de interior de casas (baked + dinámicas mínimas) | Pendiente de implementación |
| `profiles/interior_templo.gd` | Rayo cenital, bajorrelieves, ambience por sala | Pendiente de implementación |
| `profiles/subterraneo.gd` | Cuevas: piso 0.15, esporas, transición gradual | Pendiente de implementación |
| `materials/sky_material.tres` | Sky procedural por bioma (M09) | Vacía — pendiente |
| `materials/environment.tres` | WorldEnvironment base (tonemapping ACES) | Vacía — pendiente |

### 1.3 Luces dinámicas (pool) — `Assets/_Project/Lighting/dynamic/`

| Archivo | Propósito | Estado |
|---|---|---|
| `light_pool.gd` | Pool de luces dinámicas reutilizables (M62) | Pendiente de implementación |
| `luz_farol.gd` | Flicker determinista de faroles (fase + semilla) | Pendiente de implementación |
| `luz_fuego.gd` | Flicker cálido de hogueras/chimeneas | Pendiente de implementación |
| `luz_cristal.gd` | Luz ambiental sutil de cristales/glifos (M47) | Pendiente de implementación |

### 1.4 Registro y validación — `Assets/_Project/Lighting/budget/` + `Assets/_Project/Editor/`

| Archivo | Contenido | Estado |
|---|---|---|
| `budget/lighting_budget.json` | Luces, sombras, memoria por escena (RF16) | Vacía — pendiente |
| `validate_lighting.gd` | Validador: límites, piso ambiental, niebla, flicker, registro | Pendiente de implementación |

## 2. Funciones Clave (firmas GDScript previstas)

```gdscript
# ---------- lighting_service.gd (autoload) ----------
class_name LightingService
extends Node

const PISO_ANTI_OSCURIDAD := 0.15  # regla M31

var _direccional: DirectionalLight3D
var _env_sky: WorldEnvironment

func setup_global(sun: DirectionalLight3D, env: WorldEnvironment) -> void:
    # 1) registrar sol/luna (una direccional) y el environment global
    # 2) suscribirse a eventos: FRANJA_CAMBIADA (M31), CLIMA_CAMBIADO (M32)
    # 3) aplica preset inicial con easing inmediato
    pass

func _on_franja_cambiada(franja: StringName) -> void:
    # 1) preset = load("presets/franjas_" + franja + ".tres")
    # 2) tween de 3 s: elevation/color/intensidad de la direccional,
    #    color/intensidad del ambiente, densidad/color de niebla
    # 3) clamp ambiente >= PISO_ANTI_OSCURIDAD
    # 4) log LIT-FRANJA
    pass

func entrar_perfil(perfil: StringName) -> void:
    # perfiles: interior_casa, interior_templo, subterraneo, exterior
    # 1) si perfil interior: direccional a 0, ambiente del perfil
    # 2) cargar profile script de la escena (luces del perfil)
    # 3) al salir restaurar presets por franja
    pass
```

```gdscript
# ---------- light_pool.gd (pool de faroles/fuego) ----------
class_name LightPool
extends Node

const MAX_DINAMICAS := 20
const MAX_CONT_SOMBRA := 6

func obtener(tipo: StringName, pos: Vector3) -> OmniLight3D:
    # 1) buscar luz libre en el pool, si no crear (con tope MAX_DINAMICAS)
    # 2) aplicar flicker del tipo (luz_farol/luz_fuego/luz_cristal)
    return null

func desactivar_lejanas(radio: float = 30.0) -> void:
    # desactiva luces por distancia a la cámara (M61)
    pass
```

```gdscript
# ---------- validate_lighting.gd (EditorTool) ----------
class_name LightingValidator
extends RefCounted

func validar_escena(escena: Node3D) -> Array[String]:
    var errores: Array[String] = []
    # 1) contar omni/spot con shadows => MAX_CONT_SOMBRA (6)
    # 2) contar luces dinámicas totales => MAX_DINAMICAS (20)
    # 3) ambiente mínimo de Environment >= PISO_ANTI_OSCURIDAD (0.15)
    #    en perfiles interiores (siempre legible, M31)
    # 4) niebla entre rango esperado según bioma/franja del registro
    # 5) flicker: amplitud <= 15% y frecuencia <= 2 Hz (M58)
    # 6) actualizar lighting_budget.json con luces/sombras/memoria
    return errores
```

## 3. Señales y Eventos

| Evento | Emisor | Consumidor |
|---|---|---|
| `FRANJA_CAMBIADA(nueva_franja)` | GameClock (M31) | LightingService |
| `CLIMA_CAMBIADO(clima)` | ClimaService (M32) | LightingService (dim solar, niebla) |
| `PERFIL_ILUMINACION(perfil)` | Entrada/exterior (M28/M26) | LightingService |
| `lighting_budget_actualizado` | Validador | Logging M103, build CI M118 |

## 4. Logs Relacionados

| Log | Contexto | Nivel |
|---|---|---|
| `LIT-FRANJA` | transición de franja aplicada (valores finales) | INFO |
| `LIT-PERFIL` | perfil de escena activado/desactivado | INFO |
| `LIT-BUDGET` | presupuesto de luces por escena actualizado | INFO |
| `LIT-REJECT` | escena rechazada por validador (límites) | WARN |

## 5. Dependencias de Implementación

| Necesita | Módulo | Uso |
|---|---|---|
| Godot 4.x (>= 4.4.1) | M04 | DirectionalLight3D, OmniLight3D, WorldEnvironment, LightmapGI |
| Franjas horarias | M31 | Evento FRANJA_CAMBIADA |
| Clima | M32 | Dim solar y niebla en lluvia |
| Biomas | M09 | Sky y niebla por bioma |
| Mundo voxel | M08/M10 | Meshes estáticos para baked |
| Escenas estáticas | M18/M24/M25/M26 | Lightmaps e interiores |
| Materiales | M47 | Emisivos de cristales/glifos |
| VFX | M52 | Luz de fuego + partículas |
| Presupuestos | M61/M62 | Luces/sombras/memoria |
| Config gráfica | M90 | Presets de calidad y opciones |
| Accesibilidad | M58 | Flicker y opciones de luces |
| Import/bake | M108/M118 | Bake de lightmaps en CI |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentado (diseño completo, checklist completo en 05-Checklist.md)

### Lo que hice
- Documentación completa del módulo 49-Iluminación (5 archivos en plan-inicial y plan-actual).
- Presets por las 5 franjas de M31 (con valores de referencia calibrables), perfiles por tipo de escena (interior casa, templo, subterráneo, exterior), pool de luces dinámicas con flicker determinista, límites duros (≤6 con sombra, ≤20 totales), baked lightmaps para estáticos, niebla por bioma (M09/M32) y sombras con bias voxel sin acne.
- Integrado con M31/M32/M09 (día/clima/biomas), M18/M24/M25/M26 (interiores), M61/M62 (presupuestos), M58/M90 (accesibilidad y presets) y M47/M52 (materiales luminosos y VFX).

### Lo que NO pude hacer
- No implementé `lighting_service.gd`, el pool ni los validadores (se implementan en el hito M1).
- No calibré los valores exactos de luz (elevación, intensidades) — quedan como referencia para la implementación y calibración visual en M1.

### Recomendaciones para el próximo agente
- Implementar primero el LightingService con las 5 franjas y la regla anti-oscuridad (piso 0.15) end-to-end en una escena de pueblo.
- Coordinar el bake de lightmaps con M108/M118 antes de producir interiores masivos.
- Validar bias de sombras del voxel temprano (acne es el riesgo más visible).
- Considerar QA cruzado (sección 21.8) por otro modelo.