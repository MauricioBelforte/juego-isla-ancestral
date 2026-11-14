# Reporte: acoplamiento y dependencias circulares entre autoloads en `scripts/core/` (excl. EventBus/ServiceRegistry)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (Agent Manager)  
**Fecha:** 2026-11-13  
**Alcance:** autoloads definidos en `game/isla-ancestral/project.godot` cuyos scripts viven en `game/isla-ancestral/scripts/core/` (análisis estático).  
**Excluidos por solicitud:** `EventBus` y `ServiceRegistry` (ya auditados).  
**Fuentes:** `game/isla-ancestral/project.godot` (sección `[autoload]`, L19-120 aprox.), scripts en `scripts/core/`.

---

## Autoloads de `scripts/core/` identificados (orden de carga en `project.godot`)

| Autoload | Ruta | Línea en `[autoload]` |
|---|---|---:|
| `GameSettings` | `res://scripts/core/game_settings.gd` | 25 |
| `SoftlockGuard` | `res://scripts/core/softlock_guard.gd` | 34 |
| `Bootstrap` | `res://scripts/core/bootstrap.gd` | 40 |
| `TerrainLocator` | `res://scripts/core/terrain_locator.gd` | 44 |
| `EscalasGlobales` | `res://scripts/core/escalas_globales.gd` | 83 |
| `GameFlowManager` | `res://scripts/core/game_flow_manager.gd` | 95 |
| `SceneManager` | `res://scripts/core/scene_manager.gd` | 96 |

> Nota: `SesionMaster` (`scripts/core/sesion_master.gd:1-73`) no está registrado como autoload en `project.godot` (solo existe como contrato/definición inactiva, ver L18-19,31-32). `registro.gd`, `contratos.gd`, `build_info.gd`, etc. no son autoloads.

---

## 1) Referencias cruzadas, acoplamiento y ciclos de inicialización

### 1.1 Matriz de dependencias observada (autoloads `core/*`)

| Origen | Referencia a | Tipo | Evidencia (archivo:línea) | Lectura |
|---|---|---|---|---|
| `Bootstrap` | `ServiceRegistry`, `EventBus` | `/root/...` + API | `bootstrap.gd:78,126,139,147` | Fuera de alcance (excluidos), pero relevantes como base. |
| `Bootstrap` | `GameFlowManager` | `/root/...`, lectura enum, `cambiar_estado` | `bootstrap.gd:91,101-103,110-111` | Dependencia directa al autoload de flujo (carga tardía, ver §1.2). |
| `Bootstrap` | `SceneManager` | `/root/...`, `estado_flujo`, `sincronizar_flujo` | `bootstrap.gd:95,97-99,108-109` | Dependencia directa al orquestador de escenas (carga tardía). |
| `Bootstrap` | Dominios varios (mapa) | `/root/<Nombre>` dinámico | `bootstrap.gd:64-80` (`_autoregistrar_dominios`) | Acoplamiento por convención de nombres/autoloads; no crea ciclo core-core. |
| `SceneManager` | `EventBus` | `/root/...` + emisión infra | `scene_manager.gd:82,88` | Desacoplado por bus (excluido). |
| `SceneManager` | `GameFlowManager` | `/root/...`, `Estado`, `get_estado`, `cambiar_estado` | `scene_manager.gd:95,103-109,118-126` | **Acoplamiento fuerte de control**: conoce ruta, API y nombres del enum de flujo. |
| `GameFlowManager` | `EventBus` | `/root/...` + emisión infra | `game_flow_manager.gd:67,73` | Desacoplado por bus (excluido). |
| `SoftlockGuard` | `EventBus` | `/root/...` + conexión señal infra | `softlock_guard.gd:71-73` | Desacoplado por bus (excluido). |
| `SoftlockGuard` | `SaveManager` | `/root/...` + `save_completed.connect` | `softlock_guard.gd:74-76` | Dependencia directa a autoload fuera de `core/` (`scripts/saving/save_manager.gd`, autoload L30). |
| `SoftlockGuard` | Módulo M66 local | `preload(...)` invariantes/recovery | `softlock_guard.gd:13-22` | Preloads de recursos propios del módulo (no autoloads); no forma ciclo de autoload. |
| `TerrainLocator` | Escena/árbol | búsqueda `VoxelTerrain` en árbol | `terrain_locator.gd:24-40` | Sin referencias a otros autoloads. |
| `GameSettings` | — | `ConfigFile`/`FileAccess` implícito | `game_settings.gd:53-69` | Sin referencias a otros autoloads. |
| `EscalasGlobales` | — | `res://data/...` | `escalas_globales.gd:15,25` | Sin referencias a otros autoloads. |

