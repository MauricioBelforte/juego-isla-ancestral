**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 15: Recursos

> Rutas propuestas dentro de `res://_Project/` (estructura de Assets según AGENTS.md sección 24, adaptada a Godot 4.x).

## 1. Archivos Involucrados

### Scripts (GDScript, tipado)
> ⚠️ **Nota de paths (2026-08-30):** Los scripts reales están en `res://scripts/resources/`, no en `res://_Project/Scripts/Gameplay/Resources/` como se documentó originalmente.

| Archivo | Propósito | Estado |
|---|---|---|
| `scripts/resources/resource_manager.gd` | Autoload orquestador: catálogo, registro de nodos, respawn, persistencia. Señales: `drop_recogido`, `recurso_agotado`, `recoleccion_evento` | ✅ Implementado |
| `scripts/resources/resource_definition.gd` | `ResourceDefinition` (class_name): recurso serializable con `def_id`, `display_name`, `categoria` (enum MADERA/PIEDRA/FIBRA/COMIDA/MINERAL/RARO), `rareza`, `herramienta_requerida`, `golpes_requeridos`, `drops`, `valor_venta` | ✅ Implementado |
| `scripts/resources/resource_node.gd` | `ResourceNode` (class_name): nodo 3D recolectable con estados INTACTO/DANIADO/AGOTADO. Usa TerrainLocator para posicionarse. Mesh placeholder por estado | ✅ Implementado |
| `scripts/resources/resource_drop_entry.gd` | `ResourceDropEntry` (class_name): entrada de drop con `item_id`, `cantidad_min/max`, `probabilidad`, `requiere_herramienta_mejorada` | ✅ Implementado |
| `scripts/resources/resource_spawner.gd` | `ResourceSpawner` (class_name): planificación por región, presupuesto (max 200 nodos activos), radio de burbuja 48.0. Se comunica con ResourceManager | ✅ Implementado |

### Escenas y datos (editor)
| Archivo | Propósito |
|---|---|
| `res://_Project/Prefabs/Resources/ResourceNode.tscn` | Nodo genérico con Area3D + mesh slots |
| `res://_Project/Prefabs/Resources/RecursoDrops.tscn` | RigidBody3D de drop con pooling |
| `res://_Project/Prefabs/Resources/RecursoBolsa.tscn` | Bolsa recogible |
| `res://_Project/ScriptableObjects/Resources/*.tres` | Definiciones: madera_roble, madera_pino, piedra, fibra_algodon, fruta_kaki, baya_azul, cobre, hierro, oro_ancestral, cristal_estacional, polvo_estrellas... |
| `res://_Project/Config/Resources/resource_catalog.tres` | Catálogo central con lista de definiciones |

### Integración (señales de otros módulos)
| Señal | Dónde se conecta |
|---|---|
| `golpe_aplicado(pos, herramienta_id, fuerza)` | M13 (Herramientas) |
| `estacion_cambio(nueva_estacion)` | M29/M32 (Calendario/Estaciones) |
| `evento_iniciado` / `evento_finalizado` | M73 (Eventos) |
| `region_activada(region_id)` | M08 (Mundo Voxel) |
| `voxel_modificado(...)` | M17/M08 (Construcción) |
| `agregar_items(entrega)` | M14 (Inventario) |

## 1.1 Catálogo de Recursos Base (50+ definiciones)

> Cada recurso es un `ResourceDefinition` serializado como `.tres`. Los drops se calibran para que el jugador siempre tenga material para crafting inmediato (M16).

### MADERA (12 tipos)

