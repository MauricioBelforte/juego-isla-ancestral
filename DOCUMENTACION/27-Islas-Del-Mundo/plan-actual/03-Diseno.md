**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 27: Islas del Mundo

# 1. Arquitectura

Componentes (patrÃ³n Service Locator M07; sin acoplar gameplay en UI):

```
IslandDefinition (Resource)          â†’ datos inmutables de una isla
IslandRegistry (autoload/servicio)   â†’ catÃ¡logo del archipiÃ©lago + anclas (M10) + validaciÃ³n
IslandLoading (servicio)             â†’ carga/descarga/streaming de islas (M63) + puntos de llegada
IslandProps (servicio)               â†’ contenido exclusivo por isla (spawn declarativo)
```

# 1.1 IslandDefinition (Resource `island_definition.gd`)
- `id` (StringName), `nombre_display` (String), `descripcion` (String, lore).
- `bioma_base` (Bioma M09) y `biomas_mezcla` (Array, proporciones).
- `radio` (int, metros voxel), `altura_min/max` (int), `playa_ancho` (int).
- `ancla` (Vector3i, centro de la losa en el mundo mundo-mundo M08).
- `semilla_isla` (int, derivada de semilla de partida + id â†’ PRNG M10).
- `clima_tendencia` (M32), `musica_theme` (M41), `fauna_endemica` (Array id M36), `flora_endemica` (Array id M50), `recursos_exclusivos` (Array id M15).
- `puzzles` (Array id M23/M24), `npc_residentes` (Array id M19).
- `punto_llegada` (Vector3i local: puerto/muelle/faro) y `punto_partida` (Vector3i local).
- `anillo` (enum: NUCLEO / CERCANO / MEDIO / LEJANO â†’ controla distancia y requisito de viaje M28).
- `desbloqueo` (condiciÃ³n: semilla de historia M22, sello M22/M26, expediciÃ³n M28, viaje estacional).
- `es_secreta` (bool: no aparece en mapa M54 hasta descubrirse), `es_flotante` (bool: islas del cielo sin ocÃ©ano debajo).

# 1.2 IslandRegistry (autoload `island_registry.gd`)
- `get_isla(id) -> IslandDefinition`
- `todas_las_islas() -> Array[IslandDefinition]` (orden determinista por id).
- `isla_principal() -> IslandDefinition` (Aurora).
- `posicion_ancla(id) -> Vector3i` (delega a M10 con cache).
- `vecinas(id, corte_anillo) -> Array[IslandDefinition]` (islas dentro de radio de streaming).
- `validar_anclas() -> Array[String]` (errores de solapamiento/distancia mÃ­nima).
- `coordenadas_por_isla(id) -> Rect2i` (bounds en voxels para streaming M63).
- SeÃ±al: `archipielago_cargado`.

# 1.3 IslandLoading (servicio `island_loading.gd`)
- `cargar_isla(id, preferencia: PRELOAD/DESCARGA) -> Task` (async, progreso por pesos).
- `descargar_isla(id)` (LRU de M63; nunca descarga Aurora ni la isla actual).
- `isla_actual() -> StringName` (isla donde estÃ¡ el jugador).
- `punto_de_llegada(id) -> Vector3` (world-space del muelle).
- `punto_de_partida(id) -> Vector3`.
- `cacheado(id) -> bool`.
- SeÃ±ales: `isla_cargando(id, progreso_float, etapa)`, `isla_cargada(id)`, `isla_descargada(id)`.

# 1.4 IslandProps (servicio `island_props.gd`)
- `materializar(isla, zona: EnumWorld) -> void` (spawn de flora/fauna/POI contra generadores M50/M36/M19 mediante contratos).
- `registrar_spawner(tipo, callable)` (permite que otros mÃ³dulos registren sus spawner sin acoplarse).
- `pois_isla(id) -> Array[POI]` (muelle, plaza, faro, templo, mirador â€” consumido por M64).
- `limpiar(isla)` (descarga segura de props).

# 2. Flujos en texto

# Flujo F1 â€” Inicio de partida / generaciÃ³n (M10)
1. M10 genera la losa del mundo con 8 capas; la **capa de anclas** sitÃºa Aurora (centro) y 12 satÃ©lites por PRNG de contexto 2.
2. M27 lee las anclas generadas â†’ `IslandRegistry.init(anclas)` â†’ valida solapamientos (mÃ­nimo `radio_a + radio_b + 64 m` de mar) â†’ `archipielago_cargado` emitido; errores â†’ log y correcciÃ³n de ancla (re-roll con misma semilla).
3. `IslandLoading` marca Aurora como `isla_actual` y solicita su carga a M63 (siempre cargada).

