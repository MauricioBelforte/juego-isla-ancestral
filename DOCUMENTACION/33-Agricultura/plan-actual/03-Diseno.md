**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 33: Agricultura

## 1. VisiÃ³n general de la arquitectura

Capas desacopladas (M07), lectura unidireccional: Datos (CropDefinition) â†’ Estado (CropTile + FarmStateStore) â†’ OrquestaciÃ³n (FarmService) â†’ Visual/UI (CropTileVisual, HUD agrÃ­cola). La UI jamÃ¡s escribe estado directamente; solo llama a la API de FarmService.

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         CAPA UI (M53)        â”‚  HUD agricola, tooltips, tutorial
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–²â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚ llamadas API
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚       FarmService (servicio) â”‚  autoload (Service Locator)
â”‚  - avance por dÃ­a (M29)      â”‚
â”‚  - arar/plantar/regar/cosecharâ”‚
â”‚  - eventos EventBus delegados â”‚
â””â”€â”€â”€â”€â”€â”€â–²â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–²â”€â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚              â”‚ estado
â”Œâ”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ CropTile   â”‚  â”‚ FarmStateStore â”‚  persistencia (GameState M59)
â”‚ (por voxel)â”‚  â””â”€â”€â”€â”€â”€â”€â”€â–²â”€â”€â”€â”€â”€â”€â”€â”€â”˜
â””â”€â”€â”€â”€â”€â”€â–²â”€â”€â”€â”€â”€â”˜          â”‚ datos
       â”‚ instancia      â”‚
â”Œâ”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”‚
â”‚ CropTileVisual      â”‚ â”‚
â”‚ (MultiMesh pool)    â”‚ â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â”‚
            â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
            â”‚ CropDefinition (Resource) â”‚ .tres por cultivo
            â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

## 2. Componentes

### 2.1 CropDefinition (Resource, `class_name CropDefinition extends Resource`)

Datos puros por cultivo, editables en el editor de Godot como `.tres`:

| Campo | Tipo | DescripciÃ³n |
|---|---|---|
| `crop_id` | StringName | Identificador Ãºnico (ej: `maiz_ancestral`) |
| `display_name` | String | Nombre mostrado (localizable M87) |
| `description` | String | Tooltip amigable |
| `seasons` | Array[GameClock.Season] | Estaciones donde crece (M29) |
| `grow_days` | int | DÃ­as totales hasta lista (sin fertilizante) |
| `stage_count` | int | Cantidad de etapas visuales (2..6) |
| `water_need` | int | Agua requerida por dÃ­a (1 o 2) para avanzar |
| `yields` | Array[Dictionary] | `{item_id: StringName, amount: int, chance_quality: ...}` |
| `yield_seeds` | Dictionary | Semilla y cantidad reproducidas al cosechar |
| `quality_levels` | bool | Si el cultivo expone calidades COMUN/BUENA/EXCELENTE |
| `is_tree` | bool | Ãrbol frutal (perenne, no requiere replantar) |
| `is_flower` | bool | Flor decorativa / sujeta a cruce (hÃ­brido M32 agrÃ­cola) |
| `is_ancestral` | bool | Planta ancestral con desbloqueo narrativo (M22) |
| `decorative_only` | bool | No produce Ã­tems (ornamental) |
| `fertilizer_bonus` | int | DÃ­as que reduce al aplicar fertilizante (mÃ³dulo ferm M13) |

**CatÃ¡logo inicial (M15):** tomate, maÃ­z, trigo, calabaza, zanahoria, uva, algodÃ³n (fibra), flor de coral (isla), crisantemo (otoÃ±o), margarita, rosa hÃ­brida, Ã¡rbol de manzanas, Ã¡rbol de duraznos, palma de coco (isla tropical), planta ancestral de lumina (desbloqueable). ~16 definiciones base, ampliable.

### 2.2 GrowthStage (enum + Resource de datos)

Identidad de etapas global, usada por CropTile y visuales:

```gdscript
enum GrowthStage {
    SEMILLA,      # 0: reciÃ©n plantado
    Brote,        # 1: primer tallo
    CRECIENDO,    # 2: crecimiento medio
    MADURA,       # 3: madurando (falta 1 dÃ­a)
    LISTA,        # 4: cosechable
    DORMANTE,     # 5: fuera de estaciÃ³n (pausado, no muere)
    SIN_AGUA      # 6: pausado por falta de agua (se retoma al regar)
}
```