**Búsqueda de `preload`/`load` hacia otros scripts core/autoload:** no se hallaron `preload()`/`load()` que apunten a otros autoloads de `core/` en los scripts runtime analizados (`bootstrap.gd`, `game_flow_manager.gd`, `scene_manager.gd`, `softlock_guard.gd`, `terrain_locator.gd`, `game_settings.gd`, `escalas_globales.gd`).

### 1.2 Ciclos de inicialización y orden de arranque

- **No se detectan dependencias circulares (directas ni indirectas) entre autoloads de `core/`.** El grafo observado es acíclico:
  - `Bootstrap` → usa `SceneManager`/`GameFlowManager` (y otros) pero **de forma diferida**: `bootstrap.gd:51-55` (`_verificar_game_flow.call_deferred()`, `_autoregistrar_dominios.call_deferred()`, etc.), lo que evita que `Bootstrap` (orden 40) requiera que `GameFlowManager`/`SceneManager` (95/96) estén listos en su `_ready()` inmediato.
  - `SceneManager` → consulta/controla `GameFlowManager` (`scene_manager.gd:95-128`) en llamadas de flujo/carga; `GameFlowManager` **no referencia** a `SceneManager` ni a `Bootstrap` (`game_flow_manager.gd:1-73` solo consulta `/root/EventBus`). Dirección única: `SceneManager` ⇒ `GameFlowManager`.
  - `SoftlockGuard` solo se conecta a `EventBus` y `SaveManager` (`softlock_guard.gd:71-76`); ningún autoload `core/*` depende de `SoftlockGuard`.

- **Mitigaciones presentes (buenas prácticas):** uso de `get_node_or_null("/root/...")` con guardas (`bootstrap.gd:78-83,91-115,126-133`; `scene_manager.gd:82-89,95-96,118-121`; `softlock_guard.gd:71-76`), resolución diferida (`bootstrap.gd:51-55`), y sincronización idempotente (`scene_manager.gd:122-125`).

### 1.3 Hallazgos de acoplamiento fuerte / riesgo de orden

| ID | Severidad | Hallazgo | Evidencia | Riesgo |
|---|---|---|---|---|
| C1 | **Alto** | **Acoplamiento de orquestación flujo↔escena entre `SceneManager` y `GameFlowManager`**: `SceneManager` conoce la ruta del autoload, resuelve nombres del enum (`"CARGANDO"`, `"ERROR"`), inspecciona `Estado/get_estado` e invoca `cambiar_estado`. | `scene_manager.gd:32,44,62,68-73,90-137,149-160`; `game_flow_manager.gd:13-25,34-46,48-62`. `Bootstrap` replica parte de esa lógica (`bootstrap.gd:85-115`, comentarios L88-89 sobre "número mágico"). | Doble punto de conocimiento del contrato de estados; cambios en el enum/API de `GameFlowManager` obligan a tocar `SceneManager` y `Bootstrap`. Dificulta sustituir la FSM o probar en aislamiento. |
| C2 | **Medio** | **`Bootstrap` concentra lógica de transición y wiring de arranque**: además de registrar, decide paso a `MUNDO`, conoce la relación flujo↔escena y mantiene catálogos de dominios/contratos. | `bootstrap.gd:43-58,63-83,90-115,143-184,217-223`. Catálogos: `DOMINIOS_ESPERADOS` (`L23-33`) vs mapa en `_autoregistrar_dominios` (`L64-77`, incluye `event_manager`, `game_flow`, `scene_manager` no listados en `DOMINIOS_ESPERADOS`). | Deriva de configuración (drift) y acoplamiento del arranque a detalles de múltiples autoloads; `verificar_integridad_dominios` puede reportar estado inconsistente respecto a lo realmente registrado. No es ciclo, pero eleva fragilidad de inicialización. |
| C3 | **Medio** | **`SoftlockGuard` acoplado por señal concreta a `SaveManager` (autoload externo a core)**, no por contrato de bus. | `softlock_guard.gd:69-76` (`sm.save_completed.connect(...)`). Autoload `SaveManager` en `project.godot:30`. | Si cambia la señal/firma o el autoload no expone `save_completed`, el disparo por guardado se pierde silenciosamente (solo `has_signal` guard). Patrón menos desacoplado que el usado con `EventBus.infra.carga_iniciada` (`L71-73`). |
| C4 | **Bajo** | **Búsqueda de terreno por recorrido de árbol + `get_tree().current_scene`** en autoload de servicio. | `terrain_locator.gd:24-40` (`_process` reintenta cada frame si falta terrain, busca en `current_scene` y luego en todo el árbol). | Acoplamiento implícito al momento de carga de escena/estructura del árbol; coste por-frame hasta resolver (normalmente acotado). No involucra otros autoloads core, sin riesgo de ciclo. |
| C5 | **Bajo** | **Orden de autoloads fijo como dependencia implícita** (Bootstrap antes que SceneManager/GameFlowManager). | `project.godot:40,95,96` + mitigación `bootstrap.gd:51-55`. | Correcto hoy gracias a `call_deferred`/guardas; reordenar autoloads o invocar API de bootstrap fuera del flujo diferido podría exponer supuestos de disponibilidad. |

