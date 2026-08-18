**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 54: Mapa

## 1. Arquitectura general

```
┌────────────────────────── AUTOLOADS (orden de registro) ──────────────────────────┐
│ Bootstrap(M07) > EventBus(M07) > ActionLayer(M57) > UIManager(M53)                │
│                   > MapManager(M54)  [datos de mapa: regiones, exploración, pines]│
└────────────────────────────────────┬──────────────────────────────────────────────┘
                                     │ datos/eventos (dominio `map`)
┌────────────────────── GODOT TREE ───▼────────────────────────────────────────────┐
│ CanvasLayer UI_ROOT (layer 100, M53)                                             │
│ ├─ HUDScreen (M53)                                                               │
│ │   └─ MinimapView (M54: widget Control, consume MapManager)                     │
│ ├─ FullMapLayer (M54: UILayer tipo MODAL_FULL, M53)                              │
│ │   ├─ MapCanvas (Control contenedor: scale/pan del mapa)                        │
│ │   │   ├─ MapTextureRect   (textura base baked, capa 0)                         │
│ │   │   ├─ FogTextureRect    (niebla de guerra, capa 1)                          │
│ │   │   ├─ RegionGlyphLayer  (nombres/bordes de región, capa 2)                  │
│ │   │   └─ MarkerPool        (pool de sprites: marcadores + pines, capa 3)       │
│ │   └─ MapUI (panel: leyenda, filtros, pines, botón viaje/cerrar)               │
│ └─ ... (resto de capas de M53)                                                   │
└───────────────────────────────────────────────────────────────────────────────────┘
Capas de presentación (M53): MinimapView = HUD read-only; FullMapLayer = Modal Completo
(pausa total congruente con M29, bloquea input del mundo, navegación 100% por foco).
```

## 2. Componentes principales

### 2.1 MapManager (autoload, `res://mapa/core/mapa_manager.gd`)
Servicio de datos de mapa. No conoce ninguna clase de UI.

- **Regiones:** carga `RegionData[]` desde M09/M27 (id, nombre, bioma, polígono en coordenadas del mundo, si es agua/costa).
- **Exploración (niebla):** estado por región y por celda (`visto`/`visitado`); `reveal_area(center, radius)` al mover el jugador (M11 emite posición, MapManager nunca lee gameplay directo); emite `exploration_changed`.
- **Marcadores del mundo:** catálogo `MarkersCatalog` (pueblo, casa, tiendas M39, NPCs M19, templos M24, ruinas M25, islas M27, destinos M69); registrado por los módulos emisores vía API.
- **Pines:** `PlayerPinsService` (CRUD + persistencia M60).
- **Bake del mapa:** genera la `ImageTexture` base desde el chunk data (M10) con paleta cozy (M53); caché en disco (M60); regeneración con progreso visual (M63/AGENTS 8).
- **Viaje rápido:** expone `request_travel(destino_id)` que delega en la interfaz Callable de M69.

### 2.2 MapData (`res://mapa/data/map_data.gd`)
Contenedor de datos serializable (M60).

- `RegionData` (Resource): `region_id`, `name`, `biome` (enum de M09/M27), `polygon: PackedVector2Array`, `is_water`, `bounds: Rect2`.
- `RegionState`: `seen: bool`, `visited: bool` (bit por región/celda).
- `PinData` (Resource): `pin_id`, `world_pos: Vector3`, `label: String`, `created_day` (M29).
- `MapConfig` (Resource): tamaño de textura, radio de revelado, límite de pines, colores de biomas (M53 paleta).

### 2.3 MinimapView (`res://mapa/views/minimap_view.gd`)
Widget Control del HUD (M53 MinimapWidget lo integra como proveedor de datos).

