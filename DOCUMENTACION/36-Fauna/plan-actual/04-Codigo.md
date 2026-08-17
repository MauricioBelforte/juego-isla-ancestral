**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 36: Fauna

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/fauna/fauna_species.gd` | Resource | Datos puros de una especie (27 recursos .tres) |
| `res://src/fauna/fauna_clima_requerido.gd` | Resource | Requisito de clima/luna para especies condicionadas |
| `res://src/fauna/fauna_catalog.gd` | Autoload/Node | Carga y valida el catalogo de especies |
| `res://src/fauna/fauna_registry.gd` | Autoload | Autoridad de descubrimientos: avistamientos, dedupe, diario, persistencia |
| `res://src/fauna/fauna_spawner.gd` | Node3D | Burbuja de poblacion, filtros M09/M29/M31/M32, presupuesto, pool |
| `res://src/fauna/fauna_behavior.gd` | Node | FSM por animal; delega movimiento a M65; reporta avistamientos |
| `res://src/fauna/fauna_manada.gd` | Node3D | Contenedor de manadas gregarias (2-5 individuos compartiendo objetivos) |
| `res://data/fauna/especies/*.tres` | Data | 27 especies del catalogo inicial |
| `res://data/fauna/climas/*.tres` | Data | Requisitos de clima reutilizables (lluvia, niebla, nieve, luna llena) |
| `res://assets/fauna/paleta_colores.gd` | Util | Variantes de color compartidas entre especies |
| `res://assets/fauna/modelos/*.tscn` | Assets | Prefabs voxel de cada animal (M08) |
| `res://assets/fauna/audio/*.wav` | Assets | Sonidos de avistamiento y ambiente (M43/M44) |

## 2. API publica

```gdscript
# FaunaRegistry (autoload "FaunaRegistry")
extends Node

signal especie_avistada(especie_id: StringName, contexto: Dictionary)
signal especie_fotografiada(especie_id: StringName, foto_id: String)
signal diario_cambio

enum EstadoEspecie { NO_AVISTADA, AVISTADA, FOTOGRAFIADA }

const VERSION_REGISTRO: int = 1
const RUTA_SAVE: String = "user://fauna/registro.json"

func registrar_avistamiento(especie_id: StringName, contexto: Dictionary) -> void
func registrar_foto(especie_id: StringName, foto_id: String) -> void
func estado_especie(especie_id: StringName) -> EstadoEspecie
func porcentaje_descubierto() -> float
func encontrar_registrados() -> Array[Dictionary]
func obtener_contexto_especie(especie_id: StringName) -> Dictionary
func _guardar() -> void   # JSON versionado + backup
func _cargar() -> void    # con migracion de versiones
```

```gdscript
# FaunaBehavior (Node por individuo)
extends Node3D

signal solicitar_avistamiento(especie_id: StringName, contexto: Dictionary)

enum Estado { INACTIVO, DEAMBULAR, ALIMENTARSE, DESCANSAR, ALERTA, HUIDA, CURIOSA_ACERCARSE, OBSERVANDO_JUGADOR }

var especie: FaunaSpecies
var factor_miedo: float = 1.0          # pH individual +-10 % (PRNG M29)
var instancia_id: String               # UUID para dedupe por individuo

func inicializar(sp: FaunaSpecies, rng: RandomNumberGenerator) -> void
func _procesar_fsm(delta: float, jugador: Node3D, hora: int, clima: Dictionary) -> void
func _evaluar_avistamiento(jugador: Node3D, en_pantalla: bool) -> void
func _entrar_huida(dir_fuga: Vector3) -> void
func _colisionar_jugador() -> void     # colision blanda, sin dano
```

```gdscript
# FaunaSpawner (Node3D en el mundo)
extends Node3D

var radio_burbuja: float = 72.0
var presupuesto_max: int = 40
var por_especie_max: int = 6
var cache_bioma: Dictionary = {}       # pos -> bioma (cache de 20 celdas)

func _tick_spawn(delta: float) -> void
func _especie_valida(sp: FaunaSpecies, hora: int, estacion: int, clima: Dictionary) -> bool
func _generar_punto_candidato(rng: RandomNumberGenerator) -> Vector3
func _despawn_fade(individuo: FaunaBehavior) -> void
func reevaluar_por_clima(nuevo_clima: Dictionary) -> void
func reevaluar_por_hora(nueva_hora: int) -> void
func reevaluar_por_estacion(nueva_estacion: int) -> void
```

## 3. Firmas clave (detalle)

```gdscript
# FaunaSpecies.gd
class_name FaunaSpecies
extends Resource

@export var id: StringName
@export var nombre: String
@export var nombre_cientifico: String
@export var bioma_ids: Array[StringName]
@export var rareza: Rareza                     # enum { COMUN, POCO_COMUN, RARA, MUY_RARA }
@export var comportamiento: Comportamiento     # enum { HUIDA_INSTINTIVA, HUIDA_SUAVE, CURIOSA, PASIVA, PASIVA_AEREA, PASIVA_MARINA }
@export var clase: Clase                       # enum { TERRESTRE, ACUATICA, AEREA, ANFIBIA }
@export_range(0, 24) var hora_inicio: int
@export_range(0, 24) var hora_fin: int
@export var estaciones: Array[int]             # ids de estacion M29
@export var clima_especial: FaunaClimaRequerido
@export_range(0.01, 10.0) var escala_min: float
@export_range(0.01, 10.0) var escala_max: float
@export var velocidad_deambular: float
@export_range(0.5, 30.0) var radio_alarma: float
@export_range(0.5, 30.0) var radio_curiosidad: float
@export var velocidad_huida: float
@export var gregaria: bool
@export var variantes_color: PackedStringArray
@export var sonido_avistamiento: AudioStream
@export var sonidos_ambiente: Array[AudioStream]
@export var modelo_voxel: PackedScene
@export_multiline var pista_diario: String

func es_valida(hora: int, estacion: int, clima: Dictionary) -> bool
```

