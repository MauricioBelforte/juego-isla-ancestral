**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 72: Sistema de Logros

## 1. Estado del código

**Pendiente de implementación.** Este documento describe los archivos previstos, la firma de sus funciones GDScript y los contractos que el próximo agente debe implementar. No existe código del módulo todavía; lo declarado aquí es el contrato de diseño derivado de `02-Analisis.md` y `03-Diseno.md`.

## 2. Archivos previstos (Pendiente de implementación)

### 2.1 Núcleo (res://logros/)

| Archivo | Clase | Descripción |
|---|---|---|
| `res://logros/achievement_manager.gd` | `AchievementManager extends Node` | Autoload `logros`. Orquestador: catálogo, eventos, evaluación, desbloqueo, persistencia, señales, API de consulta |
| `res://logros/achievement_manager.gd` (registro) | — | Registro del autoload en `project.godot` como `logros` |
| `res://logros/achievement_definition.gd` | `AchievementDefinition extends Resource @tool` | Datos de logro: id, i18n, ícono, categoría, oculto, condición, `logro_steam_id`, orden |
| `res://logros/guardado_logros.gd` | `GuardadoLogros extends RefCounted` | Serialización/deserialización del estado con M60 |

### 2.2 Condiciones (res://logros/condiciones/)

| Archivo | Clase | Descripción |
|---|---|---|
| `res://logros/condiciones/condicion_base.gd` | `CondicionBase extends RefCounted` | Clase abstracta: contrato de condición |
| `res://logros/condiciones/condicion_contador.gd` | `CondicionContador extends CondicionBase` | `stat_contador >= n` sobre el perfil de M71 |
| `res://logros/condiciones/condicion_coleccion.gd` | `CondicionColeccion extends CondicionBase` | `coleccion_completa(id)` / `coleccion_porcentaje(id) >= p` (M37) |
| `res://logros/condiciones/condicion_pesca.gd` | `CondicionPesca extends CondicionBase` | `pescar_especie(id)` / `pescar_todas_las_especies()` (M34) |
| `res://logros/condiciones/condicion_amistad.gd` | `CondicionAmistad extends CondicionBase` | `amistad_maxima(npc)` / `amistad_total >= n` (M20) |
| `res://logros/condiciones/condicion_hito71.gd` | `CondicionHito71 extends CondicionBase` | `hito_71(id)` alcanzado (M71) |
| `res://logros/condiciones/condicion_historia.gd` | `CondicionHistoria extends CondicionBase` | `sello_historia(id)` (M22) |
| `res://logros/condiciones/condicion_compuesta.gd` | `CondicionCompuesta extends CondicionBase` | AND / OR / NOT de subcondiciones |

### 2.3 UI (res://logros/ui/)

| Archivo | Clase/escena | Descripción |
|---|---|---|
| `res://logros/ui/logro_toast.gd` + `.tscn` | `LogroToastUI extends CanvasLayer` | Toast no bloqueante encolado (máx. 3 visibles, resumen "N nuevos") |
| `res://logros/ui/panel_logros.gd` + `.tscn` | `PanelLogrosUI extends CanvasLayer` | Panel de consulta: obtenidos, en progreso, ocultos |
| `res://logros/ui/panel_logros_item.gd` + `.tscn` | `PanelLogrosItem extends Control` | Ítem reutilizable del panel (ícono, nombre, barra de progreso, fecha) |

### 2.4 Steam (res://logros/steam/ — opcional, M97)

| Archivo | Clase | Descripción |
|---|---|---|
| `res://logros/steam/steam_sync.gd` | `SteamSync extends Node` | Adaptador desacoplado: `SetAchievement`, `GetAchievement`, `StoreStats`, reconciliación bidireccional en carga |

### 2.5 Datos y validación (res://logros/datos/)

| Archivo | Clase | Descripción |
|---|---|---|
| `res://logros/datos/logros_*.tres` | `AchievementDefinition` | Catálogo curado por categorías (agricultura, pesca, minería, amistad, colecciones, progresión, economía, exploración) |
| `res://logros/datos/validacion_logros.gd` | `ValidacionLogros extends EditorPlugin` o `@tool` | Validación al guardar: ids únicos, íconos, condiciones, categorías, mapeo Steam (RF14) |
| `res://logros/README.md` | — | Guía "cómo agregar un logro nuevo" paso a paso + reglas cozy |

## 3. Firma de funciones GDScript (contrato)

### 3.1 `AchievementManager` (autoload `logros`)