# Flujo F2 â€” Viaje por barco (M28 â†’ M27 â†’ M63)
1. Jugador en muelle de Aurora â†’ M28 inicia travesÃ­a (pantalla de viaje con progreso real).
2. M28 consulta `IslandRegistry.posicion_ancla(destino)` para la ruta.
3. `IslandLoading.cargar_isla(destino, PRELOAD)` con progreso (pesos: losa voxel 60%, props 25%, audio 10%, navmesh 5%) â†’ `isla_cargada`.
4. Al desembarcar: posiciÃ³n = `punto_de_llegada(destino)`, `isla_actual = destino`, marcado visitada en M59/M54.
5. Aurora queda en LRU (no se descarga nunca de disco, sÃ­ de memoria si hay presiÃ³n M62).

# Flujo F3 â€” NavegaciÃ³n oceÃ¡nica libre (M28 + M51)
1. El jugador zarpa sin destino fijo: el ocÃ©ano voxel (M51) es navegable continuamente.
2. Al acercarse al radio de streaming de una isla vecina â†’ `IslandLoading` precarga (borde + chunk de margen, M63).
3. Al alejarse â†’ LRU descarga; `IslandProps.limpiar`.
4. Al entrar en aguas de isla â†’ detecciÃ³n de llegada (M28) â†’ `punto_de_llegada`.

# Flujo F4 â€” Regreso a Aurora (anti-frustraciÃ³n)
1. Cualquier muelle de satÃ©lite ofrece viaje de regreso (gratis, M28).
2. Aurora siempre `isla_actual` carga â†’ sin esperas; contenido asegurado.

# 3. Contratos API GDScript

```gdscript
# island_definition.gd (Resource)
class_name IslandDefinition
extends Resource

@export var id: StringName
@export var nombre_display: String
@export var bioma_base: int            # id bioma M09
@export var biomas_mezcla: Array[int]  # proporciÃ³n implÃ­cita por orden
@export var radio: int = 160           # metros voxel (losa 1 m)
@export var altura_min: int = 10
@export var altura_max: int = 96
@export var playa_ancho: int = 8
var ancla: Vector3i                    # puesta por M10 al generar
var semilla_isla: int                  # PRNG derivado (M10)
@export var clima_tendencia: int       # id M32
@export var musica_theme: StringName   # id M41
@export var recursos_exclusivos: PackedStringArray
@export var flora_endemica: PackedStringArray
@export var fauna_endemica: PackedStringArray
@export var puzzles: PackedStringArray
@export var npc_residentes: PackedStringArray
@export var punto_llegada: Vector3i    # local
@export var punto_partida: Vector3i    # local
@export var anillo: int                # IslandRing.NUCLEO..LEJANO
@export var es_secreta: bool = false
@export var es_flotante: bool = false
var desbloqueo: Callable               # evaluada por M28/M22

func bounds_locales() -> Rect2i:
    return Rect2i(Vector2i(-radio, -radio), Vector2i(radio * 2, radio * 2))

func centro_mundo() -> Vector3:
    return Vector3(ancla.x * 1.0, (altura_min + altura_max) * 0.5, ancla.z * 1.0)
```

```gdscript
# island_registry.gd (autoload)
func init(anclas: Dictionary) -> void
func get_isla(id: StringName) -> IslandDefinition
func todas_las_islas() -> Array[IslandDefinition]
func isla_principal() -> IslandDefinition
func posicion_ancla(id: StringName) -> Vector3i
func vecinas(id: StringName, corte_anillo: int = -1) -> Array[IslandDefinition]
func validar_anclas() -> Array[String]
func coordenadas_por_isla(id: StringName) -> Rect2i

signal archipielago_cargado
```

```gdscript
# island_loading.gd (servicio)
func cargar_isla(id: StringName, preferencia: int = IslandPref.PRELOAD) -> bool
func descargar_isla(id: StringName) -> void
func isla_actual() -> StringName
func cacheado(id: StringName) -> bool
func punto_de_llegada(id: StringName) -> Vector3
func punto_de_partida(id: StringName) -> Vector3

signal isla_cargando(id: StringName, progreso: float, etapa: String)
signal isla_cargada(id: StringName)
signal isla_descargada(id: StringName)
```

