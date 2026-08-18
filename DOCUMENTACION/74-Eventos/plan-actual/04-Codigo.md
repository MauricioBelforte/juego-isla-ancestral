**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 74: Eventos

## 1. Archivos previstos (Pendiente de implementación)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://eventos/event_manager.gd` | Script (autoload `eventos`) | Orquestador: catálogo, agenda, disparo, participación, recompensas, persistencia |
| `res://eventos/event_definition.gd` | Script + Resource | Definición data-driven de cada evento (`.tres`) |
| `res://eventos/condicion_evento.gd` | Script + Resource | Condiciones declarativas reutilizables |
| `res://eventos/recompensa_def.gd` | Script + Resource | Definición de recompensas |
| `res://eventos/event_state.gd` | Script | Estado serializable por evento/año |
| `res://eventos/contexto_festival.gd` | Script | Contexto para diálogos (M21) |
| `res://eventos/data/festivales/fiesta_primavera.tres` | Data | Festival de Primavera (calendario Aurora) |
| `res://eventos/data/festivales/solsticio_verano.tres` | Data | Solsticio de Verano |
| `res://eventos/data/festivales/cosecha_otono.tres` | Data | Fiesta de la Cosecha |
| `res://eventos/data/festivales/festival_invierno.tres` | Data | Festival de Invierno (año nuevo) |
| `res://eventos/data/ferias/feria_colmena.tres` | Data | Feria del pueblo (mensual) |
| `res://eventos/data/ferias/mercado_nocturno.tres` | Data | Mercado nocturno estacional |
| `res://eventos/data/competencias/torneo_pesca.tres` | Data | Torneo de Pesca (M34) |
| `res://eventos/data/competencias/concurso_minero.tres` | Data | Concurso de Minería (M35) |
| `res://eventos/data/competencias/desafio_agricola.tres` | Data | Desafío Agrícola (M33) |
| `res://eventos/data/rituales/ceremonia_templos.tres` | Data | Ceremonia de los Templos (M24) |
| `res://eventos/data/rituales/vigilia_luna.tres` | Data | Vigilia de la Luna |
| `res://eventos/data/climaticos/aurora_boreal.tres` | Data | Aurora boreal (M32) |
| `res://eventos/data/climaticos/niebla_faro.tres` | Data | Niebla del Faro |
| `res://eventos/data/sorpresas/visita_sorpresa.tres` | Data | Visitas espontáneas |
| `res://eventos/data/sorpresas/regalo_puerta.tres` | Data | Regalos a la puerta |
| `res://ui/festival/w_agenda.gd` + `.tscn` | UI | Panel de agenda anual (M53) |
| `res://ui/festival/w_banner_evento.gd` + `.tscn` | UI | Banner no-modal aviso/inicio/fin |
| `res://ui/festival/w_ventana_festival.gd` + `.tscn` | UI | Ventana de festival: condiciones, recompensas, estado |
| `res://tests/eventos/test_calendario.gd` | Test | Suite unitaria de programación (M112) |
| `res://tests/eventos/test_disparo.gd` | Test | Suite de disparo/avisos/franjas |
| `res://tests/eventos/test_recompensas.gd` | Test | Suite de token anti-duplicado |
| `res://tests/eventos/test_clima.gd` | Test | Variante cubierta/traslado (M32) |
| `res://tests/eventos/test_persistencia.gd` | Test | Guardar/cargar, evento en curso, solapes |

> **Nota:** todos los archivos de `res://eventos/**` y `res://ui/festival/**` están **Pendiente de implementación**; esta documentación define contratos y firmas de referencia para el agente delegado.

## 2. Firmas de referencia (GDScript 4.x)

### 2.1 `event_manager.gd` (autoload `eventos`)