Nota: los nombres se escriben con mayÃºsculas reducidas para cumplir la convenciÃ³n GDScript del proyecto (M111); el par `SEMILLA = 0` se declara con `enum` explÃ­cito para no depender de orden.

Regla: DORMANTE y SIN_AGUA **no avanzan ni retroceden** la cuenta de dÃ­as; al salir del estado retoman desde la misma etapa y los mismos dÃ­as acumulados.

### 2.3 CropTile (referencia de estado por voxel)

Objeto ligero (RefCounted, no Node) que representa el estado de UN voxel cultivado:

```gdscript
class_name CropTile extends RefCounted

var voxel_pos: Vector3i        # coordenada del bloque de tierra arada (M08)
var crop_def: CropDefinition   # definiciÃ³n (no se copia: referencia al catÃ¡logo)
var stage: int                 # Ã­ndice de GrowthStage
var grown_days: int            # dÃ­as acumulados en etapas activas
var water_level: int           # 0..2 (riego manual + lluvia M32)
var fertilized: bool
var quality: int               # 0 COMUN / 1 BUENA / 2 EXCELENTE (si aplica)
var planted_at_day: int        # Ã­ndice de dÃ­a del calendario (M29) al plantar
```

MÃ©todos puros: `current_stage_index()`, `is_ready()`, `is_paused()`, `can_advance_today(season, weather)`, `apply_daily_tick(season, rain: bool)` â†’ devuelve si cambiÃ³ de etapa (para evento y sonido).

### 2.4 FarmService (autoload, capa de orquestaciÃ³n)

API pÃºblica (contrato estable, detalle en secciÃ³n 4):

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
func harvest(voxel_pos: Vector3i) -> Array[Dictionary]                          # entrega Ã­tems a M14
func get_tile(voxel_pos: Vector3i) -> CropTile
func get_growth_hint(voxel_pos: Vector3i) -> String                            # tooltip amigable
func advance_day() -> void                                                     # suscrito a M29
func reserve_plot(owner_id: int, center: Vector3i, radius: int) -> bool        # parcelas M17
func get_active_farm_stats() -> Dictionary                                     # analytics M104
```

Reglas de negocio del servicio:
1. `till_tile`: solo sobre bloque `TIERRA` del catÃ¡logo M08 con cara superior expuesta; valida parcela M17 (parcela libre o del jugador).
2. `plant`: requiere `TIERRA_ARADA`, sin cultivo previo, semilla en inventario M14 (consume 1), y (si aplica) parcela con cupo libre (cupo = parcelas del jugador).
3. `water`: sube `water_level` hasta 2; el agua nunca "se desperdicia" (feedback juguetÃ³n de exceso de agua, sin castigo).
4. `harvest`: solo en etapa LISTA; remueve el CropTile, emite `yields` al inventario M14, deja el bloque `TIERRA_ARADA` listo (para Ã¡rboles frutales queda perenne en `MADURA` y reaparece la fruta a los N dÃ­as).
5. `advance_day`: itera solo los CropTile activos del jugador (mÃ¡x 400); por cada uno: resta 1 de agua; si `water_level < water_need` â†’ SIN_AGUA; si la estaciÃ³n no es apta â†’ DORMANTE; si no â†’ `grown_days += 1` y avanza etapa si corresponde; emite evento solo si hay cambio.

### 2.5 CropTileVisual (capa de presentaciÃ³n)

- Registra posiciones por especie y por etapa en un **MultiMesh** (un MultiMeshInstance3D por especie, hasta 16; las instancias rotan/segÃºn especie).
- Malla LOD: 2 niveles (cerca completa / lejos simplificada) con el presupuesto de M61.
- AnimaciÃ³n cozy: sway suave con `sin(time + offset)` por instancia (shader de instancing) sin costo por nodo.
- Feedback de pisoteo de NPC: agitaciÃ³n de la instancia 1 s, sin pÃ©rdida de progreso (evento `M64.npc_stepped_on` â†’ agitar).
- VFX de regar (M52): gotas ligeras; VFX de cosecha: partÃ­culas suaves.

## 3. Flujos principales (texto)

### Flujo 1 â€” Arar y plantar
```
1. Jugador equipa pala (M13) y usa acciÃ³n primaria sobre bloque TIERRA (M08).
2. FarmService.till_tile(voxel_pos): valida bloque y parcela (M17).
3. OK â†’ el mundo voxel (M08, VoxelTools modifier) convierte TIERRA â†’ TIERRA_ARADA (dif de chunk).
4. FarmService emite tile_tilled; sonido de tierra (M43/M44); VFX polvo (M52).
5. Jugador abre inventario (M14), selecciona semilla y apunta a la tierra arada â†’ plantar.
6. FarmService.plant(): consume semilla, crea CropTile(stage=SEMILLA, water=0), registra instancia visual.
7. Emite crop_planted; sonido de siembra; HUD muestra pista "Necesita agua" (tooltip CropTile.get_growth_hint).
```

### Flujo 2 â€” Riego y crecimiento diario
```
1. Jugador usa regadera (M13) sobre el cultivo â†’ FarmService.water(): water_level=min(2, +1).
2. Emite tile_watered; VFX gotas; sonido de agua; HUD marca "Regado hoy".
3. (Alternativo) M32 lluvia en el dÃ­a â†’ FarmService.apply_rain() rellena agua de cultivos expuestos sin techo.
4. Al final del dÃ­a, GameClock (M29) emite calendar_day_advanced â†’ FarmService.advance_day().
5. Por cada CropTile: evalÃºa agua/estaciÃ³n (2.4.5); si procede grown_days += 1 y recalcula etapa.
6. Si pasÃ³ a LISTA â†’ evento crop_ready + indicador visual (brillo suave, partÃ­cula) + notificaciÃ³n cozy.
7. Guardado (M59): FarmStateStore serializa los CropTile en el GameState.
```

### Flujo 3 â€” Cosecha y economÃ­a
```
1. Jugador interactÃºa sobre cultivo LISTA (acciÃ³n principal, M70).
2. FarmService.can_harvest() â†’ true â†’ harvest():
   - calcula rendimiento: yields base + bonificaciÃ³n de calidad (condiciones legibles, sin RNG oculto);
   - Ã¡rboles frutales: no se desplantan; entran en cooldown frutal (N dÃ­as) y siguen vivos;
   - resto: se elimina CropTile, la tierra queda arada y reutilizable.
