**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 33: Agricultura

## 1. Visión general de la arquitectura

Capas desacopladas (M07), lectura unidireccional: Datos (CropDefinition) → Estado (CropTile + FarmStateStore) → Orquestación (FarmService) → Visual/UI (CropTileVisual, HUD agrícola). La UI jamás escribe estado directamente; solo llama a la API de FarmService.

```
┌──────────────────────────────┐
│         CAPA UI (M53)        │  HUD agricola, tooltips, tutorial
└──────────────▲───────────────┘
               │ llamadas API
┌──────────────┴───────────────┐
│       FarmService (servicio) │  autoload (Service Locator)
│  - avance por día (M29)      │
│  - arar/plantar/regar/cosechar│
│  - eventos EventBus delegados │
└──────▲──────────────▲────────┘
       │              │ estado
┌──────┴─────┐  ┌─────┴──────────┐
│ CropTile   │  │ FarmStateStore │  persistencia (GameState M59)
│ (por voxel)│  └───────▲────────┘
└──────▲─────┘          │ datos
       │ instancia      │
┌──────┴──────────────┐ │
│ CropTileVisual      │ │
│ (MultiMesh pool)    │ │
└─────────────────────┘ │
            ┌───────────┴───────────┐
            │ CropDefinition (Resource) │ .tres por cultivo
            └───────────────────────┘
```

## 2. Componentes

### 2.1 CropDefinition (Resource, `class_name CropDefinition extends Resource`)

Datos puros por cultivo, editables en el editor de Godot como `.tres`:

| Campo | Tipo | Descripción |
|---|---|---|
| `crop_id` | StringName | Identificador único (ej: `maiz_ancestral`) |
| `display_name` | String | Nombre mostrado (localizable M87) |
| `description` | String | Tooltip amigable |
| `seasons` | Array[GameClock.Season] | Estaciones donde crece (M29) |
| `grow_days` | int | Días totales hasta lista (sin fertilizante) |
| `stage_count` | int | Cantidad de etapas visuales (2..6) |
| `water_need` | int | Agua requerida por día (1 o 2) para avanzar |
| `yields` | Array[Dictionary] | `{item_id: StringName, amount: int, chance_quality: ...}` |
| `yield_seeds` | Dictionary | Semilla y cantidad reproducidas al cosechar |
| `quality_levels` | bool | Si el cultivo expone calidades COMUN/BUENA/EXCELENTE |
| `is_tree` | bool | Árbol frutal (perenne, no requiere replantar) |
| `is_flower` | bool | Flor decorativa / sujeta a cruce (híbrido M32 agrícola) |
| `is_ancestral` | bool | Planta ancestral con desbloqueo narrativo (M22) |
| `decorative_only` | bool | No produce ítems (ornamental) |
| `fertilizer_bonus` | int | Días que reduce al aplicar fertilizante (módulo ferm M13) |

**Catálogo inicial (M15):** tomate, maíz, trigo, calabaza, zanahoria, uva, algodón (fibra), flor de coral (isla), crisantemo (otoño), margarita, rosa híbrida, árbol de manzanas, árbol de duraznos, palma de coco (isla tropical), planta ancestral de lumina (desbloqueable). ~16 definiciones base, ampliable.

### 2.2 GrowthStage (enum + Resource de datos)

Identidad de etapas global, usada por CropTile y visuales:

```gdscript
enum GrowthStage {
    SEMILLA,      # 0: recién plantado
    Brote,        # 1: primer tallo
    CRECIENDO,    # 2: crecimiento medio
    MADURA,       # 3: madurando (falta 1 día)
    LISTA,        # 4: cosechable
    DORMANTE,     # 5: fuera de estación (pausado, no muere)
    SIN_AGUA      # 6: pausado por falta de agua (se retoma al regar)
}
```

Nota: los nombres se escriben con mayúsculas reducidas para cumplir la convención GDScript del proyecto (M111); el par `SEMILLA = 0` se declara con `enum` explícito para no depender de orden.

Regla: DORMANTE y SIN_AGUA **no avanzan ni retroceden** la cuenta de días; al salir del estado retoman desde la misma etapa y los mismos días acumulados.

### 2.3 CropTile (referencia de estado por voxel)

Objeto ligero (RefCounted, no Node) que representa el estado de UN voxel cultivado:

```gdscript
class_name CropTile extends RefCounted

var voxel_pos: Vector3i        # coordenada del bloque de tierra arada (M08)
var crop_def: CropDefinition   # definición (no se copia: referencia al catálogo)
var stage: int                 # índice de GrowthStage
var grown_days: int            # días acumulados en etapas activas
var water_level: int           # 0..2 (riego manual + lluvia M32)
var fertilized: bool
var quality: int               # 0 COMUN / 1 BUENA / 2 EXCELENTE (si aplica)
var planted_at_day: int        # índice de día del calendario (M29) al plantar
```

Métodos puros: `current_stage_index()`, `is_ready()`, `is_paused()`, `can_advance_today(season, weather)`, `apply_daily_tick(season, rain: bool)` → devuelve si cambió de etapa (para evento y sonido).

### 2.4 FarmService (autoload, capa de orquestación)

API pública (contrato estable, detalle en sección 4):

```gdscript
class_name FarmService extends Node

## Eventos hacia EventBus (M07) con dominio FARM:
signal crop_planted(crop_id: StringName, voxel_pos: Vector3i)
signal crop_stage_changed(voxel_pos: Vector3i, stage: int)
signal crop_ready(voxel_pos: Vector3i)
signal crop_harvested(voxel_pos: Vector3i, items: Array)
signal tile_tilled(voxel_pos: Vector3i)
signal tile_watered(voxel_pos: Vector3i, water_level: int)
signal day_advanced(day_index: int)

func till_tile(voxel_pos: Vector3i) -> bool                                    # pala (M13)
func plant(crop: CropDefinition, voxel_pos: Vector3i) -> bool                  # consume semilla (M14)
func water(voxel_pos: Vector3i) -> void                                        # regadera (M13)
func apply_rain(voxel_pos: Vector3i) -> void                                   # desde M32
func can_harvest(voxel_pos: Vector3i) -> bool
func harvest(voxel_pos: Vector3i) -> Array[Dictionary]                          # entrega ítems a M14
func get_tile(voxel_pos: Vector3i) -> CropTile
func get_growth_hint(voxel_pos: Vector3i) -> String                            # tooltip amigable
func advance_day() -> void                                                     # suscrito a M29
func reserve_plot(owner_id: int, center: Vector3i, radius: int) -> bool        # parcelas M17
func get_active_farm_stats() -> Dictionary                                     # analytics M104
```

Reglas de negocio del servicio:
1. `till_tile`: solo sobre bloque `TIERRA` del catálogo M08 con cara superior expuesta; valida parcela M17 (parcela libre o del jugador).
2. `plant`: requiere `TIERRA_ARADA`, sin cultivo previo, semilla en inventario M14 (consume 1), y (si aplica) parcela con cupo libre (cupo = parcelas del jugador).
3. `water`: sube `water_level` hasta 2; el agua nunca "se desperdicia" (feedback juguetón de exceso de agua, sin castigo).
4. `harvest`: solo en etapa LISTA; remueve el CropTile, emite `yields` al inventario M14, deja el bloque `TIERRA_ARADA` listo (para árboles frutales queda perenne en `MADURA` y reaparece la fruta a los N días).
5. `advance_day`: itera solo los CropTile activos del jugador (máx 400); por cada uno: resta 1 de agua; si `water_level < water_need` → SIN_AGUA; si la estación no es apta → DORMANTE; si no → `grown_days += 1` y avanza etapa si corresponde; emite evento solo si hay cambio.

### 2.5 CropTileVisual (capa de presentación)

- Registra posiciones por especie y por etapa en un **MultiMesh** (un MultiMeshInstance3D por especie, hasta 16; las instancias rotan/según especie).
- Malla LOD: 2 niveles (cerca completa / lejos simplificada) con el presupuesto de M61.
- Animación cozy: sway suave con `sin(time + offset)` por instancia (shader de instancing) sin costo por nodo.
- Feedback de pisoteo de NPC: agitación de la instancia 1 s, sin pérdida de progreso (evento `M64.npc_stepped_on` → agitar).
- VFX de regar (M52): gotas ligeras; VFX de cosecha: partículas suaves.

## 3. Flujos principales (texto)