```gdscript
## EventManager — M74 Eventos. Servicio global (autoload "eventos").
## Consume M29 (GameClock/EventBus.time), M30 (GameClock), M32 (clima).
## Nota: dialogos con M21 vía ContextoFestival; integración NPC por señales (M19).

signal evento_proximo(evento: EventDefinition, dias: int)
signal evento_iniciado(evento: EventDefinition)
signal evento_terminado(evento: EventDefinition)
signal evento_cancelado(evento: EventDefinition, razon: StringName)
signal evento_recompensa_entregada(evento: EventDefinition, recompensa: RecompensaDef)
signal agenda_actualizada(agenda: Array[EventDefinition])

var catalogo: Dictionary = {}                    # id: EventDefinition
var agenda_anio: Array[EventDefinition] = []     # ordenada por fecha+prioridad
var estado_anual: Dictionary = {}                # anio: { evento_id: EventState }
var evento_actual: EventDefinition = null
var evento_actual_id: StringName = &""

func _ready() -> void:
    _cargar_catalogo()
    _conectar_eventbus()
    normalizar_agenda()

func get_eventos_del_dia(fecha: Dictionary) -> Array[EventDefinition]: pass
func get_eventos_proximos(dias: int) -> Array[EventDefinition]: pass
func get_estado_evento(evento_id: StringName, anio: int) -> EventState: pass
func puede_participar(evento_id: StringName) -> Dictionary: pass   # {ok: bool, razon: StringName}
func iniciar_participacion(evento_id: StringName, contexto: Dictionary = {}) -> bool: pass
func entregar_recompensa(evento_id: StringName) -> Array[RecompensaDef]: pass
func finalizar_evento(evento_id: StringName, resultado: Dictionary = {}) -> void: pass
func normalizar_agenda() -> void: pass
func registrar_sorpresa(evento_id: StringName) -> bool: pass
func get_recuerdos() -> Array: pass
func serializar() -> Dictionary: pass
func deserializar(datos: Dictionary) -> void: pass

func _on_dia_cambio(dia: Dictionary) -> void: pass      # M29
func _on_anio_cambio(datos: Dictionary) -> void: pass   # M29 → normalizar_agenda
func _on_clima_cambio(clima: Dictionary) -> void: pass  # M32 → variante cubierta/traslado
func _entregar_una(recompensa: RecompensaDef) -> void: pass  # M14/M20/M38/M71 + buzón fallback
```

### 2.2 `event_definition.gd`

```gdscript
class_name EventDefinition
extends Resource

enum Tipo { FESTIVAL, FERIA, COMPETENCIA, RITUAL, CLIMATICO, SORPRESA }

@export var id: String = ""
@export var tipo: Tipo = Tipo.FESTIVAL
@export var nombre_clave: StringName = &""          # M57 localizable
@export var descripcion_clave: StringName = &""
@export var dia: int = 0                            # 0 = relativo/condicional
@export var mes: int = 0                            # calendario Aurora M29
@export var estacion: int = -1                      # -1 = cualquiera
@export var hora_inicio: int = 0                    # minutos desde 0:00 (M30)
@export var hora_fin: int = 1440
@export var dias_aviso: int = 3
@export var prioridad: int = 10                     # solapes: mayor gana
@export var condiciones: Array[CondicionEvento] = []
@export var recompensas: Array[RecompensaDef] = []
@export var escena_recinto: PackedScene = null
@export var ocupacion_npc: Array = []               # datos para M19
@export var dialogos_id: StringName = &""           # M21
@export var variante_cubierta: PackedScene = null   # M32 lluvia/nieve
@export var recompensa_compensatoria: RecompensaDef = null
@export var flags: Dictionary = {}
```

### 2.3 `condicion_evento.gd`

```gdscript
class_name CondicionEvento
extends Resource

enum TipoCondicion { HORA_EN_FRANJA, ESTACION, CLIMA_OK, AMISTAD_MIN,
                     HISTORIA_PROGRESO, INVENTARIO_TIENE, SEMANA_DIA }

@export var tipo_condicion: TipoCondicion = TipoCondicion.ESTACION
@export var valor: Variant = null                   # int/String según tipo
@export var bandera: bool = true
@export var mensaje_fallo_clave: StringName = &""

func evaluar(ctx: Dictionary) -> Dictionary:      # {ok: bool, razon: StringName}
    pass
```

### 2.4 `recompensa_def.gd`

```gdscript
class_name RecompensaDef
extends Resource

enum TipoRecompensa { OBJETO, COLECCION, MONEDA, AMISTAD, PROGRESO, FERIA }

@export var tipo: TipoRecompensa = TipoRecompensa.OBJETO
@export var cantidad: int = 1
@export var id_item: StringName = &""              # M14
@export var id_npc: StringName = &""               # M20 amistad
@export var moneda: StringName = &""               # M38 moneda de feria
@export var progreso_id: StringName = &""          # M71
@export var clave_recuerdo: StringName = &""       # M37 galería
```