---

## 2) Señales cruzadas entre autoloads que generen acoplamiento implícito

| ID | Severidad | Señal / interacción | Emisor | Receptor | Evidencia | Evaluación |
|---|---|---|---|---|---|---|
| S1 | **Bajo** | `EventBus.infra.carga_iniciada` / `boot_completado` / `game_flow_changed` (canal de bus) | `SceneManager` (`scene_manager.gd:46,65,88`), `Bootstrap` (`bootstrap.gd:132`), `GameFlowManager` (`game_flow_manager.gd:73`) | `SoftlockGuard` (`softlock_guard.gd:71-73`), tests | Declaraciones en `event_bus.gd:165-171` | **Acoplamiento débil y explícito por contrato de bus** (deseable). No es acoplamiento implícito entre autoloads concretos. |
| S2 | **Medio** | `SaveManager.save_completed` (señal directa de autoload) | `SaveManager` (autoload externo) | `SoftlockGuard` (`softlock_guard.gd:74-76`) | `softlock_guard.gd:74-76` (`has_signal` + `connect`) | **Acoplamiento implícito al API/señal del emisor concreto** (ruta `/root/SaveManager` + nombre/firma de señal). Menos flexible que S1; cualquier cambio en `SaveManager` impacta a `SoftlockGuard`. |
| S3 | **Ruido** | Señales locales no cruzadas entre autoloads core | `GameFlowManager.estado_cambiado` (`game_flow_manager.gd:27,43`), `GameSettings.settings_changed` (`game_settings.gd:12,50,69`) | No se hallaron suscriptores entre autoloads `core/*` | Búsquedas estáticas en `scripts/core` | Sin acoplamiento cruzado core-core observado. |

**Conclusión señales:** no hay señales cruzadas *entre autoloads de `core/`* que creen acoplamiento implícito. El acoplamiento por señal relevante en este ámbito es **core → autoload externo** (`SoftlockGuard` → `SaveManager`, S2).

---

## 3) Resumen ejecutivo

- **Ciclos de inicialización / dependencias circulares entre autoloads `core/*`:** **no detectados** (análisis estático de `/root/`, `preload/load`, señales y orden de `[autoload]`).
- **Acoplamiento fuerte principal:** `SceneManager` ↔ `GameFlowManager` en la práctica es un acoplamiento direccional fuerte de orquestación (C1), con lógica parcialmente duplicada en `Bootstrap` (C2).
- **Acoplamiento implícito por señal:** `SoftlockGuard` depende de la señal concreta `SaveManager.save_completed` (S2/C3).
- **Inicialización:** el orden `Bootstrap(40)` antes de `GameFlowManager/SceneManager(95,96)` está compensado con `call_deferred` y guardas (riesgo bajo, C5).

| Severidad | Conteo |
|---|---:|
| Crítico | 0 |
| Alto | 1 (C1) |
| Medio | 3 (C2, C3, S2) |
| Bajo | 2 (C4, C5) |
| Ruido | 1 (S3) |