### Flujo 1 — Arar y plantar
```
1. Jugador equipa pala (M13) y usa acción primaria sobre bloque TIERRA (M08).
2. FarmService.till_tile(voxel_pos): valida bloque y parcela (M17).
3. OK → el mundo voxel (M08, VoxelTools modifier) convierte TIERRA → TIERRA_ARADA (dif de chunk).
4. FarmService emite tile_tilled; sonido de tierra (M43/M44); VFX polvo (M52).
5. Jugador abre inventario (M14), selecciona semilla y apunta a la tierra arada → plantar.
6. FarmService.plant(): consume semilla, crea CropTile(stage=SEMILLA, water=0), registra instancia visual.
7. Emite crop_planted; sonido de siembra; HUD muestra pista "Necesita agua" (tooltip CropTile.get_growth_hint).
```

### Flujo 2 — Riego y crecimiento diario
```
1. Jugador usa regadera (M13) sobre el cultivo → FarmService.water(): water_level=min(2, +1).
2. Emite tile_watered; VFX gotas; sonido de agua; HUD marca "Regado hoy".
3. (Alternativo) M32 lluvia en el día → FarmService.apply_rain() rellena agua de cultivos expuestos sin techo.
4. Al final del día, GameClock (M29) emite calendar_day_advanced → FarmService.advance_day().
5. Por cada CropTile: evalúa agua/estación (2.4.5); si procede grown_days += 1 y recalcula etapa.
6. Si pasó a LISTA → evento crop_ready + indicador visual (brillo suave, partícula) + notificación cozy.
7. Guardado (M59): FarmStateStore serializa los CropTile en el GameState.
```

### Flujo 3 — Cosecha y economía
```
1. Jugador interactúa sobre cultivo LISTA (acción principal, M70).
2. FarmService.can_harvest() → true → harvest():
   - calcula rendimiento: yields base + bonificación de calidad (condiciones legibles, sin RNG oculto);
   - árboles frutales: no se desplantan; entran en cooldown frutal (N días) y siguen vivos;
   - resto: se elimina CropTile, la tierra queda arada y reutilizable.
3. Los ítems (tomate, semillas reproducidas, flores...) entran al inventario M14 con notificación.
4. Emite crop_harvested; VFX de cosecha; sonido ASMR (M44).
5. El jugador vende en tiendas (M39/M38), cocina (M16) o regala (M20) — siempre opcional.
```

### Flujo 4 — Invierno (regla cozy)
```
1. Llega INVIERNO (M29): los cultivos sin aptitud invernal entran en DORMANTE.
2. Crops aptos (trigo de invierno, crisantemo, planta ancestral) siguen creciendo normal.
3. Visual: instancias en reposo (tono apagado, sin animación); tooltip: "Descansa. Volverá en primavera".
4. Al cambiar la estación apta, reanuda desde la misma etapa y mismos días (cero pérdida).
5. El suelo arado con nieve (M08/M32) no pierde el estado; dif de chunk lo conserva.
```

### Flujo 5 — Pisoteo de NPC (cozy)
```
1. Un NPC (M64) camina sobre una celda con cultivo activo (borde de navegación).
2. M64 emite evento de pisoteo; FarmService NO pierde progreso (regla innegociable).
3. CropTileVisual agita la instancia 1 s; el NPC murmura un comentario amable (M21).
4. La navegación (M64) prioriza caminos libres de cultivos cuando existen (coste alto por celda cultivada).
5. Si no existe camino alternativo, el NPC pisa sin consecuencias: el jugador jamás sufre por el vaivén del pueblo.
```

## 4. Contratos API GDScript (firmas)

Las firmas usan convenciones del proyecto (M111): `snake_case` en métodos, `PascalCase` en clases, prefijo de señal en pasado.

