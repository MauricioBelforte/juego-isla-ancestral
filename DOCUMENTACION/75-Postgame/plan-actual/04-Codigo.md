**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 75: Postgame

## 1. Archivos Involucrados

| Archivo | Ruta (proyecto) | Tipo | Estado |
|---|---|---|---|
| `postgame_manager.gd` | `Assets/_Project/Scripts/Postgame/` | Servicio (autoload) | Prototipo de diseño (sin editor Godot) |
| `postgame_catalog.tres` | `Assets/_Project/Data/Postgame/` | Resource | Prototipo de diseño (sin editor Godot) |
| `validate_postgame.gd` | `Assets/_Project/Editor/` | Validación | Prototipo de diseño (sin editor Godot) |
| `postgame_catalog` (ResourceScript) | `Assets/_Project/Scripts/Data/` | Definición de datos | Prototipo de diseño (sin editor Godot) |
| `roadmap_source.gd` (interface) | `Assets/_Project/Scripts/Postgame/` | Contrato | Prototipo de diseño (sin editor Godot) |

## 2. Funciones Clave

### 2.1 `postgame_manager.gd` — Orquestador

| Función | Firma | Propósito |
|---|---|---|
| `unlock_postgame()` | `void` | Desbloquea el postgame al terminar M22; guarda `postgame_unlocked` (M59) |
| `is_postgame_unlocked()` | `bool` | Estado del postgame (fuente: save M59) |
| `get_roadmap()` | `Dictionary` | Hoja de ruta: % por categoría derivado de cada sistema |
| `get_next_goal()` | `String` | Próxima meta visible (anti-spoiler M55) |
| `get_expansion(id)` | `PostgameExpansion` | Acceso al catálogo (fase 2 interna, `hidden`) |
| `on_festival_postgame()` | `void` | Enlace M74: festival postgame rotativo |

### 2.2 `postgame_catalog.tres` — Catálogo declarativo

| Campo | Tipo | Propósito |
|---|---|---|
| `id` | `String` | Identificador unívoco de la expansión |
| `nombre` | `String` | Nombre para diseñador (i18n M92 para jugador) |
| `fase` | `int` | 1 = lanzamiento, 2 = post-lanzamiento |
| `requisito` | `String` | Condición de desbloqueo |
| `modulo` | `String` | Módulo dueño (M27, M51, M10...) |
| `hidden` | `bool` | Oculto al jugador hasta lanzamiento |

### 2.3 `roadmap_source.gd` — Contrato de hoja de ruta

```gdscript
class_name RoadmapSource
## Contrato: cada sistema expone su % de completado sin spoilers.

func total_conocido() -> int: pass
func completado() -> int: pass
func proxima_meta() -> String: pass
```

Implementado por: M73 (colecciones), M37 (museo), M25 (ruinas), M24 (puzzles), M16 (recetas), M17 (mejoras), M74 (eventos).

### 2.4 `validate_postgame.gd` — Validación (test validable)

| Método | Propósito |
|---|---|
| `validate_expansions()` | `id` únicos; `fase` ∈ {1,2}; `modulo` existe |
| `validate_achievements()` | Logros Epílogo (M72) referencian hitos reales |
| `validate_roadmap()` | Cada fuente responde el contrato |
| `validate_events()` | Fechas M29 sin colisión |

## 3. Fragmento de Núcleo (prototipo de diseño)