---

## 4) Dos mejoras de diseño concretas (con código)

### Mejora 1 — Desacoplar `SceneManager` de `GameFlowManager` (C1)

**Idea:** que `SceneManager` no conozca la ruta/API/enum de `GameFlowManager`. `SceneManager` emite intenciones/resultado de carga por `EventBus.infra` (contrato ya existente) y `GameFlowManager` (o un adaptador de flujo) reacciona y aplica transiciones. `SceneManager` deja de llamar `get_node_or_null("/root/GameFlowManager")`, `estado_flujo`, `sincronizar_flujo`.

**Ejemplo (conceptual, GDScript) — `scene_manager.gd` (eliminar control directo de flujo):**

```gdscript
# ANTES (acoplado): scene_manager.gd
const MODO_SIN_FLUJO: int = -1
var _modo_pendiente: int = MODO_SIN_FLUJO

func cambiar_escena(ruta: String, modo: int = MODO_SIN_FLUJO) -> bool:
	if _cargando:
		return false
	if ruta.is_empty() or not ResourceLoader.exists(ruta):
		cambio_fallido.emit(ruta, "escena_inexistente")
		_sincronizar_error(modo) # -> consulta /root/GameFlowManager
		return false
	_cargando = true
	_modo_pendiente = modo
	if modo != MODO_SIN_FLUJO:
		sincronizar_flujo(estado_flujo("CARGANDO")) # acoplamiento fuerte
	cambio_iniciado.emit(ruta)
	_emitir_infra("carga_iniciada", ruta)
	call_deferred("_do_cambio", ruta)
	return true

# DESPUÉS (desacoplado): SceneManager solo orquesta escena y publica eventos
# Requiere ampliar contrato infra (p.ej. modo_objetivo: int/StringName, -1 = ninguno)
func cambiar_escena(ruta: String, modo_objetivo: StringName = &"") -> bool:
	if _cargando:
		push_warning("[M40] Cambio ya en curso; se ignora")
		return false
	if ruta.is_empty() or not ResourceLoader.exists(ruta):
		cambio_fallido.emit(ruta, "escena_inexistente")
		_emitir_infra_payload("carga_fallida", {"ruta": ruta, "motivo": "escena_inexistente", "modo": modo_objetivo})
		return false
	_cargando = true
	cambio_iniciado.emit(ruta)
	_emitir_infra_payload("carga_iniciada", {"ruta": ruta, "modo": modo_objetivo})
	call_deferred("_do_cambio", ruta, modo_objetivo)
	return true

func _do_cambio(ruta: String, modo_objetivo: StringName) -> void:
	var tree := get_tree()
	_cargando = false
	if tree == null:
		return
	var err: Error = tree.change_scene_to_file(ruta)
	if err != OK:
		cambio_fallido.emit(ruta, "error_%d" % err)
		_emitir_infra_payload("carga_fallida", {"ruta": ruta, "motivo": "error_%d" % err, "modo": modo_objetivo})
		return
	cambio_completado.emit(ruta)
	_emitir_infra_payload("carga_completada", {"ruta": ruta, "modo": modo_objetivo})
```

**Ejemplo — `game_flow_manager.gd` (suscriptor del contrato de carga, sin que SceneManager lo invoque):**

```gdscript
# game_flow_manager.gd
func _ready() -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus == null:
		return
	var infra: Variant = bus.get("infra")
	if infra != null and infra is Object:
		if infra.has_signal("carga_iniciada"):
			infra.carga_iniciada.connect(_on_carga_iniciada)
		if infra.has_signal("carga_completada"):
			infra.carga_completada.connect(_on_carga_completada)
		if infra.has_signal("carga_fallida"):
			infra.carga_fallida.connect(_on_carga_fallida)

func _on_carga_iniciada(payload: Dictionary) -> void:
	if str(payload.get("modo", "")) != "":
		cambiar_estado(Estado.CARGANDO)

func _on_carga_completada(payload: Dictionary) -> void:
	var modo := str(payload.get("modo", ""))
	if modo == "MUNDO":
		cambiar_estado(Estado.MUNDO)
	elif modo == "MENU":
		cambiar_estado(Estado.MENU)

func _on_carga_fallida(_payload: Dictionary) -> void:
	# política configurable: solo si había intención de orquestar flujo
	if str(_payload.get("modo", "")) != "":
		cambiar_estado(Estado.ERROR)
```