### 2.5 `event_state.gd`

```gdscript
class_name EventState
extends RefCounted

enum Estado { PENDIENTE, EN_CURSO, PARTICIPADO, NO_PARTICIPADO, CANCELADO }

var estado: Estado = Estado.PENDIENTE
var recompensas_recibidas: PackedStringArray = []
var mejor_puesto: int = 0
var anio_participacion: int = 0
var sorpresa_ya_usada: bool = false
var evento_id: StringName = &""
var anio: int = 0

func to_dict() -> Dictionary: pass
static func from_dict(datos: Dictionary) -> EventState: pass
```

### 2.6 `contexto_festival.gd`

```gdscript
class_name ContextoFestival
extends RefCounted

var evento: EventDefinition = null
var participante: StringName = &""                 # jornada deja nombre
var resultado: Dictionary = {}                     # {puesto, puntos, ...}
var anio: int = 0
var es_variante_cubierta: bool = false
```

## 3. Contrato de datos (APIs consumidas de otros módulos)

| Módulo | API/señal | Uso en M74 |
|---|---|---|
| M29 | `EventBus.time.dia_cambio(dia)` | Chequeo diario de agenda |
| M29 | `EventBus.time.año_cambio(datos)` | Reprogramar agenda anual |
| M29 | `EventBus.time.estacion_cambio(est)` | Validar estación de eventos |
| M30 | `GameClock.get_minutos_dia() -> int` | Franjas horarias (hora interna) |
| M30 | `EventBus.time.evento_activado(ev)` | Badge del reloj (M30 lo escucha) |
| M32 | `EventBus.clima.clima_cambio(datos)` | Variante cubierta / traslado |
| M19 | `EventBus.day.ocupacion_evento(ocup: Array)` | Emitida por M74, consumida por M19 |
| M21 | `dialogos.abrir(id, contexto)` | Diálogos de festival con ContextoFestival |
| M14 | `inventario.agregar(id_item, cantidad)` | Entrega de objetos (fallback: buzón) |
| M20 | `amistad.modificar(id_npc, delta)` | Puntos de amistad |
| M38 | `economia.suministrar_moneda(moneda, cantidad)` | Moneda de feria |
| M37 | `museo.registrar_recuerdo(datos)` | Recuerdos/colecciones |
| M60 | `GameState.M74` | Persistencia versionada |
| M63 | cargador de escenas | Recinto bajo demanda + fallback |

## 4. Reglas de oro (se documentan y se testean)

1. **Nunca** se dispara un evento leyendo el reloj del sistema operativo; solo `GameClock` (M30 regulación anti-exploit).
2. **Nada se pierde para siempre:** todo evento anual se repite el año siguiente; el token anti-duplicado es **por año**, no único.
3. **La UI nunca decide gameplay:** banners/agenda/ventana solo llaman API y escuchan señales (M09).
4. **Sin polling por frame:** los checks corren en `dia_cambio`/`año_cambio`/`clima_cambio` (coste O(n), n≈40).
5. **Fallback de carga:** si `escena_recinto` falla (M63), se cancela con aviso amable y `recompensa_compensatoria`, jamás crash.
6. **Evento != castigo:** fallar condiciones da feedback amable y re-intentos dentro del mismo día; competencias conservan 2 días de inscripción residual después de la franja.

## 5. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| Implementar recursos y autoload `eventos` | Seguir firmas de la sección 2; registrar autoload en project.godot |
| Crear catálogo inicial de datos `.tres` | 4 festivales + 2 ferias + 3 competencias + 2 rituales + 2 climáticos + 2 sorpresas |
| UI de festival (M53) | `w_agenda`, `w_banner_evento`, `w_ventana_festival` |
| Suites de test (M112) | test_calendario/disparo/recompensas/clima/persistencia |
| Contenido de minijuegos | Contratos definidos; contenidos concretos llegan con M34/M35/M33 |
| Localización (M57) | Claves `nombre_clave`/`descripcion_clave` en tablas localizables |
| Integración rutinas NPC | Ocupación por datos (M19) sin modificar M19 |
| Sonido/ambiente festival | Referenciar recursos de M41/M42/M43 por `flags` |

## 6. Tabla de pruebas de límites (para M112)