| def_id | display_name | Rareza | Herramienta | Golpes | Drops | Valor venta | Temporada | Región |
|--------|-------------|--------|-------------|--------|-------|-------------|-----------|--------|
| `madera_roble` | Madera de Roble | 0 | hacha_cualquiera | 3 | 2-4 madera_roble + 10% rama_seca | 5 | todas | cualquier |
| `madera_pino` | Madera de Pino | 0 | hacha_cualquiera | 3 | 2-3 madera_pino + 15% resina_pino | 5 | todas | bosque_nevado |
| `madera_olmo` | Madera de Olmo | 0 | hacha_cualquiera | 2 | 3-5 madera_olmo | 4 | todas | riberas |
| `madera_cerezo` | Madera de Cerezo | 1 | hacha_cualquiera | 2 | 2-3 madera_cerezo + 5% flor_cerezo | 8 | primavera | isla_raiz |
| `madera_cedro` | Madera de Cedro | 1 | hacha_hierro | 4 | 2-4 madera_cedro | 12 | todas | bosque_denso |
| `madera_ebano` | Madera de Ébano | 2 | hacha_oro | 5 | 1-2 madera_ebano | 25 | todas | zona_oscura |
| `madera_bambu` | Bambú | 0 | hacha_cualquiera | 1 | 3-6 bambu | 3 | todas | riberas |
| `madera_sauce` | Madera de Sauce | 0 | hacha_cualquiera | 2 | 2-4 madera_sauce | 5 | todas | junto_agua |
| `madera_abedul` | Madera de Abedul | 1 | hacha_cualquiera | 2 | 2-3 madera_abedul | 7 | todas | bosque_claro |
| `madera_olivo` | Madera de Olivo | 1 | hacha_hierro | 3 | 1-2 madera_olivo | 15 | todas | isla_coral |
| `madera_nogal` | Madera de Nogal | 2 | hacha_oro | 4 | 1-3 madera_nogal | 20 | todas | isla_aurora |
| `madera_sandalia` | Madera de Sandalia | 3 | hacha_cristal | 5 | 1 madera_sandalia | 50 | todas | isla_aurora |

### PIEDRA Y MINERALES (14 tipos)

| def_id | display_name | Rareza | Herramienta | Golpes | Drops | Valor venta | Temporada | Región |
|--------|-------------|--------|-------------|--------|-------|-------------|-----------|--------|
| `piedra_granito` | Granito | 0 | pico_cualquiera | 3 | 2-4 piedra_granito | 3 | todas | cualquier |
| `piedra_caliza` | Caliza | 0 | pico_cualquiera | 2 | 3-5 piedra_caliza | 2 | todas | costas |
| `piedra_schisto` | Esquisto | 0 | pico_cualquiera | 3 | 2-3 piedra_schisto | 4 | todas | montanas |
| `cobre_bruto` | Cobre Bruto | 1 | pico_hierro | 4 | 1-3 cobre_bruto + 20% pirita | 10 | todas | minas_raiz |
| `hierro_bruto` | Hierro Bruto | 1 | pico_hierro | 5 | 1-2 hierro_bruto | 15 | todas | minas_ceniza |
| `oro_bruto` | Oro Bruto | 2 | pico_oro | 6 | 1 oro_bruto | 30 | todas | minas_coral |
| `cristal_bruto` | Cristal Bruto | 3 | pico_cristal | 7 | 1 cristal_bruto | 60 | todas | minas_aurora |
| `obsidiana` | Obsidiana | 2 | pico_oro | 8 | 1 obsidiana | 35 | todas | volcan |
| `marmol` | Mármol | 1 | pico_hierro | 4 | 2-3 marmol | 12 | todas | ruinas |
| `granito_rosa` | Granito Rosa | 1 | pico_hierro | 3 | 1-2 granito_rosa | 14 | todas | isla_coral |
| `arena_cuarzo` | Arena de Cuarzo | 0 | pico_cualquiera | 1 | 3-5 arena_cuarzo | 2 | todas | costas |
| `sal_gema` | Sal Gema | 1 | pico_cualquiera | 2 | 2-4 sal_gema | 8 | todas | cuevas |
| `azabache` | Azabache | 2 | pico_oro | 5 | 1 azabache | 28 | todas | zona_oscura |
| `ambar` | Ámbar | 2 | pico_oro | 4 | 1 ambar | 32 | todas | bosque_antiguo |

### FIBRAS Y PLANTAS (10 tipos)

