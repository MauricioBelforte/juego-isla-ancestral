**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 54: Mapa

## 1. Arquitectura general

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ AUTOLOADS (orden de registro) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Bootstrap(M07) > EventBus(M07) > ActionLayer(M57) > UIManager(M53)                â”‚
â”‚                   > MapManager(M54)  [datos de mapa: regiones, exploraciÃ³n, pines]â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                                     â”‚ datos/eventos (dominio `map`)
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ GODOT TREE â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ CanvasLayer UI_ROOT (layer 100, M53)                                             â”‚
â”‚ â”œâ”€ HUDScreen (M53)                                                               â”‚
â”‚ â”‚   â””â”€ MinimapView (M54: widget Control, consume MapManager)                     â”‚
â”‚ â”œâ”€ FullMapLayer (M54: UILayer tipo MODAL_FULL, M53)                              â”‚
â”‚ â”‚   â”œâ”€ MapCanvas (Control contenedor: scale/pan del mapa)                        â”‚
â”‚ â”‚   â”‚   â”œâ”€ MapTextureRect   (textura base baked, capa 0)                         â”‚
â”‚ â”‚   â”‚   â”œâ”€ FogTextureRect    (niebla de guerra, capa 1)                          â”‚
â”‚ â”‚   â”‚   â”œâ”€ RegionGlyphLayer  (nombres/bordes de regiÃ³n, capa 2)                  â”‚
â”‚ â”‚   â”‚   â””â”€ MarkerPool        (pool de sprites: marcadores + pines, capa 3)       â”‚
â”‚ â”‚   â””â”€ MapUI (panel: leyenda, filtros, pines, botÃ³n viaje/cerrar)               â”‚
â”‚ â””â”€ ... (resto de capas de M53)                                                   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
Capas de presentaciÃ³n (M53): MinimapView = HUD read-only; FullMapLayer = Modal Completo
(pausa total congruente con M29, bloquea input del mundo, navegaciÃ³n 100% por foco).
```

## 2. Componentes principales

### 2.1 MapManager (autoload, `res://mapa/core/mapa_manager.gd`)
Servicio de datos de mapa. No conoce ninguna clase de UI.

- **Regiones:** carga `RegionData[]` desde M09/M27 (id, nombre, bioma, polÃ­gono en coordenadas del mundo, si es agua/costa).
- **ExploraciÃ³n (niebla):** estado por regiÃ³n y por celda (`visto`/`visitado`); `reveal_area(center, radius)` al mover el jugador (M11 emite posiciÃ³n, MapManager nunca lee gameplay directo); emite `exploration_changed`.
- **Marcadores del mundo:** catÃ¡logo `MarkersCatalog` (pueblo, casa, tiendas M39, NPCs M19, templos M24, ruinas M25, islas M27, destinos M69); registrado por los mÃ³dulos emisores vÃ­a API.
- **Pines:** `PlayerPinsService` (CRUD + persistencia M60).
- **Bake del mapa:** genera la `ImageTexture` base desde el chunk data (M10) con paleta cozy (M53); cachÃ© en disco (M60); regeneraciÃ³n con progreso visual (M63/AGENTS 8).
- **Viaje rÃ¡pido:** expone `request_travel(destino_id)` que delega en la interfaz Callable de M69.

### 2.2 MapData (`res://mapa/data/map_data.gd`)
Contenedor de datos serializable (M60).

- `RegionData` (Resource): `region_id`, `name`, `biome` (enum de M09/M27), `polygon: PackedVector2Array`, `is_water`, `bounds: Rect2`.
- `RegionState`: `seen: bool`, `visited: bool` (bit por regiÃ³n/celda).
- `PinData` (Resource): `pin_id`, `world_pos: Vector3`, `label: String`, `created_day` (M29).
- `MapConfig` (Resource): tamaÃ±o de textura, radio de revelado, lÃ­mite de pines, colores de biomas (M53 paleta).

### 2.3 MinimapView (`res://mapa/views/minimap_view.gd`)
Widget Control del HUD (M53 MinimapWidget lo integra como proveedor de datos).