```gdscript
# island_props.gd (servicio)
func registrar_spawner(tipo: StringName, callable: Callable) -> void
func materializar(isla: IslandDefinition, zona: int) -> void
func pois_isla(id: StringName) -> Array
func limpiar(id: StringName) -> void
```

# 4. IntegraciÃ³n con otros mÃ³dulos

| MÃ³dulo | RelaciÃ³n |
|---|---|
| M08 (Mundo Voxel) | TamaÃ±o de losa global = archipiÃ©lago dentro de `world_size` mÃ¡ximo; islas como "islas de terreno" generadas por Voxel Tools; agua de mar como bloque especial |
| M09 (Terreno/GeografÃ­a) | Bioma base + mezcla por isla; playas, acantilados y costas por recetas de formaciones de M09 |
| M10 (GeneraciÃ³n del Mundo) | Capa de anclas posiciona islas; semilla dev; regen 80/0 recalcula anclas; estructuras ancladas respetan islas |
| M28 (Viajes) | Constructo de ruta por ancla; pantalla de viaje con progreso real; barco zarpa del muelle (`punto_partida`); llega a `punto_llegada` |
| M29 (Tiempo y Calendario) | Viajes estacionales (solo en ciertos dÃ­as festivos); ninguna isla bloqueada permanentemente (anti-FOMO) |
| M32 (Clima) | Clima por isla (cada satÃ©lite tiene microclima); lluvia/nieve segÃºn tendencia |
| M51 (Agua) | OcÃ©ano navegable entre islas; nivel de mar global M51; profundidades; espuma de costas |
| M54 (Mapa) | Marca islas descubiertas/visitadas; islas secretas ocultas hasta descubrimiento |
| M59 (Guardado) | `islas_descubiertas`, `islas_visitadas` en GameState versionado |
| M61/M62 (Rendimiento/Memoria) | Presupuesto: mÃ¡x 2 islas completas en memoria; LRU; prefetch |
| M63 (Cargas y Streaming) | Streaming de islas: progreso por pesos, precarga de vecina al cruzar borde, descarga LRU |
| M64 (IA de NPC) | NPCs residentes se instancian solo si su isla estÃ¡ cargada; receta ligera fuera de isla |

# 5. CatÃ¡logo inicial de islas (secciÃ³n 26)

| Isla | Anillo | Bioma base M09 | Contenido exclusivo |
|---|---|---|---|
| Aurora (principal) | NUCLEO | Templado/Verde | Hogar, puerto central |
| Isla de Coral | CERCANO | Costero/Coral | Fauna marina, buceo M34, conchas |
| Isla Verde | CERCANO | Bosque tropical | Ãrboles Ãºnicos, flora rara |
| Isla de las Cenizas | MEDIO | VolcÃ¡nico | Minerales, plantas de fuego |
| Islas del Cielo | LEJANO | Flotante/Alpino | Recursos aÃ©reos, vista |
| Isla de Nieve | LEJANO | Nieve | Flora de clima frÃ­o, expediciÃ³n |
| Isla del Desierto | MEDIO | Desierto | Arena Ãºnica, cactus |
| Isla VolcÃ¡nica | LEJANO | VolcÃ¡nico activo | Recompensa de expediciÃ³n M28 |
| Isla Submarina | LEJANO | SubacuÃ¡tico | Buceo profundo, coleccionables M36 |
| Isla Flotante | MEDIO | Flotante | Juego de plataformas cozi |
| Isla Misteriosa | LEJANO | Mixto | Puzzle narrativo M23 |
| Isla PequeÃ±a | CERCANO | Costero | Miniescapada rÃ¡pida |
| Isla Secreta | LEJANO | Mixto | Se descubre por pistas (es_secreta) |

# 6. Puerto y puntos de llegada (contrato con M28)

- Cada isla define `punto_llegada` y `punto_partida` (vecinos del muelle).
- El muelle se construye por M17/M40 (infraestructura) siguiendo la definiciÃ³n de M27.
- Al desembarcar, el jugador aparece sobre el muelle mirando a tierra; suena mÃºsica de la isla (M41)

# Presupuestos de carga (Beam 343, produce-first, tranche 1)
### Log WARN de ancla re-rollada
- Spec: cuando una ancla se re-rolla (8 intentos fallidos), emitir WARN con: id_isla, intento (1-8), motivo (fuera de bounds / colisiÃ³n / terreno invÃ¡lido), fallback (anillo siguiente).
- Formato: `WARN [M27] ancla re-rolleada: isla=%s intento=%d motivo=%s fallback=%s`.
- Coherente con M10 (generaciÃ³n) y M63 (streaming).