| def_id | display_name | Rareza | Herramienta | Golpes | Drops | Valor venta | Temporada | Región |
|--------|-------------|--------|-------------|--------|-------|-------------|-----------|--------|
| `fibra_algodon` | Algodón | 0 | tijeras | 1 | 2-4 fibra_algodon | 3 | todas | praderas |
| `fibra_lino` | Lino | 0 | tijeras | 1 | 2-3 fibra_lino | 4 | todas | campos |
| `fibra_caña` | Caña | 0 | tijeras | 1 | 3-5 cana | 2 | todas | riberas |
| `hierba_seca` | Hierba Seca | 0 | manos | 1 | 2-3 hierba_seca | 1 | todas | cualquier |
| `moho_luminoso` | Luminoso | 1 | lupa | 1 | 1 moho_luminoso | 8 | todas | cuevas |
| `musgo_ancestral` | Musgo Ancestral | 2 | lupa | 2 | 1 musgo_ancestral | 20 | todas | ruinas |
| `liquen_perla` | Liquen Perla | 2 | tijeras | 2 | 1 liquen_perla | 22 | todas | bosque_coral |
| `flor_kaki` | Flor Kaki | 1 | tijeras | 1 | 1-2 flor_kaki | 6 | otoño | isla_raiz |
| `flor_cerezo` | Flor de Cerezo | 1 | tijeras | 1 | 1 flor_cerezo | 10 | primavera | isla_raiz |
| `algas_mares` | Algas del Mar | 0 | manos | 1 | 2-4 algas_mares | 2 | todas | costas |

### COMIDA Y FRUTAS (12 tipos)

| def_id | display_name | Rareza | Herramienta | Golpes | Drops | Valor venta | Temporada | Región |
|--------|-------------|--------|-------------|--------|-------|-------------|-----------|--------|
| `fruta_kaki` | Kaki | 0 | manos | 1 | 1-3 fruta_kaki | 4 | otoño | isla_raiz |
| `baya_azul` | Baya Azul | 0 | manos | 1 | 2-4 baya_azul | 3 | verano | bosque |
| `manzana_dorada` | Manzana Dorada | 1 | manos | 1 | 1-2 manzana_dorada | 8 | otoño | isla_aurora |
| `naranja_salvaje` | Naranja Salvaje | 0 | manos | 1 | 2-3 naranja_salvaje | 4 | primavera | isla_coral |
| `coco_playa` | Coco | 0 | manos | 1 | 1-2 coco_playa | 3 | todas | costas |
| `uva_cueva` | Uva de Cueva | 1 | tijeras | 1 | 2-3 uva_cueva | 6 | todas | cuevas |
| ` seta_luminosa` | Seta Luminosa | 1 | lupa | 1 | 1-2 seta_luminosa | 7 | todas | bosque_humedo |
| `tomate_montaña` | Tomate Montaña | 0 | manos | 1 | 1-3 tomate_montana | 3 | verano | isla_ceniza |
| `papa_ancestral` | Papa Ancestral | 1 | azada | 2 | 1-2 papa_ancestral | 8 | todas | isla_raiz |
| `calabaza_grande` | Calabaza | 0 | hacha | 2 | 1 calabaza_grande | 5 | otoño | isla_raiz |
| `chile_volcan` | Chile Volcán | 2 | manos | 1 | 1 chile_volcan | 12 | verano | isla_ceniza |
| `rosa_arctica` | Rosa Ártica | 3 | tijeras | 1 | 1 rosa_arctica | 40 | verano | isla_aurora |

### RECURSOS ESPECIALES (8 tipos)