```gdscript
# postgame_manager.gd — núcleo del postgame (M75)
extends Node

signal postgame_unlocked

const CATALOG := preload("res://Assets/_Project/Data/Postgame/postgame_catalog.tres")

var _unlocked := false
var _roadmap_sources: Dictionary = {}

func _ready() -> void:
    _unlocked = SaveManager.get_flag("postgame_unlocked", false)   # M59

func unlock_postgame() -> void:
    if _unlocked: return
    _unlocked = true
    SaveManager.set_flag("postgame_unlocked", true)                # M59
    DayNightCycle.events.show_cutscene("epilogo")                  # M22 epílogo
    TutorialManager.show_hint("ap_despues_del_final")              # M92
    postgame_unlocked.emit()

func get_roadmap() -> Dictionary:
    var roadmap := {}
    for key in _roadmap_sources:
        var src: RoadmapSource = _roadmap_sources[key]
        roadmap[key] = {
            "total": src.total_conocido(),      # anti-spoiler (M55)
            "done": src.completado(),
        }
    return roadmap

func get_next_goal() -> String:
    for key in _roadmap_sources:
        var src: RoadmapSource = _roadmap_sources[key]
        if src.completado() < src.total_conocido():
            return src.proxima_meta()           # solo la próxima visible
    return "TR_AWA_100_COMPLETADO"
```

## 4. Logs de Ejecución (sin runtime Godot — estado honesto)

No existe editor/binary Godot en el entorno de trabajo: los `.gd` de este documento son **prototipos de diseño verificados estáticamente** (estructura y tipado por inspección). La ejecución queda pendiente para el entorno destino (sección 12 del AGENTS.md aplica al editor). Sin logs de runtime disponibles hoy.

## 5. Integración Clave (regla M15: no tocar lo que funciona)

- El M75 **NO modifica** M22, M73, M37, M55, M72, M74, M59: solo los configura (categoría "Epílogo" en M72, eventos postgame en M74) o los consulta (hoja de ruta).
- La única escritura nueva: `postgame_unlocked` en save global (M59, versión 1.4 vía M60).

## 6. Desfase Plan Maestro

- PLAN MAESTRO: sección 74 "POSTGAME" (20 ítems).
- TABLA GLOBAL: ID 75 — Postgame. Desfase = +1 (documentado por directiva del usuario).

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Completado (documentación de diseño; implementación pendiente)

### Lo que hice
- Documenté el postgame completo: catálogo de expansiones FASE 1/FASE 2, hoja de ruta del 100% anti-spoiler, logros finales (categoría Epílogo, M72), eventos rotativos postgame (M74/M29), epílogo (M22) y criterios de validación.
- La hoja de ruta es derivada (nunca almacenada): cada sistema responde `RoadmapSource` (M73/M37/M25/M24/M16/M17/M74).
- Diseñé `postgame_catalog.tres` declarativo con `fase` y `hidden`: la fase 2 (islas flotantes M10, arrecife M51, jardín acuático M16) es interna al diseñador, jamás visible al jugador (sin promesas rotas).
- Documenté reglas cozy: sin grindeo, sin fechas únicas missable, sin logros imposibles.

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Sin editor Godot ni build: los `.gd` son prototipos de diseño; la ejecución queda para el entorno destino (criterios de aceptación 6 y 8 pendientes de prueba real).
- `[?]` Logros Epílogo concretos (M72): el listado final de hitos postgame depende de la implementación de M72; aquí quedó la categoría y los hitos tipo (colección completa, ruina restaurada, primer festival).
- `[?]` Nombres/tipos de actores expandidos (vecinos M19, muebles M18, plantas M50, animales M36): el catálogo referencia los módulos; los insets concretos son de cada módulo.

### Intentos fallidos / decisiones
- Descartada la pestaña postgame propia (nueva UI duplicada): la hoja de ruta vive en el diario (M55) y el museo (M37). Registrado en 02-Analisis.md (alternativas A1/A2).
- Descartado el estado "postgame" dentro de M72 (acoplamiento historia-logros): los hitos van en la categoría "Epílogo".

### Recomendaciones para el próximo agente
- Implementar `RoadmapSource` como contrato primero y los adaptadores de M73/M37/M25/M24/M16/M17/M74 después (cero sorpresas).
- Al implementar M72, crear la categoría "Epílogo" y respetar el criterio "sin logros de grindeo".
- Los eventos postgame (M74) deben programarse en el calendario (M29) con ciclo anual, sin fechas únicas.
- Al lanzar una expansión FASE 2, cambiar `hidden=false` y agregar su data real en el módulo dueño (M27/M51/M10...).
## Notas del agente — iter. 3 (DeepSeek-V4.1-Flash, 2026-10-26, Log 2200)