```gdscript
# farm/farm_service.gd
class_name FarmService extends Node

func till_tile(voxel_pos: Vector3i) -> bool
func plant(crop: CropDefinition, voxel_pos: Vector3i) -> bool
func water(voxel_pos: Vector3i) -> void
func apply_rain(voxel_pos: Vector3i) -> void
func can_harvest(voxel_pos: Vector3i) -> bool
func harvest(voxel_pos: Vector3i) -> Array[Dictionary]
func get_tile(voxel_pos: Vector3i) -> CropTile
func get_growth_hint(voxel_pos: Vector3i) -> String
func advance_day() -> void
func reserve_plot(owner_id: int, center: Vector3i, radius: int) -> bool
func get_active_farm_stats() -> Dictionary

# farm/crop_tile.gd
class_name CropTile extends RefCounted
func is_ready() -> bool
func is_paused() -> bool
func current_stage_index() -> int
func can_advance_today(season: int, rain: bool) -> bool
func apply_daily_tick(season: int, rain: bool) -> bool

# farm/crop_definition.gd
class_name CropDefinition extends Resource
func get_stage_visual_key() -> StringName

# farm/crop_tile_visual.gd
class_name CropTileVisual extends Node3D
func refresh() -> void
func shake(duration_s: float) -> void
func play_water_fx() -> void
func play_harvest_fx() -> void

# farm/farm_state_store.gd
class_name FarmStateStore extends RefCounted
func to_save_dict() -> Dictionary
func from_save_dict(data: Dictionary) -> void
func validate(data: Dictionary) -> bool
```

## 5. Integración con otros módulos

| Módulo | Rol | Contrato de integración |
|---|---|---|
| M08 Mundo Voxel | Bloque `TIERRA_ARADA` (+ variante húmeda) en el catálogo; diffs por chunk; `VoxelInstanceModifier` para instancias | FarmService llama a `VoxelAPI.set_voxel(pos, ID_TIERRA_ARADA)`; registra instancia con `VoxelInstanceModifier.add_instance(transform)` |
| M29 Tiempo y Calendario | Día de 24 min; estaciones del año (336 días); evento `calendar_day_advanced`; índice de día para determinismo | `FarmService` se suscribe a `GameClock.day_advanced`; guarda `planted_at_day` |
| M14 Inventario | Consumo de semillas, recepción de cosecha | `InventoryService.try_remove(item_id, 1)` / `try_add(items)` — nunca UI directa |
| M15 Recursos | Catálogo de semillas, frutas, fibras, flores | Las definiciones referencian `item_id` del catálogo de recursos |
| M16 Crafting | Recetas con cultivos (ensalada, pan, tinte floral, ofrendas) | Consume ítems de cosecha; no toca CropTile (los cultivos ya fueron cosechados) |
| M13 Herramientas | Pala (arar) nivel 1+; regadera con capacidad | `ToolService.try_use(tool_id, target_voxel)` → delega a FarmService según tool_id |
| M17 Construcción | Parcelas: área reservada donde arar/plantar | `reserve_plot()`; las parcelas restrigen casi todo menos caminos |
| M32 Clima | Lluvia que riega automáticamente; nieve visual sobre suelo | `WeatherService.on_rain_day(day)` → `apply_rain()` a cultivos expuestos |
| M64 IA de NPC | Navegación evita celdas cultivadas (coste alto); pisoteo sin daño | Eventbus `npc_stepped_on_farm(voxel_pos)` → shake visual |
| M61 Rendimiento | Presupuesto de instancias, LOD, evaluación diaria ≤ 2 ms | FarmService entrega `get_active_farm_stats()` al profiler de M113 |
| M59 Guardado | Persistencia de CropTile en GameState versionado | `FarmStateStore.to_save_dict()/from_save_dict()` |
| M52 Partículas y VFX | Gotas de riego, polvo de pala, brillo de cosecha | Eventos del FarmService disparan efectos de bajo costo |
| M43/M44 Audio | Sonidos de arar/regar/cosechar con capas ASMR | Eventos → audio pool (M43) con precedencia cozy (M44) |
| M53 UI/UX | HUD agrícola, tooltips de estado, notificaciones | Solo consulta API de FarmService + eventos; cero escritura directa |

## 6. Diagrama de estados del CropTile

```
                plantar
   (vacío) ────────────► SEMILLA ──► Brote ──► CRECIENDO ──► MADURA ──► LISTA ──► cosechar (a vacío)
                 ▲        │  ▲         │  ▲        │  ▲        │
                 │        │  │         │  │        │  │        │
             estación no    └──────────┴───┴────────┴──┴────────┘
             apta/agua 0        (sin agua O estación no apta → pausa, nunca retrocede)
                 │              regar o volver estación apta → reanuda misma etapa
                 ▼
             DORMANTE / SIN_AGUA ──► (idem)
```

Notas: LISTA no requiere agua (espera al jugador sin penalización). Los árboles frutales, al cosechar, vuelven a MADURA con cooldown frutal en lugar de vacío.