- Textura: reusa la textura base del MapManager a baja resolución (sin segundo bake).
- Ícono del jugador centrado, rotación fija (norte arriba); rotación del mundo al jugador NO se aplica (M58).
- Niebla aplicada como recorte del FogTextureRect; marcadores relevantes (cercanos o importantes) con pool compartido.
- Actualización solo por señal (`exploration_changed`, `markers_changed`, `player_position` a baja frecuencia 2 Hz — sin polling por frame).
- Flecha de borde: marcador importante fuera de vista → flecha en el borde del widget.
- Ocultable (`set_visible_map`) desde acción de M57 y configuración; atajo para abrir el mapa completo (`map_toggle`).

### 2.4 FullMapLayer (`res://mapa/views/full_map_layer.gd` + `.tscn`)
UILayer tipo MODAL_FULL de M53.

- `MapCanvas`: contenedor con `scale` (zoom 0.6x-3x) y `position` (pan con clamp a los bordes); zoom anclado al cursor.
- `MapTextureRect`: la textura base (una sola imagen, sin duplicados).
- `FogTextureRect`: textura de niebla (ImageTexture opaca, `modulate`); se actualiza solo en mosaicos sucios.
- `RegionGlyphLayer`: nombres de región (M88) y bordes de bioma (style M53); se refresca al entrar/salir de zoom thresholds (no por frame).
- `MarkerPool`: pool de sprites/marcadores; cluster dinámico por escala; escala constante de los sprites (top_level).
- `MapUI`: leyenda de iconos (M58), filtros por tipo, lista de pines, botones de viaje (M69), "volver al jugador", cerrar.
- Pausa: como MODAL_FULL congela el mundo (M29); al cerrar, M53 restaura el foco.

### 2.5 Explorer (niebla de guerra, `res://mapa/fog/explorer.gd`)
Node del dominio (hijo de MapManager). Lógica pura de datos, sin nodos de render.

### 2.6 MarkersCatalog (`res://mapa/markers/markers_catalog.gd`)
Node del dominio. Registro de marcadores del mundo + visibilidad según exploración + clusterización.

### 2.7 PlayerPinsService (`res://mapa/pins/player_pins_service.gd`)
Node del dominio. CRUD de pines; creado desde el mapa (posición actual o cursor) o desde gameplay (M11/M70 con validación de M54).

## 3. Flujos principales (texto)

### 3.1 Abrir el mapa completo (atajo M / botón del minimapa)
1. M57 emite acción `map_toggle`; FullMapLayer ya está registrado en UIManager (M53).
2. UIManager push de FullMapLayer (MODAL_FULL) → pausa del mundo (M29), foco inicial en "volver al jugador".
3. FullMapLayer pide a MapManager la textura base (ya cacheada; si no, dispara bake en background con barra de progreso M63).
4. Se aplican zoom inicial y pan al jugador; niebla y marcadores se dibujan desde el estado actual (sin regeneraciones).
5. Al cerrar (Esc/cancel/`map_toggle`), UIManager pop y restauración de foco; SFX del bus UI (M91).

### 3.2 Revelado de niebla
1. M11 emite `player_moved(world_pos)` (a baja frecuencia) o el detector de zona de MapManager cruza un borde de celda.
2. Explorer.reveal_around(center, radius) marca celdas/regiones como `seen` y `visited`.
3. Solo si hubo cambios: emite `exploration_changed`; modelos sólo actualizan los mosaicos sucios de la niebla (FogTextureRect) y marcadores recién visibles.
4. Flag de celda persistida con M60 (guardado de región visitada, sin guardar toda la textura).

### 3.3 Crear un pin
1. En el mapa completo: botón "Nuevo pin" o tecla asignada (M57) → pin en la posición del cursor; en el minimapa/gameplay: pin en la posición del jugador.
2. PlayerPinsService.add_pin → PinData con id, label editable (diálogo M53), fecha (M29).
3. Se agrega al MarkerPool (capa 3) y a la lista del MapUI; persistencia diferida con M60.
4. Límite de pines alcanzado → toast amable de M53 y se bloquea crear (sin datos perdidos).

