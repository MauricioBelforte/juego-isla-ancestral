**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 15: Recursos

> Rutas propuestas dentro de `res://_Project/` (estructura de Assets según AGENTS.md sección 24, adaptada a Godot 4.x).

## 1. Archivos Involucrados

### Scripts (GDScript, tipado)
| Archivo | Propósito |
|---|---|
| `res://_Project/Scripts/Gameplay/Resources/ResourceManager.gd` | Autoload orquestador: catálogo, registro de nodos, respawn, persistencia |
| `res://_Project/Scripts/Gameplay/Resources/ResourceDefinition.gd` | Recurso serializable (`.tres`) con toda la data de un material |
| `res://_Project/Scripts/Gameplay/Resources/ResourceNode.gd` | Nodo 3D recolectable con estados y feedback |
| `res://_Project/Scripts/Gameplay/Resources/ResourceDrops.gd` | Generación, dispersión, pooling e imán de drops |
| `res://_Project/Scripts/Gameplay/Resources/ResourceSpawner.gd` | Planificación por región, presupuesto y respawn |
| `res://_Project/Scripts/Gameplay/Resources/RecursoBolsa.gd` | Bolsa de drops para suelo saturado |

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