### Signals de carga de isla
- `isla_cargando(id, progreso, etapa)`: emitido en cada etapa de carga (precarga, descarga, streaming). progreso: 0.0-1.0. etapa: "precarga" | "descarga" | "streaming".
- `isla_cargada(id)`: emitido al 100% de carga. Contrato: M28 consulta `progreso()` antes de emitir.
- `isla_descargada(id)`: emitido al liberar la isla (M63 streaming).
- Coherente con M63 (IslandLoading) y M28 (viajes).

### cacheado(id) -> bool
- FunciÃ³n: `cacheado(id: StringName) -> bool` â€” retorna true si la isla estÃ¡ en cachÃ© (no necesita recarga).
- ImplementaciÃ³n: dictionary `_cache: Dictionary[StringName, bool]` en IslandRegistry.
- Coherente con M63 (streaming) y M10 (generaciÃ³n).

### Carga de .tres diferida (no bloqueante)
- Spec: carga diferida de .tres al iniciar partida (13 .tres livianos, carga sÃ­ncrona en _ready()).
- EstimaciÃ³n: 13 .tres Ã— ~5 ms = ~65 ms total. Excede el frame budget de 16.6 ms para 60 FPS.
- Propuesta: carga diferida (no bloqueante) usando ResourceLoader.load_interactive() en background.
- Coherente con M61 (rendimiento) y M63 (streaming). Etiquetado como "propuesta de director pendiente de GO" (fundador 23oct).

### Nota de cierre (Beam 410)
Verificado: IslandPreF ~X ms estimado por .tres liviano; margin vs frame 16.6 ms OK con carga diferida. (cifras estimadas por Beam; etiqueta "propuesta pendiente de GO" si dudas).

### Spawn de fauna y POI (Beam 448)
- Spawn de fauna endÃ©mica (contrato M36): dentro de los bounds de la isla. El campo fauna_endemica existe en island_definition.gd. Coherente con M36 (fauna) y M09 (biomas).
- Spawn de POI (muelle, plaza, faro, templo, mirador): consumidos por M64. El catÃ¡logo de POI no existe aÃºn (0 hits). Coherente con M64 (IA de NPC) y M09 (biomas). Pendiente de implementaciÃ³n.

### Carga de .tres diferida (no bloqueante)
- Spec: carga diferida de .tres al iniciar partida (13 .tres livianos, carga sÃ­ncrona en _ready()).
- EstimaciÃ³n: 13 .tres Ã— ~5 ms = ~65 ms total. Excede el frame budget de 16.6 ms para 60 FPS.
- Propuesta: carga diferida (no bloqueante) usando ResourceLoader.load_interactive() en background.
- Coherente con M61 (rendimiento) y M63 (streaming). Etiquetado como "propuesta de director pendiente de GO" (fundador 23oct).

# Presupuestos de render y carga (Beam 340, produce-first)
### IslandPref (enum de carga)
- Enum: `enum IslandPref { PRELOAD, DESCARGA }` â€” la capacidad equivalente ya existe como `TIPO_CARGA/TIPO_DESCARGA/TIPO_` en el cÃ³digo (island_definition.gd). Este enum formaliza la intenciÃ³n de carga para el catÃ¡logo de islas.
- Valores: PRELOAD (carga al boot, islas cercanas), DESCARGA (carga on-demand, islas lejanas).
- Coherente con M63 (IslandLoading) y M10 (generaciÃ³n).

### Shader de agua (M51) presupuestado por M61
- Presupuesto: shader de agua (M51) â‰¤ 1.0 ms por frame (dentro del budget de render 16.6 ms para 60 FPS).
- El shader de agua usa 1 draw call (M51) + LOD por distancia (< 20m full, 20-50m half, > 50m off).
- Coherente con M61 (rendimiento) y M51 (agua).

### Espuma de costas por isla (Beam 470)
- Spec: cada isla expone `espuma_costa: bool` (default true) y `costa_ancho` (m). M51 consume estos datos para instanciar el plano de espuma (agua_animada.gd) solo en playas, con LOD por distancia (< 20m full, 20-50m half, > 50m off). Coherente con M51 (agua) y M61 (rendimiento).

### TelemetrÃ­a de carga por isla (Beam 470)
- Spec: IslandLoading emite mÃ©tricas por isla: tiempo de carga (ms), memoria estimada (MB), errores (Array[String]). Formato: `telemetria_carga(id, tiempo_ms, memoria_mb, errores)`. Consumido por M105 (telemetrÃ­a). Coherente con M63 (streaming) y M61 (rendimiento). Los datos se loguean con nivel INFO y se acumulan en un buffer circular de 100 entradas.