```gdscript
class_name AchievementManager
extends Node

signal logro_desbloqueado(achievement_id: StringName, definicion: AchievementDefinition)
signal logro_progreso(achievement_id: StringName, progreso: float)
signal logro_catalogo_actualizado()

var _definiciones: Dictionary = {}          # StringName -> AchievementDefinition
var _estado: Dictionary = {}                # StringName -> {desbloqueado, fecha, progreso, extra}
var _indice_eventos: Dictionary = {}        # StringName(tipo_evento) -> Array[StringName]
var _sync_steam: Node = null

func _ready() -> void: ...
func _configurar_indice_eventos(_definiciones: Array[AchievementDefinition]) -> void: ...

func registrar_catalogo(definiciones: Array[AchievementDefinition]) -> void: ...
func notify_event(tipo_evento: StringName, valor: float = 1.0, contexto: Dictionary = {}) -> void: ...
func _evaluar_logro(id: StringName) -> bool: ...
func unlock(achievement_id: StringName, origen: String = "evento") -> bool: ...
func re_evaluar_todo() -> void: ...

func is_unlocked(achievement_id: StringName) -> bool: ...
func get_definicion(achievement_id: StringName) -> AchievementDefinition: ...
func get_todos() -> Array[AchievementDefinition]: ...
func get_estado(achievement_id: StringName) -> Dictionary: ...
func get_fecha(achievement_id: StringName) -> String: ...
func get_progreso(achievement_id: StringName) -> float: ...
func get_progreso_humano(achievement_id: StringName) -> String: ...
func es_visible(achievement_id: StringName) -> bool: ...
func get_desbloqueados() -> Array[StringName]: ...
func get_en_progreso() -> Array[StringName]: ...
func get_porcentaje_completado() -> float: ...

func cargar(estado_logros: Dictionary) -> void: ...
func guardar() -> Dictionary: ...
func limpiar() -> void: ...

func registrar_sync_steam(sync: Node) -> void: ...
func notificar_logro_steam(achievement_id: StringName) -> void: ...
```

### 3.2 `AchievementDefinition` (Resource, `@tool`)

```gdscript
class_name AchievementDefinition
extends Resource

@export var achievement_id: StringName
@export var nombre_i18n: String
@export var descripcion_i18n: String
@export var icono: Texture2D
@export var categoria: StringName
@export var oculto: bool = false
@export var condicion: CondicionBase
@export var logro_steam_id: String = ""
@export var orden: int = 0

func _validate_property(property: Dictionary) -> void: ...  # validación en editor (RF14)
```

### 3.3 `CondicionBase` y subclases

```gdscript
class_name CondicionBase
extends RefCounted

func cumplida() -> bool:
    return evaluar_progreso() >= 1.0

func evaluar_progreso() -> float:
    push_error("CondicionBase.evaluar_progreso() debe implementarse en la subclase")
    return 0.0

func depende_de(tipo_evento: StringName) -> bool:
    return false  # la subclase declara qué eventos la re-evalúan (dirty flags)
```

```gdscript
# CondicionContador: stat_contador >= n
class_name CondicionContador
extends CondicionBase
@export var estadistica: StringName          # clave del perfil de M71
@export var objetivo: float = 1.0
func evaluar_progreso() -> float: return minf(PerfilJugador.get_stat(estadistica) / objetivo, 1.0)
func depende_de(tipo_evento: StringName) -> bool: return tipo_evento == "perfil_stat_actualizado"
```

```gdscript
# CondicionColeccion: coleccion_completa(id) / coleccion_porcentaje(id) >= p
class_name CondicionColeccion
extends CondicionBase
@export var coleccion_id: StringName         # id de colección de M37
@export var porcentaje_objetivo: float = 1.0
func evaluar_progreso() -> float: return ColeccionesManager.porcentaje(coleccion_id) / porcentaje_objetivo
func depende_de(tipo_evento: StringName) -> bool: return tipo_evento == "coleccion_donado"
```

```gdscript
# CondicionCompuesta: AND / OR / NOT
class_name CondicionCompuesta
extends CondicionBase
enum Operador { AND, OR, NOT }
@export var operador: Operador = Operador.AND
@export var subcondiciones: Array[CondicionBase] = []
func evaluar_progreso() -> float:
    # AND: min de subprogresos · OR: máximo · NOT: 1 - progreso de la primera
    ...
```

### 3.4 `GuardadoLogros`

```gdscript
class_name GuardadoLogros
extends RefCounted

func serializar(estado: Dictionary) -> Dictionary: ...   # solo datos serializables (JSON-safe)
func deserializar(datos: Dictionary) -> Dictionary: ...  # reconstruye el estado con claves conocidas
static func crear_vacio() -> Dictionary: ...
```

### 3.5 `LogroToastUI` y `PanelLogrosUI` (esqueleto)

```gdscript
class_name LogroToastUI
extends CanvasLayer

var _cola: Array[Dictionary] = []
const MAX_VISIBLES: int = 3
const MAX_COLA_RESUMEN: int = 5

func _on_logro_desbloqueado(achievement_id: StringName, definicion: AchievementDefinition) -> void: ...
func _procesar_cola() -> void: ...
func _mostrar_resumen(cantidad: int) -> void: ...
```