3. Los Ã­tems (tomate, semillas reproducidas, flores...) entran al inventario M14 con notificaciÃ³n.
4. Emite crop_harvested; VFX de cosecha; sonido ASMR (M44).
5. El jugador vende en tiendas (M39/M38), cocina (M16) o regala (M20) â€” siempre opcional.
```

### Flujo 4 â€” Invierno (regla cozy)
```
1. Llega INVIERNO (M29): los cultivos sin aptitud invernal entran en DORMANTE.
2. Crops aptos (trigo de invierno, crisantemo, planta ancestral) siguen creciendo normal.
3. Visual: instancias en reposo (tono apagado, sin animaciÃ³n); tooltip: "Descansa. VolverÃ¡ en primavera".
4. Al cambiar la estaciÃ³n apta, reanuda desde la misma etapa y mismos dÃ­as (cero pÃ©rdida).
5. El suelo arado con nieve (M08/M32) no pierde el estado; dif de chunk lo conserva.
```

### Flujo 5 â€” Pisoteo de NPC (cozy)
```
1. Un NPC (M64) camina sobre una celda con cultivo activo (borde de navegaciÃ³n).
2. M64 emite evento de pisoteo; FarmService NO pierde progreso (regla innegociable).
3. CropTileVisual agita la instancia 1 s; el NPC murmura un comentario amable (M21).
4. La navegaciÃ³n (M64) prioriza caminos libres de cultivos cuando existen (coste alto por celda cultivada).
5. Si no existe camino alternativo, el NPC pisa sin consecuencias: el jugador jamÃ¡s sufre por el vaivÃ©n del pueblo.
```

## 4. Contratos API GDScript (firmas)

Las firmas usan convenciones del proyecto (M111): `snake_case` en mÃ©todos, `PascalCase` en clases, prefijo de seÃ±al en pasado.

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

## 5. IntegraciÃ³n con otros mÃ³dulos

| MÃ³dulo | Rol | Contrato de integraciÃ³n |
|---|---|---|
| M08 Mundo Voxel | Bloque `TIERRA_ARADA` (+ variante hÃºmeda) en el catÃ¡logo; diffs por chunk; `VoxelInstanceModifier` para instancias | FarmService llama a `VoxelAPI.set_voxel(pos, ID_TIERRA_ARADA)`; registra instancia con `VoxelInstanceModifier.add_instance(transform)` |
| M29 Tiempo y Calendario | DÃ­a de 24 min; estaciones del aÃ±o (336 dÃ­as); evento `calendar_day_advanced`; Ã­ndice de dÃ­a para determinismo | `FarmService` se suscribe a `GameClock.day_advanced`; guarda `planted_at_day` |
| M14 Inventario | Consumo de semillas, recepciÃ³n de cosecha | `InventoryService.try_remove(item_id, 1)` / `try_add(items)` â€” nunca UI directa |
| M15 Recursos | CatÃ¡logo de semillas, frutas, fibras, flores | Las definiciones referencian `item_id` del catÃ¡logo de recursos |
| M16 Crafting | Recetas con cultivos (ensalada, pan, tinte floral, ofrendas) | Consume Ã­tems de cosecha; no toca CropTile (los cultivos ya fueron cosechados) |
| M13 Herramientas | Pala (arar) nivel 1+; regadera con capacidad | `ToolService.try_use(tool_id, target_voxel)` â†’ delega a FarmService segÃºn tool_id |
| M17 ConstrucciÃ³n | Parcelas: Ã¡rea reservada donde arar/plantar | `reserve_plot()`; las parcelas restrigen casi todo menos caminos |
| M32 Clima | Lluvia que riega automÃ¡ticamente; nieve visual sobre suelo | `WeatherService.on_rain_day(day)` â†’ `apply_rain()` a cultivos expuestos |
| M64 IA de NPC | NavegaciÃ³n evita celdas cultivadas (coste alto); pisoteo sin daÃ±o | Eventbus `npc_stepped_on_farm(voxel_pos)` â†’ shake visual |
| M61 Rendimiento | Presupuesto de instancias, LOD, evaluaciÃ³n diaria â‰¤ 2 ms | FarmService entrega `get_active_farm_stats()` al profiler de M113 |
| M59 Guardado | Persistencia de CropTile en GameState versionado | `FarmStateStore.to_save_dict()/from_save_dict()` |
| M52 PartÃ­culas y VFX | Gotas de riego, polvo de pala, brillo de cosecha | Eventos del FarmService disparan efectos de bajo costo |
| M43/M44 Audio | Sonidos de arar/regar/cosechar con capas ASMR | Eventos â†’ audio pool (M43) con precedencia cozy (M44) |
| M53 UI/UX | HUD agrÃ­cola, tooltips de estado, notificaciones | Solo consulta API de FarmService + eventos; cero escritura directa |

## 6. Diagrama de estados del CropTile

```
                plantar
   (vacÃ­o) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–º SEMILLA â”€â”€â–º Brote â”€â”€â–º CRECIENDO â”€â”€â–º MADURA â”€â”€â–º LISTA â”€â”€â–º cosechar (a vacÃ­o)
                 â–²        â”‚  â–²         â”‚  â–²        â”‚  â–²        â”‚
                 â”‚        â”‚  â”‚         â”‚  â”‚        â”‚  â”‚        â”‚
             estaciÃ³n no    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”˜
             apta/agua 0        (sin agua O estaciÃ³n no apta â†’ pausa, nunca retrocede)
                 â”‚              regar o volver estaciÃ³n apta â†’ reanuda misma etapa
                 â–¼
             DORMANTE / SIN_AGUA â”€â”€â–º (idem)