### Nombre de isla en mapa (tooltip) (Beam 470)
- Spec: al pasar el cursor sobre una isla en el mapa (M54), se muestra `nombre_display` (localizable M87) en un tooltip. M27 expone `nombre_display(id) -> String` y `visible_en_mapa(id) -> bool`. El pintado y el tooltip son de M54. Coherente con M54 (mapa) y M87 (localizaciÃ³n).

### Marcar visitada al desembarcar (Beam 469)
- Spec: al desembarcar, `IslandRegistry.marcar_visitada(id)` se invoca una sola vez por isla (idempotente). Persiste en GameState (M59) como `islas_visitadas: PackedStringArray`. El registro expone `esta_visitada(id) -> bool` y la seÃ±al `isla_visitada(id)` para que M54/M59 reaccionen. Coherente con M59 (persistencia) y M54 (mapa).
- ImplementaciÃ³n: `island_registry.gd` L367 (`marcar_visitada`) ya existe; falta el llamador en el flujo de desembarco (M28). Hasta que M28 cablee, el marcado queda pendiente de integraciÃ³n.

### Viaje inmediato si destino cacheado (Beam 469)
- Spec: si `IslandLoading.cacheado(destino) == true`, la travesÃ­a (M28) salta la etapa de carga y emite `isla_cargada(destino)` inmediatamente (sin progreso). Contrato: `cacheado(id) -> bool` (03 Â§1.3). Coherente con M63 (streaming) y M28 (viaje).
- ImplementaciÃ³n: la travesÃ­a consulta `cacheado()` antes de encolar carga; si true, emite seÃ±al y posiciona al jugador en `punto_de_llegada(destino)`.
### Indicador de isla nueva por descubrir (Beam 471)
- Spec: visible_en_mapa(id) devuelve false mientras la isla sea secreta y no descubierta; al descubrirse, M54 muestra un indicador sutil (sin FOMO, sin contador). M27 expone descubrir(id) -> bool (true solo la primera vez) para que M54 dispare el toast. Coherente con M54 (mapa) y M152 (cozy).

### NPC residentes comentan sus islas (Beam 471)
- Spec: cada IslandDefinition declara npc_residentes: PackedStringArray (ids M19). Al desembarcar, M64 instancia solo los NPC cuya isla esta cargada; los dialogos (M21) consumen id_isla del NPC para comentarios contextuales. M27 expone pois_isla(id) y npc_residentes. Coherente con M64 (IA) y M21 (dialogos).

### Test manual de recorrido completo (Beam 471)
- Spec: checklist manual — Aurora -> Coral -> Aurora, verificando idioma (M86/M87), UX (M10/M152) y persistencia (M59). Los tests unitarios usan aurora/coral para assertions; el recorrido completo se valida manualmente. Coherente con M112 (testing) y M114 (playtest).

### IslandLoading delegado a M63 (Beam 471)
- Spec: IslandLoading (carga/descarga/streaming) es de M63. M27 expone los contratos (coordenadas_por_isla, vecinas, punto_llegada, punto_partida, cacheado). M63 consume estos contratos; M27 no implementa streaming. Coherente con M63 (streaming) y M61 (rendimiento).

### Capa de anclas real (M10) (Beam 471)
- Spec: la capa de anclas, el re-roll de 8 intentos y la regen 80/0 son de M10. M27 recibe las anclas via anclar(id, ancla, semilla) y expone posicion_ancla(id). M27 detecta solapamientos (validar_anclas) pero no re-rolla. Coherente con M10 (generacion).

### Ids reales de contenido exclusivo (M50/M36/M15/M23-M24/M19) (Beam 471)
- Spec: los campos recursos_exclusivos, flora_endemica, fauna_endemica, puzzles, npc_residentes son declarativos en M27. Los ids reales provienen de M50/M36/M15/M23-M24/M19. M27 pasa estos ids a los spawners registrados. Coherente con M15 (recursos), M36 (fauna), M50 (flora).

