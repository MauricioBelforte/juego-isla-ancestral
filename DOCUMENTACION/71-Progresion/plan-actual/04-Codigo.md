**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 71: Progresión

> Rutas previstas dentro de `res://progresion/` (estructura del proyecto Godot 4.x).
> ⚠️ **Estado: Pendiente de implementación.** Los archivos listados son diseño/documentación; no existe código runtime todavía.

## 1. Archivos Previstos

### 1.1 Scripts (GDScript, tipado)

| Archivo | Propósito | Estado |
|---|---|---|
| `res://progresion/progression_manager.gd` | Autoload `ProgressionManager`: orquestación, marcado de hitos, emisión de señales, persistencia | Pendiente de implementación |
| `res://progresion/milestone_registry.gd` | Autoload `MilestoneRegistry`: carga y validación de catálogos (hitos, desbloqueos, logros, títulos) | Pendiente de implementación |
| `res://progresion/unlock_system.gd` | Autoload `UnlockSystem`: evaluador de condiciones (dirty flags + caché) y activador de desbloqueos | Pendiente de implementación |
| `res://progresion/player_profile.gd` | Autoload `PlayerProfile`: estadísticas acumuladas y del día, primeras veces, reputación, títulos | Pendiente de implementación |
| `res://progresion/milestone_definition.gd` | Resource `MilestoneDefinition` (`.tres`): datos de un hito | Pendiente de implementación |
| `res://progresion/unlock_definition.gd` | Resource `UnlockDefinition` (`.tres`): datos de un desbloqueo | Pendiente de implementación |
| `res://progresion/condition_definition.gd` | Resource `ConditionDefinition` (`.tres`): condición tipada evaluable | Pendiente de implementación |
| `res://progresion/achievement_definition.gd` | Resource `AchievementDefinition` (`.tres`): registro base de logros | Pendiente de implementación |
| `res://progresion/title_definition.gd` | Resource `TitleDefinition` (`.tres`): título social de jugador | Pendiente de implementación |
| `res://progresion/progression_validation.gd` | Helper de validación de catálogos en editor (ids, ciclos, condiciones imposibles) | Pendiente de implementación |

### 1.2 Recursos de datos (`.tres`) — editor

| Archivo | Propósito | Estado |
|---|---|---|
| `res://progresion/data/catalogos/milestone_catalog.tres` | Catálogo central de MilestoneDefinition | Pendiente de implementación |
| `res://progresion/data/catalogos/unlock_catalog.tres` | Catálogo central de UnlockDefinition | Pendiente de implementación |
| `res://progresion/data/catalogos/achievement_catalog.tres` | Catálogo base de AchievementDefinition | Pendiente de implementación |
| `res://progresion/data/catalogos/title_catalog.tres` | Catálogo de TitleDefinition | Pendiente de implementación |
| `res://progresion/data/hitos/herramientas/hito_picota_n2.tres` | Hito de ejemplo: picota nivel 2 (M13) | Pendiente de implementación |
| `res://progresion/data/hitos/casa/hito_casa_n2.tres` | Hito de ejemplo: casa nivel 2 (M18) | Pendiente de implementación |
| `res://progresion/data/hitos/amistad/hito_amigo_n3.tres` | Hito de ejemplo: primer amigo nivel 3 (M20) | Pendiente de implementación |
| `res://progresion/data/hitos/historia/hito_sello_brisa.tres` | Hito de ejemplo: sello de la Brisa (M22) | Pendiente de implementación |
| `res://progresion/data/hitos/economia/hito_monedas_1000.tres` | Hito de ejemplo: 1000 monedas acumuladas (M38) | Pendiente de implementación |
| `res://progresion/data/hitos/colecciones/hito_fauna_completa.tres` | Hito de ejemplo: colección de aves completa (M37) | Pendiente de implementación |
| `res://progresion/data/hitos/generales/hito_dias_30.tres` | Hito de ejemplo: 30 días jugados (M29) | Pendiente de implementación |
| `res://progresion/data/unlocks/unlock_cueva_profunda.tres` | Desbloqueo de ejemplo: acceso a cueva profunda (zona) | Pendiente de implementación |
| `res://progresion/data/unlocks/unlock_receta_tela.tres` | Desbloqueo de ejemplo: receta de tela (M16) | Pendiente de implementación |
| `res://progresion/data/condiciones/cond_stat_items.tres` | Condición reutilizable: stat_min sobre estadística | Pendiente de implementación |