### 3.4 Viaje rápido desde el mapa
1. El jugador enfoca un marcador de destino de M69 (visible solo si desbloqueado).
2. Confirm → confirm popup de M53 ("¿Viajar a Ribera del Alba? (08:00, 15 monedas)" si M69 lo define).
3. Accept → `MapManager.request_travel(destino_id)` → Callable de M69 (sin imports); M69 orquesta el viaje (M28) y emite `travel_started`/`travel_finished`.
4. El mapa se cierra; el HUD muestra el progreso del viaje (módulo M69); el mapa se re-abre al llegar y muestra la nueva posición con la región revelada.

### 3.5 Cluster de marcadores
1. Al cambiar de escala (zoom/pan), MarkerPool recalcula posiciones proyectadas.
2. Marcadores con distancia proyectada < umbral → se reemplazan por un único sprite de cluster con contador (pool): tooltip lista los nombres (M53 TooltipService).
3. Al acercar el zoom, el cluster se descompone en los marcadores individuales; sin allocaciones (pool reutilizado).

## 4. Contratos de datos (interfaces de dominio)

```gdscript
# MapManager (autoload) — puntos de entrada que consumen las vistas
func get_map_texture() -> ImageTexture            # textura base baked (caché)
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

## 5. Integración con módulos

| Módulo | Integración |
|---|---|
| M53 UI/UX | FullMapLayer (UILayer MODAL_FULL), foco nativo, TooltipService, NotificationService, ThemeUx (M88), pila de capas, pausa; MinimapView consumida por MinimapWidget de M53 |
| M09 Terreno / M27 Islas | `RegionData` con biomas, polígonos y nombres; selector de isla si hay varias (M27); temple de colores de bioma en MapConfig |
| M10 Generación de mundo | Bake de la textura desde el chunk data; semilla fija por save (M60); regeneración con progreso (M63) |
| M11 Jugador | Posición del jugador vía evento (baja frecuencia) para ícono y revelado; sin lectura directa de nodos |
| M19 NPC | Marcadores dinámicos de casas/posiciones de NPCs |
| M24/M25 Templos/Ruinas | Marcadores estáticos de POIs ocultos por niebla hasta explorar |
| M28 Viajes | Ruta visual al destino si M69/M28 la proveen; coherente con el viaje en curso |
| M29/M30 Tiempo | Pausa coherente; fecha del pin (M29) en la lista de pines |
| M39 Tiendas | Registro automático de tiendas como marcadores con icono propio |
| M57 Input | Acciones `map_toggle`, `map_zoom_in/out`, `map_close`, `map_new_pin`, `map_center_player`; prompts dinámicos (ActionPromptOverlay) |
| M58 Accesibilidad | reduce_motion (revelado sin animación), forma+color, contraste AA, todo operado por foco |
| M60 Datos | Persistencia de exploración (bits por región), pines, configuración de mapa y caché de textura en disco |
| M63 Cargas | Bake en background con barra de progreso; sin bloqueo de la escena |
| M69 Fast Travel | Interfaz por Callable (sin imports de nodos); destinos, desbloqueo, costo, duración; `travel_state_changed` |
| M87/M88 | Textos localizables; fuentes Nunito/Fredoka One en nombres de región |
| M90 Gráfica | Re-aplicación del tema al cambiar resolución; layout sin cortes en 16:9/16:10 |
| M91 Audio UI | SFX de abrir/cerrar mapa, crear pin, viaje y filtros en el bus UI |
| M92 Tutorial | Notificación de primera apertura ("El mapa se revela al explorar...") |

## 6. Persistencia y estado guardado (M60)

- **RegionState**: tabla `region_state(region_id, seen, visited)` — barata, no se guarda la textura.
- **PinData**: lista serializable de pines.
- **MapConfig**: opciones del jugador (filtros, zoom preferido, visibilidad del minimapa, pines).
- **Textura base**: caché binaria por semilla del mundo; se valida contra la semilla al cargar (M60) y se regenera si difiere (con progreso M63).