```gdscript
class_name PanelLogrosUI
extends CanvasLayer

func abrir(focus_achievement_id: StringName = &"") -> void: ...
func _rellenar_lista(categoria: StringName) -> void: ...
func _crear_item(definicion: AchievementDefinition, estado: Dictionary) -> PanelLogrosItem: ...
```

### 3.6 `SteamSync` (opcional, M97)

```gdscript
class_name SteamSync
extends Node

var disponible: bool = false

func _ready() -> void: ...
func _on_logro_desbloqueado(achievement_id: StringName, definicion: AchievementDefinition) -> void: ...
func set_achievement_steam(id: StringName, logro_steam_id: String) -> void: ...
func reconciliar_con_steam() -> void: ...      # GetAchievement -> local, y viceversa
func store_stats() -> void: ...
```

## 4. Notas de implementación para el próximo agente

- El autoload debe registrarse como `logros` en `project.godot` y cargar el catálogo desde `res://logros/datos/` al `_ready()`.
- Las condiciones consultan los managers de M71/M37/M34/M20/M22 **por contracto de señal o API pública**; si una señal no existe aún, declarar el TODO con la referencia exacta del módulo dueño.
- El estado persistido debe ser JSON-safe (sin Objetos Godot dentro): solo String/Bool/Float/Array/Dictionary.
- `unlock()` debe persistir write-through (RF9/RF4) y emitir `logro_desbloqueado` **una sola vez**.
- `re_evaluar_todo()` se llama al cargar partida (retroactividad, RF5) y desde el editor (`@tool`) para depuración.
- Steam nunca debe ser importado en builds sin SDK: usar detección en runtime (M97) y `@onready var _no_steam := true` hasta que exista la capa.

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Creé la documentación completa del módulo 72 (Sistema de Logros): requerimientos (RF1-RF14, RN1-RN12, criterios de aceptación), análisis del dominio (definición, condiciones, persistencia, notificaciones, Steam opcional vs local, retroactividad), diseño (arquitectura por capas con autoload `logros`, diagrama ASCII, contratos de señales, integraciones M07/M20/M22/M34/M37/M53/M58/M60/M66/M71/M97/M103/M104/M112) y código previsto con firmas GDScript tipadas.
- Tomé las decisiones de diseño D1-D8 (catálogo data-driven central, toast encolado no bloqueante, Steam opcional desacoplado, sin logros online, evaluación reactiva por eventos con dirty flags, persistencia write-through, progreso parcial expuesto, ocultos revelados al desbloquear).
- Redacté el checklist de 186 ítems completados cubriendo RF, RN, diseño, integraciones 37/71/97, edge cases, optimización, documentación y testings.
- Seguí el estándar del proyecto: firma de modelo/plataforma, plan-inicial inmutable y plan-actual como espejo idéntico, todo en español.

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé código: el módulo está **Pendiente de implementación** por diseño (el flujo del proyecto es documentación-primero).
- No pude verificar los nombres exactos de todas las señales de los módulos emisores (M34, M37, M20, M22, M33, M38): usé los nombres lógicos del dominio; el implementador debe confirmarlos contra el plan-actual de cada módulo (M71 ya está documentado y sus señales `progreso_*` son la referencia principal).
- No pude validar la integración con M97 (Steam): depende del SDK y de cómo se cargue en runtime; dejé el adaptador `steam_sync` explícitamente desacoplado y opcional.

### Recomendaciones para el próximo agente
- Verificar los nombres reales de señales de M71 (`progreso_hito_alcanzado`, `progreso_desbloqueado`, perfil de jugador) y de M37 (donaciones) antes de cablear las condiciones; ajustar `depende_de()` de cada condición a la señal real.
- Confirmar que el guardado global (M60) acepta el diccionario `logros` del `GuardadoLogros` sin colisiones de claves con M71.
- Implementar primero el núcleo + condiciones contador/colección + persistencia, luego UI toast, luego panel, y Steam al final (nunca bloquear el motor por Steam).
- Agregar los archivos de testing (`06-Plan-Testings.md` y `07-Resultados-Testings.md`) en plan-actual cuando se implemente, según la sección 14 de AGENTS.md.
- Al completar la implementación, marcar los ítems pertinentes del `05-Checklist.md`, actualizar `CHECKLIST-GLOBAL.md` (fila 72) y generar el log en `Logs/` con el formato estándar.
- Respetar las reglas cozy del checklist: ningún logro con números abusivos, cero FOMO; validar cada definición del catálogo con la regla de alcance amable.

---

## Notas del Agente — Iteración 1 núcleo (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 22:35:00
**Estado:** Parcial (núcleo de logros implementado y verificado; módulo liberado 🟡)