### 1.3 Señales externas consumidas (contrato de entrada)

| Señal | Origen | Uso |
|---|---|---|
| `nivel_herramienta_cambio(herramienta_id, nivel)` | M13 | Actualiza estadística y reevalúa condiciones (nombre real a confirmar) |
| `nivel_casa_cambio(nivel)` | M18 | Actualiza estadística y reevalúa condiciones |
| `nivel_amistad_cambio(npc_id, nivel)` | M20 | Actualiza amistad/reputación y reevalúa condiciones |
| `sello_obtenido(sello_id)` / `capitulo_avanzado(capitulo_id)` | M22 | Refleja hitos narrativos (solo lectura) |
| `transaccion_registrada(tx: Dictionary)` | M38 | Estadísticas económicas (monedas ganadas/gastadas) |
| `trueque_exitoso(npc_id, oferta_id, entregado, recibido)` | M38 | Estadística de trueques realizados |
| `item_recolectado(item_id, cantidad)` | M15 (vía M07) | Estadística de recolección (canal de eventos) |
| `objeto_crafteado(receta_id)` | M16 (vía M07) | Estadística de crafting |
| `donacion_museo(item_id)` | M37 (vía M07) | Estadística de donaciones |
| `nuevo_dia_laborable(fecha)` | M29/M30 | Reset de estadísticas del día |

## 2. Funciones Clave (firmas GDScript previstas)

```gdscript
# ---------- milestone_definition.gd ----------
class_name MilestoneDefinition
extends Resource

@export var milestone_id: StringName
@export var nombre_i18n: String                        # clave de traducción
@export var descripcion_i18n: String
@export var condicion: ConditionDefinition
@export var recompensas: Array[Dictionary] = []        # [{tipo: "titulo"/"info"/"marcador", valor: StringName}]
@export var orden: int = 0
@export var visible: bool = true
@export var dominio: StringName = &"generales"

func validar() -> Array[String]:
    # Errores accionables: id vacío, sin condición, recompensa inválida...
    pass
```

```gdscript
# ---------- condition_definition.gd ----------
class_name ConditionDefinition
extends Resource

@export var condicion_id: StringName
@export var tipo: StringName = &"stat_min"   # stat_min / dias_jugados / nivel_modulo / sello_historia /
                                             # capitulo_historia / riqueza_acumulada / coleccion_completa /
                                             # hito_previo / primera_vez / compuesta
@export var parametros: Dictionary = {}      # {stat_id, umbral, modulo, ref, nivel, sello_id, ...}
@export var operador: StringName = &"AND"    # solo para tipo compuesta
@export var hijos: Array[Resource] = []      # ConditionDefinition (solo para compuesta)

func evaluar(estado: Dictionary) -> bool:
    # Predicado puro sobre el snapshot de estadísticas/hitos; sin efectos secundarios
    pass

func progreso_parcial(estado: Dictionary) -> Dictionary:
    # Devuelve {logrado: int, requerido: int} cuando es cuantificable; si no, {}
    pass

func validar() -> Array[String]:
    pass
```

```gdscript
# ---------- unlock_definition.gd ----------
class_name UnlockDefinition
extends Resource

@export var unlock_id: StringName
@export var tipo: StringName = &"info"       # receta / zona / mecanica / titulo / info
@export var valor: StringName                # contenido destino (receta_id, zona_id, ...)
@export var condicion: ConditionDefinition
@export var alternativa_id: StringName = &"" # ruta alternativa (coopera con M66)
@export var notificacion_i18n: String

func validar() -> Array[String]:
    pass
```