**Efecto:** elimina `/root/GameFlowManager` y conocimiento del enum desde `SceneManager` y reduce duplicación en `Bootstrap`; la FSM queda como única dueña de transiciones. (Requiere definir formalmente la señal/payload en `EventBus.infra`, fuera de este alcance.)

### Mejora 2 — Desacoplar `SoftlockGuard` de la señal concreta de `SaveManager` (C3/S2)

**Idea:** evitar `sm.save_completed.connect(...)` directo. Opción A (preferida, consistente con `carga_iniciada`): escuchar un evento de persistencia publicado en `EventBus` (p.ej. `EventBus.infra.guardado_completado` o dominio dedicado) emitido por `SaveManager`. Opción B (sin tocar EventBus): resolver por contrato en `ServiceRegistry` y conectar mediante interfaz/capability (`has_signal` + nombre configurable) en un único punto.

**Ejemplo Opción A — `softlock_guard.gd` consume solo bus:**

```gdscript
# ANTES: softlock_guard.gd:71-76
func _conectar_disparos() -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus != null and bus.infra != null and bus.infra.has_signal("carga_iniciada"):
		bus.infra.carga_iniciada.connect(func(_ruta: String): forzar_chequeo("transicion_escena"))
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_signal("save_completed"):
		sm.save_completed.connect(func(_slot: int, _reason: String): forzar_chequeo("guardado"))

# DESPUÉS: solo contrato de bus (SaveManager publica en EventBus.infra)
func _conectar_disparos() -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus == null or bus.get("infra") == null or not (bus.infra is Object):
		return
	if bus.infra.has_signal("carga_iniciada"):
		bus.infra.carga_iniciada.connect(func(_ruta: String): forzar_chequeo("transicion_escena"))
	if bus.infra.has_signal("guardado_completado"):
		bus.infra.guardado_completado.connect(func(_slot: int, _reason: String): forzar_chequeo("guardado"))
```

**Ejemplo Opción B — resolución por contrato (si no se desea ampliar el bus):**

```gdscript
# softlock_guard.gd
const SAVE_CONTRACT := "save_manager"
const SAVE_SIGNAL := "save_completed"

func _conectar_disparos() -> void:
	_conectar_bus()
	_conectar_guardado()

func _conectar_guardado() -> void:
	var sm: Object = null
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr != null and sr.has_method("get_service"):
		sm = sr.get_service(SAVE_CONTRACT)
	if sm == null:
		sm = get_node_or_null("/root/SaveManager") # fallback compatibilidad
	if sm != null and sm.has_signal(SAVE_SIGNAL):
		var cb := func(_slot: int, _reason: String): forzar_chequeo("guardado")
		if not sm.is_connected(SAVE_SIGNAL, cb):
			sm.connect(SAVE_SIGNAL, cb)
```

**Efecto:** reduce acoplamiento a una implementación concreta (`/root/SaveManager` + nombre de señal hardcodeado) y favorece un punto único de integración (bus o contrato), alineado con el patrón ya usado para `carga_iniciada`.

---

## Conclusión final

- **Ciclos/dependencias circulares entre autoloads de `scripts/core/`:** no se identificaron (grafo acíclico; `Bootstrap` mitiga el orden con `call_deferred` y guardas).
- **Acoplamiento fuerte a atender:** `SceneManager` ↔ `GameFlowManager` (orquestación y conocimiento de enum/API) con lógica duplicada en `Bootstrap`.
- **Acoplamiento implícito:** `SoftlockGuard` depende directamente de `SaveManager.save_completed` (autoload externo) en lugar de un contrato de bus/interfaz.
- **Acción recomendada:** aplicar Mejora 1 (flujo por eventos/contrato, FSM como único dueño de transiciones) y Mejora 2 (desacoplar disparo de guardado vía bus o contrato), manteniendo las guardas defensivas existentes.

**Estado del análisis:** inspección estática del repositorio al 2026-11-13; sin ejecución runtime. Hallazgos deben validarse ante emisiones/conexiones dinámicas o cambios posteriores en `project.godot`.