| def_id | display_name | Rareza | Herramienta | Golpes | Drops | Valor venta | Temporada | Región |
|--------|-------------|--------|-------------|--------|-------|-------------|-----------|--------|
| `polvo_estrellas` | Polvo de Estrellas | 3 | lupa | 1 | 1 polvo_estrellas | 80 | noche | templo |
| `resina_pino` | Resina de Pino | 1 | hacha | 2 | 1-2 resina_pino | 6 | todas | bosque_nevado |
| `barro_volcanico` | Barro Volcánico | 1 | pala | 2 | 2-3 barro_volcanico | 5 | todas | volcan |
| `arcilla_roja` | Arcilla Roja | 0 | pala | 2 | 3-5 arcilla_roja | 3 | todas | riberas |
| `incienso_silvestre` | Incienso Silvestre | 2 | tijeras | 1 | 1 incienso_silvestre | 25 | todas | monte_remoto |
| `fragmento_anillo` | Fragmento de Anillo | 3 | lupa | 1 | 1 fragmento_anillo | 100 | todas | ruinas |
| `semilla_ancestral` | Semilla Ancestral | 3 | azada | 1 | 1 semilla_ancestral | 120 | primavera | templo |
| `cristal_caverna` | Cristal de Caverna | 2 | pico_oro | 5 | 1 cristal_caverna | 35 | todas | cuevas_profundas |

### PECES (8 tipos) — M34 Pesca

| def_id | display_name | Rareza | Herramienta | Golpes | Drops | Valor venta | Temporada | Región |
|--------|-------------|--------|-------------|--------|-------|-------------|-----------|--------|
| `pez_gato` | Pez Gato | 0 | cania | — | 1 pez_gato | 5 | todas | riberas |
| `pez_dorado` | Pez Dorado | 1 | cania | — | 1 pez_dorado | 15 | todas | lagos |
| `pez_volcan` | Pez Volcánico | 2 | cania_mejorada | — | 1 pez_volcan | 25 | todas | aguas_terminales |
| `pez_luna` | Pez Luna | 2 | cania_avanzada | — | 1 pez_luna | 30 | noche | isla_aurora |
| `pez_cueva` | Pez Ciego | 1 | cania | — | 1 pez_cueva | 12 | todas | cuevas |
| `pez_mandarina` | Mandarina | 1 | cania | — | 1-2 pez_mandarina | 10 | primavera | isla_coral |
| `pez_arcoiris` | Pez Arcoíris | 3 | cania_especial | — | 1 pez_arcoiris | 60 | verano | isla_aurora |
| `pulpo_mini` | Mini Pulpo | 0 | cania | — | 1 pulpo_mini | 4 | todas | costas |

### TESOROS RAROS (5 tipos)

| def_id | display_name | Rareza | Herramienta | Golpes | Drops | Valor venta | Temporada | Región |
|--------|-------------|--------|-------------|--------|-------|-------------|-----------|--------|
| `moneda_ancestral` | Moneda Ancestral | 3 | pico_oro | — | 1 moneda_ancestral | 150 | todas | ruinas |
| `reliquia_sol` | Reliquia del Sol | 3 | lupa | — | 1 reliquia_sol | 200 | todas | templo |
| `gema_esmeralda` | Esmeralda | 2 | pico_oro | — | 1 gema_esmeralda | 45 | todas | minas_profundas |
| `gema_rubi` | Rubí | 2 | pico_oro | — | 1 gema_rubi | 40 | todas | minas_profundas |
| `mapa_tesoro` | Mapa del Tesoro | 2 | lupa | — | 1 mapa_tesoro | 50 | todas | costas |

---

TOTAL: 69 recursos base (12 madera + 14 piedra/mineral + 10 fibra/planta + 12 comida + 8 especial + 8 pescados + 5 tesoros)

---

## 2. Funciones Clave (firmas GDScript)