```gdscript
# ---------- progression_manager.gd (autoload "ProgressionManager") ----------
extends Node

signal progreso_hito_alcanzado(milestone_id: StringName, nombre_i18n: String, recompensas: Array)
signal progreso_desbloqueado(unlock_id: StringName, tipo: StringName, valor: StringName)
signal progreso_logro(logro_id: StringName)
signal progreso_primera_vez(actividad_id: StringName)
signal progreso_condicion_imposible(condicion_id: StringName, motivo: StringName)
signal progreso_resumen_cargado(hitos: int, desbloqueos: int, logros: int)

func marcar_hito(milestone_id: StringName) -> bool:
    pass    # idempotente: false si ya estaba alcanzado; emite señal + aplica recompensas no críticas

func hito_alcanzado(milestone_id: StringName) -> bool:
    pass

func hitos_alcanzados() -> Array[StringName]:
    pass

func hitos_proximos(limite: int) -> Array:
    pass    # para el sugeridor de metas de M53 (1-3 metas)

func desbloqueos_activos() -> Array[StringName]:
    pass

func guardar_estado() -> Dictionary:
    pass    # sección "progresion" versionada para GameState (M59)

func cargar_estado(data: Dictionary) -> void:
    pass    # valida contra catálogo; nunca re-emite señales; mantiene ids desconocidos

func reset_dia() -> void:
    pass    # al nuevo_dia_laborable (M29): limpia estadísticas del día
```

```gdscript
# ---------- milestone_registry.gd (autoload "MilestoneRegistry") ----------
extends Node

func load_catalogos() -> Array[String]:
    pass    # carga .tres y ejecuta validación en editor; devuelve errores accionables

func get_milestone(id: StringName) -> MilestoneDefinition:
    pass    # O(1), diccionario precargado

func get_unlock(id: StringName) -> UnlockDefinition:
    pass

func get_logro(id: StringName) -> AchievementDefinition:
    pass

func get_titulo(id: StringName) -> TitleDefinition:
    pass

func condiciones_de_estadistica(stat_id: StringName) -> Array[ConditionDefinition]:
    pass    # mapa stat_id -> condiciones dependientes (dirty flags)
```

```gdscript
# ---------- unlock_system.gd (autoload "UnlockSystem") ----------
extends Node

func reevaluar_sucias() -> void:
    pass    # recorre condiciones marcadas como sucias; informa a ProgressionManager

func marcar_sucia(stat_id: StringName) -> void:
    pass    # invalidar caché de condiciones dependientes

func evaluar(condicion_id: StringName) -> bool:
    pass    # usa caché; resultados congelados hasta invalidación

func progreso_parcial(condicion_id: StringName) -> Dictionary:
    pass    # evaluación perezosa, solo cuando M53 la pide

func activar_desbloqueo(unlock_id: StringName) -> void:
    pass    # idempotente; delega emisión a ProgressionManager

func detectar_condiciones_imposibles() -> Array:
    pass    # en carga de catálogo (estático) y en runtime (dinámico, con M66)
```

```gdscript
# ---------- player_profile.gd (autoload "PlayerProfile") ----------
extends Node

signal estadistica_cambiada(stat_id: StringName, valor_actual: Variant)

func incrementar(stat_id: StringName, cantidad: int) -> void:
    pass    # actualiza total y del día; marca sucia la estadística en UnlockSystem

func set(stat_id: StringName, valor: Variant) -> void:
    pass

func get(stat_id: StringName) -> Variant:
    pass    # fallback: devuelve 0 / false según tipo sin crashear

func estadisticas_dia() -> Dictionary:
    pass

func primera_vez(actividad_id: StringName) -> bool:
    pass

func marcar_primera_vez(actividad_id: StringName) -> void:
    pass    # emite progreso_primera_vez vía ProgressionManager

func reputacion() -> float:
    pass    # 0-100: 60% amistad promedio (M20) + 40% contribuciones (M38); nunca decrece sola

func titulos() -> Array[StringName]:
    pass

func guardar_estado() -> Dictionary:
    pass

func cargar_estado(data: Dictionary) -> void:
    pass
```

## 3. Logs Relacionados (propuestos)

| Log | Contenido |
|---|---|
| `DOM-PROG-HITO` | Cada hito alcanzado: milestone_id, dominio, fecha (día M29), condiciones evaluadas |
| `DOM-PROG-UNLOCK` | Cada desbloqueo activado: unlock_id, tipo, valor, condición origen |
| `DOM-PROG-LOGRO` | Logros desbloqueados y progresos parciales registrados |
| `DOM-PROG-STAT` | Cambios de estadísticas relevantes (solo debug: incrementos grandes, resets de día) |
| `DOM-PROG-IMP` | Condiciones imposibles detectadas: condicion_id, motivo, ruta alternativa aplicada (M66) |
| `DOM-PROG-VALIDACION` | Errores de data en editor: ids duplicados, estadísticas inexistentes, ciclos |

Formato de línea de ejemplo: `[DOM-PROG-HITO] alcanzado milestone=hito_picota_n2 dominio=herramientas dia=12 recompensas=[info receta_picota_mejorada]`