- Textura: reusa la textura base del MapManager a baja resoluciÃ³n (sin segundo bake).
- Ãcono del jugador centrado, rotaciÃ³n fija (norte arriba); rotaciÃ³n del mundo al jugador NO se aplica (M58).
- Niebla aplicada como recorte del FogTextureRect; marcadores relevantes (cercanos o importantes) con pool compartido.
- ActualizaciÃ³n solo por seÃ±al (`exploration_changed`, `markers_changed`, `player_position` a baja frecuencia 2 Hz â€” sin polling por frame).
- Flecha de borde: marcador importante fuera de vista â†’ flecha en el borde del widget.
- Ocultable (`set_visible_map`) desde acciÃ³n de M57 y configuraciÃ³n; atajo para abrir el mapa completo (`map_toggle`).

### 2.4 FullMapLayer (`res://mapa/views/full_map_layer.gd` + `.tscn`)
UILayer tipo MODAL_FULL de M53.

- `MapCanvas`: contenedor con `scale` (zoom 0.6x-3x) y `position` (pan con clamp a los bordes); zoom anclado al cursor.
- `MapTextureRect`: la textura base (una sola imagen, sin duplicados).
- `FogTextureRect`: textura de niebla (ImageTexture opaca, `modulate`); se actualiza solo en mosaicos sucios.
- `RegionGlyphLayer`: nombres de regiÃ³n (M88) y bordes de bioma (style M53); se refresca al entrar/salir de zoom thresholds (no por frame).
- `MarkerPool`: pool de sprites/marcadores; cluster dinÃ¡mico por escala; escala constante de los sprites (top_level).
- `MapUI`: leyenda de iconos (M58), filtros por tipo, lista de pines, botones de viaje (M69), "volver al jugador", cerrar.
- Pausa: como MODAL_FULL congela el mundo (M29); al cerrar, M53 restaura el foco.

### 2.5 Explorer (niebla de guerra, `res://mapa/fog/explorer.gd`)
Node del dominio (hijo de MapManager). LÃ³gica pura de datos, sin nodos de render.

### 2.6 MarkersCatalog (`res://mapa/markers/markers_catalog.gd`)
Node del dominio. Registro de marcadores del mundo + visibilidad segÃºn exploraciÃ³n + clusterizaciÃ³n.

### 2.7 PlayerPinsService (`res://mapa/pins/player_pins_service.gd`)
Node del dominio. CRUD de pines; creado desde el mapa (posiciÃ³n actual o cursor) o desde gameplay (M11/M70 con validaciÃ³n de M54).

## 3. Flujos principales (texto)

### 3.1 Abrir el mapa completo (atajo M / botÃ³n del minimapa)
1. M57 emite acciÃ³n `map_toggle`; FullMapLayer ya estÃ¡ registrado en UIManager (M53).
2. UIManager push de FullMapLayer (MODAL_FULL) â†’ pausa del mundo (M29), foco inicial en "volver al jugador".
3. FullMapLayer pide a MapManager la textura base (ya cacheada; si no, dispara bake en background con barra de progreso M63).
4. Se aplican zoom inicial y pan al jugador; niebla y marcadores se dibujan desde el estado actual (sin regeneraciones).
5. Al cerrar (Esc/cancel/`map_toggle`), UIManager pop y restauraciÃ³n de foco; SFX del bus UI (M91).

### 3.2 Revelado de niebla
1. M11 emite `player_moved(world_pos)` (a baja frecuencia) o el detector de zona de MapManager cruza un borde de celda.
2. Explorer.reveal_around(center, radius) marca celdas/regiones como `seen` y `visited`.
3. Solo si hubo cambios: emite `exploration_changed`; modelos sÃ³lo actualizan los mosaicos sucios de la niebla (FogTextureRect) y marcadores reciÃ©n visibles.
4. Flag de celda persistida con M60 (guardado de regiÃ³n visitada, sin guardar toda la textura).