```gdscript
# ---------- ResourceDefinition.gd ----------
class_name ResourceDefinition
extends Resource

@export var def_id: StringName
@export var display_name: String
@export var categoria: Categoria   # enum {MADERA, PIEDRA, FIBRA, COMIDA, MINERAL, RARO}
@export var rareza: int = 0        # 0 comun .. 3 legendario
@export var icono: Texture2D
@export var herramienta_requerida: StringName = &""   # "" = manos
@export var golpes_requeridos: int = 2
@export var drops: Array[DropEntry] = []
@export var temporada_respawn: StringName = &"todas"
@export var evento_respawn: StringName = &""          # "" = ninguno
@export var region: StringName = &""                  # "" = cualquier
@export var mesh_intacto: PackedScene
@export var mesh_daniado: PackedScene
@export var mesh_agotado: PackedScene
@export var valor_venta: int = 0
@export var fuentes_alternativas: Array[StringName] = []

func es_herramienta_valida(herr_id: StringName) -> bool:
    return herramienta_requerida == &"" or herr_id == herramienta_requerida

func es_estacional_de(nueva_estacion: StringName) -> bool:
    return temporada_respawn == &"todas" or temporada_respawn == nueva_estacion

func validar_definicion() -> Array[String]:
    # Devuelve lista de errores de data (QA en editor)
    pass

# ---------- DropEntry.gd ----------
class_name DropEntry
extends Resource

@export var item_id: StringName
@export var cantidad_min: int = 1
@export var cantidad_max: int = 1
@export var probabilidad: float = 1.0          # 0.0 .. 1.0
@export var requiere_herr_mejorada: bool = false
```

```gdscript
# ---------- ResourceNode.gd ----------
class_name ResourceNode
extends Node3D

signal recolectado_por_jugador(def_id: StringName, cantidad_total: int)

enum Estado { INTACTO, DANIADO, AGOTADO }

@export var def_id: StringName
@export var region_id: StringName
@export var voxel_base: Vector3i            # anclaje al mundo voxel M08
@export var modo_impostor: bool = false     # sin fisica ni Area3D (> 48 m)

var estado: Estado = Estado.INTACTO
var golpes_restantes: int = 1
var node_id: int = -1

func _ready() -> void:
    _suscribirse_golpes()

func aplicar_golpe(pos: Vector3, herramienta_id: StringName, fuerza: int) -> void:
    # Valida herramienta, desgasta, feedback, y al agotar llama a ResourceManager
    pass

func _on_golpe_aplicado(pos: Vector3, herramienta_id: StringName, fuerza: int) -> void:
    if _dentro_del_area(pos) and not modo_impostor:
        aplicar_golpe(pos, herramienta_id, fuerza)

func _feedback_golpe() -> void:
    pass    # animacion de sacudida + particulas del material + sonido

func _feedback_recurso_incorrecto() -> void:
    pass    # texto/visual suave "necesitas un pico"

func activar_impostor() -> void:
    pass    # mesh estatico barato, sin Area3D ni fisica

# ---------- ResourceDrops.gd ----------
class_name ResourceDrops
extends Node        # helper del ResourceManager

@export var MAX_DROPS_ZONA: int = 40
@export var MAX_DROPS_FISICOS: int = 60
@export var RADIO_IMAN: float = 1.5
@export var TIEMPO_A_BOLSA: float = 120.0

signal drop_recogido(item_id: StringName, cantidad: int)
signal suelo_saturado(se_convirtio_en_bolsa: bool)

func generar(def: ResourceDefinition, pos: Vector3, rng: RandomNumberGenerator) -> void:
    pass    # calcula cantidades por DropEntry, instancia drops con pooling

func _crear_drop_fisico(item_id: StringName, cantidad: int, pos: Vector3) -> void:
    pass

func _conseguir_drop_pool() -> RigidBody3D:
    pass

func _recoger_drop(body: Node3D, drop_id: int) -> void:
    # iman + contacto -> Inventario.agregar_items y señal drop_recogido
    pass

func _convertir_a_bolsa(item_id: StringName, cantidad: int, pos: Vector3) -> void:
    pass    # cuando el suelo esta saturado o expira el drop

# ---------- ResourceSpawner.gd ----------
class_name ResourceSpawner
extends Node        # hijo del ResourceManager

@export var RADIO_ACTIVO: float = 48.0
@export var RADIO_IMPOSTOR: float = 96.0
@export var MAX_INSTANCIAS_ACTIVAS: int = 200
@export var RADIO_REUBICACION_VOXELES: int = 8

signal recurso_reaparecio(def_id: StringName, pos: Vector3)

func planificar_region(region_id: StringName) -> void:
    pass    # genera candidatos con seed PRNG y reglas de bioma

func _validar_candidato(entry: Dictionary) -> bool:
    pass    # caminable (M08), sin superposicion, dentro de limites

func instanciar_nodo(entry: Dictionary) -> int:
    pass    # crea ResourceNode dentro de la burbuja; devuelve node_id

func procesar_respawn(nueva_estacion: StringName) -> void:
    pass    # recorre agotados con fecha vencida y los repone

func revalidar_posiciones(region_id: StringName) -> void:
    pass    # tras cargar chunk o construir (M17)

func _aplicar_presupuesto() -> void:
    pass    # alta/desactiva impostores segun distancia al jugador

# ---------- ResourceManager.gd (autoload) ----------
extends Node         # nombre de autoload: "ResourceManager"

const CATALOGO_PATH: String = "res://_Project/Config/Resources/resource_catalog.tres"

signal recurso_agotado(def_id: StringName, pos: Vector3, region_id: StringName)
signal recurso_reaparecio(def_id: StringName, pos: Vector3)
signal recoleccion_evento(def_id: StringName, cantidad_total: int, herramienta_id: StringName)

var _definiciones: Dictionary = {}          # def_id -> ResourceDefinition
var _nodos: Dictionary = {}                 # node_id -> entry {...}
var _siguiente_node_id: int = 0

func _ready() -> void:
    _cargar_catalogo()
    _conectar_senales_externas()

func obtener_def(def_id: StringName) -> ResourceDefinition:
    return _definiciones.get(def_id)

func registrar_nodo(entry: Dictionary) -> int:
    pass

func recurso_agotado(node_id: int) -> void:
    pass    # marca estado, calcula fecha_reaparicion (PRNG M29), serializa

func pedir_respawn(node_id: int) -> void:
    pass    # reposicion inmediata (eventos M73, tests, cheats)

func guardar_estado() -> Dictionary:
    pass    # solo nodos no intactos + contadores PRNG

func cargar_estado(data: Dictionary) -> void:
    pass

func cantidad_de(def_id: StringName) -> int:
    pass    # consulta de stock para M16

func _conectar_senales_externas() -> void:
    pass    # golpe_aplicado (M13), estacion_cambio (M29/M32),
            # evento_iniciado/finalizado (M73), region_activada (M08)

# ---------- RecursoBolsa.gd ----------
class_name RecursoBolsa
extends Area3D

@export var contenido: Array[Dictionary] = []   # [{item_id, cantidad}]

func recoger(jugador: Node3D) -> void:
    pass    # todo a Inventario.agregar_items; excedente a caja (M17)

func _mostrar_contenido() -> void:
    pass    # etiqueta/icono encima para que el jugador sepa que hay
```