## 4. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Documenté el diseño completo del módulo 71 (Progresión): registry central de hitos, desbloqueos data-driven con condiciones tipadas, perfil de jugador con estadísticas, registro base de logros (curaduría en M72), primeras veces y reputación comunitaria blanda.
- Definí 4 autoloads desacoplados (`ProgressionManager`, `MilestoneRegistry`, `UnlockSystem`, `PlayerProfile`) con contrato de señales hacia M07/M13/M18/M20/M22/M38/M53/M59/M66/M72.
- Especifiqué rutas previstas (`res://progresion/...`), firmas GDScript tipadas, persistencia versionada para GameState (M59) y logs del módulo (DOM-PROG-*).
- Creada la dupla plan-inicial/plan-actual con los 5 archivos obligatorios del estándar (checklist con más de 130 ítems).

### Lo que NO pude hacer (honestidad obligatoria)
- No hay código runtime: todo lo listado es diseño previsto, marcado "Pendiente de implementación".
- No se definieron los valores concretos del catálogo (cuáles hitos exactos y sus umbrales): dependen de la tabla de balance (M93) y del curado de logros (M72).
- No se verificaron los nombres reales de las señales de M13/M18/M20/M22/M38 ni del EventBus de M07: se usan nombres propuestos ("nivel_herramienta_cambio", "sello_obtenido", etc.) que deben confirmarse contra la implementación de esos módulos.
- La ruta `res://progresion/` es la propuesta por esta tarea; puede requerir ajuste a la convención global del repo Godot.
- No se resolvió cómo M72 consumirá exactamente el registro de logros (fuente de verdad del catálogo de logros): se asume que M72 es la curaduría/UI y el 71 el motor de condiciones.

### Recomendaciones para el próximo agente
- Implementar primero `ConditionDefinition` + evaluador puro (sin autoloads) con tests unitarios: es la pieza que todo lo demás consume.
- Segundo: `MilestoneRegistry` + `progression_validation.gd` con validación en editor (ids únicos, ciclos, condiciones imposibles estáticas).
- Tercero: `PlayerProfile` y `ProgressionManager` con persistencia mínima, y un primer hito de ejemplo end-to-end ("recolectar 50 maderas").
- Confirmar los nombres reales de las señales de entrada (M13/M18/M20/M22/M38) y del EventBus de M07 antes de conectar; ajustar el contrato de la sección 1.3.
- Al conectar M66 (anti-softlock), acordar el formato de `progreso_condicion_imposible` y el manejo de `alternativa_id`.
- Coordinar con M72 el reparto del catálogo de logros (quiénes definen qué) antes de poblar `achievement_catalog.tres`.
- En `plan-actual/` copiar estos archivos y actualizarlos contra el código real a medida que se implemente.

---

## Notas del Agente — Iteración 1 núcleo (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 16:25:00
**Estado:** Parcial (núcleo de progresión implementado y verificado; módulo liberado 🟡)

### Lo que hice
- PlayerProfile autoload (scripts/progresion/player_profile.gd, §3.4): estadísticas totales y del día, primeras veces, contribución comunitaria (monedas ganadas), dirty flags por estadística, reputación 60% amistad / 40% contribución (§4.5, normalizaciones documentadas: 10 niveles-amistad máx, 2000 AO contribución = 100%), reset_dia, serialización propia.
- ProgressionManager autoload (scripts/progresion/progression_manager.gd, §1/§3.1): suscribe 6 señales de dominio M07 (items→items_recolectados, purchase_done→monedas_gastadas, gift_given→regalos_dados, prereq_met→sellos, quest_completed→misiones, friendship_level_up→amistades_subidas, travel_started→viajes); evaluador de condiciones de los 10 tipos §3.6 (stat_min, dias_jugados, sello_historia, capitulo_historia, riqueza_acumulada, coleccion_completa, hito_previo, primera_vez, compuesta AND/OR/NOT) con dirty-flagging O(1) por estadística (indexación condición→hito al cargar, §7); marcar_hito idempotente con señal progreso_hito_alcanzado y log [DOM-PROG-HITO]; desbloqueos idempotentes con progreso_desbloqueado + log [DOM-PROG-UNLOCK]; progreso_parcial perezoso para M53; reflejo narrativo solo-lectura de M22 (§2.2); persistencia ISaveProvider M59 sección "progresion" versionada (§6: hitos/desbloqueos/estadísticas/primeras veces/contribución, hitos de catálogo viejo purgados, NUNCA re-emitir señales restauradas).
- Catálogo data-driven data/progresion/hitos.json (§8): 9 hitos de referencia de los 7 dominios con condiciones de los tipos del §3.6 y recompensas cosméticas/info (nunca poder duro — §8 regla de balance).
- Test test_progresion.gd: catálogo, reevaluación dirty por eventos reales (10 items → hito), idempotencia, tipos de condición (compuesta AND/NOT, coleccion, hito_previo, primera_vez, desconocido), desbloqueos idempotentes, reputación 60/40, persistencia con hito de catálogo viejo → **0 fallos**.
- Regresiones: test_historia M22 0 fallos (M71 refleja sus sellos), test_autosave M59 0 fallos.
- Checklist: relevado con los ítems del núcleo implementados.