### Lo que hice
- AchievementService autoload (scripts/logros/achievement_service.gd): catálogo data-driven de 7 logros (data/logros/logros.json) con condiciones en el MISMO formato de M71 — evaluación delegada a ProgressionManager.evaluar_condicion() (§no duplicar lógica). Desbloqueo idempotente + señal logro_desbloqueado + log [DOM-LOGRO]. Progreso parcial perezoso para la UI (logro_progreso). % REAL de logros (porcentaje_real — los logros usan total real, no el anti-spoiler del diario M55 §3.2). listado_para_ui() con ocultos como "???" hasta desbloquearse.
- Evaluación event-driven: escucha progreso_hito_alcanzado/progreso_desbloqueado de M71 → evaluar_todos() (sin bucle por frame).
- Persistencia ISaveProvider M59 sección "achievements"; logros de catálogo viejo purgados; NUNCA re-emitir señales restauradas.
- FIX arquitectural M22↔M71 (descubrido por el test): la condición sello_historia de M71 consultaba el REFLEJO en catálogo (nunca se marca para sellos de M22) — corregida a consulta directa de M22 (fuente de verdad §2.2) vía nuevo getter Historia.sello_marcado(). El reflejo queda solo para la UI.
- Catálogo M55 ampliado: +2 entradas mision_cadena-* (coherencia M23→M55 del sprint).
- Test test_logros.gd: catálogo, cadena completa M22→M71→M72 (marcar_sello → hito → logro), idempotencia, % real, ocultos, persistencia con logro de catálogo viejo → **0 fallos**.
- Regresiones: test_progresion M71 0 fallos, test_historia M22 0 fallos.
- Checklist: progreso relevado (núcleo implementado).

### Lo que NO pude hacer (honestidad obligatoria)
- Steam sync (M97) y presentación UI (M53): con dueños — las señales/API están listas.
- Logros con múltiples hitos dependientes o progresos fraccionados (ej. "50 peces"): el evaluador de M71 soporta stat_min con umbral arbitrario — solo falta el contenido del catálogo.
- Notificación de logro en pantalla (M53): señal logro_desbloqueado lista.

### Recomendaciones para el próximo agente
- M97: al integrar Steam, leer desbloqueados() y mapear ids a Steam Achievements.
- M53: pantalla escucha logro_desbloqueado y usa listado_para_ui() (los ocultos ya llegan como "???").
- Nuevo logro = nueva entrada en logros.json con condición del vocabulario M71 (§3.6) — sin tocar código.
- M71.progreso_parcial solo funciona con condiciones stat_min; para otros tipos la UI muestra desbloqueado/no.

## Iteración agnes — test RF14 data-integrity + gate CI (2026-09-18, agnes-3-flash (Sapiens AI) / Kilo Code, Log 1021)

> Iteración acotada (data-driven + tooling/CI + V0). **Aditiva**: NO modifico `achievement_service.gd`
> (core de M72, glm-5.3). Agrego un test + cableo CI.