```

Notas: LISTA no requiere agua (espera al jugador sin penalizaciÃ³n). Los Ã¡rboles frutales, al cosechar, vuelven a MADURA con cooldown frutal en lugar de vacÃ­o.
## Specs Agricultura (Beam 503)

### Guardado idempotente del tick diario
- Spec: guardado a mitad del avance de día: el tick es idempotente. Coherente con M33 (agricultura) y M07 (guardado).

### Evaluación diaria <= 2 ms con 400 cultivos
- Spec: evaluación diaria <= 2 ms con 400 cultivos. Coherente con M33 (agricultura) y M61 (rendimiento).

### Prueba de stress: 400 cultivos + lluvia global en 1 tick
- Spec: prueba de stress: 400 cultivos + lluvia global en 1 tick. Coherente con M33 (agricultura) y M61 (rendimiento).

### Test: pisoteo de NPC sobre campo con ruta y sin ruta
- Spec: test: pisoteo de NPC sobre campo con ruta y sin ruta. Coherente con M33 (agricultura) y M64 (IA).

### Deuda de rendimiento advance_day
- Spec: deuda de rendimiento (advance_day tarda 407/434 ms sobre 395 cultivos, umbral 50 ms). Tick diario por lotes/diferido. Coherente con M33 (agricultura) y M61 (rendimiento).