### Fusión documentada (iter. 1)
- MilestoneRegistry y UnlockSystem del diseño §1 quedan FUSIONADOS dentro de ProgressionManager: el catálogo es JSON (no .tres) y el evaluador vive en el manager. El desglose a 4 autoloads (extraer registry/evaluador) es iter. 2 si el volumen de hitos lo justifica — las señales y el contrato NO cambian.

### Lo que NO pude hacer (honestidad obligatoria)
- Nivel de módulos M13/M18 como condición (nivel_modulo del §3.6): implementado el tipo pero las señales nivel_herramienta_cambio/nivel_casa_cambio no existen aún en M13/M18 (el tipo queda listo; los puentes son de 1 línea cuando M13/M18 las emitan).
- Reputación con amistad real de M20: reputacion(amistad_normalizada) espera que un puente calcule la normalización desde M20 (nivel medio/max de los vecinos) — queda con dueño.
- Logros (M72) y títulos con catálogo: los tipos Achievement/Title del §3.5 quedan para la iteración con M72.
- RUIDA_PROGRESADA (M25), ESPECIE_AVISTADA (M36): puentes con dueño de esos módulos.

### Recomendaciones para el próximo agente
- M13/M18: al emitir nivel_herramienta_cambio/nivel_casa_cambio, conectar puente 1-línea en _conectar_eventos() (patrón existente) — el tipo nivel_modulo del evaluador ya lo consume.
- M72: AchievementDefinition puede reusar el evaluador de condiciones (evaluar_condicion) — no duplicar la lógica.
- Catálogo: nuevo hito = nueva entrada en hitos.json (sin tocar código). Los recompensas tipo "unlock" activan desbloqueos automáticamente.

## Notas del Agente — Iteración 2 (historial, no borra anteriores)

**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 00:20
**Estado:** Iter 2 completada

### Lo que hice
- Integré GameLogger (M103) en ProgressionManager: helpers _log_info/_log_dom_hito/_log_dom_unlock usan logger.info(msg, 3) con fallback a print().
- Añadí tipo condicional nivel_modulo (§3.6): evalúa nivel de herramienta (M13) o casa (M18) vía duck-typing directo (no señales). Retorna false sin crash si el módulo no existe.
- Corregí bug en _sello_obtenido: había código muerto (and false if false else) que dejaba la función en estado ambiguo.
- Expandí catálogo hitos.json de 9 a 15 hitos (6 nuevos: dias_7, dias_30, items_50, misiones_5, viajeros_10, sello_ceniza_sala2).
- Actualicé test_progresion.gd: esperado 15 hitos, nuevo test _test_nivel_modulo_fallback (3 checks).

### Lo que NO pude hacer
- Señales de nivel (M13/M18): el tipo nivel_modulo funciona por lectura directa, pero las señales permitirían dirty-flagging proactivo. Depende de dueños M13/M18.
- Reputación con amistad real de M20: normalización pendiente.
- Logros/títulos M72: para iteración conjunta.
- Catálogo completo 22 categorías: contenido a poblar por M93/M72.

### Recomendaciones para el próximo agente
- Cuando M13/M18 emitan señales de nivel, conectar puentes 1-línea en _conectar_eventos() (patrón existente).
- M72 puede reusar evaluar_condicion() para condiciones de logros — no duplicar lógica.
- El catálogo hitos.json es data-driven: nuevo hito = nueva entrada JSON, sin tocar código.