| # | Caso | Entrada | Esperado |
|---|---|---|---|
| 1 | Aviso previo | día -3 del festival | señal `evento_proximo(dias=3)` |
| 2 | Inicio en franja | minuto = hora_inicio | `evento_iniciado` una sola vez |
| 3 | Fin de franja | minuto = hora_fin | `evento_terminado` + estado NO_PARTICIPADO si no entró |
| 4 | Año nuevo | 31.12 → 1.1 (00:00) | Festival de Invierno inicia sin solape ni doble aviso |
| 5 | Solapamiento | feria + festival mismo día | ganá festival (prioridad), feria se corre 1 día |
| 6 | Re-entrada mismo año | participar 2 veces | 2ª se bloquea por token; aviso "recompensa ya recibida" |
| 7 | Años seguidos | año 1 y año 2 | recompensa válida en ambos (repetibilidad) |
| 8 | Lluvia (M32) | clima severo en exterior | variante cubierta activa desde alta en franja |
| 9 | Tormenta a mitad | clima cambia durante evento | no interrumpe; usa cubierta en el siguiente tick, cierre normal |
| 10 | Inventario lleno | recompensa sin espacio (M14) | cae al buzón, sin pérdida, sin duplicado |
| 11 | Guardar en curso | guardar durante franja | al cargar recinto accesible, sin banners re-mostrados |
| 12 | Fallback escena | recinto roto (M63) | `evento_cancelado` + compensación, sin crash |
| 13 | Ausente | conecta el 3.1, festival fue 1.1 | historial "no participó", sin penalización, próximo año disponible |
| 14 | Sorpresas | intentar >3 por semana | límite semanal respetado, nunca en día de festival |
| 15 | Persistencia | guardar/cargar N veces | estado de eventos idéntico, sin clonación |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Documenté el módulo 74 (Eventos) completo en `plan-inicial/` y `plan-actual/` (espejo idéntico): requerimientos, análisis del dominio (festivales, ferias, competencias, rituales, climáticos, sorpresas), diseño (EventManager, EventDefinition, CondicionEvento, RecompensaDef, EventState, agenda anual, flujos, diagramas de secuencia y estados), código previsto (archivos `res://eventos/**` y `res://ui/festival/**` marcados "Pendiente de implementación", firmas GDScript 4.x de referencia, tablas de pruebas de límites) y checklist de 120+ ítems todos `[x]` con marcador [S]/[M]/[C].
- Apliqué las reglas del proyecto: todo en español, firma Deepseek V4 Flash / OpenCode en cada archivo, dependencias M29/M30/M32/M19/M21/M53/M94 documentadas, anti-FOMO (repetibilidad anual + mundo congelado offline), anti-exploit (nunca reloj SO), modularidad (UI separada por señales), sin tocar módulos estables (M74 solo consume APIs).

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé código: los archivos de `res://eventos/**` y `res://ui/festival/**` son previstos, no existen aún (todos marcados "Pendiente de implementación").
- No actualicé `CHECKLIST-GLOBAL.md` ni `DOCUMENTACION/README.md` ni ningún archivo fuera de `DOCUMENTACION/74-Eventos/` (regla estricta de la tarea); el ID de la tabla global y el README quedan para una actualización puntual posterior del orquestador.
- No definí los contenidos específicos de diálogos/minijuegos ni los guiones de los festivales (corresponden a M21/M34/M35/M33 y a diseño de contenidos posterior).

### Recomendaciones para el próximo agente
- Verificar al implementar: que `EventBus.time.dia_cambio`/`año_cambio` de M29 y `GameClock.get_minutos_dia()` de M30 exponen exactamente los nombres usados en el contrato (sección 3 de 04-Codigo); ajustar nombres si difieren (no cambiar M29/M30, solo la llamada en M74).
- Registrar el autoload `eventos` (script `res://eventos/event_manager.gd`) en `project.godot` respetando el orden de inicialización (GameClock de M29 debe existir antes).
- Implementar primero las suites de test de límites (tabla sección 6) antes de los contenidos de festivales.
- Al crear el catálogo `.tres`, completar el checklist por evento de anti-FOMO (RN10) y validar localización con M57.
- Si `CHECKLIST-GLOBAL.md` será actualizado, usar el ID 74 y completar la fila según el protocolo (sección 21 de AGENTS.md).