```gdscript
# FaunaClimaRequerido.gd
class_name FaunaClimaRequerido
extends Resource

enum Tipo { LLUVIA, LLUVIA_INTENSA, NIEBLA, NIEVE, NOCHE_LIMPIA, LUNA_LLENA, NINGUNO }

@export var tipo: Tipo = Tipo.NINGUNO
@export var texto_pista: String   # "Despues de la lluvia..." para el diario

func se_cumple(clima: Dictionary, hora: int, fase_luna: int) -> bool
```

## 4. Suscripciones e integracion (codigo)

```gdscript
# FaunaRegistry: suscripcion a M56 Fotografia
func _ready() -> void:
    if Engine.has_singleton("M56Fotografia"):
        var foto = Engine.get_singleton("M56Fotografia")
        foto.foto_con_fauna.connect(_on_foto_con_fauna)

func _on_foto_con_fauna(foto_id: String, especie_id: StringName, contexto: Dictionary) -> void:
    if _estado[especie_id] != EstadoEspecie.FOTOGRAFIADA:
        _estado[especie_id] = EstadoEspecie.FOTOGRAFIADA
        _fotos[especie_id] = foto_id
    especie_fotografiada.emit(especie_id, foto_id)
    _guardar()

# FaunaSpawner: reaccion a M32 Clima y M31 Reloj
func _ready() -> void:
    Clima.cambio_clima.connect(reevaluar_por_clima)
    Reloj.cambio_hora.connect(reevaluar_por_hora)
    Calendario.cambio_estacion.connect(reevaluar_por_estacion)

# FaunaBehavior: delegacion a M65 Animales IA
# M65 expone: animal.set_personalidad(datos), animal.deambular(destino), animal.huir(dir)
# M36 solo setea parametros y escucha estados para transiciones propias.
```

## 5. Logs (M103 Logging)

Formato `DOM-36` (dominio Fauna) con etiqueta `[FAUNA]`:

- `[FAUNA][SPAWN] especie=lombriz_luminosa pos=(12,34,5) manada=0 rng_semilla=8821`
- `[FAUNA][DESPAWN] especie=gaviota_crestada motivo=distancia pos=(200,40,12)`
- `[FAUNA][AVISTAMIENTO] especie=tortuga_lunar instancia=uuid-77aa duplicado=false`
- `[FAUNA][DEDUPE] especie=libelula_radiante instancia=uuid-77aa entrada_omitida=si`
- `[FAUNA][CLIMA] reevaluacion_por=lluvia especies_removidas=1 especies_agregadas=2`
- `[FAUNA][FOTO] especie=murcielago_ancestral foto_id=foto-2026-08-16-003`
- `[FAUNA][ERROR] catalogo: id duplicado 'rana_ancestral' ignorado`
- `[FAUNA][MIGRACION] registro v0 -> v1: 27 especies normalizadas`
- `[FAUNA][BUDGET] activos=40/40 por_especie=6/6 spawn_saltado=si`

Reglas M103: rotacion externa; fuera de `Assets/`; los logs de runtime usan `Debug.log` con el prefijo e informan de errores criticos (catalogo invalido, save corrupto) para `M122` (crash reporting).

## 6. Pendientes de implementacion

| Pendiente | Nota |
|---|---|
| FaunaRegistry + persistencia versionada | Bloqueado por definicion de formato de partida |
| FaunaSpawner sobre Voxel Tools | Requiere M08/M09 (consulta de bioma por voxel) |
| FaunaBehavior + FSM | Requiere M65 (runtime de animales) y M61 (presupuesto) |
| 27 recursos .tres + modelos voxel | Contenido; se puede prototipar con 5 especies |
| Contrato de foto con M56 | Requiere M56 implementado; contrato firmado en este diseno |
| Tests M112 y QA M114 | Presupuesto y vida de la isla en 3 dias |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 12:30:00
**Estado:** Documentacion de diseno completa (modulo delegable; bloqueado por M65/M09)

### Lo que hice
- Catalogo de 27 especies con bioma, rareza, horario, estacion, clima especial y comportamiento.
- Arquitectura de 4 componentes (Species, Registry, Behavior, Spawner) con contratos API GDScript.
- Flujos de spawn, avistamiento con dedupe, huida, fotografia (M56) y persistencia.
- Presupuesto de poblacion (40 activos, 96 m despawn) alineado con M61/M65.

### Lo que NO hice (honestidad obligatoria)
- Implementar: requiere M65 (Animals IA), M09 (biomas funcionales) y M08 (mundo voxel).
- Contrato real con M56: firmado como API prevista; validar al implementar M56.
- Modelos voxel de las 27 especies (contenido de arte, no abarcado aqui).

### Recomendaciones para el proximo agente
- Prototipar primero con 5 especies (cangrejo_ermitano, rana_ancestral, conejo_praderas, zorro_cola_luminosa, lombriz_luminosa) para validar el flujo completo sin arte final.
- El dedupe por instancia es critico: probar con el mismo individuo acercandose y alejandose varias veces.
- La especies condicionada al clima (lombriz tras lluvia) es el mejor test de la integracion M32.
- No introducir captura ni dano bajo ninguna circunstancia: es un principio innegociable del proyecto.