## 3. Logs Relacionados

| Log | Contenido |
|---|---|
| `DOM-REC` (módulo 15) | Recolecciones: `def_id`, cantidad, herramienta, pos, region; errores de validación de definiciones; conversiones a bolsa |
| `DOM-REC-SPAWN` | Planificación de región: candidatos generados, validados y rechazados (motivo) |
| `DOM-REC-RESPAWN` | Respawns: nodo restaurado, estación/evento que lo disparó, reubicación por construcción |
| `DOM-REC-PRESUPUESTO` | Instancias activas/impostores, picos de drops, zonas saturadas |
| `DOM-IA / M103` compartido | Informes de suelo saturado y expiración de drops (solo bajo flag debug) |

Formato de línea de ejemplo: `[DOM-REC] recolectado def=madera_roble cant=4 herr=hacha_bronce region=bosque_posadas pos=(12.5, 8.0, -30.1)`

## 4. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16
**Estado:** Plan-inicial (documentación de diseño; sin código runtime aún)

### Lo que hice
- Documenté rutas propuestas, firmas GDScript y contratos de señales para el módulo 15 Recursos.
- Defini la API de integración con M08, M13, M14, M16, M29/M32/M73.

### Lo que NO pude hacer (honestidad obligatoria)
- No hay código runtime: el módulo se implementará tras existir M08 (mundo voxel) y M13 (herramientas).
- Las rutas `res://_Project/...` son propuestas; se ajustarán a la estructura final del proyecto Godot.