Tanda sobre los 4 `[ ]` que quedaban del 05-Checklist (K "material raro", Q
"FASE 2 sin UI", S "logro ruina", W "UI sin spoilers de fase 2").

### Defecto real encontrado (no era solo validacion)
`data/postgame/actividades.json` NO tenia `fase` ni `hidden`, y
`PostgameManager.actividades_disponibles()` + `sugerir_que_sigue()` devolvian
TODO el catalogo. Resultado: "La Isla Flotante" (FASE 2) se le ofrecia al
jugador como "que sigue" antes de que exista su arquitectura de streaming,
contra 03-Diseno 2.2 ("FASE 2: nunca visible al jugador; solo catalogo interno")
y Flujo D. Las aserciones que exigian 7 actividades VISIBLES consagraban el bug.

### Cambios
- `data/postgame/actividades.json`: schema_version 2 + `fase` y `hidden` por
  entrada (FASE 2 = `postgame_isla_flotante`, hidden=true).
- `postgame_manager.gd`: `es_visible_al_jugador()`, `actividades_disponibles()`
  filtrada, `actividades_internas()` (validador/disenador), `total_actividades()`,
  orden estable por id, `hito_ruina_restaurada()` (hito para M72). `sugerir_que_sigue()`
  filtra FASE 2.
- `validate_postgame.gd` NUEVO (03-Diseno 3.3 lo pedia y no existia): reglas
  `ids_unicos`, `fase_valida`, `fase2_oculta`, `dueno_declarado`, `dueno_existe`
  (contra CHECKLIST-GLOBAL), `sin_grindeo`, `logro_hito_real`. Reglas sin datos
  se declaran OMITIDAS, no se dan por buenas.
- `test_postgame.gd`: bloques nuevos `_test_fase2_invisible`, `_test_validador`
  (con 6 sondas rojas EN MEMORIA) y `_test_hito_ruina`; piso 40 -> 71 MEDIDO.
  Ademas el `_fin()` de cada bloque se movio al FINAL DEL CUERPO del bloque
  (estaba en el runner: un SCRIPT ERROR dentro del helper habria marcado el
  bloque como "visto" y la capa de nombres quedaba ciega).

### Evidencia medida
- `test_postgame.gd`: **71 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR.
- Guardian EN ROJO 2 modos: aborto de runtime -> 61 checks, 2 fallos, EXIT 1,
  NOMBRA `_test_fase2_invisible` y dispara el piso; asercion falsa -> 71/1, EXIT 1.
  Sonda borrada; sha256 del original identico (a70aeb6d4094ed80...).
- Regresiones: `test_logros` EXIT 0 (su SCRIPT ERROR en L294 es PREEXISTENTE y
  ajeno: `_desbloqueados` asignado como Array), `qa_m59_payload_sections` EXIT 0,
  `test_diario` EXIT 0.

### Lo que NO esta resuelto (dueño)
- El LOGRO "ruina restaurada" (entrada + desbloqueo) es de **M72**: su catalogo
  tiene 17 logros y `CATEGORIAS_VALIDAS` no incluye `epilogo`, asi que el item
  S del checklist NO se puede cerrar desde M75. M75 deja el hito.
- `validate_postgame.gd` NO esta cableado a `quality.yml` (limite duro: no lo
  edito). Hoy corre dentro de `test_postgame.gd`.
- El catalogo sigue siendo JSON y no `postgame_catalog.tres` como dice 3.1
  (preexistente; el item U lo da por `[x]` como "Resource embebido").

### Iter. 4 (2026-10-26) — cadena hito (M71) -> logro (M72), item S de RF19