### 3.3 Crear un pin
1. En el mapa completo: botÃ³n "Nuevo pin" o tecla asignada (M57) â†’ pin en la posiciÃ³n del cursor; en el minimapa/gameplay: pin en la posiciÃ³n del jugador.
2. PlayerPinsService.add_pin â†’ PinData con id, label editable (diÃ¡logo M53), fecha (M29).
3. Se agrega al MarkerPool (capa 3) y a la lista del MapUI; persistencia diferida con M60.
4. LÃ­mite de pines alcanzado â†’ toast amable de M53 y se bloquea crear (sin datos perdidos).

### 3.4 Viaje rÃ¡pido desde el mapa
1. El jugador enfoca un marcador de destino de M69 (visible solo si desbloqueado).
2. Confirm â†’ confirm popup de M53 ("Â¿Viajar a Ribera del Alba? (08:00, 15 monedas)" si M69 lo define).
3. Accept â†’ `MapManager.request_travel(destino_id)` â†’ Callable de M69 (sin imports); M69 orquesta el viaje (M28) y emite `travel_started`/`travel_finished`.
4. El mapa se cierra; el HUD muestra el progreso del viaje (mÃ³dulo M69); el mapa se re-abre al llegar y muestra la nueva posiciÃ³n con la regiÃ³n revelada.

### 3.5 Cluster de marcadores
1. Al cambiar de escala (zoom/pan), MarkerPool recalcula posiciones proyectadas.
2. Marcadores con distancia proyectada < umbral â†’ se reemplazan por un Ãºnico sprite de cluster con contador (pool): tooltip lista los nombres (M53 TooltipService).
3. Al acercar el zoom, el cluster se descompone en los marcadores individuales; sin allocaciones (pool reutilizado).

## 4. Contratos de datos (interfaces de dominio)

```gdscript
# MapManager (autoload) â€” puntos de entrada que consumen las vistas
func get_map_texture() -> ImageTexture            # textura base baked (cachÃ©)
func get_fog_image() -> Image                     # solo mosaicos sucios
func get_region_at(world_pos: Vector3) -> RegionData
func regions() -> Array[RegionData]
func is_explored(region_id: int) -> bool
func is_visited(region_id: int) -> bool
func reveal_area(center: Vector3, radius: float) -> void
func request_travel(destino_id: String) -> void   # delega en Callable de M69
func register_fast_travel_provider(provider: Callable) -> void

# Eventos (dominio `map`)
signal exploration_changed(region_ids: Array[int])   # marcar mosaicos sucios
signal markers_changed                                # registro/visibilidad de marcadores
signal pins_changed
signal map_texture_ready(texture: ImageTexture)
signal travel_state_changed(state: String)            # idle/requested/traveling

# MarkersCatalog
func register_world_marker(type: MarkerType, region_id: int, local_pos: Vector2, label: String) -> int
func set_visible_types(types: Array[MarkerType]) -> void

# PlayerPinsService
func add_pin(world_pos: Vector3, label: String) -> int
func remove_pin(pin_id: int) -> void
func rename_pin(pin_id: int, label: String) -> void
func pins() -> Array[PinData]

# Explorer
func reveal_around(center: Vector3, radius: float) -> Array[int]   # regiones cambiadas
func state_for(region_id: int) -> RegionState
func mark_visited(region_id: int) -> void
```

## 5. IntegraciÃ³n con mÃ³dulos