### Recomendaciones para el próximo agente
- Implementar primero `ResourceDefinition` y el catálogo de 10-12 definiciones de ejemplo.
- Validar el flujo de golpe antes que el respawn; el respawn depende de M29/M32.
- En `plan-actual/` copiar estos archivos y actualizarlos contra el código real a medida que se implemente.

## Notas del Agente (iteración 3 — 2026-08-31)

**Modelo:** GLM (Kilo)
**Plataforma:** Kilo
**Fecha:** 2026-08-31 08:25:00
**Estado:** Iter 3 cerrada. Módulo liberado a 🟡 con 5 [?] con dueño.

### Lo que hice
- **Persistencia ISaveProvider M59 (real):** `ResourceManager.get_save_data()` v2 retorna array de nodos con `{def_id, pos, estado, golpes_restantes, respawn_dia}`. `restore_save_data(data)` valida `version >= 2` y popula `_estado_guardado_pendiente`. El `ResourceSpawner` consulta `consumir_estado_guardado_para(def_id, pos)` al instanciar para aplicar el estado guardado.
- **Respawn con M29:** `ResourceNode` tiene `respawn_dia_absoluto` y `respawn_estacion` (mapeado desde `def.temporada_respawn` por `get_respawn_estacion_int`). `evaluar_respawn(dia, estacion)` vuelve a INTACTO si dia>=respawn y temporada coincide. El manager escucha `GameTime.dia_cambio` y evalúa todos los nodos diariamente.
- **Helper `recibir_golpe_en_nodo(nodo, herramienta)`:** valida `def.es_accesible_con(herramienta, true)`, aplica `aplicar_golpe`, al agotar programa respawn con `gt.dia_absoluto() + def.dias_para_respawn` (default 2), entrega drops a M14 vía `entregar_drops`, y emite `recurso_agotado`.
- **Test `test_recursos_persistencia.gd` (nuevo):** 4 tests, 13 checks, 0 fallos. Regresiones M16/M31/M15-iter2 todas verdes.

### Lo que NO pude hacer (honestidad obligatoria)
- **Cableado M13→M15:** M13 `tool_controller.gd` usa `VoxelTool.raycast` (chunks voxel) y NO detecta `ResourceNode` (Node3D con Area3D). El helper `recibir_golpe_en_nodo` está listo y testeado, pero nadie lo invoca desde el input del jugador. Opciones: (a) añadir un `RayCast3D` físico en M13 que también detecte colisionadores Node3D; (b) que el Area3D del ResourceNode use `input_event` cuando el jugador está cerca. NO toqué M13 (es de Hy3). Documentado como [?] con dueño.
- **Test de `dia_cambio` en runtime** que dispare respawn vía la señal real de M29 (el helper está, falta el test explícito).
- **Meshes del arte** (placeholders funcionales).
- **Recolección en área 3×3** (actualmente 1×1).
- **Persistencia de ResourceSpawner** (regiones + presupuesto).

### Intento fallido
- Primera versión del test usaba `ResourceNode.new()` sin añadir al árbol. `global_position` en nodo suelto emite `ERR_FAIL_COND_V_MSG` y devuelve `(0,0,0)`, así que la save tenía pos=[0,0,0] y el `consumir_estado_guardado_para` no encontraba match. **Fix:** helper `_crear_nodo_registrado()` que hace `root.add_child(nodo)` antes de setear posición. Candidato a 07-GUIA-GODOT §9.

### Recomendaciones para el próximo agente
- Resolver el cableado M13→M15 (Hy3) o añadir un RayCast3D en M13 que atraviese tanto el buffer voxel como las colisiones Node3D.
- Cuando M45 provea los meshes, reemplazar los placeholders en `ResourceNode._crear_mesh`.
- Considerar pooling de `ResourceNode` cuando el presupuesto se acerque a MAX_NODOS_ACTIVOS.