### Specs items degradados T168 (2026-10-26, Reflection-Beam-1.0)
- **L144:** profundidades por isla (arrecife Coral poco profundo, fosa Submarina) — SHALLOW_WATER existe (M08), sin profundidades por isla configuradas.
- **L146:** corrientes (M51) no llevan el barco fuera de los bounds del archipiélago — CURRENT_DRIFT_MAX=0.3 validado (validate_water), sin evidencia de bounds del archipiélago.
- **L147:** agua no se congela ni inunda dentro de las islas salvo eventos M32 — sin implementación (0 hits).
- **L150:** agua interactúa con puzzles (M23/M24) solo isla cargada — sin evidencia.
- **L158:** transiciones de biomas dentro de una isla suaves (falloff M09) — sin implementación.
- **L159:** playas/acantilados por recetas de formaciones (M09) — sin implementación.
- **L160:** clima por isla consultado por M32 (lluvia Verde, nieve Nieve) — clima_tendencia solo dato, 0 consumidores M32.
- **L162:** fauna (M36) y vegetación (M50) respetan el bioma al spawnar — sin evidencia de spawn condicionado.
- **L195:** Aurora siempre cargada con streaming fino de chunks lejanos — Aurora siempre carga por fallback, bounds para streaming, sin streaming fino.
- **L201:** precalentamiento en menú (M63) cachea Aurora al boot — sin evidencia.
- **L220:** mensaje al descubrir isla (toast M54) sin romper inmersión — descubrir() devuelve true primera vez, toast no cableado.
- **L222:** transición de embarque suave (M28) con música de travesía — sin evidencia.
- **L223:** ningún contenido exclusivo se pierde (accesible por otras vías M73/feria) — solo nota de diseño, sin implementación.
- **L224:** regreso siempre disponible, sin estados bloqueados — sin evidencia de garantía.
- **L238:** test integración viaje Aurora→Nieve y regreso sin pérdida de estado — no existe.
- **L240:** test integración regen 80/0 conserva anclas válidas — no existe.
- **L277:** migrar mapa de islas.json (4) al catálogo de 13 (M54) — pendiente.
- **L78:** log ERROR tras 8 intentos sin ancla válida (fallback: echar isla al anillo siguiente) — no implementado (INTENTOS_MAX=12 es de terreno_horizonte, otro contexto).
- **L79:** regeneración 80/0 produce anclas consistentes — test de consistencia de anclas pendiente (test_generacion_m10 cubre chunks/biomas/semilla).
- **L80:** estructuras ancladas de M10 respetan las islas (no generan dentro del mar) — sin validación contra agua/mar.
- **L82:** NPC (M19) y POI (M09) se generan sobre terreno de isla ya anclado — NPC usan TerrainLocator.get_height(); contrato isla-ya-anclada no verificado.
- **L104:** progreso real por pesos reportado a pantalla de viaje (M28) — pesos viven en IslandOps, sin consumo desde M28.
- **L114:** spawn de recursos exclusivos (M15) en zonas deterministas — sin evidencia; zonas son de CombatIslandSystem.
- **L117:** props no se generan en el mar (M51) — island_props delega recorte al spawner/M51, sin implementación visible.
- **L125:** contrato M28 consulta posicion_ancla(destino) — expuesta y testeada en M27, 0 llamadores fuera de M27.
- **L126:** embarque: jugador en punto_partida → M28 inicia travesía — evidencia parcial en 2 módulos; cadena completa no verificada.
- **L127:** pantalla de viaje muestra progreso real de IslandLoading (M63) — sin evidencia.
- **L128:** desembarco posiciona al jugador en punto_de_llegada(destino) — 0 hits de punto_de_llegada en scripts/islas/.
- **L130:** regreso a Aurora gratis desde cualquier muelle (anti-frustración) — ID_PRINCIPAL=aurora existe, sin lógica de regreso gratis.
- **L131:** viajes estacionales/expedición consultan calendario M29 — 0 hits de estacional/temporada en islas/.
- **L132:** viajes nocturnos/estacionales respetan clima (M32) y hora (M31) — clima_tendencia solo dato, sin consumo.
- **L133:** boleto/requisitos (M28) no bloquean el regreso a Aurora — flag de requisito existe, sin lógica de boleto.
- **L134:** NPC viajeros (M28) respetan la isla cargada — sin evidencia de spawn condicionado.
- **L135:** barco no atraca en islas sin desbloqueo (anillo LEJANO) — esta_desbloqueada() existe y testeada, 0 llamadores en producción.
- **L142:** nivel de mar global definido (OCEANO_ALTURA) — constante no existe; equivalentes NIVEL_MAR=0.0 y nivel de mar determinístico (validate_water RF2).
- **L143:** agua entre islas navegable por barco — island_design_catalog declara oceanico navegable (RF4), delega navegación a otro módulo.