| MÃ³dulo | IntegraciÃ³n |
|---|---|
| M53 UI/UX | FullMapLayer (UILayer MODAL_FULL), foco nativo, TooltipService, NotificationService, ThemeUx (M88), pila de capas, pausa; MinimapView consumida por MinimapWidget de M53 |
| M09 Terreno / M27 Islas | `RegionData` con biomas, polÃ­gonos y nombres; selector de isla si hay varias (M27); temple de colores de bioma en MapConfig |
| M10 GeneraciÃ³n de mundo | Bake de la textura desde el chunk data; semilla fija por save (M60); regeneraciÃ³n con progreso (M63) |
| M11 Jugador | PosiciÃ³n del jugador vÃ­a evento (baja frecuencia) para Ã­cono y revelado; sin lectura directa de nodos |
| M19 NPC | Marcadores dinÃ¡micos de casas/posiciones de NPCs |
| M24/M25 Templos/Ruinas | Marcadores estÃ¡ticos de POIs ocultos por niebla hasta explorar |
| M28 Viajes | Ruta visual al destino si M69/M28 la proveen; coherente con el viaje en curso |
| M29/M30 Tiempo | Pausa coherente; fecha del pin (M29) en la lista de pines |
| M39 Tiendas | Registro automÃ¡tico de tiendas como marcadores con icono propio |
| M57 Input | Acciones `map_toggle`, `map_zoom_in/out`, `map_close`, `map_new_pin`, `map_center_player`; prompts dinÃ¡micos (ActionPromptOverlay) |
| M58 Accesibilidad | reduce_motion (revelado sin animaciÃ³n), forma+color, contraste AA, todo operado por foco |
| M60 Datos | Persistencia de exploraciÃ³n (bits por regiÃ³n), pines, configuraciÃ³n de mapa y cachÃ© de textura en disco |
| M63 Cargas | Bake en background con barra de progreso; sin bloqueo de la escena |
| M69 Fast Travel | Interfaz por Callable (sin imports de nodos); destinos, desbloqueo, costo, duraciÃ³n; `travel_state_changed` |
| M87/M88 | Textos localizables; fuentes Nunito/Fredoka One en nombres de regiÃ³n |
| M90 GrÃ¡fica | Re-aplicaciÃ³n del tema al cambiar resoluciÃ³n; layout sin cortes en 16:9/16:10 |
| M91 Audio UI | SFX de abrir/cerrar mapa, crear pin, viaje y filtros en el bus UI |
| M92 Tutorial | NotificaciÃ³n de primera apertura ("El mapa se revela al explorar...") |

## 6. Persistencia y estado guardado (M60)

- **RegionState**: tabla `region_state(region_id, seen, visited)` â€” barata, no se guarda la textura.
- **PinData**: lista serializable de pines.
- **MapConfig**: opciones del jugador (filtros, zoom preferido, visibilidad del minimapa, pines).
- **Textura base**: cachÃ© binaria por semilla del mundo; se valida contra la semilla al cargar (M60) y se regenera si difiere (con progreso M63).
## Specs Mapa (Beam 509)

### Presupuesto mapa <= 5% del frame (M61)
- Spec: presupuesto mapa <= 5% del frame con Profiler (M61) en escena poblada. Coherente con M61 (rendimiento) y M54 (mapa).

### Jugador en otra isla: selector de islas exploradas y minimapa
- Spec: jugador en otra isla (M27): selector de islas exploradas y minimapa de la isla actual. Coherente con M27 (islas) y M54 (mapa).

### Test de rendimiento con mundo voxel completo (<= 5% frame)
- Spec: test de rendimiento con mundo voxel completo (<= 5% frame). Coherente con M61 (rendimiento) y M54 (mapa).

## Specs Mapa (Beam 645)

### Norte arriba requiere rotacion del sprite/texture
- Spec: norte arriba requiere rotacion del sprite/texture. Coherente with M54 (mapa) and M45 (arte 2D).

### Estilo ilustrado cozy documentado (manchas bioma paleta pastel, bordes suaves)
- Spec: estilo ilustrado cozy documentado (manchas bioma paleta pastel, bordes suaves). Coherente with M54 (mapa) and M45 (arte 2D).

### Navegacion 100% con gamepad y teclado (foco nativo M53)
- Spec: navegacion 100% con gamepad y teclado (foco nativo M53). Coherente with M54 (mapa) and M53 (UI).

### Marcador del pueblo (M09/M27) registrado en MarkersCatalog
- Spec: marcador del pueblo (M09/M27) registrado en MarkersCatalog. Coherente with M54 (mapa) and M27 (islas).

### Marcadores de tiendas individuales (M39) registrados automaticamente por evento
- Spec: marcadores de tiendas individuales (M39) registrados automaticamente por evento. Coherente with M54 (mapa) and M39 (infraestructura).