Cierra el pendiente de la iter. 3: el LOGRO "ruina restaurada" ya existe y se
desbloquea solo, sin que M75 escriba en el catalogo de M72.

| Pieza | Dueño | Estado medido |
|---|---|---|
| `postgame_ruina_final` (actividad real) | M75 | 7 actividades, 1 con hito asociado |
| `hito_ruina_restaurada` (`primera_vez`) | M71 `data/progresion/hitos.json` | 26 hitos (antes 25) |
| `logro_ruina_restaurada` (`hito_previo`) | M72 `data/logros/logros.json` | 18 logros (antes 17) |
| categoria `epilogo` | M72 `CATEGORIAS_VALIDAS` | RF14: 0 problemas |

Cadena (event-driven, cero polling, cero duplicacion de estado):

```
M75 registrar_actividad("postgame_ruina_final")
  -> _marcar_hito_derivado(): perfil M71 marcar_primera_vez + reevaluar_sucias()
  -> M71 evalua la condicion del hito -> marcar_hito() -> senal progreso_hito_alcanzado
  -> M72 (conectado desde _conectar_eventos) evaluar_todos()
  -> condicion hito_previo -> desbloquear("logro_ruina_restaurada")
```

M75 NO llama a M72: la unica dependencia nueva es `HITOS_POR_ACTIVIDAD` (tabla
declarativa actividad -> hito) y el guard `has_method`, asi que si M71 no esta
cargado el registro de la actividad sigue funcionando igual.

### Evidencia medida (iter. 4)
- `test_postgame.gd`: **86 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR.
  Piso `CHECKS_MINIMOS` re-medido: 71 -> **86** (15 checks nuevos del bloque
  `_test_logro_ruina_m72`).
- Guardian EN ROJO 3 sondas (restauracion byte-exacta sha256 `80c888ebc80e`):
  (A) quitar `epilogo` del vocabulario -> 86/1 EXIT 1 + RF14 nombra la categoria
  desconocida; (B) quitar `_marcar_hito_derivado` -> 86/3 EXIT 1 (hito, logro e
  idempotencia); (C) aborto de runtime al inicio del bloque -> 71 checks, 2 fallos,
  EXIT 1, NOMBRA `_test_logro_ruina_m72` y dispara el piso.
- Regresiones: `test_logros_rf1_e` 39/0 EXIT 0 (se actualizaron 2 asserts de
  conteo 17->18: son conteos, no comportamiento), `test_logros_m72_statids` 9/0,
  `test_logros_depende_de_m72` EXIT 0, `test_m72_rf6_m72` EXIT 0,
  `test_progresion` (M71) 83/0 EXIT 0.

### Hallazgos de la iter. 4 (no corregidos)
- `test_logros.gd` (M72) sigue MUERTO: `SCRIPT ERROR: Invalid assignment of
  property or key '_desbloqueados' with value of type 'Array'` aborta la corrida
  y publica `0 fallo(s)` con EXIT 0. Preexistente (ya reportado en iter. 3); sus 3
  asserts de conteo se actualizaron igual para que no mientan si alguien lo revive.
- `test_logros_rf10_m72.gd` tiene un check muerto por id inexistente:
  `get_definicion("primer_sello")` devuelve `{}` (el id real es
  `logro_primer_sello`) y `d.id` sobre `{}` lanza SCRIPT ERROR. Preexistente; el
  test sale EXIT 0 igual.
- Los 18 `icono` del catalogo de M72 apuntan a `res://assets/ui/logros/*.png` y el
  directorio `assets/ui/` NO existe (0 de 18 archivos). RF14 solo exige el campo
  no vacio, asi que el catalogo valida con los iconos muertos.
- Las claves `LOGROS.*.NOMBRE/DESC` no estan en ningun `.po` (tampoco las 17
  anteriores): deuda de i18n de M72, no de esta tanda.