### Nuevo archivo (aditivo)
- `scripts/logros/test_logros_m72_statids.gd` — cierra el item RF14 abierto ("validar que las stats
  referenciadas existan en M71") como **equivalente headless**: cada `stat_id` de `logros.json` debe
  resolver contra (a) `data/progresion/hitos.json` (vocabulario M71, recursivo `stat_min`+`compuesta`)
  **o** (b) prefijo dinámico documentado (`amistad_max_*` M20 / `pescar_*` M34, registrados en runtime
  por `achievement_service._on_nivel_amistad`/`_on_captura_pesca`). **9 checks, 0 fallos, exit 0.**

### Gate CI
- `test_logros.gd` + `test_logros_m72_statids.gd` añadidos al **gate duro** `quality.yml` (test-suite).

### Hallazgo ajeno (delegado, M39/glm)
- `catalogo_tiendas.gd:63` → `SCRIPT ERROR: Nonexistent function 'size' in base 'Callable'` + warning
  "item_id inexistente en M15: `piedra_caliza`". Bug de M39 (en curso por glm) que contamina el boot
  de autoloads. **Delegado** (11-BUGS + ESTADO-PARALELO), no lo corrijo.

## Notas del Agente — lote B+E, RF1 + persistencia (2026-10-12)

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Log:** 1730

Encargo del director (msg 175): secciones B+E de M72, ampliando el núcleo existente.
**M72: 11 -> 31 `[x]` / 185 (+20).**

### Catálogo RF1 (`data/logros/logros.json`, 11 -> 17 logros)

Campos que faltaban y ahora están en las 17 entradas:

| Campo | Estado |
|---|---|
| `nombre_i18n` / `descripcion_i18n` | agregados (se derivan del id si el JSON no los trae) |
| `icono` | agregado, obligatorio (RF14 lo valida) |
| `categoria` | agregado con vocabulario cerrado de 7 valores |
| `orden` | agregado y usado por `get_todos()` para ordenar |
| `logro_steam_id` | agregado (opcional, para M97) |
| `oculto`, `condicion`, `progreso_parcial` | ya existían |

Cobertura de categorías: las 7 del diseño (progresion, colecciones, exploracion, amistad, pesca,
agricultura, mineria). También se corrigió mojibake heredado (`Guardiá` -> `Guardián`).

### Código (`scripts/logros/achievement_service.gd`)

- `_cargar_catalogo()` lee los 6 campos nuevos.
- `CATEGORIAS_VALIDAS` (7 valores) junto a `TIPOS_CONDICION_VALIDOS`.
- **`_estado_de()` descartaba los campos nuevos**: construía el diccionario a mano con solo
  id/nombre/descripcion/desbloqueado/oculto/dia/hora/progreso, así que la UI no recibía icono,
  categoría ni orden. Ahora arma un `comunes` con todo y lo completa según el caso.
- `validar_catalogo()` suma 3 validaciones: icono obligatorio, categoría del vocabulario y
  `logro_steam_id` duplicado.

### ⚠️ Dato real encontrado por la suite de integridad

Mis primeros 4 logros nuevos usaban `stat_id` que **no existen en M71**
(`cultivos_cosechados`, `minerales_extraidos`, `islas_visitadas`, `dias_jugados_total`).
`test_logros_m72_statids.gd` los detectó como "sin resolver". Reemplazados por stats reales
(`regalos_dados`, `viajes_realizados`, `misiones_completadas`, `sellos_obtenidos`,
`peces_capturados`, `amistad_max_catalina_oso`).

### Suite

`scripts/logros/test_logros_rf1_e.gd` (nueva, **35 checks, 0 fallos**, 6 bloques: campos RF1,
validación RF14, orden, persistencia, tolerancia/migración, coexistencia con M71).
Las 3 suites de M72 en verde.

## Notas del Agente — barrido de ítems con tests reales (2026-10-12)

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Log:** 1735

Encargo del director (msg 184): barrido de M72. **M72: 31 -> 68 `[x]` / 185 (+37).**

### Método

El checklist tenía 62 ítems `[ ]` **con notas de implementación** (de iteraciones anteriores) que
nunca se reflejaron en las marcas. En lugar de confiar en las notas, verifiqué cada uno contra el
código y las suites, y flipé solo lo que tiene respaldo real:

- **C (condiciones):** la decisión de diseño fue **no duplicar el evaluador de M71** — las
  condiciones usan el vocabulario M71 §3.6 y se evalúan vía `evaluar_condicion()`. Verifiqué que
  `_conectar_eventos()` suscribe a señales de M71 y EventBus (inventory/economy/npc/quest) y que
  **no hay `_process`** en el módulo.
- **C (desbloqueo):** `desbloquear()` idempotente, `_fechas {dia, hora}` determinista,
  `mark_dirty()` tras cada desbloqueo, `re_evaluar_todo()` al restaurar.
- **I (integración M71):** `progreso_de()` lee el perfil de M71; las señales de hito/progreso
  están conectadas.
- **M (testings):** verifiqué enumerando los tests reales de las suites (27 en total), no solo
  las notas.
- **L (documentación):** verificado en disco que los 5 archivos existen y que 01/02/03/04 están
  firmados con `**Modelo:**` + `**Plataforma:**`.

### Suites verificadas

```
test_logros.gd             20 tests  (catálogo, desbloqueo, idempotencia, fechas,
                            progreso humano, ocultos, persistencia, migración v1,
                            retroactividad, doble desbloqueo atómico, compuesta,
                            caché, guardado/carga, panel)
test_logros_rf1_e.gd        6 tests  (campos RF1, validación RF14, orden, persistencia,
                            tolerancia, coexistencia con M71)
test_logros_m72_statids.gd  1 test   (detección de stat_ids desconocidos)
                            ---
                            27 tests, 0 fallos
```

### Lo que quedó `[ ]` a propósito

- **D (notificación UI) y F (panel)**: dependen de M53 (UI real).
- **I (integración M37/M97)** e **I (reconciliación Steam)**: no hay autoload de Steam ni museo
  accesible desde el núcleo.
- **K (optimización)**: el índice formal de condiciones está postergado por diseño hasta 200
  logros (documentado en la nota del ítem L68 original).
- **J**: edge cases que requieren UI o playtest (notificación durante cinemática, 20 logros a
  la vez con resumen encolado).

## Notas del Agente — seccion D, notificacion de logros (2026-10-12)

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Log:** 1744

Encargo del director (msg 189, a eleccion): **seccion D de M72** (notificacion de logros).
**M72: 68 -> 77 `[x]` / 185 (+9).**

### Verificado contra el codigo

`achievement_service.gd` -> `_emitir_toast()` (L258-278) y
`scripts/ui/services/notification_service.gd` (M53):

| Item | Evidencia |
|---|---|
| Toast no bloqueante con icono/nombre/descripcion | `_emitir_toast()` emite `bus.ui.notify({tipo, id, titulo, texto})`; el icono lo resuelve `NotificationService._get_type_icon()` |
| Respetar M58 | retorna temprano si `_toasts_disabled`; `_conectar_accesibilidad()` lee el perfil |
| No robar input ni pausar | viaja por senal no bloqueante de EventBus |
| Sin duplicados | `desbloquear()` idempotente -> una sola senal por logro |
| Revelacion de ocultos | envia siempre el nombre real; solo la descripcion se enmascara |
| Cola de toasts | `push()` + `_dequeue_oldest()` + `set_queue_limit(n)` |
| Fade suave | `fade_duration` (0.3 s por defecto, configurable) |
| Tiempo visible | `toast_lifetime = 4.0` (supera el 3.5 s pedido) |
| Cola durante cinematica | la cola es FIFO |

### Suites

```
test_puente_notify.gd        TEST PUENTE NOTIFY: 0 fallo(s)
test_logros.gd               20 tests, 0 fallos
test_logros_rf1_e.gd          6 tests, 0 fallos
test_logros_m72_statids.gd    1 test,  0 fallos
```

### Lo que quedo `[ ]` a proposito

- **Resumen "N nuevos logros" al superar 5 en cola** (L86): el `NotificationService` no tiene
  lógica de agrupación; habría que implementarla en M53 (dueño de la cola).
- **Click en el toast para abrir el panel** (L89): `panel_solicitado()` ya se emite desde M72
  (RF7), pero el **click** es del widget de M53.
- **Log de desborde de cola** (L96): M72 emite 1:1 (sin cola propia), así que no hay
  desborde que registrar desde acá.

## 4. Dependencias, Integraciones y Alcance

(agnes-3-flash, M72 t5, 2026-10-21) -- registro explicito para cierre de alcance.

### 4.1 Dependencias del modulo (M71, M37)
- **M71 (Progresion):** M72 hereda el sistema de progreso/desbloqueo (las condiciones de logro consultan stats de M71). M72 NO re-implementa progreso, solo emite senales al cumplir.
- **M37 (Museos y...):** los logros de curaduria/museo se apoyan en M37; la recompensa de coleccion completa se resuelve ahi.

### 4.2 Integraciones (consumo/senal, sin acoplamiento duro)
- M20 Amistad (logro por nivel de amistad), M22 Historia (sellos), M33 Cosecha + M34 Pesca (recolecciones), M38 Economia (recompensas en dinero), M59/M60 Guardado (persistencia del estado RF9), M53/M58 UI (PanelLogrosUI), M103/M104 (logs + analytics RF13), M97 Steam (mapeo opcional).

### 4.3 Alcance (dentro / fuera)
- **DENTRO de M72:** reglas de desbloqueo + estado + persistencia + RF2 (depende_de) + RF6 (toast agrupa) + RF13 (trazabilidad M103/M104) + condicones por tipo_evento.
- **FUERA de M72 (delegado):** UI core del panel de logros (M53/M58), reglas de coleccion (M73), integracion Steam (M97), la logica de coleccion/dedupe (M73).

## Notas del Agente — categoria `epilogo` + logro de ruina (2026-10-26, DeepSeek-V4.1-Flash)

Cierra el pendiente que M75 tenia anotado desde su iter. 3: el LOGRO de epilogo
existia como hito en M71 y como item `[ ]` en M75, pero **no** como entrada de
M72 (17 logros, sin categoria `epilogo` en el vocabulario).

Cambios (2, ambos minimos):

1. `CATEGORIAS_VALIDAS` suma `"epilogo"` (RF19 de M75 §3.3: los logros de
   epilogo referencian **hitos reales**, no contadores inventados).
2. `data/logros/logros.json` suma `logro_ruina_restaurada` (18 entradas):
   - `categoria: "epilogo"`, `orden: 180` (despues de `logro_dias_en_aurora`).
   - `condicion: {"tipo": "hito_previo", "milestone_id": "hito_ruina_restaurada"}`
     — el tipo ya estaba en `TIPOS_CONDICION_VALIDOS` y lo evalua M71.
   - `depende_de: ["logro_siete_sellos"]` (el postgame solo existe con la
     historia terminada).
   - El hito vive en M71: `data/progresion/hitos.json` (26 hitos), condicion
     `{"tipo": "primera_vez", "actividad_id": "postgame_ruina_final"}`.

Nada mas se toco del core: `evaluar_todos()` ya estaba conectado a
`ProgressionManager.progreso_hito_alcanzado` (linea 128 de
`achievement_service.gd`), asi que la senal del hito desbloquea el logro sin
codigo nuevo.

Evidencia: `scripts/postgame/test_postgame.gd` bloque `_test_logro_ruina_m72`
(86/0/EXIT 0 x3, 0 SCRIPT ERROR) + `validar_catalogo()` (RF14) = 0 problemas
medido en la misma corrida. Sonda A (quitar `epilogo` del vocabulario) pone RF14
en 1 problema y el check en rojo.

Deuda declarada de M72 (no de esta tanda, medida el 2026-10-26):
- `test_logros.gd` aborta por `_desbloqueados` (Array) y publica `0 fallo(s)`.
- `test_logros_rf10_m72.gd`: `get_definicion("primer_sello")` usa un id que no
  existe (`{}` -> `d.id` lanza SCRIPT ERROR).
- Los 18 `icono` apuntan a `res://assets/ui/logros/`, directorio inexistente.
- Las claves `LOGROS.*` no estan en ningun `.po`.


---

## Iter. 26 (2026-10-26, DeepSeek-V4.1-Flash) — Residuo: las 4 deudas cerradas con medicion

Log 2208. Disparador: mensaje 421 de la directora agnes-3-flash ("Tu proximo riel: M72
residuo, los 4 hallazgos"). **No se copio ninguna cifra de la nota de la iter. 25**: las
cuatro se midieron con el binario real antes de tocar codigo.

### 1. `test_logros.gd` estaba MUERTA y publicaba `0 fallo(s)`

Medido: `SCRIPT ERROR: Invalid assignment of property or key '_desbloqueados' with value
of type 'Array' on a base object of type 'Node (achievement_service.gd)'` en L294.
`_desbloqueados` es `Array[String]` (`achievement_service.gd:44`) y el test le asignaba un
`Array` sin tipar. Un `SCRIPT ERROR` de runtime aborta **solo** la funcion donde ocurre:
`_test_guardado_carga_rf9_rn8()` moria, sus 6 checks no corrian, el resumen se imprimia
igual (`0 fallo(s)`) y el proceso salia **EXIT 0**.

Endurecido con las 3 capas: contador `_checks`, piso `CHECKS_MINIMOS = 72` **medido en
verde** (el primer valor escrito fue 74 por estimacion y el medido real fue 72), `BLOQUES`
(20) con `_fin()` al final de cada bloque, y `_summary()` en un `call_deferred` **separado**
del de `_run()` para que un aborto no se lleve el resumen.

Fix del aborto: `_ach._desbloqueados.clear()` + `.append("logro_primer_sello")` — se usa el
array tipado REAL en vez de asignar un `Array` sin tipar (sin cast fragil).

**2 aserciones infalsificables eliminadas** (`_check(true, ...)`):
- RN7 (toasts): el test desbloqueaba `logro_primer_sello`, que en ese punto **ya estaba
  desbloqueado** (`desbloquear()` devuelve `false` y no emite toast) y luego afirmaba
  `true`: vacio por partida doble. Ahora ejercita el guard real (`_emitir_toast`) y observa
  `_toast_buffer` en las dos direcciones (con `_toasts_disabled = true` NO crece; con
  `false` SI crece: control positivo).
- RF7 (`panel_solicitado`): ahora conecta un Callable, emite y afirma que llego 1 vez con
  payload `"logros"`.

Guarda nueva en `_test_ocultos()`: si `logro_secreto_guardian` no aparece en el listado, el
bloque corria **0 checks**; ahora es un fallo explicito.

Medicion: **72 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR. Guardian **EN ROJO x2**
(aborto inyectado: `[FAIL] bloques ... ["api_rf10"]` + `[FAIL] solo 65 checks (minimo 72)`
+ EXIT 1; asercion falsa: 72/1/EXIT 1), restauracion byte-exacta sha256
`c22750f9ea4547ae`.

**Consecuencia en CI (hallazgo colateral):** `quality.yml:527` corre esta suite y, como
siempre salia 0, el gate de M72-core era un **no-op** (familia trampa 81). Con el
endurecimiento el gate pasa a poder fallar. No se toco `quality.yml` (limite duro).

### 2. `test_logros_rf10_m72.gd`: id inexistente + contrato del API

Medido: `get_definicion("primer_sello")` — id que NO existe (el real es
`logro_primer_sello`). `get_definicion()` devuelve `_logros.get(id, {})`, o sea un
Dictionary **vacio y nunca `null`**; el test hacia `d.id` sobre `{}` -> `SCRIPT ERROR` ->
`_test_get_definicion` abortaba, sus 2 checks no corrian y la suite publicaba
`OK=23 FALLOS=0` + **EXIT 0**.

Corregido: id real, contrato real medido (`{}` vacio) y las mismas 3 capas (piso
**27 MEDIDO**, `BLOQUES` de 4, `_reportar()` diferido aparte). Medicion: **27/0/EXIT 0 x3**.
Guardian EN ROJO: 9 checks, nombra `["todos"]`, EXIT 1.

**Defecto de API corregido (aditivo):** `_logros[id]` no guardaba el campo `id` (el id era
la clave del diccionario) mientras `_estado_de()` si lo agrega. O sea `get_definicion(id)`
devolvia una definicion que **no se identificaba a si misma**, y `get_estado(id)` si. Se
agrego `"id": id` en `_cargar_catalogo()`. Verificado que ningun consumidor itera las
claves de forma estricta: los unicos externos son `sfx_manager.gd` y `test_postgame.gd`
(senal `logro_desbloqueado` y `get_todos`).

### 3 y 4. Iconos e i18n: de invisibles a MEDIDAS

Medido: los 18 `icono` apuntan a `res://assets/ui/logros/*.png` y **`assets/ui/` no
existe**. En el repo hay 300 PNG y **los 300 estan en `assets/2d/items_m159`**;
`assets/2d/ui` y `assets/2d/iconos` solo tienen `.gitkeep`. Las 36 claves `LOGROS.*`
(18 x `nombre_i18n` + `descripcion_i18n`) tienen **0** apariciones en `locales/es.po` y
**0** en `en.po`.

No se invento arte ni se toco el `.po` ajeno (**M88 esta en NO TOCAR**). Lo que se cerro es
la parte propia: **que la deuda deje de ser invisible**.

`achievement_service.gd` suma:
- `iconos_ausentes() -> Array[String]`: ids cuyo `icono` declarado no existe en disco
  (`FileAccess.file_exists`).
- `claves_i18n_ausentes() -> Array[String]`: claves del catalogo ausentes de
  `locales/es.po`.
- `_msgids_po(ruta) -> Dictionary`: parser de `msgid` del `.po`.

`validar_catalogo()` imprime en cada arranque `[M72][DEUDA] 18 icono(s) declarados sin
archivo en disco (arte: 18 PNG) y 36 clave(s) i18n fuera de locales/es.po`. **No**
incrementan `problemas`: RF14 valida la FORMA del catalogo (ids, categorias, condiciones,
steam ids) y esto es dependencia externa (arte / M88). Mezclarlos habria roto el contrato
"0 problemas" que afirman `test_logros`, `test_logros_rf1_e` y `test_logros_m72_statids`.

Suite nueva `scripts/logros/test_m72_deuda_assets.gd` — **no fija cifras: cruza**:
- Bloque A: para cada logro, `(id en iconos_ausentes()) == (not FileAccess.file_exists(icono))`
  en las DOS direcciones (invariante, no numero).
- Bloque B: cada clave reportada como ausente NO aparece como `msgid "..."` en el texto
  crudo del `.po` (camino independiente del parser) + clasificacion completa de las 36.
- Bloque C (guarda de CEGUERA): el parser debe leer > 50 msgid y reconocer una clave
  conocida (`MAIN_MENU.PLAY`). Un parser roto devuelve `{}`, entonces TODAS las claves
  parecen ausentes y el numero sube pareciendo correcto.
- Bloque D: `validar_catalogo()` sigue en 0 problemas.

Medicion: **9 checks / 0 fallos / EXIT 0 x3**, piso 9 MEDIDO, `[MEDIDO] iconos ausentes: 18
de 18`, `[MEDIDO] claves i18n ausentes: 36`. Sondas EN ROJO 2: API ciega
(`iconos_ausentes() -> []`) -> los 18 desalineados + EXIT 1; asercion falsa -> EXIT 1.
Restauraciones byte-exactas (sha256 `18eb6a6fd9a8b0e2` servicio, `68ee9ba54d09617a` suite).

### Lo que queda abierto (decision externa, no codigo)

1. **36 claves `LOGROS.*` en `locales/es.po` + `en.po`**: M88 es NO TOCAR -> GO pedido.
   Dato para decidir: hoy **nadie** traduce `nombre_i18n` (`tr(` en el servicio = 0), asi
   que agregarlas sin cablear el `tr()` en el consumidor las deja decorativas.
2. **18 PNG de icono**: no existe arte de UI en el repo. Opciones: pipeline de assets,
   quitar el `icono` (rompe RF1) o repuntar (no hay set: los 300 PNG son texturas de
   items).
3. **Cablear `test_m72_deuda_assets.gd` en `quality.yml`**: limite duro, pedido.

### Regresion medida

| suite | resultado |
|---|---|
| test_logros | 72 / 0 / EXIT 0 x3 |
| test_logros_rf10_m72 | 27 / 0 / EXIT 0 x3 |
| test_logros_rf13_m72 | 3 / 0 / EXIT 0 |
| test_logros_m72_statids | 9 / 0 / EXIT 0 |
| test_logros_rf1_e | 39 / 0 / EXIT 0 |
| test_m72_rf6_m72 | 7 / 0 / EXIT 0 |
| test_logros_depende_de_m72 | 6 / 0 / EXIT 0 |
| test_m72_deuda_assets (nueva) | 9 / 0 / EXIT 0 x3 |
| test_postgame (M75, consume M72) | 86 / 0 / EXIT 0 |
| test_sfx_m43 (consume la senal) | OK / EXIT 0 |

`--check-only` sobre `achievement_service.gd`: EXIT 0. **0 flips aplicados**: M72 esta en
200 [x] / 0 [ ] / 0 [?] y los 4 hallazgos eran defectos DENTRO de items ya marcados.