## Specs Mapa (Beam 646)

### Marcadores de casas de NPCs (M19) registrados por evento
- Spec: marcadores de casas de NPCs (M19) registrados por evento. Coherente with M54 (mapa) and M19 (amistad).

### Marcadores de islas/zones (M27) según islands exploradas
- Spec: marcadores de islas/zones (M27) según islands exploradas. Coherente with M54 (mapa) and M27 (islas).

### Iconos SVG por tipo (casa, tienda, NPC, templo, destino, pin) de M46/M53
- Spec: iconos SVG por tipo (casa, tienda, NPC, templo, destino, pin) de M46/M53. Coherente with M54 (mapa) and M46 (texturas).

### Tooltip del marcador al enfocar/hover (M53 TooltipService)
- Spec: tooltip del marcador al enfocar/hover (M53 TooltipService). Coherente with M54 (mapa) and M53 (UI).

### Confirmacion amable antes del viaje (confirm popup M53 con costo/duracion si M69)
- Spec: confirmacion amable antes del viaje (confirm popup M53 con costo/duracion si M69). Coherente with M54 (mapa) and M69 (viaje rapido).


## Specs Mapa (Beam 647)

### Test end-to-end: bloqueado -> desbloqueo -> viaje -> cancelacion -> llegada
- Spec: test end-to-end: bloqueado -> desbloqueo -> viaje -> cancelacion -> llegada. Coherente with M54 (mapa) and M28 (viajes).

### Marcado de visited al cruzar el borde de una region (evento M09/M27)
- Spec: marcado de visited al cruzar el borde de una region (evento M09/M27). Coherente with M54 (mapa) and M27 (islas).

### Persistencia de exploracion con M60 (bits por region/celda, no texturas)
- Spec: persistencia de exploracion con M60 (bits por region/celda, no texturas). Coherente with M54 (mapa) and M60 (rendimiento).

### Transicion suave de revelado (Tween 300 ms) reducible por reduce_motion (M58)
- Spec: transicion suave de revelado (Tween 300 ms) reducible por reduce_motion (M58). Coherente with M54 (mapa) and M58 (accesibilidad).

### Limites de region delineados dentro de la niebla (bordes visibles)
- Spec: limites de region delineados dentro de la niebla (bordes visibles). Coherente with M54 (mapa) and M58 (accesibilidad).


## Specs Mapa (Beam 648)

### Explorer (niebla) como nodo de dominio con logica pura de datos
- Spec: explorer (niebla) como nodo de dominio con logica pura de datos. Coherente with M54 (mapa) and M09 (generacion).

### RegionData alimentado por M09/M27
- Spec: RegionData alimentado por M09/M27. Coherente with M54 (mapa) and M27 (islas).

### Posicion jugador por evento baja frecuencia
- Spec: posicion jugador por evento baja frecuencia. Coherente with M54 (mapa) and M11 (movimiento).

### Registro casas NPCs como marcadores dinamicos
- Spec: registro casas NPCs como marcadores dinamicos. Coherente with M54 (mapa) and M19 (amistad).

### Ruta visual destino viaje
- Spec: ruta visual destino viaje. Coherente with M54 (mapa) and M28 (viajes).


## Specs Mapa (Beam 649)

### Tiendas registradas automaticamente
- Spec: tiendas registradas automaticamente. Coherente with M54 (mapa) and M39 (infraestructura).

### Accesibilidad reduce_motion, daltonismo, contraste AA
- Spec: accesibilidad reduce_motion, daltonismo, contraste AA. Coherente with M54 (mapa) and M58 (accesibilidad).

### M63: bake en background con barra de progreso (AGENTS 8)
- Spec: M63: bake en background con barra de progreso (AGENTS 8). Coherente with M54 (mapa) and M63 (streaming).

### Destinos, desbloqueo, viaje por interfaz Callable
- Spec: destinos, desbloqueo, viaje por interfaz Callable. Coherente with M54 (mapa) and M69 (viaje rapido).

### Viaje rapido solicitado con dialogo abierto: peticion encolada por pila M53
- Spec: viaje rapido solicitado con dialogo abierto: peticion encolada por pila M53. Coherente with M54 (mapa) and M69 (viaje rapido).


## Specs Mapa (Beam 650)

### Marcadores de islas/zones (M27) segun islands exploradas
- Spec: marcadores de islas/zones (M27) segun islands exploradas. Coherente with M54 (mapa) and M27 (islas).

### Cruce de region por barco (M28): revelado de golpe sin glitch (granos por mosaico)
- Spec: cruce de region por barco (M28): revelado de golpe sin glitch (granos por mosaico). Coherente with M54 (mapa) and M28 (viajes).

### Bake incremental por secciones del mundo para no bloquear (M63)
- Spec: bake incremental por secciones del mundo para no bloquear (M63). Coherente with M54 (mapa) and M63 (streaming).

### Test de navegacion completa con gamepad (30 minutos)
- Spec: test de navegacion completa con gamepad (30 minutos). Coherente with M54 (mapa) and M56 (interfaz).

### Test de viaje rapido end-to-end con M69
- Spec: test de viaje rapido end-to-end con M69. Coherente with M54 (mapa) and M69 (viaje rapido).


## Specs Mapa (Beam 651)

### Pool unico de sprites de marcadores, clusters y pines en ambas vistas
- Spec: pool unico de sprites de marcadores, clusters y pines en ambas vistas. Coherente with M54 (mapa) and M61 (rendimiento).

### Texturas comprimidas y dimensionadas por M108
- Spec: texturas comprimidas y dimensionadas por M108. Coherente with M54 (mapa) and M108 (pipeline).

### Datos: data/map/map_data.json — 9 POIs reales de la Isla Raiz
- Spec: datos: data/map/map_data.json — 9 POIs reales de la Isla Raiz (spawn/Chozavil/ruina/mesa/faro/templo_raiz/playa/plaza/ladera) con categorias y coordenadas dentro del mundo (radio 256). Coherente with M54 (mapa) and M09 (generacion).

### scripts/map/map_schema.gd — valida POIs
- Spec: scripts/map/map_schema.gd — valida POIs (id unico, nombre, categorias permitidas, coords 0-512 dentro del mundo). Coherente with M54 (mapa) and M108 (pipeline).


## Specs Mapa (Beam 652)

### Test headless: 12/12 checks OK (RF3/RF5/RF6, geometría)

## 7. Niebla por estado de visita (fog density by visited state)

La niebla de guerra (FogTextureRect, capa 1 del FullMapLayer; FogRenderer del minimapa) aplica una densidad de opacidad diferenciada según el estado de exploración de cada región:

- Región **no explorada** (ni `visto` ni `visitado`): niebla densa (opaca); oculta completamente el terreno y los marcadores de esa región.
- Región **visto** (revelada al menos una vez por `reveal_area`): niebla intermedia; se distingue la forma de la región pero no detalles de marcadores ni nombres.
- Región **visitado** (jugador cruzó el borde de la región): niebla ligera, más clara; se muestran los colores de bioma y los marcadores de esa región.

Contrato:
- `Explorer.reveal_around(center, radius)` marca celdas/regiones como `seen` y `visited` (visto → visitado al cruzar el borde de la región, evento M09/M27).
- Solo si hubo cambios de estado de exploración: `MapManager` emite `exploration_changed(region_ids)` y se actualizan solo los mosaicos sucios de la niebla (FogTextureRect), sin regenerar la textura completa por frame.
- Transición suave al cambiar estado: Tween 300 ms, reducible por `reduce_motion` (M58).
- La densidad de niebla se lee desde `MapManager._regiones_exploradas` (visitados) y `_exploradas` (vistos); las vistas (MinimapView, FullMapLayer) la aplican vía `modulate` de la FogTextureRect.
- Spec: test headless: 12/12 checks OK (RF3/RF5/RF6, geometría) — exit 0. Coherente with M54 (mapa) and M112 (testing).
